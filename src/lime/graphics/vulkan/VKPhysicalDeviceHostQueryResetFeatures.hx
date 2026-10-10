package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceHostQueryResetFeatures` — 1 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceHostQueryResetFeatures
{
	public var hostQueryReset(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceHostQueryResetFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceHostQueryResetFeatures = new VKPhysicalDeviceHostQueryResetFeatures();
		vKPhysicalDeviceHostQueryResetFeatures.hostQueryReset = VKFeatureWords.flag (words, 0);
		return vKPhysicalDeviceHostQueryResetFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES;
	}
}

