package lime.graphics.vulkan;

import haxe.Int64;

/**
	Memory requirements returned by the Vulkan 1.1+ query path.

	Extends the Vulkan 1.0 `VKMemoryRequirements` shape with the dedicated
	allocation hints that only `vkGetBufferMemoryRequirements2` /
	`vkGetImageMemoryRequirements2` can report.
**/
class VKMemoryRequirements2
{
	public var alignment(default, null):Int64;
	public var memoryTypeBits(default, null):Int;
	public var prefersDedicatedAllocation(default, null):Bool;
	public var requiresDedicatedAllocation(default, null):Bool;
	public var size(default, null):Int64;

	public function new(size:Int64, alignment:Int64, memoryTypeBits:Int, prefersDedicatedAllocation:Bool, requiresDedicatedAllocation:Bool)
	{
		this.size = size;
		this.alignment = alignment;
		this.memoryTypeBits = memoryTypeBits;
		this.prefersDedicatedAllocation = prefersDedicatedAllocation;
		this.requiresDedicatedAllocation = requiresDedicatedAllocation;
	}

	public static function fromDynamic(data:Dynamic):VKMemoryRequirements2
	{
		if (data == null)
		{
			return null;
		}

		return new VKMemoryRequirements2(Int64.make(data.size.high, data.size.low), Int64.make(data.alignment.high, data.alignment.low),
			data.memoryTypeBits, data.prefersDedicatedAllocation == true, data.requiresDedicatedAllocation == true);
	}

	/**
		Projects the Vulkan 1.0-shaped subset, for use with the classic
		`VKDevice.allocateMemory` path.
	**/
	public function toMemoryRequirements():VKMemoryRequirements
	{
		return new VKMemoryRequirements(size, alignment, memoryTypeBits);
	}
}
