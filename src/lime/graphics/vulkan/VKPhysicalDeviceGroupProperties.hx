package lime.graphics.vulkan;

import haxe.Int64;

/**
	One physical-device group (Vulkan 1.1 device groups).

	Returned by `VKInstance.enumeratePhysicalDeviceGroups()`. On a normal
	single-GPU or SLI/CrossFire setup each group holds exactly one device; the
	group form exists so an engine can use several GPUs from one logical device.
**/
class VKPhysicalDeviceGroupProperties
{
	public var physicalDeviceCount(default, null):Int;

	/**
		Handles of the devices in this group, in the same order the implementation
		reported them.
	**/
	public var physicalDevices(default, null):Array<Int64>;

	/**
		`true` when the group may be used with a subset of `physicalDevices`.
	**/
	public var subsetAllocation(default, null):Bool;

	public function new(physicalDeviceCount:Int, physicalDevices:Array<Int64>, subsetAllocation:Bool)
	{
		this.physicalDeviceCount = physicalDeviceCount;
		this.physicalDevices = physicalDevices;
		this.subsetAllocation = subsetAllocation;
	}

	public static function fromDynamic(data:Dynamic):VKPhysicalDeviceGroupProperties
	{
		if (data == null)
		{
			return null;
		}

		var devices = new Array<Int64>();
		var raw:Dynamic = data.physicalDevices;

		if (raw != null)
		{
			var length:Int = untyped raw.length;
			for (i in 0...length)
			{
				var entry:Dynamic = untyped raw[i];
				devices.push(Int64.make(entry.high, entry.low));
			}
		}

		return new VKPhysicalDeviceGroupProperties(data.physicalDeviceCount, devices, data.subsetAllocation == true);
	}
}
