package lime.graphics.vulkan;

/**
	Tiling and buffer capabilities reported for a single `VkFormat`.

	Returned by `VKPhysicalDevice.getFormatProperties()`.
**/
class VKFormatProperties
{
	public var bufferFeatures(default, null):Int;
	public var linearTilingFeatures(default, null):Int;
	public var optimalTilingFeatures(default, null):Int;

	public function new(linearTilingFeatures:Int, optimalTilingFeatures:Int, bufferFeatures:Int)
	{
		this.linearTilingFeatures = linearTilingFeatures;
		this.optimalTilingFeatures = optimalTilingFeatures;
		this.bufferFeatures = bufferFeatures;
	}

	public static function fromDynamic(data:Dynamic):VKFormatProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKFormatProperties(data.linearTilingFeatures, data.optimalTilingFeatures, data.bufferFeatures);
	}
}
