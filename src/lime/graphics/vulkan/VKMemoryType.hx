package lime.graphics.vulkan;

/**
	A single memory type exposed by a physical device.
**/
class VKMemoryType
{
	public var heapIndex(default, null):Int;
	public var propertyFlags(default, null):Int;

	public function new(propertyFlags:Int, heapIndex:Int)
	{
		this.propertyFlags = propertyFlags;
		this.heapIndex = heapIndex;
	}
}
