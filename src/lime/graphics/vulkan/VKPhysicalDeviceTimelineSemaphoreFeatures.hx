package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceTimelineSemaphoreFeatures` — 1 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceTimelineSemaphoreFeatures
{
	public var timelineSemaphore(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceTimelineSemaphoreFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceTimelineSemaphoreFeatures = new VKPhysicalDeviceTimelineSemaphoreFeatures();
		vKPhysicalDeviceTimelineSemaphoreFeatures.timelineSemaphore = VKFeatureWords.flag (words, 0);
		return vKPhysicalDeviceTimelineSemaphoreFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES;
	}
}

