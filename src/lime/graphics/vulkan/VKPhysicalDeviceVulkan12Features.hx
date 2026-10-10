package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceVulkan12Features` — 47 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceVulkan12Features
{
	public var samplerMirrorClampToEdge(default, null):Bool;
	public var drawIndirectCount(default, null):Bool;
	public var storageBuffer8BitAccess(default, null):Bool;
	public var uniformAndStorageBuffer8BitAccess(default, null):Bool;
	public var storagePushConstant8(default, null):Bool;
	public var shaderBufferInt64Atomics(default, null):Bool;
	public var shaderSharedInt64Atomics(default, null):Bool;
	public var shaderFloat16(default, null):Bool;
	public var shaderInt8(default, null):Bool;
	public var descriptorIndexing(default, null):Bool;
	public var shaderInputAttachmentArrayDynamicIndexing(default, null):Bool;
	public var shaderUniformTexelBufferArrayDynamicIndexing(default, null):Bool;
	public var shaderStorageTexelBufferArrayDynamicIndexing(default, null):Bool;
	public var shaderUniformBufferArrayNonUniformIndexing(default, null):Bool;
	public var shaderSampledImageArrayNonUniformIndexing(default, null):Bool;
	public var shaderStorageBufferArrayNonUniformIndexing(default, null):Bool;
	public var shaderStorageImageArrayNonUniformIndexing(default, null):Bool;
	public var shaderInputAttachmentArrayNonUniformIndexing(default, null):Bool;
	public var shaderUniformTexelBufferArrayNonUniformIndexing(default, null):Bool;
	public var shaderStorageTexelBufferArrayNonUniformIndexing(default, null):Bool;
	public var descriptorBindingUniformBufferUpdateAfterBind(default, null):Bool;
	public var descriptorBindingSampledImageUpdateAfterBind(default, null):Bool;
	public var descriptorBindingStorageImageUpdateAfterBind(default, null):Bool;
	public var descriptorBindingStorageBufferUpdateAfterBind(default, null):Bool;
	public var descriptorBindingUniformTexelBufferUpdateAfterBind(default, null):Bool;
	public var descriptorBindingStorageTexelBufferUpdateAfterBind(default, null):Bool;
	public var descriptorBindingUpdateUnusedWhilePending(default, null):Bool;
	public var descriptorBindingPartiallyBound(default, null):Bool;
	public var descriptorBindingVariableDescriptorCount(default, null):Bool;
	public var runtimeDescriptorArray(default, null):Bool;
	public var samplerFilterMinmax(default, null):Bool;
	public var scalarBlockLayout(default, null):Bool;
	public var imagelessFramebuffer(default, null):Bool;
	public var uniformBufferStandardLayout(default, null):Bool;
	public var shaderSubgroupExtendedTypes(default, null):Bool;
	public var separateDepthStencilLayouts(default, null):Bool;
	public var hostQueryReset(default, null):Bool;
	public var timelineSemaphore(default, null):Bool;
	public var bufferDeviceAddress(default, null):Bool;
	public var bufferDeviceAddressCaptureReplay(default, null):Bool;
	public var bufferDeviceAddressMultiDevice(default, null):Bool;
	public var vulkanMemoryModel(default, null):Bool;
	public var vulkanMemoryModelDeviceScope(default, null):Bool;
	public var vulkanMemoryModelAvailabilityVisibilityChains(default, null):Bool;
	public var shaderOutputViewportIndex(default, null):Bool;
	public var shaderOutputLayer(default, null):Bool;
	public var subgroupBroadcastDynamicId(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceVulkan12Features
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceVulkan12Features = new VKPhysicalDeviceVulkan12Features();
		vKPhysicalDeviceVulkan12Features.samplerMirrorClampToEdge = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceVulkan12Features.drawIndirectCount = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceVulkan12Features.storageBuffer8BitAccess = VKFeatureWords.flag (words, 2);
		vKPhysicalDeviceVulkan12Features.uniformAndStorageBuffer8BitAccess = VKFeatureWords.flag (words, 3);
		vKPhysicalDeviceVulkan12Features.storagePushConstant8 = VKFeatureWords.flag (words, 4);
		vKPhysicalDeviceVulkan12Features.shaderBufferInt64Atomics = VKFeatureWords.flag (words, 5);
		vKPhysicalDeviceVulkan12Features.shaderSharedInt64Atomics = VKFeatureWords.flag (words, 6);
		vKPhysicalDeviceVulkan12Features.shaderFloat16 = VKFeatureWords.flag (words, 7);
		vKPhysicalDeviceVulkan12Features.shaderInt8 = VKFeatureWords.flag (words, 8);
		vKPhysicalDeviceVulkan12Features.descriptorIndexing = VKFeatureWords.flag (words, 9);
		vKPhysicalDeviceVulkan12Features.shaderInputAttachmentArrayDynamicIndexing = VKFeatureWords.flag (words, 10);
		vKPhysicalDeviceVulkan12Features.shaderUniformTexelBufferArrayDynamicIndexing = VKFeatureWords.flag (words, 11);
		vKPhysicalDeviceVulkan12Features.shaderStorageTexelBufferArrayDynamicIndexing = VKFeatureWords.flag (words, 12);
		vKPhysicalDeviceVulkan12Features.shaderUniformBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 13);
		vKPhysicalDeviceVulkan12Features.shaderSampledImageArrayNonUniformIndexing = VKFeatureWords.flag (words, 14);
		vKPhysicalDeviceVulkan12Features.shaderStorageBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 15);
		vKPhysicalDeviceVulkan12Features.shaderStorageImageArrayNonUniformIndexing = VKFeatureWords.flag (words, 16);
		vKPhysicalDeviceVulkan12Features.shaderInputAttachmentArrayNonUniformIndexing = VKFeatureWords.flag (words, 17);
		vKPhysicalDeviceVulkan12Features.shaderUniformTexelBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 18);
		vKPhysicalDeviceVulkan12Features.shaderStorageTexelBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 19);
		vKPhysicalDeviceVulkan12Features.descriptorBindingUniformBufferUpdateAfterBind = VKFeatureWords.flag (words, 20);
		vKPhysicalDeviceVulkan12Features.descriptorBindingSampledImageUpdateAfterBind = VKFeatureWords.flag (words, 21);
		vKPhysicalDeviceVulkan12Features.descriptorBindingStorageImageUpdateAfterBind = VKFeatureWords.flag (words, 22);
		vKPhysicalDeviceVulkan12Features.descriptorBindingStorageBufferUpdateAfterBind = VKFeatureWords.flag (words, 23);
		vKPhysicalDeviceVulkan12Features.descriptorBindingUniformTexelBufferUpdateAfterBind = VKFeatureWords.flag (words, 24);
		vKPhysicalDeviceVulkan12Features.descriptorBindingStorageTexelBufferUpdateAfterBind = VKFeatureWords.flag (words, 25);
		vKPhysicalDeviceVulkan12Features.descriptorBindingUpdateUnusedWhilePending = VKFeatureWords.flag (words, 26);
		vKPhysicalDeviceVulkan12Features.descriptorBindingPartiallyBound = VKFeatureWords.flag (words, 27);
		vKPhysicalDeviceVulkan12Features.descriptorBindingVariableDescriptorCount = VKFeatureWords.flag (words, 28);
		vKPhysicalDeviceVulkan12Features.runtimeDescriptorArray = VKFeatureWords.flag (words, 29);
		vKPhysicalDeviceVulkan12Features.samplerFilterMinmax = VKFeatureWords.flag (words, 30);
		vKPhysicalDeviceVulkan12Features.scalarBlockLayout = VKFeatureWords.flag (words, 31);
		vKPhysicalDeviceVulkan12Features.imagelessFramebuffer = VKFeatureWords.flag (words, 32);
		vKPhysicalDeviceVulkan12Features.uniformBufferStandardLayout = VKFeatureWords.flag (words, 33);
		vKPhysicalDeviceVulkan12Features.shaderSubgroupExtendedTypes = VKFeatureWords.flag (words, 34);
		vKPhysicalDeviceVulkan12Features.separateDepthStencilLayouts = VKFeatureWords.flag (words, 35);
		vKPhysicalDeviceVulkan12Features.hostQueryReset = VKFeatureWords.flag (words, 36);
		vKPhysicalDeviceVulkan12Features.timelineSemaphore = VKFeatureWords.flag (words, 37);
		vKPhysicalDeviceVulkan12Features.bufferDeviceAddress = VKFeatureWords.flag (words, 38);
		vKPhysicalDeviceVulkan12Features.bufferDeviceAddressCaptureReplay = VKFeatureWords.flag (words, 39);
		vKPhysicalDeviceVulkan12Features.bufferDeviceAddressMultiDevice = VKFeatureWords.flag (words, 40);
		vKPhysicalDeviceVulkan12Features.vulkanMemoryModel = VKFeatureWords.flag (words, 41);
		vKPhysicalDeviceVulkan12Features.vulkanMemoryModelDeviceScope = VKFeatureWords.flag (words, 42);
		vKPhysicalDeviceVulkan12Features.vulkanMemoryModelAvailabilityVisibilityChains = VKFeatureWords.flag (words, 43);
		vKPhysicalDeviceVulkan12Features.shaderOutputViewportIndex = VKFeatureWords.flag (words, 44);
		vKPhysicalDeviceVulkan12Features.shaderOutputLayer = VKFeatureWords.flag (words, 45);
		vKPhysicalDeviceVulkan12Features.subgroupBroadcastDynamicId = VKFeatureWords.flag (words, 46);
		return vKPhysicalDeviceVulkan12Features;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_VULKAN_1_2_FEATURES;
	}
}
