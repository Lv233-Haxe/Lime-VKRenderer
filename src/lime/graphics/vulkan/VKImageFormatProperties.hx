package lime.graphics.vulkan;

import haxe.Int64;

/**
	Limits reported for a specific image format/type/tiling/usage combination.

	Returned by `VKPhysicalDevice.getImageFormatProperties()`, or `null` when the
	combination is not supported.
**/
class VKImageFormatProperties
{
	public var maxArrayLayers(default, null):Int;
	public var maxExtent(default, null):VKExtent3D;
	public var maxMipLevels(default, null):Int;
	public var maxResourceSize(default, null):Int64;
	public var sampleCounts(default, null):Int;

	public function new(maxExtent:VKExtent3D, maxMipLevels:Int, maxArrayLayers:Int, sampleCounts:Int, maxResourceSize:Int64)
	{
		this.maxExtent = maxExtent;
		this.maxMipLevels = maxMipLevels;
		this.maxArrayLayers = maxArrayLayers;
		this.sampleCounts = sampleCounts;
		this.maxResourceSize = maxResourceSize;
	}

	public static function fromDynamic(data:Dynamic):VKImageFormatProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKImageFormatProperties(VKExtent3D.fromDynamic(data.maxExtent), data.maxMipLevels, data.maxArrayLayers, data.sampleCounts,
			Int64.make(data.maxResourceSize.high, data.maxResourceSize.low));
	}
}
