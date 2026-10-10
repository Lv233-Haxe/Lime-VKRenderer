package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures` — 1 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceSeparateDepthStencilLayoutsFeatures
{
	public var separateDepthStencilLayouts(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceSeparateDepthStencilLayoutsFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceSeparateDepthStencilLayoutsFeatures = new VKPhysicalDeviceSeparateDepthStencilLayoutsFeatures();
		vKPhysicalDeviceSeparateDepthStencilLayoutsFeatures.separateDepthStencilLayouts = VKFeatureWords.flag (words, 0);
		return vKPhysicalDeviceSeparateDepthStencilLayoutsFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES;
	}
}

