package lime.graphics.vulkan;

/**
	`VkPhysicalDeviceDescriptorIndexingProperties` — DescriptorIndexing properties.

	Obtained from `VKPhysicalDevice`; decode the object returned by the
	corresponding query with `fromDynamic`.

	@see docs/vulkan-progress.md
**/
class VKDescriptorIndexingProperties
{
	public var maxUpdateAfterBindDescriptorsInAllPools(default, null):Int;
	public var shaderUniformBufferArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderSampledImageArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderStorageBufferArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderStorageImageArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderInputAttachmentArrayNonUniformIndexingNative(default, null):Bool;
	public var robustBufferAccessUpdateAfterBind(default, null):Bool;
	public var quadDivergentImplicitLod(default, null):Bool;
	public var maxPerStageDescriptorUpdateAfterBindSamplers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindUniformBuffers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindStorageBuffers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindSampledImages(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindStorageImages(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindInputAttachments(default, null):Int;
	public var maxPerStageUpdateAfterBindResources(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindSamplers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindUniformBuffers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindUniformBuffersDynamic(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageBuffers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageBuffersDynamic(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindSampledImages(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageImages(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindInputAttachments(default, null):Int;

	public function new()
	{
	}

	public static function fromDynamic(data:Dynamic):VKDescriptorIndexingProperties
	{
		if (data == null)
		{
			return null;
		}

		var result = new VKDescriptorIndexingProperties();
		result.__load (data);
		return result;
	}

	private function __load(data:Dynamic):Void
	{
		maxUpdateAfterBindDescriptorsInAllPools = data.maxUpdateAfterBindDescriptorsInAllPools;
		shaderUniformBufferArrayNonUniformIndexingNative = (data.shaderUniformBufferArrayNonUniformIndexingNative == true);
		shaderSampledImageArrayNonUniformIndexingNative = (data.shaderSampledImageArrayNonUniformIndexingNative == true);
		shaderStorageBufferArrayNonUniformIndexingNative = (data.shaderStorageBufferArrayNonUniformIndexingNative == true);
		shaderStorageImageArrayNonUniformIndexingNative = (data.shaderStorageImageArrayNonUniformIndexingNative == true);
		shaderInputAttachmentArrayNonUniformIndexingNative = (data.shaderInputAttachmentArrayNonUniformIndexingNative == true);
		robustBufferAccessUpdateAfterBind = (data.robustBufferAccessUpdateAfterBind == true);
		quadDivergentImplicitLod = (data.quadDivergentImplicitLod == true);
		maxPerStageDescriptorUpdateAfterBindSamplers = data.maxPerStageDescriptorUpdateAfterBindSamplers;
		maxPerStageDescriptorUpdateAfterBindUniformBuffers = data.maxPerStageDescriptorUpdateAfterBindUniformBuffers;
		maxPerStageDescriptorUpdateAfterBindStorageBuffers = data.maxPerStageDescriptorUpdateAfterBindStorageBuffers;
		maxPerStageDescriptorUpdateAfterBindSampledImages = data.maxPerStageDescriptorUpdateAfterBindSampledImages;
		maxPerStageDescriptorUpdateAfterBindStorageImages = data.maxPerStageDescriptorUpdateAfterBindStorageImages;
		maxPerStageDescriptorUpdateAfterBindInputAttachments = data.maxPerStageDescriptorUpdateAfterBindInputAttachments;
		maxPerStageUpdateAfterBindResources = data.maxPerStageUpdateAfterBindResources;
		maxDescriptorSetUpdateAfterBindSamplers = data.maxDescriptorSetUpdateAfterBindSamplers;
		maxDescriptorSetUpdateAfterBindUniformBuffers = data.maxDescriptorSetUpdateAfterBindUniformBuffers;
		maxDescriptorSetUpdateAfterBindUniformBuffersDynamic = data.maxDescriptorSetUpdateAfterBindUniformBuffersDynamic;
		maxDescriptorSetUpdateAfterBindStorageBuffers = data.maxDescriptorSetUpdateAfterBindStorageBuffers;
		maxDescriptorSetUpdateAfterBindStorageBuffersDynamic = data.maxDescriptorSetUpdateAfterBindStorageBuffersDynamic;
		maxDescriptorSetUpdateAfterBindSampledImages = data.maxDescriptorSetUpdateAfterBindSampledImages;
		maxDescriptorSetUpdateAfterBindStorageImages = data.maxDescriptorSetUpdateAfterBindStorageImages;
		maxDescriptorSetUpdateAfterBindInputAttachments = data.maxDescriptorSetUpdateAfterBindInputAttachments;
	}
}
