package lime.graphics.vulkan;

/**
	Describes one queue family on a Vulkan physical device.
**/
class VKQueueFamilyInfo
{
	public var index(default, null):Int;
	public var flags(default, null):Int;

	/**
		Finest image-transfer granularity this family supports.

		Only populated by the Vulkan 1.1 query
		(`VKPhysicalDevice.getQueueFamilyProperties2()`); `null` from the 1.0 path.
	**/
	public var minImageTransferGranularity(default, null):VKExtent3D;
	public var queueCount(default, null):Int;
	public var timestampValidBits(default, null):Int;
	public var supportsGraphics(default, null):Bool;
	public var supportsCompute(default, null):Bool;
	public var supportsTransfer(default, null):Bool;
	public var supportsPresent(default, null):Bool;

	@:allow(lime.graphics.vulkan.VKPhysicalDevice)
	private function new(data:Dynamic)
	{
		index = data.index;
		flags = data.flags;
		queueCount = data.queueCount;
		timestampValidBits = data.timestampValidBits;
		supportsGraphics = data.supportsGraphics;
		supportsCompute = data.supportsCompute;
		supportsTransfer = data.supportsTransfer;
		supportsPresent = data.supportsPresent;

		var granularity:Dynamic = data.minImageTransferGranularity;
		minImageTransferGranularity = (granularity != null) ? VKExtent3D.fromDynamic(granularity) : null;
	}

	/**
		Checks whether this queue family satisfies a requested capability set.
	**/
	public inline function matches(requireGraphics:Bool = false, requirePresent:Bool = false, requireCompute:Bool = false, requireTransfer:Bool = false):Bool
	{
		if (requireGraphics && !supportsGraphics) return false;
		if (requirePresent && !supportsPresent) return false;
		if (requireCompute && !supportsCompute) return false;
		if (requireTransfer && !supportsTransfer) return false;
		return true;
	}
}
