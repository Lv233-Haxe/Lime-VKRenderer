package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceImagelessFramebufferFeatures` — 1 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceImagelessFramebufferFeatures
{
	public var imagelessFramebuffer(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceImagelessFramebufferFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceImagelessFramebufferFeatures = new VKPhysicalDeviceImagelessFramebufferFeatures();
		vKPhysicalDeviceImagelessFramebufferFeatures.imagelessFramebuffer = VKFeatureWords.flag (words, 0);
		return vKPhysicalDeviceImagelessFramebufferFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES;
	}
}

