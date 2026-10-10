package lime.graphics.vulkan;

import haxe.Int64;

/**
	`VkPhysicalDeviceMaintenance3Properties` — Vulkan 1.1 descriptor and allocation
	limits that did not exist in the 1.0 property struct.

	Obtained from `VKPhysicalDeviceProperties2.maintenance3`.
**/
class VKMaintenance3Properties
{
	/**
		Largest allocation this device supports, in bytes.
	**/
	public var maxMemoryAllocationSize(default, null):Int64;

	/**
		Descriptor count per descriptor set, summed across all bindings.
	**/
	public var maxPerSetDescriptors(default, null):Int;

	public function new(maxPerSetDescriptors:Int, maxMemoryAllocationSize:Int64)
	{
		this.maxPerSetDescriptors = maxPerSetDescriptors;
		this.maxMemoryAllocationSize = maxMemoryAllocationSize;
	}

	public static function fromDynamic(data:Dynamic):VKMaintenance3Properties
	{
		if (data == null)
		{
			return null;
		}

		return new VKMaintenance3Properties(data.maxPerSetDescriptors,
			Int64.make(data.maxMemoryAllocationSize.high, data.maxMemoryAllocationSize.low));
	}
}
