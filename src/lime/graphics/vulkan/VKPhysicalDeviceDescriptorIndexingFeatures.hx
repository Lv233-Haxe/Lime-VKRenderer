package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceDescriptorIndexingFeatures` — 20 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceDescriptorIndexingFeatures
{
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

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceDescriptorIndexingFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceDescriptorIndexingFeatures = new VKPhysicalDeviceDescriptorIndexingFeatures();
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderInputAttachmentArrayDynamicIndexing = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderUniformTexelBufferArrayDynamicIndexing = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderStorageTexelBufferArrayDynamicIndexing = VKFeatureWords.flag (words, 2);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderUniformBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 3);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderSampledImageArrayNonUniformIndexing = VKFeatureWords.flag (words, 4);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderStorageBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 5);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderStorageImageArrayNonUniformIndexing = VKFeatureWords.flag (words, 6);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderInputAttachmentArrayNonUniformIndexing = VKFeatureWords.flag (words, 7);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderUniformTexelBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 8);
		vKPhysicalDeviceDescriptorIndexingFeatures.shaderStorageTexelBufferArrayNonUniformIndexing = VKFeatureWords.flag (words, 9);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingUniformBufferUpdateAfterBind = VKFeatureWords.flag (words, 10);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingSampledImageUpdateAfterBind = VKFeatureWords.flag (words, 11);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingStorageImageUpdateAfterBind = VKFeatureWords.flag (words, 12);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingStorageBufferUpdateAfterBind = VKFeatureWords.flag (words, 13);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingUniformTexelBufferUpdateAfterBind = VKFeatureWords.flag (words, 14);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingStorageTexelBufferUpdateAfterBind = VKFeatureWords.flag (words, 15);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingUpdateUnusedWhilePending = VKFeatureWords.flag (words, 16);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingPartiallyBound = VKFeatureWords.flag (words, 17);
		vKPhysicalDeviceDescriptorIndexingFeatures.descriptorBindingVariableDescriptorCount = VKFeatureWords.flag (words, 18);
		vKPhysicalDeviceDescriptorIndexingFeatures.runtimeDescriptorArray = VKFeatureWords.flag (words, 19);
		return vKPhysicalDeviceDescriptorIndexingFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES;
	}
}

