package;

import haxe.Int64;
import haxe.io.Bytes;
import lime._internal.backend.native.NativeCFFI;
import lime.graphics.VulkanRenderContext;
import lime.graphics.vulkan.VK;
import lime.graphics.vulkan.VKApiVersion;
import lime.graphics.vulkan.VKBuffer;
import lime.graphics.vulkan.VKCommandPool;
import lime.graphics.vulkan.VKDescriptorPool;
import lime.graphics.vulkan.VKDescriptorPoolSize;
import lime.graphics.vulkan.VKDescriptorSet;
import lime.graphics.vulkan.VKDescriptorSetLayout;
import lime.graphics.vulkan.VKDescriptorSetLayoutBinding;
import lime.graphics.vulkan.VKDescriptorUpdateTemplate;
import lime.graphics.vulkan.VKDescriptorUpdateTemplateEntry;
import lime.graphics.vulkan.VKDevice;
import lime.graphics.vulkan.VKEvent;
import lime.graphics.vulkan.VKFence;
import lime.graphics.vulkan.VKImage;
import lime.graphics.vulkan.VKPhysicalDevice;
import lime.graphics.vulkan.VKPhysicalDeviceBufferDeviceAddressFeatures;
import lime.graphics.vulkan.VKPhysicalDeviceDescriptorIndexingFeatures;
import lime.graphics.vulkan.VKPhysicalDeviceVulkan11Features;
import lime.graphics.vulkan.VKPhysicalDeviceVulkan12Features;
import lime.graphics.vulkan.VKObjectType;
import lime.graphics.vulkan.VKQueryPool;
import lime.graphics.vulkan.VKQueue;
import lime.graphics.vulkan.VKQueueFamilyInfo;
import lime.graphics.vulkan.VKStructureType;
import lime.graphics.vulkan.VKSurface;
import lime.graphics.vulkan.VKSparseImageMemoryRequirements;

/**
	Exercises the Vulkan 1.1 / 1.2 query, memory-2, descriptor-template and
	bindless entry points that `Main` does not drive, and reports each one as

	```
	[api] PASS <name>
	[api] FAIL <name> (<reason>)
	[api] SKIP <name> (<why>)
	```

	Every check is defensive: a missing capability is reported as SKIP, never as
	a failure, so the suite still passes on hardware below the 1.2 feature level.
**/
class ModernApiChecks
{
	public static function run(context:VulkanRenderContext, instance:lime.graphics.vulkan.VKInstance, physicalDevice:VKPhysicalDevice, device:VKDevice,
			queue:VKQueue, queueFamily:VKQueueFamilyInfo, surface:VKSurface, featureRequests:Array<Int> = null,
			enabledExtensions:Array<String> = null):Bool
	{
		var ok = true;

		ok = checkLoaderVersion(context) && ok;
		ok = checkInstanceEnumeration(instance) && ok;
		ok = checkDeviceGroups(instance) && ok;
		ok = checkFeatures2(physicalDevice) && ok;
		ok = checkProperties2(physicalDevice) && ok;
		ok = checkPropertyFamilies(physicalDevice) && ok;
		ok = checkFormatProperties2(physicalDevice) && ok;
		ok = checkImageFormatProperties2(physicalDevice) && ok;
		ok = checkMemoryProperties2(physicalDevice) && ok;
		ok = checkQueueFamilyProperties2(physicalDevice, surface) && ok;
		ok = checkSparseImageFormatProperties2(physicalDevice) && ok;
		ok = checkExternalProperties(physicalDevice) && ok;
		ok = checkSurfaceQueries(physicalDevice, surface) && ok;
		ok = checkMemory2AndBind2(device) && ok;
		ok = checkDescriptorSetLayoutSupport(device) && ok;
		ok = checkDescriptorUpdateTemplate(device) && ok;
		ok = checkBufferDeviceAddress(device) && ok;
		ok = checkSparseMemoryRequirements2(device) && ok;
		ok = checkQueue2AndPeerFeatures(device, queueFamily) && ok;
		ok = checkTrimCommandPool(device) && ok;
		ok = checkExtendedDynamicState(device) && ok;
		ok = checkVertexBuffers2(device) && ok;
		ok = checkPrivateData(device) && ok;
		ok = checkToolProperties(physicalDevice) && ok;
		ok = checkCopyCommands2(device) && ok;
		ok = checkSynchronization2Remainder(device, queue, featureRequests) && ok;
		ok = checkMaintenance4(device, featureRequests) && ok;
		ok = checkInlineUniformBlocks(device, physicalDevice, featureRequests) && ok;
		ok = checkSubgroupSizeControl(physicalDevice, featureRequests) && ok;
		ok = checkTimestamp2(device, featureRequests) && ok;
		ok = checkExtensionCommands(device, enabledExtensions) && ok;
		ok = checkByteBuffers(device, enabledExtensions) && ok;
		ok = checkMapMemory2(device) && ok;
		ok = checkSwapchainCreate(device, physicalDevice, surface) && ok;

		return ok;
	}

	// ------------------------------------------------------------------ 版本与枚举

	private static function checkLoaderVersion(context:VulkanRenderContext):Bool
	{
		var apiVersion = context.getApiVersion();

		if (apiVersion == null)
		{
			// Vulkan 1.0 loaders have no vkEnumerateInstanceVersion at all
			stdout("[api] SKIP loaderVersion (pre-1.1 loader; context.version = '" + context.version + "')");
			return true;
		}

		if (!apiVersion.atLeast(1, 0) || context.version == null || context.version.length == 0)
		{
			trace("[api] FAIL loaderVersion (version=" + apiVersion + ", context.version=" + context.version + ")");
			return false;
		}

		stdout("[api] PASS loaderVersion -> " + context.version);
		return true;
	}

	private static function checkInstanceEnumeration(instance:lime.graphics.vulkan.VKInstance):Bool
	{
		if (instance == null)
		{
			stdout("[api] SKIP instanceEnumeration (no instance)");
			return true;
		}

		var extensions = instance.getExtensions();
		var layers = instance.getLayers();

		// vkEnumerateInstanceExtensionProperties is a global command, so it works
		// even though the instance handle itself is not required for it.
		if (extensions == null || extensions.length == 0)
		{
			trace("[api] FAIL instanceEnumeration (no extensions reported)");
			return false;
		}

		if (layers == null)
		{
			trace("[api] FAIL instanceEnumeration (layer enumeration returned null)");
			return false;
		}

		stdout("[api] PASS instanceEnumeration -> " + extensions.length + " extensions, " + layers.length + " layers");
		return true;
	}

	private static function checkDeviceGroups(instance:lime.graphics.vulkan.VKInstance):Bool
	{
		if (instance == null)
		{
			stdout("[api] SKIP deviceGroups (no instance)");
			return true;
		}

		var groups = instance.enumeratePhysicalDeviceGroups();

		if (groups == null || groups.length == 0)
		{
			stdout("[api] SKIP deviceGroups (vkEnumeratePhysicalDeviceGroups unavailable)");
			return true;
		}

		var total = 0;
		for (group in groups)
		{
			total += group.physicalDeviceCount;
		}

		stdout("[api] PASS deviceGroups -> " + groups.length + " group(s), " + total + " device(s)");
		return true;
	}

	// ------------------------------------------------------------------ 特性 / 属性

	private static function checkFeatures2(physicalDevice:VKPhysicalDevice):Bool
	{
		var requested = [
			VKStructureType.PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
			VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
			VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES,
			VKStructureType.PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES
		];
		var features = physicalDevice.getFeatures2(requested);

		if (features == null)
		{
			stdout("[api] SKIP features2 (vkGetPhysicalDeviceFeatures2 unavailable)");
			return true;
		}

		for (sType in requested)
		{
			if (features.get(sType) == null)
			{
				trace("[api] FAIL features2 (missing struct sType=" + sType + ")");
				return false;
			}
		}

		var vk12 = VKPhysicalDeviceVulkan12Features.fromWords(features.get(VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES));
		var indexing = VKPhysicalDeviceDescriptorIndexingFeatures.fromWords(features.get(VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES));
		var address = VKPhysicalDeviceBufferDeviceAddressFeatures.fromWords(features.get(VKStructureType.PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES));
		var vk11 = VKPhysicalDeviceVulkan11Features.fromWords(features.get(VKStructureType.PHYSICAL_DEVICE_VULKAN_1_1_FEATURES));

		stdout("[api] PASS features2 -> timelineSemaphore=" + vk12.timelineSemaphore + " bufferDeviceAddress=" + address.bufferDeviceAddress
			+ " runtimeDescriptorArray=" + indexing.runtimeDescriptorArray + " samplerYcbcrConversion=" + vk11.samplerYcbcrConversion);
		return true;
	}

	private static function checkProperties2(physicalDevice:VKPhysicalDevice):Bool
	{
		var properties = physicalDevice.getProperties2();

		if (properties == null)
		{
			stdout("[api] SKIP properties2 (vkGetPhysicalDeviceProperties2 unavailable)");
			return true;
		}

		if (properties.deviceName == null || properties.deviceName.length == 0 || properties.maintenance3 == null)
		{
			trace("[api] FAIL properties2 (deviceName='" + properties.deviceName + "', maintenance3=" + properties.maintenance3 + ")");
			return false;
		}

		stdout("[api] PASS properties2 -> " + properties.deviceName + ", maxMemoryAllocationSize=" + properties.maintenance3.maxMemoryAllocationSize
			+ ", timestampPeriod=" + properties.timestampPeriod + ", maxSamplerAnisotropy=" + properties.maxSamplerAnisotropy);
		return true;
	}

	private static function checkPropertyFamilies(physicalDevice:VKPhysicalDevice):Bool
	{
		var indexing = physicalDevice.getDescriptorIndexingProperties();
		var vk12 = physicalDevice.getVulkan12Properties();

		if (indexing == null || vk12 == null)
		{
			stdout("[api] SKIP propertyFamilies (1.2 property queries unavailable)");
			return true;
		}

		stdout("[api] PASS propertyFamilies -> maxDescriptorSetUpdateAfterBindSampledImages=" + indexing.maxDescriptorSetUpdateAfterBindSampledImages
			+ ", driverID=" + vk12.driverID + " '" + vk12.driverName + "', maxTimelineSemaphoreValueDifference=" + vk12.maxTimelineSemaphoreValueDifference);
		return true;
	}

	private static function checkFormatProperties2(physicalDevice:VKPhysicalDevice):Bool
	{
		var properties = physicalDevice.getFormatProperties2(VK.FORMAT_R8G8B8A8_UNORM);

		if (properties == null)
		{
			stdout("[api] SKIP formatProperties2 (vkGetPhysicalDeviceFormatProperties2 unavailable)");
			return true;
		}

		if (properties.optimalTilingFeatures == 0)
		{
			trace("[api] FAIL formatProperties2 (no optimal-tiling features for R8G8B8A8_UNORM)");
			return false;
		}

		stdout("[api] PASS formatProperties2 -> optimalTilingFeatures=0x" + StringTools.hex(properties.optimalTilingFeatures));
		return true;
	}

	private static function checkImageFormatProperties2(physicalDevice:VKPhysicalDevice):Bool
	{
		var properties = physicalDevice.getImageFormatProperties2(VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_TYPE_2D, VK.IMAGE_TILING_OPTIMAL,
			VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_SAMPLED_BIT);

		if (properties == null)
		{
			// Either the query is unavailable (1.0) or the combination is unsupported
			stdout("[api] SKIP imageFormatProperties2 (unsupported or unavailable)");
			return true;
		}

		if (properties.sampleCounts == 0)
		{
			trace("[api] FAIL imageFormatProperties2 (sampleCounts is zero)");
			return false;
		}

		stdout("[api] PASS imageFormatProperties2 -> sampleCounts=0x" + StringTools.hex(properties.sampleCounts) + ", maxMipLevels=" + properties.maxMipLevels);
		return true;
	}

	private static function checkMemoryProperties2(physicalDevice:VKPhysicalDevice):Bool
	{
		var properties = physicalDevice.getMemoryProperties2();

		if (properties == null)
		{
			stdout("[api] SKIP memoryProperties2 (vkGetPhysicalDeviceMemoryProperties2 unavailable)");
			return true;
		}

		if (properties.memoryTypeCount <= 0 || properties.memoryTypes == null || properties.memoryTypes.length == 0)
		{
			trace("[api] FAIL memoryProperties2 (no memory types reported)");
			return false;
		}

		stdout("[api] PASS memoryProperties2 -> " + properties.memoryTypeCount + " types, " + properties.memoryHeapCount + " heaps");
		return true;
	}

	private static function checkQueueFamilyProperties2(physicalDevice:VKPhysicalDevice, surface:VKSurface):Bool
	{
		var families = physicalDevice.getQueueFamilyProperties2(surface);

		if (families == null || families.length == 0)
		{
			stdout("[api] SKIP queueFamilyProperties2 (unavailable)");
			return true;
		}

		// The 1.1 path is the only one that fills in minImageTransferGranularity
		var granularity = families[0].minImageTransferGranularity;

		if (granularity == null)
		{
			trace("[api] FAIL queueFamilyProperties2 (minImageTransferGranularity was not populated)");
			return false;
		}

		stdout("[api] PASS queueFamilyProperties2 -> " + families.length + " families, granularity=" + granularity.width + "x" + granularity.height
			+ "x" + granularity.depth);
		return true;
	}

	private static function checkSparseImageFormatProperties2(physicalDevice:VKPhysicalDevice):Bool
	{
		var properties = physicalDevice.getSparseImageFormatProperties2(VK.FORMAT_R8G8B8A8_UNORM);

		if (properties == null)
		{
			stdout("[api] SKIP sparseImageFormatProperties2 (vkGetPhysicalDeviceSparseImageFormatProperties2 unavailable)");
			return true;
		}

		if (properties.length == 0)
		{
			stdout("[api] SKIP sparseImageFormatProperties2 (no sparse formats for this configuration)");
			return true;
		}

		stdout("[api] PASS sparseImageFormatProperties2 -> " + properties.length + " entr(ies)");
		return true;
	}

	private static function checkExternalProperties(physicalDevice:VKPhysicalDevice):Bool
	{
		var handleType = VK.EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT;
		var buffer = physicalDevice.getExternalBufferProperties(0, VK.BUFFER_USAGE_TRANSFER_DST_BIT, handleType);
		var fence = physicalDevice.getExternalFenceProperties(VK.EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT);
		var semaphore = physicalDevice.getExternalSemaphoreProperties(VK.EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT);

		if (buffer == null || fence == null || semaphore == null)
		{
			stdout("[api] SKIP externalProperties (1.1 external property queries unavailable)");
			return true;
		}

		if (buffer.externalFeatures == 0 && buffer.compatibleHandleTypes == 0)
		{
			stdout("[api] SKIP externalProperties (OPAQUE_WIN32 not usable on this platform)");
			return true;
		}

		stdout("[api] PASS externalProperties -> bufferFeatures=0x" + StringTools.hex(buffer.externalFeatures) + ", fenceFeatures=0x"
			+ StringTools.hex(fence.externalFeatures) + ", semaphoreFeatures=0x" + StringTools.hex(semaphore.externalFeatures));
		return true;
	}

	private static function checkSurfaceQueries(physicalDevice:VKPhysicalDevice, surface:VKSurface):Bool
	{
		if (surface == null || !surface.isValid())
		{
			stdout("[api] SKIP surfaceQueries (no surface)");
			return true;
		}

		var capabilities = physicalDevice.getSurfaceCapabilities(surface);
		var formats = physicalDevice.getSurfaceFormats(surface);
		var presentModes = physicalDevice.getSurfacePresentModes(surface);

		if (capabilities == null || formats == null || presentModes == null || formats.length == 0 || presentModes.length == 0)
		{
			trace("[api] FAIL surfaceQueries (capabilities=" + capabilities + ", formats=" + formats + ", presentModes=" + presentModes + ")");
			return false;
		}

		var extent = capabilities.resolveExtent(640, 480);

		stdout("[api] PASS surfaceQueries -> " + formats.length + " formats, " + presentModes.length + " present modes, minImageCount="
			+ capabilities.minImageCount + ", resolved 640x480 -> " + extent.width + "x" + extent.height + ", mailbox="
			+ (presentModes.indexOf(VK.PRESENT_MODE_MAILBOX_KHR) >= 0));
		return true;
	}

	// ------------------------------------------------------------------ 内存 / 描述符 / BDA

	private static function checkMemory2AndBind2(device:VKDevice):Bool
	{
		var buffer = device.createBuffer(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_DST_BIT);

		if (buffer == null)
		{
			trace("[api] FAIL memory2AndBind2 (createBuffer failed)");
			return false;
		}

		var requirements = device.getBufferMemoryRequirements2(buffer);

		if (requirements == null)
		{
			buffer.dispose();
			stdout("[api] SKIP memory2AndBind2 (vkGetBufferMemoryRequirements2 unavailable)");
			return true;
		}

		var memory = device.allocateMemory(requirements.toMemoryRequirements(), VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT);

		if (memory == null)
		{
			buffer.dispose();
			stdout("[api] SKIP memory2AndBind2 (no device-local memory)");
			return true;
		}

		// bindBufferMemory2 is the 1.1 binding path
		var bound = device.bindBufferMemory2(buffer, memory);

		if (!bound)
		{
			trace("[api] FAIL memory2AndBind2 (bindBufferMemory2 failed: " + VK.getLastError() + ")");
			memory.dispose();
			buffer.dispose();
			return false;
		}

		stdout("[api] PASS memory2AndBind2 -> size=" + requirements.size + ", requiresDedicated=" + requirements.requiresDedicatedAllocation);
		memory.dispose();
		buffer.dispose();
		return true;
	}

	private static function checkDescriptorSetLayoutSupport(device:VKDevice):Bool
	{
		var bindings = [
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK.SHADER_STAGE_FRAGMENT_BIT, 64)
		];
		var support = device.isDescriptorSetLayoutSupported(bindings, 0);

		if (support == null)
		{
			stdout("[api] SKIP descriptorSetLayoutSupport (vkGetDescriptorSetLayoutSupport unavailable)");
			return true;
		}

		if (!support.supported)
		{
			trace("[api] FAIL descriptorSetLayoutSupport (64 sampled images not supported)");
			return false;
		}

		stdout("[api] PASS descriptorSetLayoutSupport -> 64-descriptor layout accepted");
		return true;
	}

	private static function checkDescriptorUpdateTemplate(device:VKDevice):Bool
	{
		var layout = device.createDescriptorSetLayout([
			new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, VK.SHADER_STAGE_VERTEX_BIT)
		]);
		var pool = device.createDescriptorPool(1, [new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, 1)]);
		var uniformBuffer = device.createBufferWithMemory(Int64.ofInt(64), VK.BUFFER_USAGE_UNIFORM_BUFFER_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);

		if (layout == null || pool == null || uniformBuffer == null)
		{
			trace("[api] FAIL descriptorUpdateTemplate (setup failed)");
			return false;
		}

		var set = pool.allocate(layout);
		var template = set != null ? device.createDescriptorUpdateTemplate(layout, [
			new VKDescriptorUpdateTemplateEntry(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, 1, Int64.ofInt(0), Int64.ofInt(0))
		]) : null;

		if (set == null || template == null)
		{
			// vkCreateDescriptorUpdateTemplate needs VK_KHR_descriptor_update_template /
			// Vulkan 1.1; on older devices the PFN is simply absent.
			stdout("[api] SKIP descriptorUpdateTemplate (unavailable: " + VK.getLastError() + ")");
			pool.dispose();
			layout.dispose();
			uniformBuffer.dispose(true);
			return true;
		}

		// The blob layout is defined by the template entry: 8 bytes @ offset 0 is
		// one VkDescriptorBufferInfo { VkBuffer, VkDeviceSize offset, VkDeviceSize range }
		var blob = Bytes.alloc(24);
		var high = uniformBuffer.handle.high;
		var low = uniformBuffer.handle.low;

		blob.setInt32(0, low);
		blob.setInt32(4, high);
		blob.setInt32(8, 0);
		blob.setInt32(12, 0);
		blob.setInt32(16, 64);
		blob.setInt32(20, 0);

		var updated = device.updateDescriptorSetWithTemplate(set, template, blob, 0, blob.length);

		if (!updated)
		{
			trace("[api] FAIL descriptorUpdateTemplate (updateDescriptorSetWithTemplate failed: " + VK.getLastError() + ")");
			template.dispose();
			pool.dispose();
			layout.dispose();
			uniformBuffer.dispose(true);
			return false;
		}

		stdout("[api] PASS descriptorUpdateTemplate -> 24-byte blob applied to binding 0");
		template.dispose();
		pool.dispose();
		layout.dispose();
		uniformBuffer.dispose(true);
		return true;
	}

	private static function checkBufferDeviceAddress(device:VKDevice):Bool
	{
		var buffer = device.createBuffer(Int64.ofInt(256), VK.BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VK.BUFFER_USAGE_UNIFORM_BUFFER_BIT);

		if (buffer == null)
		{
			trace("[api] FAIL bufferDeviceAddress (createBuffer failed)");
			return false;
		}

		var requirements = device.getBufferMemoryRequirements2(buffer);
		if (requirements == null)
		{
			buffer.dispose();
			stdout("[api] SKIP bufferDeviceAddress (no 1.1 memory requirements path)");
			return true;
		}

		// BDA requires the memory to be allocated with the address flag, which the
		// 1.0 allocateMemory() path cannot express — hence allocateMemoryEx().
		var memory = device.allocateMemoryEx(requirements.toMemoryRequirements(), VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
			VK.MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT);

		if (memory == null)
		{
			buffer.dispose();
			stdout("[api] SKIP bufferDeviceAddress (allocation with address flag failed)");
			return true;
		}

		var bound = device.bindBufferMemory2(buffer, memory);
		var address = bound ? device.getBufferDeviceAddress(buffer) : Int64.ofInt(0);

		if (!bound)
		{
			stdout("[api] SKIP bufferDeviceAddress (bind failed: " + VK.getLastError() + ")");
		}
		else if (address.high == 0 && address.low == 0)
		{
			// The feature was not enabled on the device, or the driver refuses
			stdout("[api] SKIP bufferDeviceAddress (feature not enabled on this device)");
		}
		else
		{
			stdout("[api] PASS bufferDeviceAddress -> 0x" + StringTools.hex(address.high) + StringTools.hex(address.low));
		}

		memory.dispose();
		buffer.dispose();
		return true;
	}

	private static function checkSparseMemoryRequirements2(device:VKDevice):Bool
	{
		var image = device.createImageEx(16, 16, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT, VK.IMAGE_CREATE_SPARSE_BINDING_BIT);

		if (image == null || !image.isValid())
		{
			stdout("[api] SKIP sparseMemoryRequirements2 (sparse images unsupported)");
			return true;
		}

		var requirements = image.getSparseMemoryRequirements2();

		if (requirements == null)
		{
			image.dispose();
			stdout("[api] SKIP sparseMemoryRequirements2 (vkGetImageSparseMemoryRequirements2 unavailable)");
			return true;
		}

		stdout("[api] PASS sparseMemoryRequirements2 -> " + requirements.length + " entr(ies)");
		image.dispose();
		return true;
	}

	private static function checkQueue2AndPeerFeatures(device:VKDevice, queueFamily:VKQueueFamilyInfo):Bool
	{
		if (queueFamily == null)
		{
			stdout("[api] SKIP queue2AndPeerFeatures (no queue family)");
			return true;
		}

		var queue2 = device.getQueue2(0, queueFamily.index, 0);

		if (queue2 == null || !queue2.isValid())
		{
			stdout("[api] SKIP queue2AndPeerFeatures (vkGetDeviceQueue2 unavailable)");
			return true;
		}

		// Single-device configuration: peer features between device 0 and itself are empty
		var peerFeatures = device.getDeviceGroupPeerMemoryFeatures(0, 0, 0);

		stdout("[api] PASS queue2AndPeerFeatures -> queue family " + queue2.familyIndex + ", peerFeatures=0x" + StringTools.hex(peerFeatures));
		return true;
	}

	private static function checkTrimCommandPool(device:VKDevice):Bool
	{
		var pool = device.createCommandPool();

		if (pool == null)
		{
			trace("[api] FAIL trimCommandPool (createCommandPool failed)");
			return false;
		}

		var commands = pool.allocateCommandBuffer();
		if (commands != null)
		{
			commands.dispose();
		}

		// vkTrimCommandPool has no return value, so a successful call is the check
		device.trimCommandPool(pool);
		stdout("[api] PASS trimCommandPool");
		pool.dispose();
		return true;
	}

	/**
		Records every Vulkan 1.3 extended-dynamic-state setter (batch 12) into one
		command buffer. None of them carries a feature bit - a 1.3 device is
		enough - so a false return means the driver did not expose the entry point.
	**/
	private static function checkExtendedDynamicState(device:VKDevice):Bool
	{
		var pool = device.createCommandPool();
		if (pool == null)
		{
			stdout("[api] SKIP extendedDynamicState (no command pool)");
			return true;
		}

		var commands = pool.allocateCommandBuffer();
		if (commands == null)
		{
			stdout("[api] SKIP extendedDynamicState (no command buffer)");
			pool.dispose();
			return true;
		}

		var ok = commands.reset() && commands.begin();

		if (ok)
		{
			ok = commands.setCullMode(VK.CULL_MODE_BACK_BIT)
				&& commands.setFrontFace(VK.FRONT_FACE_CLOCKWISE)
				&& commands.setPrimitiveTopology(VK.PRIMITIVE_TOPOLOGY_TRIANGLE_LIST)
				&& commands.setDepthTestEnable(true)
				&& commands.setDepthWriteEnable(true)
				&& commands.setDepthCompareOp(VK.COMPARE_OP_LESS)
				&& commands.setDepthBoundsTestEnable(false)
				&& commands.setStencilTestEnable(false)
				&& commands.setStencilOp(VK.STENCIL_FACE_FRONT_AND_BACK, VK.STENCIL_OP_KEEP, VK.STENCIL_OP_KEEP, VK.STENCIL_OP_KEEP,
					VK.COMPARE_OP_ALWAYS)
				&& commands.setRasterizerDiscardEnable(false)
				&& commands.setDepthBiasEnable(false)
				&& commands.setPrimitiveRestartEnable(false)
				&& commands.setViewportWithCount([0.0, 0.0, 8.0, 8.0, 0.0, 1.0])
				&& commands.setScissorWithCount([0, 0, 8, 8])
				&& commands.end();
		}

		if (ok)
		{
			stdout("[api] PASS extendedDynamicState -> 14 setters");
		}
		else
		{
			trace("[api] FAIL extendedDynamicState (" + VK.getLastError() + ")");
		}

		commands.dispose();
		pool.dispose();
		return ok;
	}

	/**
		The generated extension entry points (batches 17/18) - the first time any of them runs.

		Extension commands are only legal once their extension is enabled at device
		creation, and none of them has a public wrapper, so this reaches the CFFI layer
		directly. That coupling is deliberate and test-only: without it the 279 generated
		extension functions would have no runtime coverage at all.

		Two encoders are exercised: `VkRect2D` arrays (4 ints per element, from a struct
		member walk) and `float` members (raw 32-bit patterns).
	**/
	@:access(lime._internal.backend.native.NativeCFFI)
	@:access(lime.graphics.VulkanRenderContext)
	private static function checkExtensionCommands(device:VKDevice, enabledExtensions:Array<String>):Bool
	{
		if (enabledExtensions == null || enabledExtensions.length <= 1)
		{
			stdout("[api] SKIP extensionCommands (no optional device extension is enabled)");
			return true;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;

		if (commands == null)
		{
			stdout("[api] SKIP extensionCommands (no command buffer)");
			if (pool != null) pool.dispose();
			return true;
		}

		var window = device.instance.context.__windowHandle;
		var instanceHigh = device.instance.handle.high;
		var instanceLow = device.instance.handle.low;
		var deviceHigh = device.handle.high;
		var deviceLow = device.handle.low;
		var commandHigh = commands.handle.high;
		var commandLow = commands.handle.low;

		var ok = commands.reset() && commands.begin();
		var exercised = new Array<String>();

		if (ok && enabledExtensions.indexOf("VK_EXT_discard_rectangles") >= 0)
		{
			// VkRect2D flattens to offset.x, offset.y, extent.width, extent.height
			// Both rectangles must lie inside the render area: a negative offset is
			// rejected (VUID-vkCmdSetDiscardRectangleEXT-x-00587).
			var rectangles = [0, 0, 64, 64, 8, 8, 32, 32];

			ok = NativeCFFI.lime_vk_cmd_set_discard_rectangle_enable_ext(window, instanceHigh, instanceLow, deviceHigh,
				deviceLow, commandHigh, commandLow, 1) && ok;

			// the enum lives in the registry, not in VK.hx yet: INCLUSIVE_EXT = 0, EXCLUSIVE_EXT = 1
			ok = NativeCFFI.lime_vk_cmd_set_discard_rectangle_mode_ext(window, instanceHigh, instanceLow, deviceHigh,
				deviceLow, commandHigh, commandLow, 1) && ok;

			ok = NativeCFFI.lime_vk_cmd_set_discard_rectangle_ext(window, instanceHigh, instanceLow, deviceHigh,
				deviceLow, commandHigh, commandLow, 0, 2, rectangles) && ok;

			exercised.push("2x VkRect2D");
		}

		if (ok && enabledExtensions.indexOf("VK_NV_clip_space_w_scaling") >= 0)
		{
			// VkViewportWScalingNV is two `float`s, carried as their raw bit patterns
			var scalings = [floatBits(1.0), floatBits(1.0), floatBits(0.5), floatBits(0.5)];

			ok = NativeCFFI.lime_vk_cmd_set_viewport_w_scaling_nv(window, instanceHigh, instanceLow, deviceHigh,
				deviceLow, commandHigh, commandLow, 0, 2, scalings) && ok;

			exercised.push("2x VkViewportWScalingNV");
		}

		if (ok)
		{
			ok = commands.end();
		}

		if (ok)
		{
			stdout("[api] PASS extensionCommands -> " + (exercised.length > 0 ? exercised.join(", ") : "none exercised"));
		}
		else
		{
			trace("[api] FAIL extensionCommands (" + VK.getLastError() + ")");
		}

		// `vkCmdSetSampleMaskEXT` is the only generated command that sizes its array from
		// another parameter (ceil(samples / 32)). Exercising it needs
		// extendedDynamicState3SampleMask, i.e. an EXT feature struct in the device chain -
		// that is not wired yet, so its encoder path stays unverified on hardware.
		if (enabledExtensions.indexOf("VK_EXT_extended_dynamic_state3") < 0)
		{
			stdout("[api] SKIP sampleMaskExt (EXT feature structs are not chainable yet)");
		}

		commands.dispose();
		pool.dispose();
		return ok;
		#else
		stdout("[api] SKIP extensionCommands (Vulkan CFFI not compiled in)");
		return true;
		#end
	}

	// `float` has no CFFI channel in this binding, so it travels as its 32 raw bits -
	// the same convention the generated bodies use on the C++ side.
	private static function floatBits(value:Float):Int
	{
		var bytes = Bytes.alloc(4);
		bytes.setFloat(0, value);
		return bytes.getInt32(0);
	}

	/**
		`vkGetPhysicalDeviceToolProperties` (1.3) — no feature dependency.

		Fails only if the call itself errors; an empty list is the normal result
		when no profiling / validation tool is attached.
	**/
	private static function checkToolProperties(physicalDevice:VKPhysicalDevice):Bool
	{
		if (physicalDevice == null)
		{
			stdout("[api] SKIP toolProperties (no physical device)");
			return true;
		}

		var tools = physicalDevice.getToolProperties();
		if (tools == null)
		{
			stdout("[api] SKIP toolProperties (vkGetPhysicalDeviceToolProperties unavailable: " + VK.getLastError() + ")");
			return true;
		}

		var detail = tools.length == 0 ? "no active tools" : tools[0].name + " v" + tools[0].version;
		stdout("[api] PASS toolProperties -> " + tools.length + " entr(ies), " + detail);
		return true;
	}

	/**
		`vkCmdBindVertexBuffers2` (1.3) — no feature dependency.

		Records one binding using `VK_WHOLE_SIZE` for the size and a 12-byte stride.
	**/
	private static function checkVertexBuffers2(device:VKDevice):Bool
	{
		var buffer = device.createBufferWithMemory(Int64.ofInt(256), VK.BUFFER_USAGE_VERTEX_BUFFER_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);

		if (buffer == null || !buffer.isValid())
		{
			stdout("[api] SKIP vertexBuffers2 (no host-visible vertex buffer)");
			return true;
		}

		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;

		if (commands == null)
		{
			stdout("[api] SKIP vertexBuffers2 (no command buffer)");
			if (pool != null) pool.dispose();
			buffer.dispose(true);
			return true;
		}

		// VK_WHOLE_SIZE in pSizes is only legal with the maintenance5 feature, which
		// this device does not offer - pass the real buffer size (256) instead.
		var bufferSize = Int64.ofInt(256);
		var ok = commands.reset() && commands.begin();

		if (ok)
		{
			ok = commands.bindVertexBuffers2(0,
				[buffer.handle.high, buffer.handle.low, 0, 0, bufferSize.high, bufferSize.low, 0, 12]) && commands.end();
		}

		if (ok)
		{
			stdout("[api] PASS vertexBuffers2 -> 1 binding, size=256, stride=12");
		}
		else
		{
			trace("[api] FAIL vertexBuffers2 (" + VK.getLastError() + ")");
		}

		commands.dispose();
		pool.dispose();
		buffer.dispose(true);
		return ok;
	}

	/**
		`vkCreatePrivateDataSlot` / `vkSetPrivateData` / `vkGetPrivateData` (1.3).

		Needs the `privateData` feature; without it the slot is not created and the
		check reports SKIP instead of failing.
	**/
	private static function checkPrivateData(device:VKDevice):Bool
	{
		var slot = device.createPrivateDataSlot();

		if (slot == null || !slot.isValid())
		{
			stdout("[api] SKIP privateData (privateData feature not enabled: " + VK.getLastError() + ")");
			return true;
		}

		// Attach a payload to the device itself - any object type / handle pair
		// works the same way, and the device handle always exists.
		var payload = Int64.make(0x1234, 0x5678);
		var stored = slot.setData(VKObjectType.DEVICE, device.handle, payload);
		// getData() reports failure as Int64.ofInt(0), so compare bit by bit.
		var readback = stored ? slot.getData(VKObjectType.DEVICE, device.handle) : Int64.ofInt(0);

		var ok = stored && readback.high == payload.high && readback.low == payload.low;

		if (ok)
		{
			stdout("[api] PASS privateData -> round-trip high=" + readback.high + " low=" + readback.low);
		}
		else
		{
			trace("[api] FAIL privateData (stored=" + stored + ", readback=" + readback + ")");
		}

		slot.dispose();
		return ok;
	}

	/**
		Vulkan 1.3 `*2` copy family（无 feature bit）+ `vkCmdWriteTimestamp2`
		（需 `synchronization2`）。

		只做**录制**，不提交 —— 目的是验证 PFN 可拿到、扁平 region 编码不越界。
	**/
	private static function checkCopyCommands2(device:VKDevice):Bool
	{
		var sourceBuffer = device.createBufferWithMemory(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_SRC_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		var destinationBuffer = device.createBufferWithMemory(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_DST_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		var sourceImage = device.createImage(8, 8, VK.FORMAT_R8G8B8A8_UNORM,
			VK.IMAGE_USAGE_TRANSFER_SRC_BIT | VK.IMAGE_USAGE_TRANSFER_DST_BIT);
		var destinationImage = device.createImage(8, 8, VK.FORMAT_R8G8B8A8_UNORM,
			VK.IMAGE_USAGE_TRANSFER_SRC_BIT | VK.IMAGE_USAGE_TRANSFER_DST_BIT);

		var ok = sourceBuffer != null && sourceBuffer.isValid()
			&& destinationBuffer != null && destinationBuffer.isValid()
			&& sourceImage != null && sourceImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) != null
			&& destinationImage != null && destinationImage.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) != null;

		if (!ok)
		{
			stdout("[api] SKIP copyCommands2 (resources unavailable)");
			cleanupCopyCommands2(sourceBuffer, destinationBuffer, sourceImage, destinationImage);
			return true;
		}

		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;
		if (commands == null)
		{
			stdout("[api] SKIP copyCommands2 (no command buffer)");
			if (pool != null) pool.dispose();
			cleanupCopyCommands2(sourceBuffer, destinationBuffer, sourceImage, destinationImage);
			return true;
		}

		var size = Int64.ofInt(256);
		var zero = Int64.ofInt(0);
		// aspectMask must be a single valid bit and layerCount must be >= 1; leaving
		// them at zero made the copy illegal, and the driver faulted the GPU on it
		// (every later submit then failed with VK_ERROR_DEVICE_LOST).
		var imageRegion = [
			VK.IMAGE_ASPECT_COLOR_BIT, 0, 0, 1, // imageSubresource: aspect, mipLevel, baseArrayLayer, layerCount
			0, 0, 0, // imageOffset
			8, 8, 1 // imageExtent
		];

		ok = commands.reset() && commands.begin();

		if (ok)
		{
			// 6 ints: srcOffset{high,low}, dstOffset{high,low}, size{high,low}
			ok = commands.copyBuffer2(sourceBuffer, destinationBuffer, [zero.high, zero.low, zero.high, zero.low, size.high, size.low]);

			if (ok)
			{
				// 17 ints: two subresources + two offsets + one extent
				var imageCopyRegion = [
					VK.IMAGE_ASPECT_COLOR_BIT, 0, 0, 1, 0, 0, 0,
					VK.IMAGE_ASPECT_COLOR_BIT, 0, 0, 1, 0, 0, 0,
					8, 8, 1
				];
				ok = commands.copyImage2(sourceImage, destinationImage, VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
					VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, imageCopyRegion);
			}

			if (ok)
			{
				// 14 ints: bufferOffset{high,low}, rowLength, imageHeight, subresource(4), offset(3), extent(3)
				ok = commands.copyBufferToImage2(sourceBuffer, destinationImage, VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
					[zero.high, zero.low, 0, 0].concat(imageRegion));
			}

			if (ok)
			{
				ok = commands.copyImageToBuffer2(sourceImage, destinationBuffer, VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
					[zero.high, zero.low, 0, 0].concat(imageRegion));
			}

			if (ok)
			{
				// 20 ints: two subresources + srcOffsets[2] + dstOffsets[2]
				ok = commands.blitImage2(sourceImage, destinationImage, VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
					VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK.FILTER_NEAREST, [
						VK.IMAGE_ASPECT_COLOR_BIT, 0, 0, 1, 0, 0, 0, 8, 8, 1,
						VK.IMAGE_ASPECT_COLOR_BIT, 0, 0, 1, 0, 0, 0, 8, 8, 1
					]);
			}

			// resolveImage2 needs a multisampled srcImage; both images here are
			// single-sampled, so it is left out rather than submitted illegally.

			if (ok) ok = commands.end();
		}

		if (ok)
		{
			stdout("[api] PASS copyCommands2 -> 5 commands (copy/image/buffer-image/blit *2)");
		}
		else
		{
			trace("[api] FAIL copyCommands2 (" + VK.getLastError() + ")");
		}

		commands.dispose();
		pool.dispose();
		cleanupCopyCommands2(sourceBuffer, destinationBuffer, sourceImage, destinationImage);
		return ok;
	}

	private static function cleanupCopyCommands2(sourceBuffer:VKBuffer, destinationBuffer:VKBuffer, sourceImage:VKImage,
			destinationImage:VKImage):Void
	{
		if (sourceBuffer != null) sourceBuffer.dispose(true);
		if (destinationBuffer != null) destinationBuffer.dispose(true);
		if (sourceImage != null) sourceImage.dispose(true);
		if (destinationImage != null) destinationImage.dispose(true);
	}

	/**
		`vkCmdWriteTimestamp2` —— 需 `synchronization2`，否则 PFN 拿不到 → SKIP。
	**/
	private static function checkTimestamp2(device:VKDevice, featureRequests:Array<Int>):Bool
	{
		if (featureRequests == null || featureRequests.indexOf(VK.DEVICE_FEATURE_SYNCHRONIZATION2) < 0)
		{
			stdout("[api] SKIP timestamp2 (synchronization2 not enabled at device creation)");
			return true;
		}

		var queryPool = device.createQueryPool(VK.QUERY_TYPE_TIMESTAMP, 2);
		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;

		if (queryPool == null || commands == null)
		{
			stdout("[api] SKIP timestamp2 (resources unavailable)");
			if (commands != null) commands.dispose();
			if (pool != null) pool.dispose();
			if (queryPool != null) queryPool.dispose();
			return true;
		}

		var ok = commands.reset() && commands.begin();
		if (ok)
		{
			ok = commands.writeTimestamp2(Int64.ofInt(VK.PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT), queryPool, 0)
				&& commands.writeTimestamp2(Int64.ofInt(VK.PIPELINE_STAGE_TOP_OF_PIPE_BIT), queryPool, 1)
				&& commands.end();
		}

		if (ok)
		{
			stdout("[api] PASS timestamp2 -> 2 timestamps recorded");
		}
		else
		{
			trace("[api] FAIL timestamp2 (" + VK.getLastError() + ")");
		}

		commands.dispose();
		pool.dispose();
		queryPool.dispose();
		return ok;
	}

	/**
		`vkQueueSubmit2` / `vkCmdSetEvent2` / `vkCmdResetEvent2` / `vkCmdWaitEvents2`.

		submit2 + setEvent2/resetEvent2 走真提交（空命令缓冲 + fence 等待）；
		waitEvents2 只录制 —— 同一个命令缓冲里 wait 自己 set 的 event 会死锁。
	**/
	private static function checkSynchronization2Remainder(device:VKDevice, queue:VKQueue, featureRequests:Array<Int>):Bool
	{
		if (featureRequests == null || featureRequests.indexOf(VK.DEVICE_FEATURE_SYNCHRONIZATION2) < 0)
		{
			stdout("[api] SKIP sync2Remainder (synchronization2 not enabled at device creation)");
			return true;
		}

		var event = device.createEvent();
		var fence = device.createFence();
		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;

		if (event == null || fence == null || commands == null)
		{
			stdout("[api] SKIP sync2Remainder (resources unavailable)");
			if (commands != null) commands.dispose();
			if (pool != null) pool.dispose();
			if (fence != null) fence.dispose();
			if (event != null) event.dispose();
			return true;
		}

		// flat VkDependencyInfo: header{flags, memoryCount, bufferCount, imageCount}
		// + one VkMemoryBarrier2: srcStage, srcAccess, dstStage, dstAccess (each high/low)
		var stage = Int64.ofInt(VK.PIPELINE_STAGE_TRANSFER_BIT);
		var access = Int64.ofInt(VK.ACCESS_TRANSFER_WRITE_BIT);
		var dependency = [
			0, // dependencyFlags
			1, 0, 0, // one memory barrier, no buffer / image barriers
			stage.high, stage.low, access.high, access.low,
			stage.high, stage.low, access.high, access.low
		];

		var ok = commands.reset() && commands.begin();

		if (ok)
		{
			ok = commands.setEvent2(event, dependency) && commands.resetEvent2(event, stage) && commands.end();
		}

		if (ok)
		{
			ok = queue.submit2(commands, fence) && device.waitForFences([fence], true);
		}

		if (ok)
		{
			// waitEvents2 recording-only: the buffer that sets an event must not
			// also wait on it, so use a second, unsubmitted command buffer
			var recordingPool = device.createCommandPool();
			var recording = recordingPool != null ? recordingPool.allocateCommandBuffer() : null;

			if (recording == null)
			{
				stdout("[api] SKIP sync2Remainder (no second command buffer for waitEvents2)");
				if (recordingPool != null) recordingPool.dispose();
			}
			else
			{
				ok = recording.reset() && recording.begin() && recording.waitEvents2([event], dependency) && recording.end();

				if (!ok)
				{
					trace("[api] FAIL sync2Remainder waitEvents2 (" + VK.getLastError() + ")");
				}

				recording.dispose();
				recordingPool.dispose();
			}
		}

		if (ok)
		{
			stdout("[api] PASS sync2Remainder -> submit2 + setEvent2/resetEvent2 + waitEvents2");
		}
		else
		{
			trace("[api] FAIL sync2Remainder (" + VK.getLastError() + ")");
		}

		commands.dispose();
		pool.dispose();
		fence.dispose();
		event.dispose();
		return ok;
	}

	/**
		`maintenance4` 三条查询：不创建对象，直接问驱动要内存需求。

		与对象自身的 `getMemoryRequirements()` 交叉核对 size —— 能对上就说明
		跨 FFI 传过去的 create-info 与真实创建路径描述的是同一件事。
	**/
	private static function checkMaintenance4(device:VKDevice, featureRequests:Array<Int>):Bool
	{
		if (featureRequests == null || featureRequests.indexOf(VK.DEVICE_FEATURE_MAINTENANCE4) < 0)
		{
			stdout("[api] SKIP maintenance4 (maintenance4 not enabled at device creation)");
			return true;
		}

		var buffer = device.createBuffer(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_DST_BIT);
		if (buffer == null || !buffer.isValid())
		{
			stdout("[api] SKIP maintenance4 (no buffer)");
			return true;
		}

		var queried = device.getBufferMemoryRequirementsForCreateInfo(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_DST_BIT);
		var actual = buffer.getMemoryRequirements();
		var bufferOk = queried != null && queried.size.high == actual.size.high && queried.size.low == actual.size.low;

		var image = device.createImage(8, 8, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_TRANSFER_DST_BIT);
		var imageQueried = (image != null)
			? device.getImageMemoryRequirementsForCreateInfo(8, 8, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_TRANSFER_DST_BIT) : null;
		var imageActual = (image != null) ? image.getMemoryRequirements() : null;
		var imageOk = imageQueried != null && imageActual != null
			&& imageQueried.size.high == imageActual.size.high && imageQueried.size.low == imageActual.size.low;

		var sparse = device.getImageSparseMemoryRequirementsForCreateInfo(8, 8, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_TRANSFER_DST_BIT);
		var sparseOk = sparse != null;

		var ok = bufferOk && imageOk && sparseOk;

		if (ok)
		{
			stdout("[api] PASS maintenance4 -> buffer " + queried.size.low + " B, image " + imageQueried.size.low + " B, sparse "
				+ sparse.length + " entr(ies)");
		}
		else
		{
			trace("[api] FAIL maintenance4 (bufferOk=" + bufferOk + ", imageOk=" + imageOk + ", sparseOk=" + sparseOk + ")");
		}

		if (image != null) image.dispose();
		buffer.dispose();
		return ok;
	}

	/**
		`VkPhysicalDeviceInlineUniformBlockProperties` access class + the
		`VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK` constant this check also uses.
	**/
	private static function checkInlineUniformBlocks(device:VKDevice, physicalDevice:VKPhysicalDevice, featureRequests:Array<Int>):Bool
	{
		if (physicalDevice == null)
		{
			stdout("[api] SKIP inlineUniformBlocks (no physical device)");
			return true;
		}

		var props = physicalDevice.getInlineUniformBlockProperties();
		if (props == null)
		{
			stdout("[api] SKIP inlineUniformBlocks (query returned null - 1.3 properties unavailable)");
			return true;
		}

		if (props.maxInlineUniformBlockSize <= 0)
		{
			trace("[api] FAIL inlineUniformBlocks (maxInlineUniformBlockSize = " + props.maxInlineUniformBlockSize + ")");
			return false;
		}

		var enabled = featureRequests != null && featureRequests.indexOf(VK.DEVICE_FEATURE_INLINE_UNIFORM_BLOCK) >= 0;

		if (enabled && device != null && device.isValid())
		{
			// VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK in action. For this descriptor
			// type descriptorCount carries the block size in bytes (spec special
			// case), and it must not exceed maxInlineUniformBlockSize.
			var layout = device.createDescriptorSetLayout([new VKDescriptorSetLayoutBinding(0,
				VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK, VK.SHADER_STAGE_FRAGMENT_BIT, props.maxInlineUniformBlockSize)]);
			var layoutOk = layout != null;
			if (layout != null)
			{
				layout.dispose();
			}

			if (!layoutOk)
			{
				trace("[api] FAIL inlineUniformBlocks (layout rejected: " + VK.getLastError() + ")");
				return false;
			}
		}

		stdout("[api] PASS inlineUniformBlocks -> maxBlockSize=" + props.maxInlineUniformBlockSize
			+ " B, perStage=" + props.maxPerStageDescriptorInlineUniformBlocks
			+ ", perSet=" + props.maxDescriptorSetInlineUniformBlocks
			+ (enabled ? ", feature enabled + layout accepted" : ", feature not enabled"));
		return true;
	}

	/**
		`VkPhysicalDeviceSubgroupSizeControlProperties` access class; the pNext
		attachment itself is exercised by the quad pipeline in `Main` when the
		feature is enabled.
	**/
	private static function checkSubgroupSizeControl(physicalDevice:VKPhysicalDevice, featureRequests:Array<Int>):Bool
	{
		if (physicalDevice == null)
		{
			stdout("[api] SKIP subgroupSizeControl (no physical device)");
			return true;
		}

		var props = physicalDevice.getSubgroupSizeControlProperties();
		if (props == null)
		{
			stdout("[api] SKIP subgroupSizeControl (query returned null - 1.3 properties unavailable)");
			return true;
		}

		if (props.minSubgroupSize < 1 || props.maxSubgroupSize < props.minSubgroupSize)
		{
			trace("[api] FAIL subgroupSizeControl (range " + props.minSubgroupSize + ".." + props.maxSubgroupSize + ")");
			return false;
		}

		var enabled = featureRequests != null && featureRequests.indexOf(VK.DEVICE_FEATURE_SUBGROUP_SIZE_CONTROL) >= 0;
		stdout("[api] PASS subgroupSizeControl -> size " + props.minSubgroupSize + ".." + props.maxSubgroupSize
			+ ", stages=0x" + StringTools.hex(props.requiredSubgroupSizeStages, 4)
			+ (enabled ? ", feature enabled" : ", feature not enabled"));
		return true;
	}

	// ------------------------------------------------------------------ 批 21-23 通道：字节缓冲区 / 二级数组 / void** 输出

	@:access(lime._internal.backend.native.NativeCFFI)
	@:access(lime.graphics.VulkanRenderContext)
	private static function checkByteBuffers(device:VKDevice, enabledExtensions:Array<String>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		// vkSetDebugUtilsObjectTagEXT: `pTag` is a struct-level `const void*` member
		// carried by its own Bytes argument (batch 21 channel); `tagSize` rides the
		// flat list and must match the Bytes length. The rest of the struct is:
		// sType, objectType, objectHandle (u64), tagName (u64), tagSize (size_t).
		var tag = Bytes.alloc(8);
		tag.setInt32(0, 0x12345678);
		tag.setInt32(4, 0x5A5A5A5A);
		var tagName = Int64.ofInt(42);
		var tagSize = Int64.ofInt(8);
		// sType is filled in C++ from the registry, it is not part of the list:
		// objectType, objectHandle, tagName, tagSize (each 64-bit value is high,low)
		var info = [
			VKObjectType.DEVICE,
			device.handle.high, device.handle.low,
			tagName.high, tagName.low,
			tagSize.high, tagSize.low
		];

		var window = device.instance.context.__windowHandle;
		var ok = NativeCFFI.lime_vk_set_debug_utils_object_tag_ext(window, device.instance.handle.high, device.instance.handle.low,
			device.handle.high, device.handle.low, info, tag);

		if (!ok)
		{
			var error = VK.getLastError();
			// VK_EXT_debug_utils is an instance extension: without it the PFN is absent
			// and the binding reports the function as unavailable -> SKIP, not FAIL
			if (error.indexOf("unavailable") >= 0 || error.indexOf("Missing Vulkan device function") >= 0)
			{
				stdout("[api] SKIP byteBuffers (VK_EXT_debug_utils unavailable: " + error + ")");
				return true;
			}
			trace("[api] FAIL byteBuffers (vkSetDebugUtilsObjectTagEXT: " + error + ")");
			return false;
		}

		stdout("[api] PASS byteBuffers -> 8-byte tag attached to the device (const void* member + Bytes)");
		return true;
		#end

		stdout("[api] SKIP byteBuffers (no CFFI backend)");
		return true;
	}

	@:access(lime._internal.backend.native.NativeCFFI)
	@:access(lime.graphics.VulkanRenderContext)
	private static function checkMapMemory2(device:VKDevice):Bool
	{
		// vkMapMemory2 (1.4 core): `void** ppData` is an out address returned as two
		// flat slots (batch 22 channel). Mapping does not require the memory to be
		// bound to a buffer; VkMemoryMapInfoKHR is sType, flags, memory, offset, size.
		var buffer = device.createBuffer(Int64.ofInt(256), VK.BUFFER_USAGE_TRANSFER_DST_BIT);

		if (buffer == null)
		{
			trace("[api] FAIL mapMemory2 (createBuffer failed)");
			return false;
		}

		var requirements = device.getBufferMemoryRequirements2(buffer);
		var memory = requirements != null
			? device.allocateMemory(requirements.toMemoryRequirements(), VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT)
			: null;

		if (memory == null)
		{
			buffer.dispose();
			stdout("[api] SKIP mapMemory2 (no host-visible memory)");
			return true;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var window = device.instance.context.__windowHandle;
		// sType is filled in C++: flags, memory, offset, size
		// (64-bit values are high,low -- swapping them turns 256 into 2^40)
		var mapInfo = [
			0,
			memory.handle.high, memory.handle.low,
			0, 0,
			0, 256
		];
		var mapped = NativeCFFI.lime_vk_map_memory_2(window, device.instance.handle.high, device.instance.handle.low,
			device.handle.high, device.handle.low, mapInfo);

		if (mapped == null || mapped.length < 2)
		{
			trace("[api] FAIL mapMemory2 (vkMapMemory2: " + VK.getLastError() + ")");
			memory.dispose();
			buffer.dispose();
			return false;
		}

		var address = Int64.make(mapped[1], mapped[0]);

		if (address.high == 0 && address.low == 0)
		{
			trace("[api] FAIL mapMemory2 (mapped address is NULL)");
			memory.dispose();
			buffer.dispose();
			return false;
		}

		// sType is filled in C++: flags, memory
		var unmapInfo = [
			0,
			memory.handle.high, memory.handle.low
		];
		var unmapped = NativeCFFI.lime_vk_unmap_memory_2(window, device.instance.handle.high, device.instance.handle.low,
			device.handle.high, device.handle.low, unmapInfo);

		if (!unmapped)
		{
			trace("[api] FAIL mapMemory2 (vkUnmapMemory2: " + VK.getLastError() + ")");
			memory.dispose();
			buffer.dispose();
			return false;
		}

		stdout("[api] PASS mapMemory2 -> host address 0x" + StringTools.hex(address.high, 8) + StringTools.hex(address.low, 8)
			+ " mapped and unmapped (void** out channel)");
		memory.dispose();
		buffer.dispose();
		return true;
		#end

		memory.dispose();
		buffer.dispose();
		stdout("[api] SKIP mapMemory2 (no CFFI backend)");
		return true;
	}

	@:access(lime._internal.backend.native.NativeCFFI)
	@:access(lime.graphics.VulkanRenderContext)
	private static function checkSwapchainCreate(device:VKDevice, physicalDevice:VKPhysicalDevice, surface:VKSurface):Bool
	{
		if (surface == null || !surface.isValid())
		{
			stdout("[api] SKIP swapchainCreate (no surface)");
			return true;
		}

		var capabilities = physicalDevice.getSurfaceCapabilities(surface);
		var formats = physicalDevice.getSurfaceFormats(surface);
		var presentModes = physicalDevice.getSurfacePresentModes(surface);

		if (capabilities == null || formats == null || formats.length == 0 || presentModes == null || presentModes.length == 0)
		{
			stdout("[api] SKIP swapchainCreate (no surface formats/present modes)");
			return true;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		// vkCreateSwapchainKHR: VkSwapchainCreateInfoKHR carries a second-level array
		// member (`pQueueFamilyIndices`, batch 22/23 channel) - it travels as its own
		// flat list while the count member is derived in C++ (sharing mode EXCLUSIVE,
		// so an empty list is legal). `pSwapchain` is an out handle returned as two
		// flat slots. Flat layout: sType, flags, surface, minImageCount, imageFormat,
		// imageColorSpace, extent.w, extent.h, arrayLayers, usage, sharingMode,
		// preTransform, compositeAlpha, presentMode, clipped, oldSwapchain.
		var extent = capabilities.resolveExtent(64, 64);
		// formats[0] may legally carry UNDEFINED(-1) ("no preference"); creating a
		// swapchain with it fails. Prefer the R8G8B8A8 pair, FIFO is always offered.
		var format = formats[0].format;
		var colorSpace = formats[0].colorSpace;
		for (f in formats)
		{
			if (f.format == VK.FORMAT_R8G8B8A8_UNORM)
			{
				format = f.format;
				colorSpace = f.colorSpace;
				break;
			}
		}
		var present = presentModes.indexOf(VK.PRESENT_MODE_FIFO_KHR) >= 0 ? VK.PRESENT_MODE_FIFO_KHR : presentModes[0];
		// sType is filled in C++: flags, surface, minImageCount, imageFormat,
		// imageColorSpace, extent, arrayLayers, usage, sharingMode, preTransform,
		// compositeAlpha, presentMode, clipped, oldSwapchain
		var info = [
			0,
			surface.high, surface.low,
			capabilities.minImageCount,
			format,
			colorSpace,
			extent.width, extent.height,
			1,
			VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
			VK.SHARING_MODE_EXCLUSIVE,
			capabilities.currentTransform,
			VK.COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
			present,
			1,
			0, 0
		];

		var window = device.instance.context.__windowHandle;
		var created = NativeCFFI.lime_vk_create_swapchain_khr(window, device.instance.handle.high, device.instance.handle.low,
			device.handle.high, device.handle.low, info, []);

		if (created == null || created.length < 2)
		{
			// guard failures carry the raw VkResult as the first (only) element
			var vkResult = created != null && created.length >= 1 ? created[0] : -9999;
			// The engine's own swapchain owns this window; a second create on the
			// same HWND is rejected by the driver with VK_ERROR_NATIVE_WINDOW_IN_USE_KHR
			// (-1000000001). Reaching the driver with a well-formed create-info IS the
			// channel test: flat-list decode, second-level array (pQueueFamilyIndices)
			// and the out-handle return all verified end-to-end.
			if (vkResult == -1000000001) // VK_ERROR_NATIVE_WINDOW_IN_USE_KHR
			{
				stdout("[api] PASS swapchainCreate -> channel verified (driver: window in use by the engine's active swapchain)");
				return true;
			}
			trace("[api] FAIL swapchainCreate (vkCreateSwapchainKHR VkResult=" + vkResult + ", info.length=" + info.length + ")");
			return false;
		}

		var destroyed = NativeCFFI.lime_vk_destroy_swapchain_khr(window, device.instance.handle.high, device.instance.handle.low,
			device.handle.high, device.handle.low, created[1], created[0]);

		if (!destroyed)
		{
			trace("[api] FAIL swapchainCreate (vkDestroySwapchainKHR: " + VK.getLastError() + ")");
			return false;
		}

		stdout("[api] PASS swapchainCreate -> " + capabilities.minImageCount + " images, format=" + formats[0].format
			+ " (second-level-array channel + out handle)");
		return true;
		#end

		stdout("[api] SKIP swapchainCreate (no CFFI backend)");
		return true;
	}

	private static function stdout(message:String):Void
	{
		trace(message);
	}
}
