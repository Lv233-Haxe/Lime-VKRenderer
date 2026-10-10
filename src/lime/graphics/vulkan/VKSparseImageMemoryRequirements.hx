package lime.graphics.vulkan;

import haxe.Int64;

/**
	Sparse memory requirements for one aspect of a `VKImage`.

	Returned by `VKImage.getSparseMemoryRequirements()`.
**/
class VKSparseImageMemoryRequirements
{
	public var aspectMask(default, null):Int;
	public var flags(default, null):Int;
	public var imageGranularity(default, null):VKExtent3D;
	public var imageMipTailFirstLod(default, null):Int;
	public var imageMipTailOffset(default, null):Int64;
	public var imageMipTailSize(default, null):Int64;
	public var imageMipTailStride(default, null):Int64;

	public function new(aspectMask:Int, imageGranularity:VKExtent3D, flags:Int, imageMipTailFirstLod:Int, imageMipTailSize:Int64,
			imageMipTailOffset:Int64, imageMipTailStride:Int64)
	{
		this.aspectMask = aspectMask;
		this.imageGranularity = imageGranularity;
		this.flags = flags;
		this.imageMipTailFirstLod = imageMipTailFirstLod;
		this.imageMipTailSize = imageMipTailSize;
		this.imageMipTailOffset = imageMipTailOffset;
		this.imageMipTailStride = imageMipTailStride;
	}

	public static function fromDynamic(data:Dynamic):VKSparseImageMemoryRequirements
	{
		if (data == null)
		{
			return null;
		}

		return new VKSparseImageMemoryRequirements(data.aspectMask, VKExtent3D.fromDynamic(data.imageGranularity), data.flags,
			data.imageMipTailFirstLod, Int64.make(data.imageMipTailSize.high, data.imageMipTailSize.low),
			Int64.make(data.imageMipTailOffset.high, data.imageMipTailOffset.low), Int64.make(data.imageMipTailStride.high, data.imageMipTailStride.low));
	}
}
