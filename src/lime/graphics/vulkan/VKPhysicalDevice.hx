package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	Describes a Vulkan physical device discovered through a `VKInstance`.
**/
class VKPhysicalDevice
{
	public var instance(default, null):VKInstance;
	public var handle(default, null):Int64;
	public var name(default, null):String;
	public var apiVersion(default, null):Int;
	public var apiVersionString(default, null):String;
	public var driverVersion(default, null):Int;
	public var vendorID(default, null):Int;
	public var deviceID(default, null):Int;
	public var deviceType(default, null):Int;
	public var deviceTypeName(default, null):String;
	public var framebufferColorSampleCounts(default, null):Int;
	public var framebufferDepthSampleCounts(default, null):Int;
	public var framebufferNoAttachmentsSampleCounts(default, null):Int;
	public var framebufferStencilSampleCounts(default, null):Int;
	public var isDiscrete(default, null):Bool;
	public var maxPushConstantsSize(default, null):Int;
	public var minStorageBufferOffsetAlignment(default, null):Int64;
	public var minUniformBufferOffsetAlignment(default, null):Int64;
	public var nonCoherentAtomSize(default, null):Int64;
	public var supportsPresent(default, null):Bool;
	public var queueFamilies(default, null):Array<VKQueueFamilyInfo>;

	@:allow(lime.graphics.vulkan.VKInstance)
	private function new(instance:VKInstance, data:Dynamic)
	{
		this.instance = instance;
		handle = VK.__makeHandle(data.handle);
		name = (data.name != null) ? #if (!lime_doc_gen || lime_cffi) CFFI.stringValue(data.name) #else cast data.name #end : "";
		apiVersion = data.apiVersion;
		apiVersionString = VK.versionString(apiVersion);
		driverVersion = data.driverVersion;
		vendorID = data.vendorID;
		deviceID = data.deviceID;
		deviceType = data.deviceType;
		framebufferColorSampleCounts = data.framebufferColorSampleCounts;
		framebufferDepthSampleCounts = data.framebufferDepthSampleCounts;
		framebufferNoAttachmentsSampleCounts = data.framebufferNoAttachmentsSampleCounts;
		framebufferStencilSampleCounts = data.framebufferStencilSampleCounts;
		maxPushConstantsSize = data.maxPushConstantsSize;
		minStorageBufferOffsetAlignment = VK.__makeHandle(data.minStorageBufferOffsetAlignment);
		minUniformBufferOffsetAlignment = VK.__makeHandle(data.minUniformBufferOffsetAlignment);
		nonCoherentAtomSize = VK.__makeHandle(data.nonCoherentAtomSize);
		deviceTypeName = switch (deviceType)
		{
			case 1: "integrated-gpu";
			case 2: "discrete-gpu";
			case 3: "virtual-gpu";
			case 4: "cpu";
			default: "other";
		}
		isDiscrete = (deviceType == 2);
		supportsPresent = false;

		queueFamilies = [];
		var rawQueueFamilies:Dynamic = data.queueFamilies;
		if (rawQueueFamilies != null)
		{
			var length:Int = untyped rawQueueFamilies.length;
			for (i in 0...length)
			{
				var queueFamily = new VKQueueFamilyInfo(untyped rawQueueFamilies[i]);
				queueFamilies.push(queueFamily);
				if (queueFamily.supportsPresent)
				{
					supportsPresent = true;
				}
			}
		}
	}

	/**
		Creates a logical device with optional Vulkan features explicitly enabled.

		**Why this exists**: `createDevice()` leaves every optional feature disabled
		(the C++ side passes an all-zero `VkPhysicalDeviceFeatures` and no pNext
		chain). That makes a large part of the API surface unusable — timeline
		semaphores, buffer device address, indirect draw count, descriptor indexing,
		host query reset, YCbCr conversion, sparse binding and the optional 1.0
		states all require their feature bit.

		`features` is a list of `VK.DEVICE_FEATURE_*` ids. Every requested feature is
		validated against `vkGetPhysicalDeviceFeatures2` first: an unsupported
		request **fails** with the feature name rather than being silently dropped,
		so callers can trim their list from `getFeatures2()` / `getFeatures()`.

		`VK.DEVICE_FEATURE_*` ids 17 and above need a Vulkan 1.2 device; on 1.1
		hardware they are rejected (the promoted feature structs are 1.2-only).

		```haxe
		var requests = [];
		var core = getFeatures();
		if (core.sparseBinding) requests.push (VK.DEVICE_FEATURE_SPARSE_BINDING);

		var vk12 = VKPhysicalDeviceVulkan12Features.fromWords (
			getFeatures2 ([VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES])
				.get (VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES));
		if (vk12.timelineSemaphore) requests.push (VK.DEVICE_FEATURE_TIMELINE_SEMAPHORE);

		var device = physicalDevice.createDeviceWithFeatures (queueFamily, null, requests);
		```
	**/
	public function createDeviceWithFeatures(queueFamily:VKQueueFamilyInfo = null, extensions:Array<String> = null,
			features:Array<Int> = null):VKDevice
	{
		if (queueFamily == null)
		{
			queueFamily = getQueueFamily(true, supportsPresent);
		}

		if (extensions == null)
		{
			extensions = [VK.KHR_SWAPCHAIN_EXTENSION_NAME];
		}

		if (queueFamily == null || instance == null || instance.context == null || !instance.isValid())
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var data:Dynamic = NativeCFFI.lime_vk_create_device_with_features(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
			handle.high, handle.low, queueFamily.index, extensions, features);

		if (data != null)
		{
			return new VKDevice(this, queueFamily, extensions, data);
		}
		#end

		return null;
	}

	/**
		Creates a logical device with one queue from the requested queue family.
		If no queue family is provided, Lime selects a graphics-capable family
		that can present to the current surface when that data is available.

		> This leaves every optional Vulkan feature disabled. Use
		> `createDeviceWithFeatures()` when you need timeline semaphores, buffer
		> device address, indirect draw count, descriptor indexing, or any other
		> optional feature.
	**/
	public function createDevice(queueFamily:VKQueueFamilyInfo = null, extensions:Array<String> = null):VKDevice
	{
		if (queueFamily == null)
		{
			queueFamily = getQueueFamily(true, supportsPresent);
		}

		if (extensions == null)
		{
			extensions = [VK.KHR_SWAPCHAIN_EXTENSION_NAME];
		}

		if (queueFamily == null || instance == null || instance.context == null || !instance.isValid())
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var data:Dynamic = NativeCFFI.lime_vk_create_device(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
			handle.low, queueFamily.index, extensions);
		if (data != null)
		{
			return new VKDevice(this, queueFamily, extensions, data);
		}
		#end

		return null;
	}

	/**
		Returns the first queue family that matches the requested capabilities.
	**/
	public function getQueueFamily(requireGraphics:Bool = true, requirePresent:Bool = false, requireCompute:Bool = false,
			requireTransfer:Bool = false):VKQueueFamilyInfo
	{
		for (queueFamily in queueFamilies)
		{
			if (queueFamily.matches(requireGraphics, requirePresent, requireCompute, requireTransfer))
			{
				return queueFamily;
			}
		}

		return null;
	}

	public inline function hasQueueFamily(requireGraphics:Bool = true, requirePresent:Bool = false, requireCompute:Bool = false,
			requireTransfer:Bool = false):Bool
	{
		return getQueueFamily(requireGraphics, requirePresent, requireCompute, requireTransfer) != null;
	}

	/**
		Queries a chain of Vulkan 1.1/1.2 feature structs.

		Convenience wrapper over `VK.getPhysicalDeviceFeatures2`. Prefer the typed
		decoders so field order never has to be counted by hand:

		```haxe
		var features = device.getFeatures2 ([
			VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
		]);
		var vk12 = VKPhysicalDeviceVulkan12Features.fromWords (
			features.get (VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES));
		if (vk12.descriptorIndexing) { ... }
		```
	**/
	public function getFeatures2(structTypes:Array<Int>):Map<Int, Array<Int>>
	{
		return VK.getPhysicalDeviceFeatures2(this, structTypes);
	}

	/**
		Returns the descriptor-indexing limits (the ceiling on bindless arrays).

		Requires Vulkan 1.2 (or `VK_EXT_descriptor_indexing`); `null` otherwise.
		Use together with `getFeatures2` to decide whether a bindless sprite
		batcher fits this device.
	**/
	public function getDescriptorIndexingProperties():VKDescriptorIndexingProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_descriptor_indexing_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKDescriptorIndexingProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the aggregate Vulkan 1.2 properties (driver identity, resolve
		modes, timeline limits, integer framebuffer sample counts).
	**/
	public function getVulkan12Properties():VKVulkan12Properties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_vulkan12_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKVulkan12Properties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the inline-uniform-block limits (`maxInlineUniformBlockSize` and
		the per-stage / per-set descriptor counts, update-after-bind included).

		Requires Vulkan 1.3 (or `VK_EXT_inline_uniform_block`); `null` otherwise.
	**/
	public function getInlineUniformBlockProperties():VKInlineUniformBlockProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_inline_uniform_block_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKInlineUniformBlockProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the subgroup size range plus the stages that allow a required
		size (`VkPhysicalDeviceSubgroupSizeControlProperties`).

		Requires Vulkan 1.3 (or `VK_EXT_subgroup_size_control`); `null` otherwise.
		Combine with `VK.DEVICE_FEATURE_SUBGROUP_SIZE_CONTROL` and
		`VKGraphicsPipelineInfo.vertexRequiredSubgroupSize` /
		`VKDevice.createComputePipeline(..., requiredSubgroupSize)`.
	**/
	public function getSubgroupSizeControlProperties():VKSubgroupSizeControlProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_subgroup_size_control_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKSubgroupSizeControlProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the boolean feature set supported by this physical device.

		Check this before relying on optional Vulkan 1.0 features such as
		`samplerAnisotropy`, `geometryShader` or `wideLines`.
	**/
	public function getFeatures():VKPhysicalDeviceFeatures
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_features(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKPhysicalDeviceFeatures.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns tiling and buffer capabilities for a `VkFormat`.
	**/
	public function getFormatProperties(format:Int):VKFormatProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_format_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, format);
			return VKFormatProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the limits for a specific image format/type/tiling/usage combination,
		or `null` when that combination is not supported.
	**/
	public function getImageFormatProperties(format:Int, imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL,
			usage:Int = VK.IMAGE_USAGE_SAMPLED_BIT, flags:Int = 0):VKImageFormatProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_image_format_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, format, imageType, tiling, usage, flags);
			return VKImageFormatProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the memory types and heaps exposed by this physical device.
	**/
	public function getMemoryProperties():VKPhysicalDeviceMemoryProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_memory_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKPhysicalDeviceMemoryProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the sparse image format granularity data for a format/type/sample
		count/usage/tiling combination.
	**/
	public function getSparseImageFormatProperties(format:Int, imageType:Int = VK.IMAGE_TYPE_2D, samples:Int = VK.SAMPLE_COUNT_1_BIT,
			usage:Int = VK.IMAGE_USAGE_SAMPLED_BIT, tiling:Int = VK.IMAGE_TILING_OPTIMAL):Array<VKSparseImageFormatProperties>
	{
		var properties = new Array<VKSparseImageFormatProperties>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_sparse_image_format_properties(instance.context.__windowHandle,
				instance.handle.high, instance.handle.low, handle.high, handle.low, format, imageType, samples, usage, tiling);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					properties.push(VKSparseImageFormatProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return properties;
	}

	/**
		Enumerates the device extensions available for this physical device,
		optionally filtered to those provided by the named implicit layer.
	**/
	public function getDeviceExtensions(layerName:String = null):Array<VKExtensionProperties>
	{
		var extensions = new Array<VKExtensionProperties>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_enumerate_device_extension_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, layerName);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					extensions.push(VKExtensionProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return extensions;
	}

	/**
		Lists the tools currently attached to this physical device (Vulkan 1.3).

		Profiling and validation layers announce themselves here; `purposes` is a
		bitmask of `VK.TOOL_PURPOSE_*` values. Most systems report an empty list
		when no tool is active, which is the normal case rather than an error.
	**/
	public function getToolProperties():Array<VKToolProperties>
	{
		var tools = new Array<VKToolProperties>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_tool_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					tools.push(VKToolProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return tools;
	}

	/**
		Enumerates the device layers available for this physical device.

		Device layers are deprecated; this is exposed for completeness of the
		Vulkan 1.0 surface.
	**/
	public function getDeviceLayers():Array<VKLayerProperties>
	{
		var layers = new Array<VKLayerProperties>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_enumerate_device_layer_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					layers.push(VKLayerProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return layers;
	}

	/**
		Queries device properties through the Vulkan 1.1 path.

		Returns the core property subset plus the 1.1 `maintenance3` and
		`multiview` structs. Prefer this over the 1.0 fields when you need
		`maxMemoryAllocationSize` or the per-set descriptor cap.
	**/
	public function getProperties2():VKPhysicalDeviceProperties2
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_properties2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKPhysicalDeviceProperties2.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Vulkan 1.1 form of `getFormatProperties()`.
	**/
	public function getFormatProperties2(format:Int):VKFormatProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_format_properties2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, format);
			return VKFormatProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Vulkan 1.1 form of `getImageFormatProperties()`.
	**/
	public function getImageFormatProperties2(format:Int, imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL,
			usage:Int = VK.IMAGE_USAGE_SAMPLED_BIT, flags:Int = 0):VKImageFormatProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_image_format_properties2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, format, imageType, tiling, usage, flags);
			return VKImageFormatProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Vulkan 1.1 form of `getMemoryProperties()`.
	**/
	public function getMemoryProperties2():VKPhysicalDeviceMemoryProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_memory_properties2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low);
			return VKPhysicalDeviceMemoryProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Vulkan 1.1 form of the queue family list.

		Unlike the 1.0 path this also fills in `minImageTransferGranularity`, and
		it accepts a surface so `supportsPresent` can be filled for it.
	**/
	public function getQueueFamilyProperties2(surface:VKSurface = null):Array<VKQueueFamilyInfo>
	{
		var families = new Array<VKQueueFamilyInfo>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_queue_family_properties2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, surface != null ? surface.high : 0, surface != null ? surface.low : 0);

			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					families.push(new VKQueueFamilyInfo(untyped result[i]));
				}
			}
		}
		#end

		return families;
	}

	/**
		Vulkan 1.1 form of `getSparseImageFormatProperties()`.
	**/
	public function getSparseImageFormatProperties2(format:Int, imageType:Int = VK.IMAGE_TYPE_2D, samples:Int = VK.SAMPLE_COUNT_1_BIT,
			usage:Int = VK.IMAGE_USAGE_SAMPLED_BIT, tiling:Int = VK.IMAGE_TILING_OPTIMAL):Array<VKSparseImageFormatProperties>
	{
		var properties = new Array<VKSparseImageFormatProperties>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_sparse_image_format_properties2(instance.context.__windowHandle,
				instance.handle.high, instance.handle.low, handle.high, handle.low, format, imageType, samples, usage, tiling);

			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					properties.push(VKSparseImageFormatProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return properties;
	}

	/**
		Reports whether buffers created with the given flags/usage can be shared
		through `handleType`, and which handle types they can be exported to.

		This is the Vulkan 1.1 replacement for the removed
		`vkGetPhysicalDeviceExternalImageFormatProperties` query.
	**/
	public function getExternalBufferProperties(flags:Int, usage:Int, handleType:Int):VKExternalProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_external_buffer_properties(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, flags, usage, handleType);
			return VKExternalProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Reports external-fence sharing capability for a handle type.
	**/
	public function getExternalFenceProperties(handleType:Int):VKExternalProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_external_fence_properties(instance.context.__windowHandle,
				instance.handle.high, instance.handle.low, handle.high, handle.low, handleType);
			return VKExternalProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Reports external-semaphore sharing capability for a handle type.

		This is the query that gates sharing a timeline semaphore with a video
		decoder or another graphics API.
	**/
	public function getExternalSemaphoreProperties(handleType:Int):VKExternalProperties
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle))
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_external_semaphore_properties(instance.context.__windowHandle,
				instance.handle.high, instance.handle.low, handle.high, handle.low, handleType);
			return VKExternalProperties.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the surface capabilities for this device + surface pair.

		Query this before building a swapchain. Use `resolveExtent()` on the
		result to turn a requested window size into a legal swapchain extent.
	**/
	public function getSurfaceCapabilities(surface:VKSurface):VKSurfaceCapabilities
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle) && surface != null && surface.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_physical_device_surface_capabilities(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, surface.high, surface.low);
			return VKSurfaceCapabilities.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the surface formats this device can present to `surface`.
	**/
	public function getSurfaceFormats(surface:VKSurface):Array<VKSurfaceFormat>
	{
		var formats = new Array<VKSurfaceFormat>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle) && surface != null && surface.isValid())
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_surface_formats(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, surface.high, surface.low);

			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					formats.push(VKSurfaceFormat.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return formats;
	}

	/**
		Returns the present modes this device supports for `surface`.

		Worth checking for a 2D renderer that wants low latency:
		`VK.PRESENT_MODE_MAILBOX_KHR` / `VK.PRESENT_MODE_IMMEDIATE_KHR` are
		optional, and only `VK.PRESENT_MODE_FIFO_KHR` is guaranteed.
	**/
	public function getSurfacePresentModes(surface:VKSurface):Array<Int>
	{
		var modes = new Array<Int>();

		#if (!macro && lime_cffi && lime_vulkan)
		if (instance != null && instance.isValid() && !VK.__isZero(handle) && surface != null && surface.isValid())
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_physical_device_surface_present_modes(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, surface.high, surface.low);

			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					modes.push(untyped result[i]);
				}
			}
		}
		#end

		return modes;
	}

	public function getMaxUsableSampleCount(requireDepth:Bool = false, requireStencil:Bool = false):Int
	{
		var counts = framebufferColorSampleCounts;
		if (requireDepth)
		{
			counts &= framebufferDepthSampleCounts;
		}
		if (requireStencil)
		{
			counts &= framebufferStencilSampleCounts;
		}

		for (sampleCount in [
			VK.SAMPLE_COUNT_64_BIT,
			VK.SAMPLE_COUNT_32_BIT,
			VK.SAMPLE_COUNT_16_BIT,
			VK.SAMPLE_COUNT_8_BIT,
			VK.SAMPLE_COUNT_4_BIT,
			VK.SAMPLE_COUNT_2_BIT
		])
		{
			if ((counts & sampleCount) != 0)
			{
				return sampleCount;
			}
		}

		return VK.SAMPLE_COUNT_1_BIT;
	}

	public function supportsSampleCount(samples:Int, requireDepth:Bool = false, requireStencil:Bool = false):Bool
	{
		var counts = framebufferColorSampleCounts;
		if (requireDepth)
		{
			counts &= framebufferDepthSampleCounts;
		}
		if (requireStencil)
		{
			counts &= framebufferStencilSampleCounts;
		}
		return (counts & samples) != 0;
	}
}
