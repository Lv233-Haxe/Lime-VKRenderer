package;

import haxe.Int64;
import haxe.Timer;
import haxe.io.Bytes;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.RenderContextType;
import lime.graphics.VulkanRenderContext;
import lime.graphics.vulkan.VK;
import lime.graphics.vulkan.VKStructureType;
import lime.graphics.vulkan.VKExtensionProperties;
import lime._internal.backend.native.NativeCFFI;
import lime.graphics.vulkan.VKBuffer;
import lime.graphics.vulkan.VKCommandBuffer;
import lime.graphics.vulkan.VKCommandPool;
import lime.graphics.vulkan.VKDescriptorPool;
import lime.graphics.vulkan.VKDescriptorPoolSize;
import lime.graphics.vulkan.VKDescriptorSet;
import lime.graphics.vulkan.VKDescriptorSetLayout;
import lime.graphics.vulkan.VKDescriptorSetLayoutBinding;
import lime.graphics.vulkan.VKDevice;
import lime.graphics.vulkan.VKFence;
import lime.graphics.vulkan.VKFramebuffer;
import lime.graphics.vulkan.VKGraphicsPipelineInfo;
import lime.graphics.vulkan.VKImage;
import lime.graphics.vulkan.VKImageView;
import lime.graphics.vulkan.VKInstance;
import lime.graphics.vulkan.VKPhysicalDevice;
import lime.graphics.vulkan.VKPipeline;
import lime.graphics.vulkan.VKPipelineLayout;
import lime.graphics.vulkan.VKQueueFamilyInfo;
import lime.graphics.vulkan.VKRenderPass;
import lime.graphics.vulkan.VKSampler;
import lime.graphics.vulkan.VKSemaphore;
import lime.graphics.vulkan.VKShaderModule;
import lime.graphics.vulkan.VKSurface;
import lime.graphics.vulkan.VKSwapchain;
import lime.graphics.vulkan.VKVertexAttribute;
import lime.graphics.vulkan.VKVertexBinding;
import lime.system.System;
import lime.utils.Assets;

class Main extends Application
{
	private static inline var DEPTH_FORMAT = VK.FORMAT_D32_SFLOAT;
	private static inline var OFFSCREEN_FORMAT = VK.FORMAT_R8G8B8A8_UNORM;
	private static inline var OFFSCREEN_SIZE = 256;
	private static inline var REQUESTED_MSAA_SAMPLES = VK.SAMPLE_COUNT_4_BIT;
	// Grid stress scene: 16 cubes driven by ONE dynamic-UBO descriptor, one
	// 256-byte slice per object (256 >= any minUniformBufferOffsetAlignment),
	// plus the same slice scheme on a verification FBO that is rendered once,
	// copied back and pixel-checked at startup.
	private static inline var GRID_COUNT = 16;
	private static inline var GRID_SLICE = 256;
	private static inline var GRID_BUFFER_SIZE = GRID_COUNT * GRID_SLICE;
	// The API version this smoke test is written against. When the loader or the
	// physical device tops out below this, `negotiateApiVersion()` clamps down to
	// what the machine actually reports instead of failing device creation.
	private static inline var REQUESTED_VULKAN_MAJOR = 1;
	// Ask for the newest header version. Machines that top out below this are
	// clamped by `negotiateApiVersion()`; asking high is safe because the
	// driver/loader only ever report what they actually implement.
	private static inline var REQUESTED_VULKAN_MINOR = 4;
	// Lime feature ids, as consumed by `createDeviceWithFeatures()` and by the
	// C++ `ApplyVulkanDeviceFeature` switch. The numbering is lime's own, NOT
	// Vulkan bit numbers: the C++ switch also records which `*Features` struct
	// each id feeds, and that is what pins its minimum API version:
	//   1..16  -> VkPhysicalDeviceFeatures        (1.0 core)
	//   17..22 -> VkPhysicalDeviceVulkan11Features (needs 1.1)
	//   23..40 -> VkPhysicalDeviceVulkan12Features (needs 1.2)
	//   41..55 -> VkPhysicalDeviceVulkan13Features (needs 1.3)
	//   57..77 -> VkPhysicalDeviceVulkan14Features (needs 1.4; field order per
	//             vulkan_core.h 1.4.357, whose 21 fields include the post-1.4
	//             appended subgroupRotateClustered / line split / robustness /
	//             hostImageCopy bits)
	//   56     -> VkPhysicalDeviceFeatures.sparseResidencyImage2D (1.0 core,
	//             but numbered after the 1.3 block, so it is handled apart)
	private static inline var FEATURE_ID_1_0_MAX = 16;
	private static inline var FEATURE_ID_1_1_MAX = 22;
	private static inline var FEATURE_ID_1_2_MAX = 40;
	private static inline var FEATURE_ID_1_3_MAX = 55;
	private static inline var FEATURE_ID_1_4_MAX = 77;
	private static inline var FEATURE_ID_SPARSE_RESIDENCY_IMAGE_2D = 56;

	private var colorImage:VKImage;
	private var colorView:VKImageView;
	private var commandBuffer:VKCommandBuffer;
	private var commandPool:VKCommandPool;
	private var cubeDescriptorSet:VKDescriptorSet;
	private var cubeDescriptorSetLayout:VKDescriptorSetLayout;
	private var cubeFragmentShader:VKShaderModule;
	private var cubeIndexBuffer:VKBuffer;
	private var cubePipeline:VKPipeline;
	private var cubePipelineLayout:VKPipelineLayout;
	private var cubeVertexBuffer:VKBuffer;
	private var cubeVertexShader:VKShaderModule;
	private var depthImage:VKImage;
	private var depthView:VKImageView;
	private var descriptorPool:VKDescriptorPool;
	private var device:VKDevice;
	private var deviceExtensions:Array<String>;
	private var fence:VKFence;
	private var finished:Bool;
	private var framebuffers:Array<VKFramebuffer> = [];
	private var frameCount:Int = 0;
	private var imageAvailable:Array<VKSemaphore> = [];
	private var imageViews:Array<VKImageView> = [];
	private var instance:VKInstance;
	private var offscreenDescriptorSet:VKDescriptorSet;
	private var offscreenDescriptorSetLayout:VKDescriptorSetLayout;
	private var offscreenFramebuffer:VKFramebuffer;
	private var offscreenImage:VKImage;
	private var offscreenPipeline:VKPipeline;
	private var offscreenPipelineLayout:VKPipelineLayout;
	private var offscreenRenderPass:VKRenderPass;
	private var offscreenSampler:VKSampler;
	private var offscreenView:VKImageView;
	private var physicalDevice:VKPhysicalDevice;
	private var preloadComplete:Bool;
	private var quadFragmentShader:VKShaderModule;
	private var quadIndexBuffer:VKBuffer;
	private var quadVertexBuffer:VKBuffer;
	private var quadVertexShader:VKShaderModule;
	private var queueFamily:VKQueueFamilyInfo;
	private var renderFinished:Array<VKSemaphore> = [];
	private var renderPass:VKRenderPass;
	private var msaaSamples:Int = VK.SAMPLE_COUNT_1_BIT;
	private var sourceTextureImage:VKImage;
	private var sourceTextureSampler:VKSampler;
	private var sourceTextureView:VKImageView;
	private var surface:VKSurface;
	private var swapchain:VKSwapchain;
	private var uniformBuffer:VKBuffer;
	private var cubeDynSetLayout:VKDescriptorSetLayout;
	private var cubeDynSet:VKDescriptorSet;
	private var cubeDynPipeline:VKPipeline;
	private var cubeDynPipelineLayout:VKPipelineLayout;
	private var cubeDynUniformBuffer:VKBuffer;
	private var gridSetLayout:VKDescriptorSetLayout;
	private var gridSet:VKDescriptorSet;
	private var gridPipeline:VKPipeline;
	private var gridPipelineLayout:VKPipelineLayout;
	private var gridUniformBuffer:VKBuffer;
	private var gridVertexShader:VKShaderModule;
	private var gridFragmentShader:VKShaderModule;
	private var verifyRenderPass:VKRenderPass;
	private var verifyImage:VKImage;
	private var verifyView:VKImageView;
	private var verifyFramebuffer:VKFramebuffer;
	private var verifyStaging:VKBuffer;
	private var windowCreated:Bool;
	// Effective API version after negotiation (loader + device clamped to
	// REQUESTED_VULKAN_MAJOR/MINOR). Defaults to 1.0 so callers can gate
	// 1.1+ query paths before negotiation has run.
	private var apiMajor:Int = 1;
	private var apiMinor:Int = 0;
	// Timed-run support: 0 = run until the window closes (desktop default).
	// Android has no window close, so a timed finish is the default there; the
	// LIME_VK_SMOKE_SECONDS environment variable overrides both when present.
	private var smokeDurationSeconds:Float = #if android 30 #else 0 #end;
	private var runStartedAt:Float = -1;
	private var checksFailed:Bool;

	public function new()
	{
		super();

		var envSeconds = Sys.getEnv("LIME_VK_SMOKE_SECONDS");
		if (envSeconds != null)
		{
			var parsed = Std.parseFloat(envSeconds);

			if (parsed > 0)
			{
				smokeDurationSeconds = parsed;
			}
		}
	}

	override public function onWindowCreate():Void
	{
		super.onWindowCreate();

		if (window == null)
		{
			fail("Missing primary window");
			return;
		}

		if (window.context == null || window.context.type != RenderContextType.VULKAN || window.context.vulkan == null)
		{
			fail("Primary window was not created with a Vulkan context");
			return;
		}

		windowCreated = true;
		tryCreateRenderer();
	}

	override public function onPreloadComplete():Void
	{
		super.onPreloadComplete();

		preloadComplete = true;
		tryCreateRenderer();
	}

	override public function onWindowResize(width:Int, height:Int):Void
	{
		super.onWindowResize(width, height);

		if (!finished && device != null && device.isValid() && width > 0 && height > 0)
		{
			recreateSwapchain(width, height);
		}
	}

	override public function render(context:RenderContext):Void
	{
		super.render(context);

		if (finished || device == null)
		{
			return;
		}

		if (!drawFrame())
		{
			return;
		}

		frameCount++;

		if (runStartedAt < 0)
		{
			runStartedAt = Timer.stamp();
		}

		if (frameCount % 120 == 0)
		{
			var mode = smokeDurationSeconds > 0 ? "timed " + smokeDurationSeconds + "s" : "unlimited";
			trace("[vk] frame " + frameCount + " (" + mode + ")");
		}

		if (smokeDurationSeconds > 0 && Timer.stamp() - runStartedAt >= smokeDurationSeconds)
		{
			finishRun();
		}
	}

	private function createRenderer(context:VulkanRenderContext):Void
	{
		var extensions = context.getInstanceExtensions();
		if (extensions == null || extensions.length == 0)
		{
			fail("No Vulkan instance extensions were reported");
			return;
		}

		var procAddr = context.getInstanceProcAddr();
		if (!isNonZero(procAddr))
		{
			fail("vkGetInstanceProcAddr was not available");
			return;
		}

		instance = VK.createInstance(context, "LimeVulkanSmoke");
		if (instance == null || !instance.isValid())
		{
			fail("Failed to create Vulkan instance: " + VK.getLastError());
			return;
		}

		surface = instance.createSurface();
		if (surface == null || !surface.isValid())
		{
			fail("Failed to create Vulkan surface");
			return;
		}

		physicalDevice = instance.pickPhysicalDevice(surface);
		if (physicalDevice == null || !physicalDevice.hasQueueFamily(true, true))
		{
			fail("No present-capable graphics queue family was found");
			return;
		}

		negotiateApiVersion();

		msaaSamples = physicalDevice.supportsSampleCount(REQUESTED_MSAA_SAMPLES, true) ? REQUESTED_MSAA_SAMPLES : VK.SAMPLE_COUNT_1_BIT;

		// Probe VK_EXT_extended_dynamic_state3: when the device reports both the
		// extension and its feature words, enable it through the extension feature
		// chain so checkExtFeatureChain can legally record vkCmdSetSampleMaskEXT
		// (the last unverified flat-list encoding path).
		deviceExtensions = [VK.KHR_SWAPCHAIN_EXTENSION_NAME];
		var extSTypes:Array<Int> = [];
		var extWords:Array<Int> = [];

		if (atLeastApiVersion(1, 3) && hasDeviceExtension(VK.EXT_EXTENDED_DYNAMIC_STATE_3_EXTENSION_NAME))
		{
			var sType = VKStructureType.PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT;
			var words = physicalDevice.getFeatures2([sType]).get(sType);

			if (words != null && words.length > 0)
			{
				extSTypes.push(sType);
				extWords = extWords.concat(words);
				deviceExtensions.push(VK.EXT_EXTENDED_DYNAMIC_STATE_3_EXTENSION_NAME);
				trace("[vk] requesting VK_EXT_extended_dynamic_state3 via the extension feature chain (" + words.length + " words)");
			}
		}

		if (atLeastApiVersion(1, 3) && hasDeviceExtension(VK.EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME))
		{
			var sType2 = VKStructureType.PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT;
			var words2 = physicalDevice.getFeatures2([sType2]).get(sType2);

			if (words2 != null && words2.length > 0)
			{
				extSTypes.push(sType2);
				extWords = extWords.concat(words2);
				deviceExtensions.push(VK.EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME);
				trace("[vk] requesting VK_EXT_extended_dynamic_state2 via the extension feature chain (" + words2.length + " words)");
			}
		}

		if (hasDeviceExtension(VK.EXT_SHADER_OBJECT_EXTENSION_NAME))
		{
			deviceExtensions.push(VK.EXT_SHADER_OBJECT_EXTENSION_NAME);
			trace("[vk] enabling VK_EXT_shader_object");
		}

		queueFamily = physicalDevice.getQueueFamily(true, true);
		device = physicalDevice.createDeviceWithFeatures(queueFamily, deviceExtensions, buildFeatureRequests(), extSTypes, extWords);
		if (device == null || !device.isValid() || device.graphicsQueue == null || !device.graphicsQueue.isValid())
		{
			fail("Failed to create Vulkan logical device: " + VK.getLastError());
			return;
		}

		commandPool = device.createCommandPool(queueFamily);
		commandBuffer = commandPool != null ? commandPool.allocateCommandBuffer() : null;
		fence = device.createFence(true);

		if (commandPool == null || commandBuffer == null || fence == null)
		{
			fail("Failed to create Vulkan frame synchronization resources: " + VK.getLastError());
			return;
		}

		swapchain = device.createSwapchain(surface, window.width, window.height);
		if (swapchain == null || !swapchain.isValid() || swapchain.images.length == 0)
		{
			fail("Failed to create Vulkan swapchain: " + VK.getLastError());
			return;
		}

		// One acquire + present semaphore pair per swapchain image. A single
		// shared pair cannot render past frame 2: the second
		// vkAcquireNextImageKHR waits on a semaphore the previous submit already
		// consumed and nobody signals again, so the loop stalls.
		if (!createFrameSemaphores())
		{
			fail("Failed to create per-swapchain-image semaphores: " + VK.getLastError());
			return;
		}

		if (!createSourceTexture()
			|| !createGeometry()
			|| !createDescriptorLayouts()
			|| !createOffscreenPass()
			|| !createOnscreenPass()
			|| !createGridVerifyPass()
			|| !verifyGridReadback())
		{
			return;
		}

		runFeatureChecks(context);
	}

	/**
		True when the physical device reports the named device extension. Uses the
		enumerate-device-extension-properties CFFI directly (there is no typed
		wrapper on VKPhysicalDevice yet).
	**/
	@:access(lime._internal.backend.native.NativeCFFI)
	@:access(lime.graphics.VulkanRenderContext)
	private function hasDeviceExtension(name:String):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		// Dynamic, not typed: the CFFI returns anonymous objects, and a typed
		// Array<VKExtensionProperties> would read the CLASS's C++ field layout
		// (null) instead of the Dynamic field.
		var list:Array<Dynamic> = cast NativeCFFI.lime_vk_enumerate_device_extension_properties(
			instance.context.__windowHandle, instance.handle.high, instance.handle.low, physicalDevice.handle.high, physicalDevice.handle.low, null);
		var found = false;

		if (list != null)
		{
			for (entry in list)
			{
				if (entry != null && entry.name == name)
				{
					found = true;
					break;
				}
			}
		}

		trace("[vk] dev ext probe '" + name + "': " + (list == null ? "null" : Std.string(list.length)) + " entries -> " + found);
		return found;
		#end

		return false;
	}

	/**
		Builds the feature-id list to probe, capped by the negotiated API version.

		Ids above the negotiated ceiling back `*Features` structs the device does
		not implement, so probing them would report failures that are really just
		"this machine only speaks 1.2". The list is therefore truncated at the
		highest id the negotiated version can take.

		These ids are now passed to `createDeviceWithFeatures()` itself (the
		main device is feature-full, unsupported bits are clipped by the native
		validation), so every check below runs against a legally-enabled device.
	**/
	private function buildFeatureRequests():Array<Int>
	{
		var ceiling = FEATURE_ID_1_0_MAX;

		if (atLeastApiVersion(1, 1)) ceiling = FEATURE_ID_1_1_MAX;
		if (atLeastApiVersion(1, 2)) ceiling = FEATURE_ID_1_2_MAX;
		if (atLeastApiVersion(1, 3)) ceiling = FEATURE_ID_1_3_MAX;
		if (atLeastApiVersion(1, 4)) ceiling = FEATURE_ID_1_4_MAX;

		var requests = [];

		for (id in 1...ceiling + 1)
		{
			requests.push(id);
		}

		// Backed by VkPhysicalDeviceFeatures (1.0), so legal at every ceiling,
		// but numbered after the 1.3 block - add it back explicitly.
		if (ceiling < FEATURE_ID_SPARSE_RESIDENCY_IMAGE_2D)
		{
			requests.push(FEATURE_ID_SPARSE_RESIDENCY_IMAGE_2D);
		}

		return requests;
	}

	/**
		Runs the modern-API and cloud checks against the feature set the
		negotiated API version allows, and fails the smoke run if any check that
		should have been possible reports a failure.

		Both suites are defensive by design: a capability the machine does not
		have is reported as SKIP, never as a failure, so a 1.0 or 1.1 machine
		still completes the run.
	**/
	private function runFeatureChecks(vulkanContext:VulkanRenderContext):Void
	{
		var featureRequests = buildFeatureRequests();

		trace("[vk] feature ids probed at api " + apiMajor + "." + apiMinor + ": " + featureRequests.length + " (ids 1.."
			+ featureRequests[featureRequests.length - 1] + ")");

		if (!ModernApiChecks.run(vulkanContext, instance, physicalDevice, device, device.graphicsQueue, queueFamily, surface, featureRequests,
			device.extensions, apiMajor, apiMinor))
		{
			// A check that could not run is not a reason to kill the process:
			// log it and keep going so the rest of the suite still reports.
			checksFailed = true;
			trace("[vk] modern API checks reported problems (api " + apiMajor + "." + apiMinor + ")");
		}

		if (!CloudSmoke.run(device, device.graphicsQueue, featureRequests, apiMajor, apiMinor))
		{
			checksFailed = true;
			trace("[vk] cloud checks reported problems (api " + apiMajor + "." + apiMinor + ")");
		}
	}

	private function tryCreateRenderer():Void
	{
		if (device != null || !windowCreated || !preloadComplete || window == null || window.context == null || window.context.vulkan == null)
		{
			return;
		}

		createRenderer(window.context.vulkan);
	}

	/**
		Clamps the API version this smoke test targets down to what the machine
		actually offers.

		Three ceilings are intersected, lowest wins:

		1. `REQUESTED_VULKAN_MAJOR.MINOR` - what the test is written against.
		2. The loader version (`vkEnumerateInstanceVersion`); a pre-1.1 loader
		   reports no version at all and is treated as 1.0.
		3. `VkPhysicalDeviceProperties.apiVersion` - what the driver supports.

		The negotiated result lands in `apiMajor`/`apiMinor` and is logged, so a
		run on older hardware degrades visibly instead of dying in device
		creation. Rendering itself only uses 1.0 core commands plus
		VK_KHR_swapchain, so a 1.0 ceiling still exercises the full smoke path.
	**/
	private function negotiateApiVersion():Void
	{
		var loaderVersion = instance.getApiVersion();
		var loaderMajor = loaderVersion != null ? loaderVersion.major : 1;
		var loaderMinor = loaderVersion != null ? loaderVersion.minor : 0;

		var deviceVersion = physicalDevice.apiVersion;
		var deviceMajor = deviceVersion >>> 22;
		var deviceMinor = (deviceVersion >>> 12) & 0x3FF;

		var major = REQUESTED_VULKAN_MAJOR;
		var minor = REQUESTED_VULKAN_MINOR;

		if (major > loaderMajor || (major == loaderMajor && minor > loaderMinor))
		{
			major = loaderMajor;
			minor = loaderMinor;
		}

		if (major > deviceMajor || (major == deviceMajor && minor > deviceMinor))
		{
			major = deviceMajor;
			minor = deviceMinor;
		}

		apiMajor = major;
		apiMinor = minor;

		trace("[vk] api version: loader=" + loaderMajor + "." + loaderMinor + " device=" + VK.versionString(deviceVersion) + " -> using "
			+ major + "." + minor);

		if (!atLeastApiVersion(1, 1))
		{
			trace("[vk] negotiated below 1.1: 1.1+ query paths (features2/properties2) are unavailable on this machine");
		}
	}

	/**
		True when the negotiated API version is at least `major.minor`.
	**/
	private function atLeastApiVersion(major:Int, minor:Int):Bool
	{
		return apiMajor > major || (apiMajor == major && apiMinor >= minor);
	}

	private function createSourceTexture():Bool
	{
		sourceTextureImage = device.createImage(2, 2, OFFSCREEN_FORMAT, VK.IMAGE_USAGE_TRANSFER_DST_BIT | VK.IMAGE_USAGE_SAMPLED_BIT);
		if (sourceTextureImage == null || sourceTextureImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			fail("Failed to create Vulkan texture image: " + VK.getLastError());
			return false;
		}

		var pixels = Bytes.alloc(16);
		var values = [
			0xFF, 0x90, 0x20, 0xFF,
			0x10, 0xD8, 0xFF, 0xFF,
			0xFF, 0xFF, 0xFF, 0xFF,
			0x20, 0x40, 0xFF, 0xFF
		];
		for (i in 0...values.length)
		{
			pixels.set(i, values[i]);
		}

		var staging = device.createStagingBuffer(Int64.ofInt(pixels.length), pixels);
		if (staging == null)
		{
			fail("Failed to create Vulkan texture staging buffer: " + VK.getLastError());
			return false;
		}

		if (!commandBuffer.reset()
			|| !commandBuffer.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)
			|| !commandBuffer.pipelineBarrierImage(sourceTextureImage, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
				VK.PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK.PIPELINE_STAGE_TRANSFER_BIT, 0, VK.ACCESS_TRANSFER_WRITE_BIT, VK.IMAGE_ASPECT_COLOR_BIT)
			|| !commandBuffer.copyBufferToImage(staging, sourceTextureImage, 2, 2)
			|| !commandBuffer.pipelineBarrierImage(sourceTextureImage, VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK.IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
				VK.PIPELINE_STAGE_TRANSFER_BIT, VK.PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK.ACCESS_TRANSFER_WRITE_BIT, VK.ACCESS_SHADER_READ_BIT,
				VK.IMAGE_ASPECT_COLOR_BIT)
			|| !commandBuffer.end())
		{
			staging.dispose(true);
			fail("Failed to record Vulkan texture upload commands: " + VK.getLastError());
			return false;
		}

		if (!fence.waitForever() || !fence.reset() || !device.graphicsQueue.submit(commandBuffer, fence) || !fence.waitForever())
		{
			staging.dispose(true);
			fail("Failed to submit Vulkan texture upload: " + VK.getLastError());
			return false;
		}

		staging.dispose(true);

		sourceTextureView = sourceTextureImage.createView(OFFSCREEN_FORMAT);
		sourceTextureSampler = device.createSampler(VK.FILTER_NEAREST, VK.SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, VK.SAMPLER_MIPMAP_MODE_NEAREST);

		if (sourceTextureView == null || sourceTextureSampler == null)
		{
			fail("Failed to create Vulkan texture view/sampler: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createGeometry():Bool
	{
		if (!createQuadGeometry() || !createCubeGeometry())
		{
			return false;
		}

		uniformBuffer = device.createUniformBuffer(Int64.ofInt(64), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		if (uniformBuffer == null)
		{
			fail("Failed to create Vulkan uniform buffer: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createQuadGeometry():Bool
	{
		var vertices = Bytes.alloc(4 * 32);
		var data = [
			-0.72, -0.72, 0.0, 1.0, 1.0, 1.0, 1.0, 0.86,
			 0.72, -0.72, 1.0, 1.0, 1.0, 1.0, 1.0, 0.86,
			 0.72,  0.72, 1.0, 0.0, 1.0, 1.0, 1.0, 0.86,
			-0.72,  0.72, 0.0, 0.0, 1.0, 1.0, 1.0, 0.86
		];
		for (i in 0...data.length)
		{
			vertices.setFloat(i * 4, data[i]);
		}

		var indices = Bytes.alloc(6 * 2);
		var indexData = [0, 1, 2, 2, 3, 0];
		for (i in 0...indexData.length)
		{
			indices.setUInt16(i * 2, indexData[i]);
		}

		quadVertexBuffer = device.createVertexBuffer(Int64.ofInt(vertices.length), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT,
			vertices);
		quadIndexBuffer = device.createIndexBuffer(Int64.ofInt(indices.length), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT,
			indices);

		if (quadVertexBuffer == null || quadIndexBuffer == null)
		{
			fail("Failed to create Vulkan quad buffers: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createCubeGeometry():Bool
	{
		var vertexData = [
			-1.0, -1.0,  1.0, 0.0, 1.0,  1.0, 0.85, 0.55, 1.0,
			 1.0, -1.0,  1.0, 1.0, 1.0,  1.0, 0.85, 0.55, 1.0,
			 1.0,  1.0,  1.0, 1.0, 0.0,  1.0, 0.85, 0.55, 1.0,
			-1.0,  1.0,  1.0, 0.0, 0.0,  1.0, 0.85, 0.55, 1.0,
			 1.0, -1.0, -1.0, 0.0, 1.0, 0.55,  0.8,  1.0, 1.0,
			-1.0, -1.0, -1.0, 1.0, 1.0, 0.55,  0.8,  1.0, 1.0,
			-1.0,  1.0, -1.0, 1.0, 0.0, 0.55,  0.8,  1.0, 1.0,
			 1.0,  1.0, -1.0, 0.0, 0.0, 0.55,  0.8,  1.0, 1.0,
			-1.0, -1.0, -1.0, 0.0, 1.0, 0.75,  1.0, 0.65, 1.0,
			-1.0, -1.0,  1.0, 1.0, 1.0, 0.75,  1.0, 0.65, 1.0,
			-1.0,  1.0,  1.0, 1.0, 0.0, 0.75,  1.0, 0.65, 1.0,
			-1.0,  1.0, -1.0, 0.0, 0.0, 0.75,  1.0, 0.65, 1.0,
			 1.0, -1.0,  1.0, 0.0, 1.0,  1.0, 0.75,  0.6, 1.0,
			 1.0, -1.0, -1.0, 1.0, 1.0,  1.0, 0.75,  0.6, 1.0,
			 1.0,  1.0, -1.0, 1.0, 0.0,  1.0, 0.75,  0.6, 1.0,
			 1.0,  1.0,  1.0, 0.0, 0.0,  1.0, 0.75,  0.6, 1.0,
			-1.0,  1.0,  1.0, 0.0, 1.0, 0.65, 0.95,  1.0, 1.0,
			 1.0,  1.0,  1.0, 1.0, 1.0, 0.65, 0.95,  1.0, 1.0,
			 1.0,  1.0, -1.0, 1.0, 0.0, 0.65, 0.95,  1.0, 1.0,
			-1.0,  1.0, -1.0, 0.0, 0.0, 0.65, 0.95,  1.0, 1.0,
			-1.0, -1.0, -1.0, 0.0, 1.0,  1.0, 0.65, 0.75, 1.0,
			 1.0, -1.0, -1.0, 1.0, 1.0,  1.0, 0.65, 0.75, 1.0,
			 1.0, -1.0,  1.0, 1.0, 0.0,  1.0, 0.65, 0.75, 1.0,
			-1.0, -1.0,  1.0, 0.0, 0.0,  1.0, 0.65, 0.75, 1.0
		];

		var indexData = [
			 0,  1,  2,  2,  3,  0,
			 4,  5,  6,  6,  7,  4,
			 8,  9, 10, 10, 11,  8,
			12, 13, 14, 14, 15, 12,
			16, 17, 18, 18, 19, 16,
			20, 21, 22, 22, 23, 20
		];

		var vertices = Bytes.alloc(vertexData.length * 4);
		for (i in 0...vertexData.length)
		{
			vertices.setFloat(i * 4, vertexData[i]);
		}

		var indices = Bytes.alloc(indexData.length * 2);
		for (i in 0...indexData.length)
		{
			indices.setUInt16(i * 2, indexData[i]);
		}

		cubeVertexBuffer = device.createVertexBuffer(Int64.ofInt(vertices.length), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT,
			vertices);
		cubeIndexBuffer = device.createIndexBuffer(Int64.ofInt(indices.length), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT,
			indices);

		if (cubeVertexBuffer == null || cubeIndexBuffer == null)
		{
			fail("Failed to create Vulkan cube buffers: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createDescriptorLayouts():Bool
	{
		offscreenDescriptorSetLayout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK.SHADER_STAGE_FRAGMENT_BIT)
		]);
		cubeDescriptorSetLayout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, VK.SHADER_STAGE_VERTEX_BIT),
			new VKDescriptorSetLayoutBinding(1, VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK.SHADER_STAGE_FRAGMENT_BIT)
		]);
		// Dynamic-UBO variants: binding 0's offset is supplied per draw via
		// vkCmdBindDescriptorSets dynamicOffsets, so all 16 cubes share one set.
		cubeDynSetLayout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, VK.SHADER_STAGE_VERTEX_BIT),
			new VKDescriptorSetLayoutBinding(1, VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK.SHADER_STAGE_FRAGMENT_BIT)
		]);
		gridSetLayout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, VK.SHADER_STAGE_VERTEX_BIT)
		]);
		descriptorPool = device.createDescriptorPool(4, [
			new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 3),
			new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, 1),
			new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, 2)
		]);

		if (offscreenDescriptorSetLayout == null || cubeDescriptorSetLayout == null || cubeDynSetLayout == null || gridSetLayout == null
			|| descriptorPool == null)
		{
			fail("Failed to create Vulkan descriptor layouts: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createOffscreenPass():Bool
	{
		offscreenRenderPass = device.createRenderPass(OFFSCREEN_FORMAT, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT, VK.ATTACHMENT_LOAD_OP_CLEAR,
			VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
		offscreenImage = device.createImage(OFFSCREEN_SIZE, OFFSCREEN_SIZE, OFFSCREEN_FORMAT,
			VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_SAMPLED_BIT | VK.IMAGE_USAGE_TRANSFER_SRC_BIT);

		if (offscreenRenderPass == null
			|| offscreenImage == null
			|| offscreenImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			fail("Failed to create Vulkan offscreen render target: " + VK.getLastError());
			return false;
		}

		offscreenView = offscreenImage.createView(OFFSCREEN_FORMAT);
		offscreenSampler = device.createSampler(VK.FILTER_LINEAR, VK.SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, VK.SAMPLER_MIPMAP_MODE_LINEAR);
		offscreenFramebuffer = offscreenView != null ? device.createFramebuffer(offscreenRenderPass, [offscreenView], OFFSCREEN_SIZE, OFFSCREEN_SIZE) : null;

		offscreenDescriptorSet = descriptorPool.allocate(offscreenDescriptorSetLayout);
		offscreenPipelineLayout = device.createPipelineLayout([offscreenDescriptorSetLayout]);
		quadVertexShader = device.createShaderModule(Assets.getBytes("Assets/shaders/quad.vert.spv"));
		quadFragmentShader = device.createShaderModule(Assets.getBytes("Assets/shaders/quad.frag.spv"));

		if (offscreenView == null
			|| offscreenSampler == null
			|| offscreenFramebuffer == null
			|| offscreenDescriptorSet == null
			|| offscreenPipelineLayout == null
			|| quadVertexShader == null
			|| quadFragmentShader == null
			|| !offscreenDescriptorSet.updateImage(0, sourceTextureView, sourceTextureSampler))
		{
			fail("Failed to create Vulkan offscreen pipeline resources: " + VK.getLastError());
			return false;
		}

		var info = new VKGraphicsPipelineInfo();
		info.blend = true;
		info.cullMode = VK.CULL_MODE_NONE;
		info.vertexBindings.push(new VKVertexBinding(0, 32, VK.VERTEX_INPUT_RATE_VERTEX));
		info.vertexAttributes.push(new VKVertexAttribute(0, 0, VK.FORMAT_R32G32_SFLOAT, 0));
		info.vertexAttributes.push(new VKVertexAttribute(1, 0, VK.FORMAT_R32G32_SFLOAT, 8));
		info.vertexAttributes.push(new VKVertexAttribute(2, 0, VK.FORMAT_R32G32B32A32_SFLOAT, 16));

		offscreenPipeline = device.createGraphicsPipeline(offscreenRenderPass, offscreenPipelineLayout, quadVertexShader, quadFragmentShader, info);
		if (offscreenPipeline == null)
		{
			fail("Failed to create Vulkan offscreen graphics pipeline: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function createOnscreenPass():Bool
	{
		if (msaaSamples != VK.SAMPLE_COUNT_1_BIT)
		{
			renderPass = device.createRenderPass(swapchain.format, DEPTH_FORMAT, msaaSamples, VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_DONT_CARE,
				VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, VK.IMAGE_LAYOUT_UNDEFINED,
				VK.IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_DONT_CARE, swapchain.format,
				VK.ATTACHMENT_LOAD_OP_DONT_CARE, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR);
		}
		else
		{
			renderPass = device.createRenderPass(swapchain.format, DEPTH_FORMAT, VK.SAMPLE_COUNT_1_BIT, VK.ATTACHMENT_LOAD_OP_CLEAR,
				VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_PRESENT_SRC_KHR);
		}

		if (renderPass == null || !createColorResources() || !createDepthResources() || !createFramebuffers())
		{
			fail("Failed to create Vulkan onscreen render pass resources: " + VK.getLastError());
			return false;
		}

		cubeDescriptorSet = descriptorPool.allocate(cubeDescriptorSetLayout);
		cubePipelineLayout = device.createPipelineLayout([cubeDescriptorSetLayout]);
		cubeVertexShader = device.createShaderModule(Assets.getBytes("Assets/shaders/cube.vert.spv"));
		cubeFragmentShader = device.createShaderModule(Assets.getBytes("Assets/shaders/cube.frag.spv"));

		if (cubeDescriptorSet == null
			|| cubePipelineLayout == null
			|| cubeVertexShader == null
			|| cubeFragmentShader == null
			|| !cubeDescriptorSet.updateBuffer(0, uniformBuffer, 64)
			|| !cubeDescriptorSet.updateImage(1, offscreenView, offscreenSampler))
		{
			fail("Failed to create Vulkan cube descriptor resources: " + VK.getLastError());
			return false;
		}

		var info = new VKGraphicsPipelineInfo();
		info.depthTest = true;
		info.depthWrite = true;
		info.depthCompareOp = VK.COMPARE_OP_LESS;
		info.cullMode = VK.CULL_MODE_BACK_BIT;
		info.frontFace = VK.FRONT_FACE_CLOCKWISE;
		info.rasterizationSamples = msaaSamples;
		info.vertexBindings.push(new VKVertexBinding(0, 36, VK.VERTEX_INPUT_RATE_VERTEX));
		info.vertexAttributes.push(new VKVertexAttribute(0, 0, VK.FORMAT_R32G32B32_SFLOAT, 0));
		info.vertexAttributes.push(new VKVertexAttribute(1, 0, VK.FORMAT_R32G32_SFLOAT, 12));
		info.vertexAttributes.push(new VKVertexAttribute(2, 0, VK.FORMAT_R32G32B32A32_SFLOAT, 20));

		cubePipeline = device.createGraphicsPipeline(renderPass, cubePipelineLayout, cubeVertexShader, cubeFragmentShader, info);
		if (cubePipeline == null)
		{
			fail("Failed to create Vulkan cube graphics pipeline: " + VK.getLastError());
			return false;
		}

		// Dynamic-UBO cube pipeline: identical state, but binding 0 is a
		// UNIFORM_BUFFER_DYNAMIC whose offset changes per draw, so the 16-cube
		// grid needs a single descriptor set instead of sixteen.
		cubeDynSet = descriptorPool.allocate(cubeDynSetLayout);
		cubeDynPipelineLayout = device.createPipelineLayout([cubeDynSetLayout]);
		cubeDynUniformBuffer = device.createUniformBuffer(Int64.ofInt(GRID_BUFFER_SIZE),
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);

		if (cubeDynSet == null)
		{
			fail("Failed to allocate dynamic-UBO cube descriptor set: " + VK.getLastError());
			return false;
		}
		if (cubeDynPipelineLayout == null)
		{
			fail("Failed to create dynamic-UBO cube pipeline layout: " + VK.getLastError());
			return false;
		}
		if (cubeDynUniformBuffer == null)
		{
			fail("Failed to create dynamic-UBO cube uniform buffer: " + VK.getLastError());
			return false;
		}
		if (!cubeDynSet.updateBuffer(0, cubeDynUniformBuffer, 64, 0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC))
		{
			fail("Failed to write dynamic-UBO cube descriptor (buffer): " + VK.getLastError());
			return false;
		}
		if (!cubeDynSet.updateImage(1, offscreenView, offscreenSampler))
		{
			fail("Failed to write dynamic-UBO cube descriptor (image): " + VK.getLastError());
			return false;
		}

		cubeDynPipeline = device.createGraphicsPipeline(renderPass, cubeDynPipelineLayout, cubeVertexShader, cubeFragmentShader, info);
		if (cubeDynPipeline == null)
		{
			fail("Failed to create Vulkan dynamic-UBO cube pipeline: " + VK.getLastError());
			return false;
		}

		return true;
	}

	/**
		Offscreen verification target: a plain (non-MSAA) FBO whose render pass
		ends in TRANSFER_SRC_OPTIMAL so the rendered color can be copied straight
		into a host-visible buffer and pixel-checked.
	**/
	private function createGridVerifyPass():Bool
	{
		verifyRenderPass = device.createRenderPass(OFFSCREEN_FORMAT, VK.FORMAT_UNDEFINED, VK.SAMPLE_COUNT_1_BIT,
			VK.ATTACHMENT_LOAD_OP_CLEAR, VK.ATTACHMENT_STORE_OP_STORE, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
		verifyImage = device.createImage(OFFSCREEN_SIZE, OFFSCREEN_SIZE, OFFSCREEN_FORMAT,
			VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_TRANSFER_SRC_BIT);
		verifyStaging = device.createBufferWithMemory(Int64.ofInt(OFFSCREEN_SIZE * OFFSCREEN_SIZE * 4), VK.BUFFER_USAGE_TRANSFER_DST_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);

		if (verifyRenderPass == null
			|| verifyImage == null
			|| verifyStaging == null
			|| verifyImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			fail("Failed to create Vulkan verify render target: " + VK.getLastError());
			return false;
		}

		verifyView = verifyImage.createView(OFFSCREEN_FORMAT);
		verifyFramebuffer = verifyView != null ? device.createFramebuffer(verifyRenderPass, [verifyView], OFFSCREEN_SIZE, OFFSCREEN_SIZE) : null;

		gridSet = descriptorPool.allocate(gridSetLayout);
		gridPipelineLayout = device.createPipelineLayout([gridSetLayout]);
		gridUniformBuffer = device.createUniformBuffer(Int64.ofInt(GRID_BUFFER_SIZE),
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		gridVertexShader = device.createShaderModule(Assets.getBytes("Assets/shaders/grid.vert.spv"));
		gridFragmentShader = device.createShaderModule(Assets.getBytes("Assets/shaders/grid.frag.spv"));

		if (verifyView == null
			|| verifyFramebuffer == null
			|| gridSet == null
			|| gridPipelineLayout == null
			|| gridUniformBuffer == null
			|| gridVertexShader == null
			|| gridFragmentShader == null
			|| !gridSet.updateBuffer(0, gridUniformBuffer, 80, 0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC))
		{
			fail("Failed to create Vulkan grid verify resources: " + VK.getLastError());
			return false;
		}

		var info = new VKGraphicsPipelineInfo();
		info.blend = true;
		info.cullMode = VK.CULL_MODE_NONE;
		info.vertexBindings.push(new VKVertexBinding(0, 32, VK.VERTEX_INPUT_RATE_VERTEX));
		info.vertexAttributes.push(new VKVertexAttribute(0, 0, VK.FORMAT_R32G32_SFLOAT, 0));
		info.vertexAttributes.push(new VKVertexAttribute(1, 0, VK.FORMAT_R32G32_SFLOAT, 8));
		info.vertexAttributes.push(new VKVertexAttribute(2, 0, VK.FORMAT_R32G32B32A32_SFLOAT, 16));

		gridPipeline = device.createGraphicsPipeline(verifyRenderPass, gridPipelineLayout, gridVertexShader, gridFragmentShader, info);
		if (gridPipeline == null)
		{
			fail("Failed to create Vulkan grid verify pipeline: " + VK.getLastError());
			return false;
		}

		return true;
	}

	/**
		Slice layout shared by the cube grid (mat4 only) and the verify grid
		(mat4 + tint): 256-byte stride, content in the first 64/80 bytes.
	**/
	private function writeMatrixSlice(bytes:Bytes, slice:Int, matrix:Array<Float>):Void
	{
		var base = slice * GRID_SLICE;

		for (i in 0...16)
		{
			bytes.setFloat(base + i * 4, matrix[i]);
		}
	}

	private function writeTintSlice(bytes:Bytes, slice:Int, r:Float, g:Float, b:Float):Void
	{
		var base = slice * GRID_SLICE + 64;

		bytes.setFloat(base, r);
		bytes.setFloat(base + 4, g);
		bytes.setFloat(base + 8, b);
		bytes.setFloat(base + 12, 1.0);
	}

	/**
		Fills the verification slices: cell (col,row) of a 4x4 grid gets a
		distinct tint and an MVP that maps the shared quad onto exactly that
		cell, so the readback can assert all 16 dynamic offsets independently.
	**/
	private function writeGridVerifySlices():Bool
	{
		var palette = [
			[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0], [1.0, 1.0, 0.0],
			[1.0, 0.0, 1.0], [0.0, 1.0, 1.0], [1.0, 0.5, 0.0], [0.5, 0.0, 1.0],
			[0.0, 1.0, 0.5], [1.0, 1.0, 1.0], [0.25, 0.5, 1.0], [1.0, 0.25, 0.5],
			[0.5, 1.0, 0.25], [0.75, 0.75, 0.0], [0.0, 0.75, 0.75], [0.5, 0.25, 0.0]
		];
		var bytes = Bytes.alloc(GRID_BUFFER_SIZE);

		for (i in 0...GRID_COUNT)
		{
			var col = i % 4;
			var row = Std.int(i / 4);
			// Quad vertices span +-0.72; scale them into a 0.5-wide NDC cell.
			var s = 0.25 / 0.72;
			var tx = -0.75 + col * 0.5;
			// Vulkan NDC y points DOWN (+y = bottom row of the framebuffer),
			// so image row 0 is at ty = -0.75.
			var ty = -0.75 + row * 0.5;
			var mvp = multiply(translation(tx, ty, 0), scaleUniform(s));

			writeMatrixSlice(bytes, i, mvp);
			writeTintSlice(bytes, i, palette[i][0], palette[i][1], palette[i][2]);
		}

		return gridUniformBuffer.upload(bytes);
	}

	/**
		Renders the 16 tinted cells into the verify FBO once, copies the color
		image back and asserts every cell's center pixel: proves per-slice
		dynamic-UBO addressing, FBO rendering and image->buffer readback all at
		once. Any slice mix-up shows up as a wrong cell color.
	**/
	private function verifyGridReadback():Bool
	{
		if (!writeGridVerifySlices())
		{
			fail("Failed to upload grid verification slices: " + VK.getLastError());
			return false;
		}

		var recorded = commandBuffer.reset()
			&& commandBuffer.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)
			&& commandBuffer.beginRenderPass(verifyRenderPass, verifyFramebuffer, OFFSCREEN_SIZE, OFFSCREEN_SIZE, 0, 0, 0, 1)
			&& commandBuffer.setViewport(0, 0, OFFSCREEN_SIZE, OFFSCREEN_SIZE)
			&& commandBuffer.setScissor(0, 0, OFFSCREEN_SIZE, OFFSCREEN_SIZE)
			&& commandBuffer.bindPipeline(gridPipeline)
			&& commandBuffer.bindVertexBuffer(quadVertexBuffer)
			&& commandBuffer.bindIndexBuffer(quadIndexBuffer);

		if (recorded)
		{
			for (i in 0...GRID_COUNT)
			{
				recorded = recorded
					&& commandBuffer.bindDescriptorSet(gridPipelineLayout, gridSet, 0, VK.PIPELINE_BIND_POINT_GRAPHICS, [i * GRID_SLICE])
					&& commandBuffer.drawIndexed(6);
			}
		}

		recorded = recorded
			&& commandBuffer.endRenderPass()
			&& commandBuffer.copyImageToBufferRegion(verifyImage, verifyStaging, OFFSCREEN_SIZE, OFFSCREEN_SIZE)
			&& commandBuffer.end()
			&& fence.reset()
			&& device.graphicsQueue.submit(commandBuffer, fence)
			&& fence.waitForever();

		if (!recorded)
		{
			fail("Failed to record/submit grid verification pass: " + VK.getLastError());
			return false;
		}

		var pixels = Bytes.alloc(OFFSCREEN_SIZE * OFFSCREEN_SIZE * 4);

		if (!verifyStaging.download(pixels))
		{
			fail("Failed to download grid verification FBO: " + VK.getLastError());
			return false;
		}

		var palette = [
			[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0], [1.0, 1.0, 0.0],
			[1.0, 0.0, 1.0], [0.0, 1.0, 1.0], [1.0, 0.5, 0.0], [0.5, 0.0, 1.0],
			[0.0, 1.0, 0.5], [1.0, 1.0, 1.0], [0.25, 0.5, 1.0], [1.0, 0.25, 0.5],
			[0.5, 1.0, 0.25], [0.75, 0.75, 0.0], [0.0, 0.75, 0.75], [0.5, 0.25, 0.0]
		];
		var mismatches = "";

		for (i in 0...GRID_COUNT)
		{
			var cx = (i % 4) * 64 + 32;
			var cy = Std.int(i / 4) * 64 + 32;
			var o = (cy * OFFSCREEN_SIZE + cx) * 4;
			var r = pixels.get(o);
			var g = pixels.get(o + 1);
			var b = pixels.get(o + 2);
			var er = Math.round(palette[i][0] * 255);
			var eg = Math.round(palette[i][1] * 255);
			var eb = Math.round(palette[i][2] * 255);

			if (Math.abs(r - er) > 4 || Math.abs(g - eg) > 4 || Math.abs(b - eb) > 4)
			{
				mismatches += ' cell$i(got $r,$g,$b want $er,$eg,$eb)';
			}
		}

		if (mismatches.length > 0)
		{
			fail("Grid UBO/FBO readback mismatched:" + mismatches);
			return false;
		}

		trace("[vk] PASS gridUboReadback (16/16 dynamic-UBO cells pixel-exact in FBO readback)");
		return true;
	}

	private function createColorResources():Bool
	{
		disposeColorResources();

		if (msaaSamples == VK.SAMPLE_COUNT_1_BIT)
		{
			return true;
		}

		colorImage = device.createImage(swapchain.width, swapchain.height, swapchain.format,
			VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT, 1, 1, 1, VK.IMAGE_TYPE_2D, VK.IMAGE_TILING_OPTIMAL, msaaSamples);
		if (colorImage == null || colorImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			return false;
		}

		colorView = colorImage.createView(swapchain.format);
		return colorView != null;
	}

	private function createDepthResources():Bool
	{
		disposeDepthResources();

		depthImage = device.createImage(swapchain.width, swapchain.height, DEPTH_FORMAT, VK.IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, 1, 1, 1,
			VK.IMAGE_TYPE_2D, VK.IMAGE_TILING_OPTIMAL, msaaSamples);
		if (depthImage == null || depthImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			return false;
		}

		depthView = depthImage.createView(DEPTH_FORMAT, VK.IMAGE_ASPECT_DEPTH_BIT);
		return depthView != null;
	}

	private function createFramebuffers():Bool
	{
		disposeSwapchainFramebuffers();

		for (image in swapchain.images)
		{
			var imageView = image.createView(swapchain.format);
			if (imageView == null)
			{
				fail("Failed to create Vulkan swapchain image view: " + VK.getLastError());
				return false;
			}

			var attachments = msaaSamples != VK.SAMPLE_COUNT_1_BIT ? [colorView, depthView, imageView] : [imageView, depthView];
			var framebuffer = device.createFramebuffer(renderPass, attachments, swapchain.width, swapchain.height);
			if (framebuffer == null)
			{
				imageView.dispose();
				fail("Failed to create Vulkan framebuffer: " + VK.getLastError());
				return false;
			}

			imageViews.push(imageView);
			framebuffers.push(framebuffer);
		}

		return true;
	}

	private function drawFrame():Bool
	{
		if (imageAvailable.length == 0 || renderFinished.length == 0)
		{
			fail("Frame semaphores are not ready");
			return false;
		}

		if (!fence.waitForever())
		{
			fail("Failed to wait for Vulkan frame fence: " + VK.getLastError());
			return false;
		}

		// Round-robin over the semaphore slots rather than the swapchain image
		// index: the acquire result is not known until after the acquire, and
		// the fence at the top of this function guarantees the previous frame
		// that used this slot has already been consumed.
		var slot = frameCount % imageAvailable.length;
		var acquireSemaphore = imageAvailable[slot];
		var presentSemaphore = renderFinished[slot];

		var acquired = swapchain.acquireNextImage(acquireSemaphore);
		if (acquired.result == VK.ERROR_OUT_OF_DATE_KHR)
		{
			return recreateSwapchain(window.width, window.height);
		}
		if (!acquired.isSuccess())
		{
			fail("Failed to acquire Vulkan swapchain image: " + VK.getLastError());
			return false;
		}

		var framebuffer = framebuffers[acquired.imageIndex];
		if (framebuffer == null)
		{
			fail("Swapchain image did not have a framebuffer");
			return false;
		}

		if (!updateCubeUniform() || !updateGridCubes())
		{
			fail("Failed to update Vulkan uniform buffers: " + VK.getLastError());
			return false;
		}

		if (!commandBuffer.reset()
			|| !commandBuffer.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)
			|| !commandBuffer.beginRenderPass(offscreenRenderPass, offscreenFramebuffer, OFFSCREEN_SIZE, OFFSCREEN_SIZE, 0.02, 0.04, 0.07, 1.0)
			|| !commandBuffer.setViewport(0, 0, OFFSCREEN_SIZE, OFFSCREEN_SIZE)
			|| !commandBuffer.setScissor(0, 0, OFFSCREEN_SIZE, OFFSCREEN_SIZE)
			|| !commandBuffer.bindPipeline(offscreenPipeline)
			|| !commandBuffer.bindDescriptorSet(offscreenPipelineLayout, offscreenDescriptorSet)
			|| !commandBuffer.bindVertexBuffer(quadVertexBuffer)
			|| !commandBuffer.bindIndexBuffer(quadIndexBuffer)
			|| !commandBuffer.drawIndexed(6)
			|| !commandBuffer.endRenderPass()
			|| !commandBuffer.pipelineBarrierImage(offscreenImage, VK.IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK.IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
				VK.PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK.PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK.ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
				VK.ACCESS_SHADER_READ_BIT, VK.IMAGE_ASPECT_COLOR_BIT)
			|| !commandBuffer.beginRenderPass(renderPass, framebuffer, swapchain.width, swapchain.height, 0.07, 0.08, 0.09, 1.0, 1.0)
			|| !commandBuffer.setViewport(0, 0, swapchain.width, swapchain.height)
			|| !commandBuffer.setScissor(0, 0, swapchain.width, swapchain.height)
			|| !commandBuffer.bindPipeline(cubeDynPipeline)
			|| !commandBuffer.bindVertexBuffer(cubeVertexBuffer)
			|| !commandBuffer.bindIndexBuffer(cubeIndexBuffer))
		{
			fail("Failed to record Vulkan draw commands: " + VK.getLastError());
			return false;
		}

		// 16 cubes, one shared dynamic-UBO descriptor set: each draw selects its
		// own 256-byte slice via the bind-time dynamic offset.
		for (i in 0...GRID_COUNT)
		{
			if (!commandBuffer.bindDescriptorSet(cubeDynPipelineLayout, cubeDynSet, 0, VK.PIPELINE_BIND_POINT_GRAPHICS, [i * GRID_SLICE])
				|| !commandBuffer.drawIndexed(36))
			{
				fail("Failed to record grid cube draw " + i + ": " + VK.getLastError());
				return false;
			}
		}

		if (!commandBuffer.endRenderPass() || !commandBuffer.end())
		{
			fail("Failed to finish Vulkan draw commands: " + VK.getLastError());
			return false;
		}

		if (!fence.reset()
			|| !device.graphicsQueue.submitSynced(commandBuffer, acquireSemaphore, presentSemaphore, fence)
			|| !fence.waitForever())
		{
			fail("Failed to submit Vulkan draw commands: " + VK.getLastError());
			return false;
		}

		var presentResult = device.graphicsQueue.present(swapchain, acquired.imageIndex, presentSemaphore);
		if (presentResult == VK.ERROR_OUT_OF_DATE_KHR)
		{
			return recreateSwapchain(window.width, window.height);
		}
		if (presentResult != VK.SUCCESS && presentResult != VK.SUBOPTIMAL_KHR)
		{
			fail("Failed to present Vulkan swapchain image: " + VK.getLastError());
			return false;
		}

		return true;
	}

	private function updateCubeUniform():Bool
	{
		var aspect = swapchain.height > 0 ? swapchain.width / swapchain.height : 1.0;
		var angle = Timer.stamp();
		var model = multiply(rotationY(angle), rotationX(angle * 0.61));
		var view = translation(0, 0, -4.25);
		var projection = perspective(Math.PI / 3, aspect, 0.1, 100);
		var mvp = multiply(projection, multiply(view, model));
		var bytes = Bytes.alloc(64);

		for (i in 0...16)
		{
			bytes.setFloat(i * 4, mvp[i]);
		}

		return uniformBuffer.upload(bytes);
	}

	/**
		Per-frame update of the 16 dynamic-UBO slices driving the cube grid:
		4x4 arrangement, each cube spinning on its own axes with a phase offset
		and a gentle bob, so every frame rewrites all 4096 buffer bytes.
	**/
	private function updateGridCubes():Bool
	{
		var time = Timer.stamp();
		var bytes = Bytes.alloc(GRID_BUFFER_SIZE);

		for (i in 0...GRID_COUNT)
		{
			var col = i % 4;
			var row = Std.int(i / 4);
			var phase = i * 0.7;
			var x = -0.75 + col * 0.5;
			var y = -0.6 + row * 0.4 + Math.sin(time * 1.3 + phase) * 0.05;
			var spin = time * (0.9 + (i % 3) * 0.25) + phase;
			var model = multiply(translation(x, y, 0), multiply(rotationY(spin), multiply(rotationX(spin * 0.61), scaleUniform(0.16))));
			var mvp = multiply(perspective(Math.PI / 3, 1.0, 0.1, 100), multiply(translation(0, 0, -3.2), model));

			writeMatrixSlice(bytes, i, mvp);
		}

		return cubeDynUniformBuffer.upload(bytes);
	}

	private function recreateSwapchain(width:Int, height:Int):Bool
	{
		if (width <= 0 || height <= 0 || swapchain == null)
		{
			return false;
		}

		if (!device.waitIdle())
		{
			fail("Failed to idle Vulkan device before swapchain recreation: " + VK.getLastError());
			return false;
		}

		disposeSwapchainResources();
		var oldSwapchain = swapchain;
		swapchain = oldSwapchain.recreate(width, height);
		oldSwapchain.dispose();

		if (swapchain == null || !swapchain.isValid() || swapchain.images.length == 0)
		{
			fail("Failed to recreate Vulkan swapchain: " + VK.getLastError());
			return false;
		}

		return createColorResources() && createDepthResources() && createFramebuffers() && createFrameSemaphores();
	}

	/**
		(Re)creates one acquire + present semaphore pair per swapchain image.

		Called after the swapchain exists and again after every swapchain
		recreation, because the image count can change with the extent.
	**/
	private function createFrameSemaphores():Bool
	{
		disposeFrameSemaphores();

		var count = swapchain != null ? swapchain.images.length : 0;
		if (count <= 0)
		{
			return false;
		}

		for (i in 0...count)
		{
			var acquire = device.createSemaphore();
			var present = device.createSemaphore();

			if (acquire == null || present == null)
			{
				disposeFrameSemaphores();
				return false;
			}

			imageAvailable.push(acquire);
			renderFinished.push(present);
		}

		return true;
	}

	private function disposeFrameSemaphores():Void
	{
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
	}

	private function disposeSwapchainResources():Void
	{
		disposeSwapchainFramebuffers();
		disposeColorResources();
		disposeDepthResources();
	}

	private function disposeSwapchainFramebuffers():Void
	{
		for (framebuffer in framebuffers)
		{
			if (framebuffer != null)
			{
				framebuffer.dispose();
			}
		}
		framebuffers = [];

		for (imageView in imageViews)
		{
			if (imageView != null)
			{
				imageView.dispose();
			}
		}
		imageViews = [];
	}

	private function disposeColorResources():Void
	{
		if (colorView != null)
		{
			colorView.dispose();
			colorView = null;
		}
		if (colorImage != null)
		{
			colorImage.dispose(true);
			colorImage = null;
		}
	}

	private function disposeDepthResources():Void
	{
		if (depthView != null)
		{
			depthView.dispose();
			depthView = null;
		}
		if (depthImage != null)
		{
			depthImage.dispose(true);
			depthImage = null;
		}
	}

	private function complete():Void
	{
		//disposeRenderer();

		if (window != null)
		{
			window.resize(1280, 720);
		}
		onWindowResize(1280,720);
		//System.exit(0);
		finished = false;
	}

	private function disposeRenderer():Void
	{
		if (device != null && device.isValid())
		{
			device.waitIdle();
		}

		disposeSwapchainResources();
		if (offscreenFramebuffer != null) offscreenFramebuffer.dispose();
		if (offscreenView != null) offscreenView.dispose();
		if (offscreenImage != null) offscreenImage.dispose(true);
		if (offscreenSampler != null) offscreenSampler.dispose();
		if (cubeIndexBuffer != null) cubeIndexBuffer.dispose(true);
		if (cubeVertexBuffer != null) cubeVertexBuffer.dispose(true);
		if (quadIndexBuffer != null) quadIndexBuffer.dispose(true);
		if (quadVertexBuffer != null) quadVertexBuffer.dispose(true);
		if (uniformBuffer != null) uniformBuffer.dispose(true);
		if (cubePipeline != null) cubePipeline.dispose();
		if (cubePipelineLayout != null) cubePipelineLayout.dispose();
		if (offscreenPipeline != null) offscreenPipeline.dispose();
		if (offscreenPipelineLayout != null) offscreenPipelineLayout.dispose();
		if (verifyStaging != null) verifyStaging.dispose(true);
		if (verifyFramebuffer != null) verifyFramebuffer.dispose();
		if (verifyView != null) verifyView.dispose();
		if (verifyImage != null) verifyImage.dispose(true);
		if (verifyRenderPass != null) verifyRenderPass.dispose();
		if (gridPipeline != null) gridPipeline.dispose();
		if (gridPipelineLayout != null) gridPipelineLayout.dispose();
		if (gridVertexShader != null) gridVertexShader.dispose();
		if (gridFragmentShader != null) gridFragmentShader.dispose();
		if (cubeDynPipeline != null) cubeDynPipeline.dispose();
		if (cubeDynPipelineLayout != null) cubeDynPipelineLayout.dispose();
		if (cubeDynUniformBuffer != null) cubeDynUniformBuffer.dispose(true);
		if (gridUniformBuffer != null) gridUniformBuffer.dispose(true);
		if (gridSetLayout != null) gridSetLayout.dispose();
		if (cubeDynSetLayout != null) cubeDynSetLayout.dispose();
		if (descriptorPool != null) descriptorPool.dispose();
		if (cubeDescriptorSetLayout != null) cubeDescriptorSetLayout.dispose();
		if (offscreenDescriptorSetLayout != null) offscreenDescriptorSetLayout.dispose();
		if (sourceTextureSampler != null) sourceTextureSampler.dispose();
		if (sourceTextureView != null) sourceTextureView.dispose();
		if (sourceTextureImage != null) sourceTextureImage.dispose(true);
		if (cubeFragmentShader != null) cubeFragmentShader.dispose();
		if (cubeVertexShader != null) cubeVertexShader.dispose();
		if (quadFragmentShader != null) quadFragmentShader.dispose();
		if (quadVertexShader != null) quadVertexShader.dispose();
		if (renderPass != null) renderPass.dispose();
		if (offscreenRenderPass != null) offscreenRenderPass.dispose();
		if (fence != null) fence.dispose();
		disposeFrameSemaphores();
		if (commandBuffer != null) commandBuffer.dispose();
		if (commandPool != null) commandPool.dispose();
		if (swapchain != null) swapchain.dispose();
		if (device != null) device.dispose();
		if (surface != null) surface.dispose();
		if (instance != null) instance.dispose();

		commandBuffer = null;
		commandPool = null;
		colorImage = null;
		colorView = null;
		cubeDescriptorSet = null;
		cubeDescriptorSetLayout = null;
		cubeFragmentShader = null;
		cubeIndexBuffer = null;
		cubePipeline = null;
		cubePipelineLayout = null;
		cubeVertexBuffer = null;
		cubeVertexShader = null;
		descriptorPool = null;
		device = null;
		fence = null;
		instance = null;
		offscreenDescriptorSet = null;
		offscreenDescriptorSetLayout = null;
		offscreenFramebuffer = null;
		offscreenImage = null;
		offscreenPipeline = null;
		offscreenPipelineLayout = null;
		offscreenRenderPass = null;
		offscreenSampler = null;
		offscreenView = null;
		quadFragmentShader = null;
		quadIndexBuffer = null;
		quadVertexBuffer = null;
		quadVertexShader = null;
		renderPass = null;
		sourceTextureImage = null;
		sourceTextureSampler = null;
		sourceTextureView = null;
		surface = null;
		swapchain = null;
		uniformBuffer = null;
	}

	/**
		Timed-run completion (Android default, or LIME_VK_SMOKE_SECONDS anywhere):
		prints one grep-able summary line, disposes Vulkan resources and exits
		with 0/1 according to the check results. Android has no window close, so
		without this the smoke would render forever.
	**/
	private function finishRun():Void
	{
		if (finished)
		{
			return;
		}

		finished = true;

		var seconds = runStartedAt >= 0 ? Math.max(0, Timer.stamp() - runStartedAt) : 0;

		trace("[vk] SMOKE SUMMARY seconds=" + Math.round(seconds) + " frames=" + frameCount + " status="
		+ (checksFailed ? "FAIL" : "PASS"));

		disposeRenderer();
		System.exit(checksFailed ? 1 : 0);
	}

	private function fail(message:String):Void
	{
		trace("Vulkan smoke failed: " + message);
		finished = true;
		trace("[vk] SMOKE SUMMARY frames=" + frameCount + " status=FAIL (" + message + ")");
		disposeRenderer();
		System.exit(1);
	}

	private static function identity():Array<Float>
	{
		return [
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		];
	}

	private static inline function isNonZero(value:Int64):Bool
	{
		return value.high != 0 || value.low != 0;
	}

	private static function multiply(a:Array<Float>, b:Array<Float>):Array<Float>
	{
		var result = [];

		for (column in 0...4)
		{
			for (row in 0...4)
			{
				var value = 0.0;
				for (i in 0...4)
				{
					value += a[i * 4 + row] * b[column * 4 + i];
				}
				result[column * 4 + row] = value;
			}
		}

		return result;
	}

	private static function perspective(fovY:Float, aspect:Float, near:Float, far:Float):Array<Float>
	{
		var f = 1.0 / Math.tan(fovY * 0.5);
		var result = [
			f / aspect, 0.0,                         0.0,  0.0,
			       0.0,  -f,                         0.0,  0.0,
			       0.0, 0.0,          far / (near - far), -1.0,
			       0.0, 0.0, (far * near) / (near - far),  0.0
		];
		return result;
	}

	private static function rotationX(angle:Float):Array<Float>
	{
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		var result = identity();
		result[5] = c;
		result[6] = s;
		result[9] = -s;
		result[10] = c;
		return result;
	}

	private static function rotationY(angle:Float):Array<Float>
	{
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		var result = identity();
		result[0] = c;
		result[2] = -s;
		result[8] = s;
		result[10] = c;
		return result;
	}

	private static function translation(x:Float, y:Float, z:Float):Array<Float>
	{
		var result = identity();
		result[12] = x;
		result[13] = y;
		result[14] = z;
		return result;
	}

	private static function scaleUniform(s:Float):Array<Float>
	{
		var result = identity();
		result[0] = s;
		result[5] = s;
		result[10] = s;
		return result;
	}
}
