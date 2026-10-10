package lime.graphics.vulkan;

/**
	Sparse image format capabilities for a format/type/sample/usage/tiling combination.

	Returned by `VKPhysicalDevice.getSparseImageFormatProperties()`.
**/
class VKSparseImageFormatProperties
{
	public var aspectMask(default, null):Int;
	public var flags(default, null):Int;
	public var imageGranularity(default, null):VKExtent3D;

	public function new(aspectMask:Int, imageGranularity:VKExtent3D, flags:Int)
	{
		this.aspectMask = aspectMask;
		this.imageGranularity = imageGranularity;
		this.flags = flags;
	}

	public static function fromDynamic(data:Dynamic):VKSparseImageFormatProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKSparseImageFormatProperties(data.aspectMask, VKExtent3D.fromDynamic(data.imageGranularity), data.flags);
	}
}
