package lime.graphics.vulkan;

import haxe.io.Bytes;
import lime.graphics.vulkan._internal.Vulkan2DShaders;
import lime.math.Vector2;
import haxe.Int64;


/**
	A batched 2D renderer over Lime's managed Vulkan API.

	Self-contained: `create()` brings up instance / surface / device / swapchain
	(the proven managed path), owns a textured-quad pipeline and a CPU-side quad
	batch, and presents through the swapchain every frame. This is the rendering
	core intended to sit under a display-list renderer (OpenFL integration).

	Per frame:

	```haxe
	renderer.beginFrame(0, 0, 0, 1);
	renderer.drawTexture(texture, x, y, width, height, 0, 0, 1, 1, r, g, b, a);
	renderer.endFrame();
	```

	Quads are expanded CPU-side into a persistently mapped vertex buffer and
	drawn in submission order (painter's algorithm); texture switches split the
	batch. Alpha blending (SRC_ALPHA / ONE_MINUS_SRC_ALPHA) and linear filtering
	are on by default.

	`renderToBytes` replays arbitrary quads into an offscreen target and reads
	the pixels back - the verification path for tests and the base for a future
	ShaderFilter pipeline.
**/
@:allow(lime.graphics.vulkan.Vulkan2DTexture)
class Vulkan2DRenderer
{
	private static inline var MAX_QUADS = 8192;
	private static inline var VERTICES_PER_QUAD = 4;
	private static inline var FLOATS_PER_VERTEX = 5; // pos(2) uv(2) + 4ub packed as 1 float slot? no - see STRIDE
	private static inline var BYTES_PER_VERTEX = 32; // pos 2f + uv 2f + rgba 4f(smoke 验证过的布局)
	private static inline var MAX_TEXTURES = 256;

	public var isValid(default, null):Bool;
	public var lastError(default, null):String;
	public var width(default, null):Int;
	public var height(default, null):Int;

	private var context:VulkanRenderContext;
	private var instance:VKInstance;
	private var surface:VKSurface;
	private var physicalDevice:VKPhysicalDevice;
	private var device:VKDevice;
	private var queueFamily:VKQueueFamilyInfo;
	private var swapchain:VKSwapchain;

	private var renderPass:VKRenderPass;
	private var framebuffers:Array<VKFramebuffer> = [];
	private var imageViews:Array<VKImageView> = [];

	private var commandPool:VKCommandPool;
	private var commandBuffer:VKCommandBuffer;
	private var fence:VKFence;
	private var imageAvailable:Array<VKSemaphore> = [];
	private var renderFinished:Array<VKSemaphore> = [];

	private var pipeline:VKPipeline;
	private var offscreenPipeline:VKPipeline;
	private var pipelineLayout:VKPipelineLayout;
	private var setLayout:VKDescriptorSetLayout;
	private var descriptorPool:VKDescriptorPool;
	private var vertexBuffer:VKBuffer;
	private var indexBuffer:VKBuffer;

	private var frameCount:Int = 0;
	private var quads:Array<Vulkan2DQuad> = [];
	private var flushBytes:Bytes;

	private var offscreenRenderPass:VKRenderPass;
	private var offscreenImage:VKImage;
	private var offscreenView:VKImageView;
	private var offscreenFramebuffer:VKFramebuffer;
	private var offscreenStaging:VKBuffer;
	private var offscreenWidth:Int = 0;
	private var offscreenHeight:Int = 0;

	@:access(lime.graphics.VulkanRenderContext)
	@:allow(lime.graphics.VulkanRenderContext)
	private function new()
	{
		isValid = false;
		lastError = "";
	}

	public static function create(context:VulkanRenderContext, applicationName:String = "Lime2D"):Vulkan2DRenderer
	{
		var renderer = new Vulkan2DRenderer();

		#if (!macro && lime_cffi && lime_vulkan)
		if (renderer.initialize(context, applicationName))
		{
			return renderer;
		}
		#end

		return null;
	}

	private function initialize(context:VulkanRenderContext, applicationName:String):Bool
	{
		this.context = context;

		if (!createDevice(applicationName) || !createSwapchainObjects())
		{
			return false;
		}

		if (!createRenderResources())
		{
			return false;
		}

		isValid = true;
		return true;
	}

	private function fail(message:String):Bool
	{
		lastError = message;
		trace("[Vulkan2DRenderer] " + message);
		return false;
	}

	private function createDevice(applicationName:String):Bool
	{
				instance = VK.createInstance(context, applicationName);
		if (instance == null || !instance.isValid())
		{
			return fail("Failed to create Vulkan instance: " + VK.getLastError());
		}

				surface = instance.createSurface();
		if (surface == null || !surface.isValid())
		{
			return fail("Failed to create Vulkan surface");
		}

				physicalDevice = instance.pickPhysicalDevice(surface);
		if (physicalDevice == null || !physicalDevice.hasQueueFamily(true, true))
		{
			return fail("No present-capable graphics queue family was found");
		}

		queueFamily = physicalDevice.getQueueFamily(true, true);
				device = physicalDevice.createDeviceWithFeatures(queueFamily, null, buildFeatureRequests());
		if (device == null || !device.isValid() || device.graphicsQueue == null)
		{
			return fail("Failed to create Vulkan logical device: " + VK.getLastError());
		}

				commandPool = device.createCommandPool(queueFamily);
		commandBuffer = commandPool != null ? commandPool.allocateCommandBuffer() : null;
		fence = device.createFence(true);

		if (commandPool == null || commandBuffer == null || fence == null)
		{
			return fail("Failed to create Vulkan command resources: " + VK.getLastError());
		}

		return true;
	}

	private function buildFeatureRequests():Array<Int>
	{
		// The 2D pipeline itself needs no optional features; requesting none keeps
		// device creation valid on every Vulkan 1.0 implementation.
		return [];
	}

	private function createSwapchainObjects():Bool
	{
		var size = context.getDrawableSize();

		if (size != null && size.x > 0 && size.y > 0)
		{
			width = Std.int(size.x);
			height = Std.int(size.y);
		}

		if (width <= 0 || height <= 0)
		{
			width = 640;
			height = 480;
		}

				swapchain = device.createSwapchain(surface, width, height);
		if (swapchain == null || !swapchain.isValid() || swapchain.images.length == 0)
		{
			return fail("Failed to create Vulkan swapchain: " + VK.getLastError());
		}

		return recreateFrameResources();
	}

	private function recreateFrameResources():Bool
	{
		disposeFrameResources();

		width = swapchain.width;
		height = swapchain.height;

				renderPass = device.createRenderPass(swapchain.format, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT,
			VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR);
		if (renderPass == null)
		{
			return fail("Failed to create Vulkan 2D render pass: " + VK.getLastError());
		}

		for (image in swapchain.images)
		{
			var imageView = image.createView(swapchain.format);
			if (imageView == null)
			{
				return fail("Failed to create Vulkan 2D image view: " + VK.getLastError());
			}

			imageViews.push(imageView);

			var framebuffer = device.createFramebuffer(renderPass, [imageView], width, height);
			if (framebuffer == null)
			{
				return fail("Failed to create Vulkan 2D framebuffer: " + VK.getLastError());
			}

			framebuffers.push(framebuffer);
		}

		var pairCount = swapchain.images.length;

		for (i in 0...pairCount)
		{
			imageAvailable.push(device.createSemaphore());
			renderFinished.push(device.createSemaphore());
		}

		return true;
	}

	private function disposeFrameResources():Void
	{
		for (framebuffer in framebuffers)
		{
			if (framebuffer != null) framebuffer.dispose();
		}
		for (view in imageViews)
		{
			if (view != null) view.dispose();
		}

		framebuffers = [];
		imageViews = [];

		for (semaphore in imageAvailable)
		{
			if (semaphore != null) semaphore.dispose();
		}
		for (semaphore in renderFinished)
		{
			if (semaphore != null) semaphore.dispose();
		}

		imageAvailable = [];
		renderFinished = [];

		if (renderPass != null)
		{
			renderPass.dispose();
			renderPass = null;
		}
	}

	private function createRenderResources():Bool
	{
				// binding 1 = texture (fragment);positions are pre-transformed to NDC
		// CPU-side, so there is no UBO at all
		setLayout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(1, VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK.SHADER_STAGE_FRAGMENT_BIT)
		]);
		descriptorPool = device.createDescriptorPool(MAX_TEXTURES, [
			new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, MAX_TEXTURES)
		]);

		var vertexSize = MAX_QUADS * VERTICES_PER_QUAD * BYTES_PER_VERTEX;
				vertexBuffer = device.createVertexBuffer(Int64.ofInt(vertexSize),
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		flushBytes = Bytes.alloc(vertexSize);

		var indexCount = MAX_QUADS * 6;
		var indices = Bytes.alloc(indexCount * 2);

		for (i in 0...MAX_QUADS)
		{
			var base = i * VERTICES_PER_QUAD;
			var o = i * 12;

			indices.setUInt16((o + 0) * 2, base + 0);
			indices.setUInt16((o + 1) * 2, base + 1);
			indices.setUInt16((o + 2) * 2, base + 2);
			indices.setUInt16((o + 3) * 2, base + 2);
			indices.setUInt16((o + 4) * 2, base + 3);
			indices.setUInt16((o + 5) * 2, base + 0);
		}

		indexBuffer = device.createIndexBuffer(Int64.ofInt(indexCount * 2),
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT, indices);

		if (setLayout == null || descriptorPool == null || vertexBuffer == null || indexBuffer == null)
		{
			return fail("Failed to create Vulkan 2D batch resources: " + VK.getLastError());
		}

				pipelineLayout = device.createPipelineLayout([setLayout]);
		var vertexShader = device.createShaderModule(shaderBytes(Vulkan2DShaders.VERT));
		var fragmentShader = device.createShaderModule(shaderBytes(Vulkan2DShaders.FRAG));

		if (pipelineLayout == null || vertexShader == null || fragmentShader == null)
		{
			return fail("Failed to create Vulkan 2D pipeline inputs: " + VK.getLastError());
		}

		var info = new VKGraphicsPipelineInfo();
		info.blend = true;
		info.cullMode = VK.CULL_MODE_NONE;
		info.vertexBindings.push(new VKVertexBinding(0, BYTES_PER_VERTEX, VK.VERTEX_INPUT_RATE_VERTEX));
		info.vertexAttributes.push(new VKVertexAttribute(0, 0, VK.FORMAT_R32G32_SFLOAT, 0));
		info.vertexAttributes.push(new VKVertexAttribute(1, 0, VK.FORMAT_R32G32_SFLOAT, 8));
		info.vertexAttributes.push(new VKVertexAttribute(2, 0, VK.FORMAT_R8G8B8A8_UNORM, 16));

				pipeline = device.createGraphicsPipeline(renderPass, pipelineLayout, vertexShader, fragmentShader, info);
		vertexShader.dispose();
		fragmentShader.dispose();

		if (pipeline == null)
		{
			return fail("Failed to create Vulkan 2D pipeline: " + VK.getLastError());
		}

		return true;
	}

	/**
		Creates a sampled RGBA texture from 32-bit BGRA pixels (lime Image bytes
		are BGRA premultiplied; the shader multiplies by tint directly, so pass
		already-premultiplied data for correct alpha blending).
	**/
	public function createTexture(width:Int, height:Int, pixels:Bytes):Vulkan2DTexture
	{
		if (!isValid || pixels == null || pixels.length < width * height * 4)
		{
			lastError = "createTexture: invalid pixels";
			return null;
		}

		var texture = new Vulkan2DTexture(this, width, height);

		if (!texture.upload(pixels))
		{
			lastError = texture.lastError;
			texture.dispose();
			return null;
		}

		return texture;
	}

	@:allow(lime.graphics.vulkan.Vulkan2DTexture)
	private function allocateDescriptorSet(view:VKImageView, sampler:VKSampler):VKDescriptorSet
	{
		var set = descriptorPool.allocate(setLayout);

		if (set == null)
		{
			lastError = "Failed to allocate texture descriptor set: " + VK.getLastError();
			return null;
		}

		if (!set.updateImage(1, view, sampler))
		{
			lastError = "Failed to write texture descriptor: " + VK.getLastError();
			return null;
		}

		return set;
	}

	/**
		Queues one textured quad (drawn this frame by `endFrame`).
	**/
	public function drawTexture(texture:Vulkan2DTexture, x:Float, y:Float, width:Float, height:Float, u0:Float = 0, v0:Float = 0,
		u1:Float = 1, v1:Float = 1, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1, rotation:Float = 0):Void
	{
		if (!isValid || quads.length >= MAX_QUADS || texture == null || !texture.isValid)
		{
			return;
		}

		var quad = new Vulkan2DQuad();
		quad.texture = texture;
		quad.x = x;
		quad.y = y;
		quad.width = width;
		quad.height = height;
		quad.u0 = u0;
		quad.v0 = v0;
		quad.u1 = u1;
		quad.v1 = v1;
		quad.r = r;
		quad.g = g;
		quad.b = b;
		quad.a = a;
		quad.rotation = rotation;
		quads.push(quad);
	}

	/**
		Queues one quad with four explicit corner positions (world space; the
		batcher applies the ortho transform). Corner order matches the UV order:
		(x0,y0)=uv(u0,v0) ... (x3,y3)=uv(u0,v1).
	**/
	public function drawQuadCorners(texture:Vulkan2DTexture, x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float,
		x3:Float, y3:Float, u0:Float = 0, v0:Float = 0, u1:Float = 1, v1:Float = 1, r:Float = 1, g:Float = 1, b:Float = 1,
		a:Float = 1):Void
	{
		if (!isValid || quads.length >= MAX_QUADS || texture == null || !texture.isValid)
		{
			return;
		}

		var quad = new Vulkan2DQuad();
		quad.texture = texture;
		quad.corners = [x0, y0, x1, y1, x2, y2, x3, y3];
		quad.u0 = u0;
		quad.v0 = v0;
		quad.u1 = u1;
		quad.v1 = v1;
		quad.r = r;
		quad.g = g;
		quad.b = b;
		quad.a = a;
		quads.push(quad);
	}

	/**
		Requests a swapchain recreate (call after the window size changed).
	**/
	public function resize(width:Int, height:Int):Bool
	{
		if (!isValid)
		{
			return false;
		}

		return recreateSwapchain();
	}

	/**
		Clear color for the next `endFrame`.
	**/
	public var clearColorR:Float = 0;
	public var clearColorG:Float = 0;
	public var clearColorB:Float = 0;
	public var clearColorA:Float = 1;

	public function setClearColor(r:Float, g:Float, b:Float, a:Float = 1):Void
	{
		clearColorR = r;
		clearColorG = g;
		clearColorB = b;
		clearColorA = a;
	}

	/**
		Flushes the queued quads and presents. Returns false when the frame could
		not be drawn (swapchain out of date triggers an automatic recreate and the
		caller simply draws the next frame).
	**/
	public function endFrame():Bool
	{
		if (!isValid)
		{
			return false;
		}

		if (!fence.waitForever())
		{
			return fail("Failed to wait for Vulkan 2D frame fence");
		}

		var slot = frameCount % imageAvailable.length;
		var acquireSemaphore = imageAvailable[slot];
		var presentSemaphore = renderFinished[slot];

		var acquired = swapchain.acquireNextImage(acquireSemaphore);

		if (acquired.result == VK.ERROR_OUT_OF_DATE_KHR)
		{
			return recreateSwapchain();
		}

		if (!acquired.isSuccess())
		{
			return fail("Failed to acquire Vulkan 2D swapchain image: " + VK.getLastError());
		}

		var framebuffer = framebuffers[acquired.imageIndex];
		frameCount++;

		if (!commandBuffer.reset() || !commandBuffer.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT))
		{
			return fail("Failed to begin Vulkan 2D command buffer");
		}

		if (!commandBuffer.beginRenderPass(renderPass, framebuffer, width, height, clearColorR, clearColorG, clearColorB, clearColorA)
			|| !commandBuffer.setViewport(0, 0, width, height)
			|| !commandBuffer.setScissor(0, 0, width, height))
		{
			return fail("Failed to begin Vulkan 2D render pass");
		}

		if (quads.length > 0)
		{
			if (!recordQuads(quads, width, height, false))
			{
				return false;
			}
		}

		if (!commandBuffer.endRenderPass() || !commandBuffer.end())
		{
			return fail("Failed to end Vulkan 2D render pass");
		}

		if (!fence.reset() || !device.graphicsQueue.submitSynced(commandBuffer, acquireSemaphore, presentSemaphore, fence)
			|| !fence.waitForever())
		{
			return fail("Failed to submit Vulkan 2D frame: " + VK.getLastError());
		}

		var presentResult = device.graphicsQueue.present(swapchain, acquired.imageIndex, presentSemaphore);

		if (presentResult == VK.ERROR_OUT_OF_DATE_KHR)
		{
			return recreateSwapchain();
		}

		if (presentResult != VK.SUCCESS && presentResult != VK.SUBOPTIMAL_KHR)
		{
			return fail("Failed to present Vulkan 2D swapchain image: " + VK.getLastError());
		}

		quads = [];
		return true;
	}

	private function recreateSwapchain():Bool
	{
		if (!device.waitIdle())
		{
			return fail("Failed to idle Vulkan 2D device before swapchain recreation");
		}

		var oldSwapchain = swapchain;
		swapchain = oldSwapchain.recreate(0, 0);

		if (swapchain == null || !swapchain.isValid())
		{
			oldSwapchain.dispose();
			return fail("Failed to recreate Vulkan 2D swapchain: " + VK.getLastError());
		}

		oldSwapchain.dispose();

		if (!recreateFrameResources())
		{
			return false;
		}

		quads = [];
		return true;
	}

	/**
		Expands the quad list into the mapped vertex buffer and records one
		drawIndexed per texture batch.
	**/
	private function recordQuads(quadList:Array<Vulkan2DQuad>, targetWidth:Int, targetHeight:Int, offscreen:Bool):Bool
	{
		var quadCount = quadList.length;

		if (quadCount > MAX_QUADS)
		{
			quadCount = MAX_QUADS;
		}

		var o = 0;
		var sx = 2.0 / targetWidth;
		var sy = 2.0 / targetHeight;

		for (i in 0...quadCount)
		{
			var quad = quadList[i];
			var hw = quad.width / 2;
			var hh = quad.height / 2;
			var cos = quad.rotation == 0 ? 1 : Math.cos(quad.rotation);
			var sin = quad.rotation == 0 ? 0 : Math.sin(quad.rotation);
			var cx = quad.x + hw;
			var cy = quad.y + hh;

			var cr = clamp01(quad.r);
			var cg = clamp01(quad.g);
			var cb = clamp01(quad.b);
			var ca = clamp01(quad.a);

			// 顶点交错:[pos(2f) uv(2f) color(4ub)] × 4,stride 20 必须逐顶点写
			for (c in 0...4)
			{
				var lx = (c == 0 || c == 3) ? -hw : hw;
				var ly = (c < 2) ? -hh : hh;

				var wx = cx + lx * cos - ly * sin;
				var wy = cy + lx * sin + ly * cos;

				// CPU 侧正交变换:像素空间 → NDC(y 向下与像素一致)
				flushBytes.setFloat(o, wx * sx - 1);
				flushBytes.setFloat(o + 4, wy * sy - 1);
				o += 8;

				// uv: (u0,v0) (u1,v0) (u1,v1) (u0,v1)
				var u = (c == 0 || c == 3) ? quad.u0 : quad.u1;
				var v = (c < 2) ? quad.v0 : quad.v1;
				flushBytes.setFloat(o, u);
				flushBytes.setFloat(o + 4, v);
				o += 8;

				flushBytes.setFloat(o, cr);
				flushBytes.setFloat(o + 4, cg);
				flushBytes.setFloat(o + 8, cb);
				flushBytes.setFloat(o + 12, ca);
				o += 16;
			}
		}

		var byteLength = quadCount * VERTICES_PER_QUAD * BYTES_PER_VERTEX;

		if (!vertexBuffer.upload(flushBytes, null, 0, byteLength))
		{
			return fail("Failed to upload Vulkan 2D vertex buffer");
		}

		var check = Bytes.alloc(80);
		vertexBuffer.download(check, null, 0, 80);
		trace("[2d] v0 pos=" + check.getFloat(0) + "," + check.getFloat(4) + " v1 pos=" + check.getFloat(32) + ","
			+ check.getFloat(36) + " uv0=" + check.getFloat(8) + "," + check.getFloat(12));

		var activePipeline = offscreen ? offscreenPipeline : pipeline;

		if (!commandBuffer.bindPipeline(activePipeline)
			|| !commandBuffer.bindVertexBuffer(vertexBuffer)
			|| !commandBuffer.bindIndexBuffer(indexBuffer))
		{
			return fail("Failed to bind Vulkan 2D pipeline");
		}

		// batch by texture
		var batchStart = 0;

		for (i in 1...quadCount + 1)
		{
			var sameTexture = i < quadCount && quadList[i].texture == quadList[batchStart].texture;

			if (sameTexture)
			{
				continue;
			}

			var batchQuads = i - batchStart;

			if (!commandBuffer.bindDescriptorSet(pipelineLayout, quadList[batchStart].texture.descriptorSet)
				|| !commandBuffer.drawIndexed(batchQuads * 6, 1, batchStart * 6))
			{
				return fail("Failed to record Vulkan 2D draw: " + VK.getLastError());
			}

			batchStart = i;
		}

		return true;
	}


	private static function shaderBytes(data:Array<Int>):Bytes
	{
		var bytes = Bytes.alloc(data.length);

		for (i in 0...data.length)
		{
			bytes.set(i, data[i]);
		}

		return bytes;
	}

	private function failBytes(message:String):Bytes
	{
		fail(message);
		return null;
	}

	private function clamp01(v:Float):Float
	{
		return v < 0 ? 0 : (v > 1 ? 1 : v);
	}

	/**
		Replays `quadList` into an offscreen RGBA target of the given size and
		returns the raw BGRA bytes (verification path; also the base for a future
		ShaderFilter pipeline). Blocking by design.
	**/
	public function renderToBytes(targetWidth:Int, targetHeight:Int, clearR:Float, clearG:Float, clearB:Float, clearA:Float,
		quadList:Array<Vulkan2DQuad>):Bytes
	{
		if (!isValid || targetWidth <= 0 || targetHeight <= 0)
		{
			return null;
		}

		if (targetWidth != offscreenWidth || targetHeight != offscreenHeight)
		{
			disposeOffscreen();
			offscreenWidth = targetWidth;
			offscreenHeight = targetHeight;

			offscreenRenderPass = device.createRenderPass(VK.FORMAT_R8G8B8A8_UNORM, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT,
				VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED,
				VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
			offscreenImage = device.createImage(targetWidth, targetHeight, VK.FORMAT_R8G8B8A8_UNORM,
				VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_TRANSFER_SRC_BIT);
			offscreenStaging = device.createBufferWithMemory(Int64.ofInt(targetWidth * targetHeight * 4), VK.BUFFER_USAGE_TRANSFER_DST_BIT,
				VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);

			if (offscreenRenderPass == null || offscreenImage == null || offscreenStaging == null
				|| offscreenImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
			{
				fail("Failed to create Vulkan 2D offscreen target: " + VK.getLastError());
				return null;
			}

			offscreenView = offscreenImage.createView(VK.FORMAT_R8G8B8A8_UNORM);
			offscreenFramebuffer = offscreenView != null
				? device.createFramebuffer(offscreenRenderPass, [offscreenView], targetWidth, targetHeight) : null;

			if (offscreenView == null || offscreenFramebuffer == null)
			{
				fail("Failed to create Vulkan 2D offscreen framebuffer: " + VK.getLastError());
				return null;
			}

			// 管线与 render pass 必须兼容:离屏格式 R8G8B8A8 与 swapchain 格式不同,
			// 因此离屏管线单独针对 offscreenRenderPass 创建(着色器/布局共享)
			var offInfo = new VKGraphicsPipelineInfo();
			offInfo.blend = true;
			offInfo.cullMode = VK.CULL_MODE_NONE;
			offInfo.vertexBindings.push(new VKVertexBinding(0, BYTES_PER_VERTEX, VK.VERTEX_INPUT_RATE_VERTEX));
			offInfo.vertexAttributes.push(new VKVertexAttribute(0, 0, VK.FORMAT_R32G32_SFLOAT, 0));
			offInfo.vertexAttributes.push(new VKVertexAttribute(1, 0, VK.FORMAT_R32G32_SFLOAT, 8));
			offInfo.vertexAttributes.push(new VKVertexAttribute(2, 0, VK.FORMAT_R32G32B32A32_SFLOAT, 16));

			offscreenPipeline = device.createGraphicsPipeline(offscreenRenderPass, pipelineLayout,
				device.createShaderModule(shaderBytes(Vulkan2DShaders.VERT)),
				device.createShaderModule(shaderBytes(Vulkan2DShaders.FRAG)), offInfo);

			if (offscreenPipeline == null)
			{
				fail("Failed to create Vulkan 2D offscreen pipeline: " + VK.getLastError());
				return null;
			}
		}

		if (!fence.waitForever() || !commandBuffer.reset() || !commandBuffer.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT))
		{
			return failBytes("Failed to begin Vulkan 2D offscreen command buffer");
		}

		if (!commandBuffer.beginRenderPass(offscreenRenderPass, offscreenFramebuffer, targetWidth, targetHeight, clearR, clearG, clearB, clearA)
			|| !commandBuffer.setViewport(0, 0, targetWidth, targetHeight)
			|| !commandBuffer.setScissor(0, 0, targetWidth, targetHeight))
		{
			return failBytes("Failed to begin Vulkan 2D offscreen render pass");
		}

		if (quadList != null && quadList.length > 0 && !recordQuads(quadList, targetWidth, targetHeight, true))
		{
			return null;
		}

		if (!commandBuffer.endRenderPass()
			|| !commandBuffer.copyImageToBufferRegion(offscreenImage, offscreenStaging, targetWidth, targetHeight)
			|| !commandBuffer.end())
		{
			return failBytes("Failed to record Vulkan 2D offscreen copy");
		}

		if (!fence.reset() || !device.graphicsQueue.submit(commandBuffer, fence) || !fence.waitForever())
		{
			return failBytes("Failed to submit Vulkan 2D offscreen: " + VK.getLastError());
		}

		var pixels = Bytes.alloc(targetWidth * targetHeight * 4);

		if (!offscreenStaging.download(pixels))
		{
			return failBytes("Failed to download Vulkan 2D offscreen pixels");
		}

		return pixels;
	}

	private function disposeOffscreen():Void
	{
		if (offscreenFramebuffer != null) offscreenFramebuffer.dispose();
		if (offscreenView != null) offscreenView.dispose();
		if (offscreenStaging != null) offscreenStaging.dispose(true);

		if (offscreenImage != null)
		{
			offscreenImage.dispose(true);
		}

		if (offscreenPipeline != null)
		{
			offscreenPipeline.dispose();
			offscreenPipeline = null;
		}

		if (offscreenRenderPass != null) offscreenRenderPass.dispose();

		offscreenFramebuffer = null;
		offscreenView = null;
		offscreenStaging = null;
		offscreenImage = null;
		offscreenRenderPass = null;
	}

	public function dispose():Void
	{
		if (!isValid)
		{
			return;
		}

		device.waitIdle();
		disposeOffscreen();
		disposeFrameResources();

		if (pipeline != null) pipeline.dispose();
		if (pipelineLayout != null) pipelineLayout.dispose();
		if (setLayout != null) setLayout.dispose();
		if (descriptorPool != null) descriptorPool.dispose();
		if (vertexBuffer != null) vertexBuffer.dispose(true);
		if (indexBuffer != null) indexBuffer.dispose(true);

		if (commandBuffer != null) commandBuffer.dispose();
		if (commandPool != null) commandPool.dispose();
		if (fence != null) fence.dispose();
		if (swapchain != null) swapchain.dispose();
		if (device != null) device.dispose();
		if (surface != null) surface.dispose();
		if (instance != null) instance.dispose();

		commandBuffer = null;
		commandPool = null;
		fence = null;
		swapchain = null;
		device = null;
		surface = null;
		instance = null;
		pipeline = null;
		pipelineLayout = null;
		setLayout = null;
		descriptorPool = null;
		vertexBuffer = null;
		indexBuffer = null;

		isValid = false;
	}
}
