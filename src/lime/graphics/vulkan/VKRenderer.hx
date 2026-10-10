package lime.graphics.vulkan;

import lime.graphics.Image;
#if (!lime_doc_gen || lime_vulkan)
import lime.graphics.vulkan.VK;
import lime.graphics.vulkan.VKCommandBuffer;
import lime.graphics.vulkan.VKCommandPool;
import lime.graphics.vulkan.VKDevice;
import lime.graphics.vulkan.VKFramebuffer;
import lime.graphics.vulkan.VKImage;
import lime.graphics.vulkan.VKImageView;
import lime.graphics.vulkan.VKPhysicalDevice;
import lime.graphics.vulkan.VKQueue;
import lime.graphics.vulkan.VKQueueFamilyInfo;
import lime.graphics.vulkan.VKRenderPass;
import lime.graphics.vulkan.VKSemaphore;
import lime.graphics.vulkan.VKSurface;
import lime.graphics.vulkan.VKSwapchain;
import lime.math.Vector2;
#end
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
#end
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFIPointer;
#end
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	Lime's managed Vulkan validation renderer.

	This is useful for smoke tests and samples, but application renderers should
	build on `VK` handles such as `VKInstance`, `VKDevice`, and `VKQueue`.
**/
class VKRenderer
{
	public var commandPool(get, never):#if (!lime_doc_gen || lime_vulkan) VKCommandPool #else Dynamic #end;
	public var device(get, never):#if (!lime_doc_gen || lime_vulkan) VKDevice #else Dynamic #end;
	public var info(get, never):String;
	public var isValid(get, never):Bool;
	public var lastError(get, never):String;
	public var queue(get, never):#if (!lime_doc_gen || lime_vulkan) VKQueue #else Dynamic #end;
	public var renderPass(get, never):#if (!lime_doc_gen || lime_vulkan) VKRenderPass #else Dynamic #end;
	public var swapchain(get, never):#if (!lime_doc_gen || lime_vulkan) VKSwapchain #else Dynamic #end;

	/**
		Whether the Haxe-managed device (`initialize()`) is live. When this is `true` the
		renderer can record real draw commands through `beginDraw()` / `endDraw()`; when it is
		`false` only the built-in clear + present + overlay path is available.
	**/
	public var hasDevice(get, never):Bool;

	private var __handle:#if (!lime_doc_gen || lime_cffi) CFFIPointer #else Dynamic #end;
	private var __info:String;

	#if (!lime_doc_gen || lime_vulkan)
	private var __commandBuffer:VKCommandBuffer;
	private var __frameFence:VKFence;
	private var __fenceArmed:Bool;
	private var __poolDirty:Bool;

	/**
		Frame start: waits for the previous frame's command buffer (via the frame fence --
		NOT a queue-wide wait, which would also block on the previous PRESENT and halve the
		frame rate of unlocked-framerate games), then resets the command pool.
	**/
	public function prepareFrame():Void
	{
		if (__device == null) return;

		// UNSIGNALED at creation: this fence is submitted for the FIRST time this frame
		// and must not be in the SIGNALED state (VUID-vkQueueSubmit-fence-00063). Every
		// subsequent frame it is waited + reset in the __poolDirty branch below.
		if (__frameFence == null) __frameFence = __device.createFence(false);

		if (__poolDirty)
		{
			if (__fenceArmed)
			{
				__frameFence.waitForever();
				__frameFence.reset();
			}
			else
			{
				// upload-only previous frame: no fence was armed, drain the queue instead
				try { __queue.waitIdle(); } catch (e:Dynamic) {}
			}

			if (__commandPool != null) __commandPool.reset();
			__poolDirty = false;
			__fenceArmed = false;
		}
	}

	public function markCommandPoolDirty():Void
	{
		__poolDirty = true;
	}
	private var __commandPool:VKCommandPool;
	private var __context:lime.graphics.VulkanRenderContext;
	private var __device:VKDevice;
	private var __framebuffers:Array<VKFramebuffer>;
	private var __beginDrawFailures:Int;
	private var __imageAvailable:VKSemaphore;
	private var __imageIndex:Int;
	private var __imageViews:Array<VKImageView>;
	private var __instance:lime.graphics.vulkan.VKInstance;
	private var __physicalDevice:VKPhysicalDevice;
	private var __queue:VKQueue;
	private var __queueFamily:VKQueueFamilyInfo;
	private var __renderFinished:VKSemaphore;
	private var __renderFinishedByImage:Array<VKSemaphore>;
	private var __acquireSemaphores:Array<VKSemaphore>;
	private var __acquireIndex:Int;
	private var __renderPass:VKRenderPass;

	// Second pass over the swapchain image with loadOp=LOAD: VulkanRenderer suspends the
	// main pass mid-frame to record offscreen ShaderFilter compositing passes, then
	// reopens the swapchain pass WITHOUT clearing what was already drawn. Compatibility
	// with pipelines created against __renderPass only requires the same format + samples;
	// loadOp/layouts are free to differ.
	private var __loadRenderPass:VKRenderPass;

	// True while the main swapchain pass is open on the command buffer. endDraw() only
	// ends the pass when this is set -- suspend/resume keep it in sync.
	public var passOpen(default, null):Bool;

	private var __surface:VKSurface;
	private var __swapchain:VKSwapchain;
	private var __height:Int;
	private var __width:Int;
	#end

	@:allow(lime.graphics.VulkanRenderContext)
	private function new(handle:#if (!lime_doc_gen || lime_cffi) CFFIPointer #else Dynamic #end)
	{
		__handle = handle;
		__info = "";

		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			refreshInfo();
		}
		#end
	}

	/**
		Creates a renderer without the built-in C++ smoke path, then brings up a
		Haxe-managed Vulkan device / swapchain so real draw commands can be recorded.

		This is the entry point applications should use when they intend to draw with Vulkan
		instead of only clearing and presenting. It touches no new CFFI entry points: every
		object comes from the existing `lime.graphics.vulkan.*` classes.
	**/
	public static function create(context:lime.graphics.VulkanRenderContext, applicationName:String = "Lime"):VKRenderer
	{
		var renderer = new VKRenderer(null);

		#if (!macro && lime_vulkan)
		renderer.__context = context;
		renderer.initialize(applicationName);
		#end

		return renderer;
	}

	#if (!lime_doc_gen || lime_vulkan)
	/**
		Brings up instance, surface, physical device, logical device, swapchain, render pass
		and framebuffers. Safe to call repeatedly; returns `true` once `hasDevice` is true.
	**/
	public function initialize(applicationName:String = "Lime"):Bool
	{
		if (__device != null) return true;
		if (__context == null)
		{
			__info = "VKRenderer.initialize: no VulkanRenderContext";
			return false;
		}

		try
		{
			__instance = VK.createInstance(__context, applicationName);
			if (__instance == null) { __info = "VKRenderer.initialize: createInstance failed"; return false; }

			__surface = __instance.createSurface(__context);
			if (__surface == null) { __info = "VKRenderer.initialize: createSurface failed"; return false; }

			__physicalDevice = __instance.pickPhysicalDevice(__surface, true);
			if (__physicalDevice == null) { __info = "VKRenderer.initialize: no usable physical device"; return false; }

			__queueFamily = __physicalDevice.getQueueFamily(true, true, false);
			if (__queueFamily == null) { __info = "VKRenderer.initialize: no present-capable queue family"; return false; }

			__device = __physicalDevice.createDevice(__queueFamily, null);
			if (__device == null) { __info = "VKRenderer.initialize: createDevice failed"; return false; }

			__queue = __device.graphicsQueue;
			__commandPool = __device.createCommandPool(__queueFamily);
			__commandBuffer = __commandPool.allocateCommandBuffer();
			__imageAvailable = __device.createSemaphore();
			__renderFinished = __device.createSemaphore();
			__framebuffers = [];
			__imageViews = [];
			__imageIndex = -1;
			__beginDrawFailures = 0;

			// UNSIGNALED, not signaled: this fence is submitted by the FIRST endDraw()
			// before any prepareFrame() wait+reset cycle has ever touched it. A signaled
			// fence here trips VUID-vkQueueSubmit-fence-00063 ("submitted in SIGNALED
			// state") exactly once, on frame one. Every later frame it is reset in
			// prepareFrame() before the next submission.
			if (__frameFence == null) __frameFence = __device.createFence(false);
			if (__renderFinishedByImage == null)
			{
				__renderFinishedByImage = [];
				for (i in 0...8) __renderFinishedByImage.push(__device.createSemaphore());
			}

			return createSwapchainResources();
		}
		catch (e:Dynamic)
		{
			__info = "VKRenderer.initialize: " + Std.string(e);
			return false;
		}
	}

	/**
		Reports a null sub-object once (or every 300th time) so a broken frame loop is visible
		in the log instead of surfacing only as an opaque `Null Object Reference`.
	**/
	private function __checkTrace(what:String):Void
	{
		__beginDrawFailures++;

		if (__beginDrawFailures <= 3 || __beginDrawFailures % 300 == 0)
		{
			trace('[VKRenderer] beginDraw: $what is null (x$__beginDrawFailures)');
		}
	}

	private function createSwapchainResources():Bool
	{
		var size = __context.getDrawableSize();
		var width = (size != null && size.x > 0) ? Math.round(size.x) : (__width > 0 ? __width : 1);
		var height = (size != null && size.y > 0) ? Math.round(size.y) : (__height > 0 ? __height : 1);

		__width = width;
		__height = height;

		// Two swapchains must never be alive on the same surface, so an existing one is
		// recreated (which retires the old handle) rather than re-created from scratch.
		// FIFO would lock an unlocked-framerate game to the display refresh; MAILBOX gives
		// tear-free unlocked presentation on desktop GPUs. Fall back to FIFO if unavailable.
		var requestedMode = VK.PRESENT_MODE_MAILBOX_KHR;

		if (Sys.getEnv ("LIME_VULKAN_FORCE_FIFO") != null) requestedMode = VK.PRESENT_MODE_FIFO_KHR;

		if (__swapchain == null)
		{
			__swapchain = __device.createSwapchain(__surface, width, height, requestedMode);

			if (__swapchain == null && requestedMode != VK.PRESENT_MODE_FIFO_KHR)
			{
				requestedMode = VK.PRESENT_MODE_FIFO_KHR;
				__swapchain = __device.createSwapchain(__surface, width, height, requestedMode);
			}
		}
		else
		{
			__swapchain = __swapchain.recreate(width, height);
		}

		if (__swapchain == null) { __info = "VKRenderer: createSwapchain failed (" + VK.getLastError() + ")"; return false; }

		trace("[VKRenderer] present mode: " + (requestedMode == VK.PRESENT_MODE_MAILBOX_KHR ? "MAILBOX (unlocked)"
			: (requestedMode == VK.PRESENT_MODE_IMMEDIATE_KHR ? "IMMEDIATE (unlocked, tearing)" : "FIFO (vsync)")));

		if (__renderPass != null)
		{
			__renderPass.dispose();
			__renderPass = null;
		}

		// The color attachment has to end in PRESENT_SRC_KHR: the default is
		// COLOR_ATTACHMENT_OPTIMAL, which leaves the image in a layout the presentation
		// engine cannot read (the symptom is a solid white window).
		__renderPass = __device.createRenderPass(__swapchain.format, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT,
			VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR);
		if (__renderPass == null) { __info = "VKRenderer: createRenderPass failed (" + VK.getLastError() + ")"; return false; }

		if (__loadRenderPass != null) __loadRenderPass.dispose();
		__loadRenderPass = __device.createRenderPass(__swapchain.format, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT,
			VK.ATTACHMENT_LOAD_OP_LOAD, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR);
		if (__loadRenderPass == null) { __info = "VKRenderer: createRenderPass(load) failed (" + VK.getLastError() + ")"; return false; }

		for (view in __imageViews)
		{
			if (view != null) view.dispose();
		}
		for (framebuffer in __framebuffers)
		{
			if (framebuffer != null) framebuffer.dispose();
		}
		__imageViews = [];
		__framebuffers = [];

		var images = __swapchain.refreshImages();

		if (images == null || images.length == 0)
		{
			__info = "VKRenderer: swapchain produced no images (" + VK.getLastError() + ")";
			trace("[VKRenderer] " + __info);
			return false;
		}

		for (i in 0...images.length)
		{
			var image = images[i];

			if (image == null)
			{
				__info = "VKRenderer: swapchain image " + i + " is null";
				trace("[VKRenderer] " + __info);
				return false;
			}

			var view = image.createView(__swapchain.format);

			if (view == null)
			{
				__info = "VKRenderer: createView failed for image " + i + " (" + VK.getLastError() + ")";
				trace("[VKRenderer] " + __info);
				return false;
			}

			__imageViews.push(view);

			var framebuffer = __device.createFramebuffer(__renderPass, [view], width, height);

			if (framebuffer == null)
			{
				__info = "VKRenderer: createFramebuffer failed for image " + i + " (" + VK.getLastError() + ")";
				trace("[VKRenderer] " + __info);
				return false;
			}

			__framebuffers.push(framebuffer);
		}

		trace('[VKRenderer] swapchain ${width}x${height} images=${__framebuffers.length} format=0x' + StringTools.hex(__swapchain.format, 8));

		return true;
	}

	/**
		Rebuilds the swapchain and its framebuffers after a window resize.
	**/
	public function resizeDevice():Bool
	{
		if (__device == null) return false;

		// the previous frame's command buffer may still be executing and referencing the
		// render pass / framebuffers / swapchain about to be destroyed -- drain first
		try
		{
			__device.waitIdle();
		}
		catch (e:Dynamic) {}

		try
		{
			return createSwapchainResources();
		}
		catch (e:Dynamic)
		{
			__info = "VKRenderer.resizeDevice: " + Std.string(e);
			return false;
		}
	}

	/**
		Acquires the next swapchain image, begins a command buffer and begins the render pass.
		Returns a command buffer ready for `bindPipeline` / `draw`, or `null` when the frame
		cannot be started (swapchain out of date and not recoverable this frame).
	**/
	public function beginDraw(red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 1):VKCommandBuffer
	{
		if (__device == null) { __checkTrace("device"); return null; }
		if (__swapchain == null) { __checkTrace("swapchain"); return null; }
		if (__renderPass == null) { __checkTrace("renderPass"); return null; }
		if (__commandPool == null) { __checkTrace("commandPool"); return null; }
		if (__commandBuffer == null) { __checkTrace("commandBuffer"); return null; }

		// the frame fence was waited/reset in prepareFrame() -- the command pool is clean
		if (__framebuffers == null || __framebuffers.length == 0) { __checkTrace("framebuffers"); return null; }

		try
		{
			// acquire with a rotating semaphore; the render-finished semaphore is per image,
			// because a binary semaphore used for acquire may still be held by a presentation
			// of the SAME image (VUID-vkAcquireNextImageKHR-semaphore-01779)
			if (__acquireSemaphores == null)
			{
				__acquireSemaphores = [];
				for (i in 0...8) __acquireSemaphores.push(__device.createSemaphore());
			}

			__acquireIndex = (__acquireIndex + 1) % 8;
			var acquired = __swapchain.acquireNextImage(__acquireSemaphores[__acquireIndex], null);

			if (acquired == null || acquired.result < 0 || acquired.result > 1)
			{
				__beginDrawFailures++;
				if (__beginDrawFailures <= 3 || __beginDrawFailures % 300 == 0)
				{
					trace('[VKRenderer] acquire returned ' + (acquired == null ? "null" : Std.string(acquired.result))
						+ ' (x$__beginDrawFailures, images=${__framebuffers.length}, ${__width}x${__height})');
				}
				return null;
			}

			__beginDrawFailures = 0;
			__imageIndex = acquired.imageIndex;

			if (__imageIndex < 0 || __imageIndex >= __framebuffers.length)
			{
				trace('[VKRenderer] acquire returned out-of-range image index $__imageIndex of ${__framebuffers.length}');
				return null;
			}

			// the command pool was reset in prepareFrame() after the frame fence confirmed
			// the previous frame's work has completed

			if (!__commandBuffer.begin())
			{
				trace("[VKRenderer] commandBuffer.begin() failed (" + VK.getLastError() + ")");
				return null;
			}

			if (!__commandBuffer.beginRenderPass(__renderPass, __framebuffers[__imageIndex], __width, __height, red, green, blue, alpha))
			{
				trace("[VKRenderer] beginRenderPass failed (" + VK.getLastError() + ")");
				return null;
			}

			passOpen = true;

			// Graphics pipelines created through `VKGraphicsPipelineInfo` declare the viewport
			// and scissor as dynamic state, and `beginRenderPass()` does not set them -- with
			// dynamic state left unset the geometry is clipped away entirely (an invisible
			// draw with a fully working pipeline).
			if (!__commandBuffer.setViewport(0, 0, __width, __height) || !__commandBuffer.setScissor(0, 0, __width, __height))
			{
				trace("[VKRenderer] setViewport/setScissor failed (" + VK.getLastError() + ")");
				return null;
			}

			return __commandBuffer;
		}
		catch (e:Dynamic)
		{
			__info = "VKRenderer.beginDraw: " + Std.string(e);
			trace("[VKRenderer] beginDraw threw: " + __info);
			return null;
		}
	}

	/**
		Ends the open main render pass so offscreen passes can be recorded into the same
		command buffer (Vulkan forbids nested render passes). The caller reopens the pass
		with resumePass() once the offscreen work is recorded; endDraw() skips its own
		endRenderPass while the pass is suspended. Returns false when nothing was open.
	**/
	public function suspendPass():Bool
	{
		if (!passOpen || __commandBuffer == null) return false;

		if (!__commandBuffer.endRenderPass()) return false;
		passOpen = false;
		return true;
	}

	/**
		Reopens the swapchain render pass with loadOp=LOAD after suspendPass() -- everything
		drawn into it before the suspension stays on the swapchain image (initial and final
		layout are PRESENT_SRC, the state the image sits in between the two passes).
	**/
	public function resumePass():Bool
	{
		if (passOpen || __commandBuffer == null || __loadRenderPass == null) return false;
		if (__imageIndex < 0 || __imageIndex >= __framebuffers.length) return false;

		// clear values are ignored by the LOAD pass
		if (!__commandBuffer.beginRenderPass(__loadRenderPass, __framebuffers[__imageIndex], __width, __height, 0, 0, 0, 0))
		{
			trace("[VKRenderer] resumePass: beginRenderPass(load) failed (" + VK.getLastError() + ")");
			return false;
		}

		if (!__commandBuffer.setViewport(0, 0, __width, __height) || !__commandBuffer.setScissor(0, 0, __width, __height))
		{
			trace("[VKRenderer] resumePass: setViewport/setScissor failed (" + VK.getLastError() + ")");
			return false;
		}

		passOpen = true;
		return true;
	}

	/**
		Ends the render pass and command buffer, submits it and presents the swapchain image.
	**/
	public function endDraw(commandBuffer:VKCommandBuffer):Bool
	{
		if (__device == null || commandBuffer == null || __imageIndex < 0) return false;

		try
		{
			// the pass may be suspended (offscreen ShaderFilter passes were recorded into
			// this command buffer and resumePass() reopened the main pass) -- only end it
			// when it is actually open
			if (passOpen)
			{
				commandBuffer.endRenderPass();
				passOpen = false;
			}
			commandBuffer.end();

			var signalSemaphore = __renderFinishedByImage != null ? __renderFinishedByImage[__imageIndex] : __renderFinished;
			var waitSemaphore = __acquireSemaphores != null ? __acquireSemaphores[__acquireIndex] : __imageAvailable;
			var submitted = __queue.submitSynced(commandBuffer, waitSemaphore, signalSemaphore, __frameFence);
			__poolDirty = true;

			if (submitted)
			{
				// Only a fence whose submission actually reached the queue may be waited on
				// in prepareFrame(); an unsignaled fence that was never submitted would
				// waitForever() there and deadlock the renderer.
				__fenceArmed = true;

				var presentSemaphore = __renderFinishedByImage != null ? __renderFinishedByImage[__imageIndex] : __renderFinished;
				__queue.present(__swapchain, __imageIndex, presentSemaphore);
			}
			else
			{
				// Submit failed: the fence stays unsignaled (never queued), the render-pass
				// semaphore never fires, so presenting would block forever -- skip it.
				// Next frame prepareFrame() takes the __queue.waitIdle() branch instead.
				trace("[VKRenderer] frame submit failed (" + VK.getLastError() + "); skipping present");
			}

			__imageIndex = -1;
			return true;
		}
		catch (e:Dynamic)
		{
			__info = "VKRenderer.endDraw: " + Std.string(e);
			return false;
		}
	}

	private function disposeDevice():Void
	{
		if (__device == null) return;

		try
		{
			__device.waitIdle();
		}
		catch (e:Dynamic) {}

		for (framebuffer in __framebuffers)
		{
			if (framebuffer != null) framebuffer.dispose();
		}
		for (view in __imageViews)
		{
			if (view != null) view.dispose();
		}
		if (__renderPass != null) __renderPass.dispose();
		if (__swapchain != null) __swapchain.dispose();
		if (__commandPool != null) __commandPool.dispose();
		if (__frameFence != null) { __frameFence.dispose(); __frameFence = null; }
		__fenceArmed = false;
		__poolDirty = false;
		if (__renderFinishedByImage != null)
			{
				for (s in __renderFinishedByImage) if (s != null) s.dispose();
				__renderFinishedByImage = null;
			}
		if (__acquireSemaphores != null)
			{
				for (s in __acquireSemaphores) if (s != null) s.dispose();
				__acquireSemaphores = null;
			}
		if (__renderFinished != null) __renderFinished.dispose();
		if (__imageAvailable != null) __imageAvailable.dispose();
		if (__device != null) __device.dispose();
		if (__instance != null) __instance.dispose();

		__framebuffers = [];
		__imageViews = [];
		__renderPass = null;
		__swapchain = null;
		__commandPool = null;
		__commandBuffer = null;
		__renderFinished = null;
		__imageAvailable = null;
		__device = null;
		__queue = null;
		__physicalDevice = null;
		__queueFamily = null;
		__surface = null;
		__instance = null;
	}
	#end

	public function dispose():Void
	{
		#if (!macro && lime_vulkan)
		disposeDevice();
		#end

		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			NativeCFFI.lime_vulkan_renderer_destroy(__handle);
			__handle = null;
		}
		#end
	}

	public function render(red:Float, green:Float, blue:Float, alpha:Float = 1.0):Bool
	{
		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			return NativeCFFI.lime_vulkan_renderer_render(__handle, red, green, blue, alpha);
		}
		#end

		return false;
	}

	public function refreshInfo():String
	{
		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			var value:Dynamic = NativeCFFI.lime_vulkan_renderer_get_info(__handle);
			__info = (value != null) ? CFFI.stringValue(value) : "";
		}
		#end

		return __info;
	}

	public function setOverlayImage(image:Image, x:Int, y:Int):Bool
	{
		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			if (image == null)
			{
				return NativeCFFI.lime_vulkan_renderer_clear_overlay(__handle);
			}

			if (image.buffer != null && image.width > 0 && image.height > 0)
			{
				return NativeCFFI.lime_vulkan_renderer_set_overlay(__handle, image.data.toBytes(), image.width, image.height, x, y);
			}
		}
		#end

		return false;
	}

	public function clearOverlay():Bool
	{
		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			return NativeCFFI.lime_vulkan_renderer_clear_overlay(__handle);
		}
		#end

		return false;
	}

	public function resize():Bool
	{
		#if (!macro && lime_cffi)
		if (__handle != null)
		{
			return NativeCFFI.lime_vulkan_renderer_resize(__handle);
		}
		#end

		return false;
	}

	public static function getLastError():String
	{
		#if (!macro && lime_cffi)
		var value:Dynamic = NativeCFFI.lime_vulkan_renderer_get_last_error();
		if (value != null)
		{
			return CFFI.stringValue(value);
		}
		#end

		return "";
	}

	private inline function get_commandPool():#if (!lime_doc_gen || lime_vulkan) VKCommandPool #else Dynamic #end
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __commandPool;
		#else
		return null;
		#end
	}

	private inline function get_device():#if (!lime_doc_gen || lime_vulkan) VKDevice #else Dynamic #end
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __device;
		#else
		return null;
		#end
	}

	private inline function get_hasDevice():Bool
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __device != null;
		#else
		return false;
		#end
	}

	private inline function get_info():String
	{
		return __info;
	}

	private inline function get_isValid():Bool
	{
		#if (!lime_doc_gen || lime_vulkan)
		if (__device != null) return true;
		#end

		return __handle != null;
	}

	private inline function get_lastError():String
	{
		return getLastError();
	}

	private inline function get_queue():#if (!lime_doc_gen || lime_vulkan) VKQueue #else Dynamic #end
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __queue;
		#else
		return null;
		#end
	}

	private inline function get_renderPass():#if (!lime_doc_gen || lime_vulkan) VKRenderPass #else Dynamic #end
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __renderPass;
		#else
		return null;
		#end
	}

	private inline function get_swapchain():#if (!lime_doc_gen || lime_vulkan) VKSwapchain #else Dynamic #end
	{
		#if (!lime_doc_gen || lime_vulkan)
		return __swapchain;
		#else
		return null;
		#end
	}
}
