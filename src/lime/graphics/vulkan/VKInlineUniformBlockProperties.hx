package lime.graphics.vulkan;

/**
	`VkPhysicalDeviceInlineUniformBlockProperties` - the inline-uniform-block
	limits (Vulkan 1.3 core, originally `VK_EXT_inline_uniform_block`).

	An inline uniform block is a uniform buffer whose storage lives inside the
	descriptor set itself, which is why it has both a size ceiling and its own
	descriptor-count budgets. Obtained from
	`VKPhysicalDevice.getInlineUniformBlockProperties()`.

	Requires the `inlineUniformBlock` feature (`VK.DEVICE_FEATURE_INLINE_UNIFORM_BLOCK`)
	before a layout with such a binding can be used.
**/
class VKInlineUniformBlockProperties
{
	/**
		Maximum size in bytes of a single inline uniform block binding.
	**/
	public var maxInlineUniformBlockSize(default, null):Int;

	/**
		Maximum number of inline uniform blocks per pipeline stage, without and
		with update-after-bind descriptor sets.
	**/
	public var maxPerStageDescriptorInlineUniformBlocks(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks(default, null):Int;

	/**
		Maximum number of inline uniform blocks per descriptor set, without and
		with update-after-bind descriptor sets.
	**/
	public var maxDescriptorSetInlineUniformBlocks(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindInlineUniformBlocks(default, null):Int;

	public function new(maxInlineUniformBlockSize:Int, maxPerStageDescriptorInlineUniformBlocks:Int,
			maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks:Int, maxDescriptorSetInlineUniformBlocks:Int,
			maxDescriptorSetUpdateAfterBindInlineUniformBlocks:Int)
	{
		this.maxInlineUniformBlockSize = maxInlineUniformBlockSize;
		this.maxPerStageDescriptorInlineUniformBlocks = maxPerStageDescriptorInlineUniformBlocks;
		this.maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks = maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks;
		this.maxDescriptorSetInlineUniformBlocks = maxDescriptorSetInlineUniformBlocks;
		this.maxDescriptorSetUpdateAfterBindInlineUniformBlocks = maxDescriptorSetUpdateAfterBindInlineUniformBlocks;
	}

	public static function fromDynamic(data:Dynamic):VKInlineUniformBlockProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKInlineUniformBlockProperties(data.maxInlineUniformBlockSize,
			data.maxPerStageDescriptorInlineUniformBlocks, data.maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks,
			data.maxDescriptorSetInlineUniformBlocks, data.maxDescriptorSetUpdateAfterBindInlineUniformBlocks);
	}
}
