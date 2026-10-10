package lime.graphics.vulkan;

/**
	`VkPhysicalDeviceMultiviewProperties` — Vulkan 1.1 multi-view limits.

	Obtained from `VKPhysicalDeviceProperties2.multiview`. Only relevant when the
	`multiview` feature is enabled; a 2D renderer normally ignores both values.
**/
class VKMultiviewProperties
{
	public var maxMultiviewInstanceIndex(default, null):Int;
	public var maxMultiviewViewCount(default, null):Int;

	public function new(maxMultiviewViewCount:Int, maxMultiviewInstanceIndex:Int)
	{
		this.maxMultiviewViewCount = maxMultiviewViewCount;
		this.maxMultiviewInstanceIndex = maxMultiviewInstanceIndex;
	}

	public static function fromDynamic(data:Dynamic):VKMultiviewProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKMultiviewProperties(data.maxMultiviewViewCount, data.maxMultiviewInstanceIndex);
	}
}
