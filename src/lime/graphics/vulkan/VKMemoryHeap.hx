package lime.graphics.vulkan;

import haxe.Int64;

/**
	A single memory heap exposed by a physical device.
**/
class VKMemoryHeap
{
	public var flags(default, null):Int;
	public var size(default, null):Int64;

	public function new(size:Int64, flags:Int)
	{
		this.size = size;
		this.flags = flags;
	}
}
