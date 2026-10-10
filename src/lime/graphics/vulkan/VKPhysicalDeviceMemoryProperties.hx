package lime.graphics.vulkan;

import haxe.Int64;

/**
	Memory types and heaps exposed by a physical device.

	Returned by `VKPhysicalDevice.getMemoryProperties()`. Use the memory type bits
	from `VKMemoryRequirements.memoryTypeBits` to find a compatible type index.
**/
class VKPhysicalDeviceMemoryProperties
{
	public var memoryHeapCount(default, null):Int;
	public var memoryHeaps(default, null):Array<VKMemoryHeap>;
	public var memoryTypeCount(default, null):Int;
	public var memoryTypes(default, null):Array<VKMemoryType>;

	public function new(memoryTypeCount:Int, memoryTypes:Array<VKMemoryType>, memoryHeapCount:Int, memoryHeaps:Array<VKMemoryHeap>)
	{
		this.memoryTypeCount = memoryTypeCount;
		this.memoryTypes = memoryTypes;
		this.memoryHeapCount = memoryHeapCount;
		this.memoryHeaps = memoryHeaps;
	}

	/**
		Finds the first memory type that satisfies both `memoryTypeBits` and
		`requiredFlags`, or `-1` when no type matches.
	**/
	public function findMemoryType(memoryTypeBits:Int, requiredFlags:Int):Int
	{
		if (memoryTypes == null)
		{
			return -1;
		}

		for (i in 0...memoryTypes.length)
		{
			var memoryType = memoryTypes[i];
			if ((memoryTypeBits & (1 << i)) != 0 && (memoryType.propertyFlags & requiredFlags) == requiredFlags)
			{
				return i;
			}
		}

		return -1;
	}

	public static function fromDynamic(data:Dynamic):VKPhysicalDeviceMemoryProperties
	{
		if (data == null)
		{
			return null;
		}

		var memoryTypes = new Array<VKMemoryType>();
		var rawTypes:Dynamic = data.memoryTypes;
		if (rawTypes != null)
		{
			var typeCount:Int = untyped rawTypes.length;
			for (i in 0...typeCount)
			{
				var rawType:Dynamic = untyped rawTypes[i];
				memoryTypes.push(new VKMemoryType(rawType.propertyFlags, rawType.heapIndex));
			}
		}

		var memoryHeaps = new Array<VKMemoryHeap>();
		var rawHeaps:Dynamic = data.memoryHeaps;
		if (rawHeaps != null)
		{
			var heapCount:Int = untyped rawHeaps.length;
			for (i in 0...heapCount)
			{
				var rawHeap:Dynamic = untyped rawHeaps[i];
				memoryHeaps.push(new VKMemoryHeap(Int64.make(rawHeap.size.high, rawHeap.size.low), rawHeap.flags));
			}
		}

		return new VKPhysicalDeviceMemoryProperties(data.memoryTypeCount, memoryTypes, data.memoryHeapCount, memoryHeaps);
	}
}
