package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceVulkan14Features` — 21 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_VULKAN_1_4_FEATURES` and decoding the returned word array.

	The last nine fields were appended to the struct after the initial Vulkan 1.4
	release (`shaderSubgroupRotateClustered`, the line-rasterization split bits,
	`pipelineRobustness`, `hostImageCopy`); on drivers built against older headers
	they are never reported and read as `false`.
**/
class VKPhysicalDeviceVulkan14Features
{
	public var globalPriorityQuery(default, null):Bool;
	public var shaderSubgroupRotate(default, null):Bool;
	public var shaderSubgroupRotateClustered(default, null):Bool;
	public var shaderFloatControls2(default, null):Bool;
	public var shaderExpectAssume(default, null):Bool;
	public var rectangularLines(default, null):Bool;
	public var bresenhamLines(default, null):Bool;
	public var smoothLines(default, null):Bool;
	public var stippledRectangularLines(default, null):Bool;
	public var stippledBresenhamLines(default, null):Bool;
	public var stippledSmoothLines(default, null):Bool;
	public var vertexAttributeInstanceRateDivisor(default, null):Bool;
	public var vertexAttributeInstanceRateZeroDivisor(default, null):Bool;
	public var indexTypeUint8(default, null):Bool;
	public var dynamicRenderingLocalRead(default, null):Bool;
	public var maintenance5(default, null):Bool;
	public var maintenance6(default, null):Bool;
	public var pipelineProtectedAccess(default, null):Bool;
	public var pipelineRobustness(default, null):Bool;
	public var hostImageCopy(default, null):Bool;
	public var pushDescriptor(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceVulkan14Features
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceVulkan14Features = new VKPhysicalDeviceVulkan14Features();
		vKPhysicalDeviceVulkan14Features.globalPriorityQuery = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceVulkan14Features.shaderSubgroupRotate = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceVulkan14Features.shaderSubgroupRotateClustered = VKFeatureWords.flag (words, 2);
		vKPhysicalDeviceVulkan14Features.shaderFloatControls2 = VKFeatureWords.flag (words, 3);
		vKPhysicalDeviceVulkan14Features.shaderExpectAssume = VKFeatureWords.flag (words, 4);
		vKPhysicalDeviceVulkan14Features.rectangularLines = VKFeatureWords.flag (words, 5);
		vKPhysicalDeviceVulkan14Features.bresenhamLines = VKFeatureWords.flag (words, 6);
		vKPhysicalDeviceVulkan14Features.smoothLines = VKFeatureWords.flag (words, 7);
		vKPhysicalDeviceVulkan14Features.stippledRectangularLines = VKFeatureWords.flag (words, 8);
		vKPhysicalDeviceVulkan14Features.stippledBresenhamLines = VKFeatureWords.flag (words, 9);
		vKPhysicalDeviceVulkan14Features.stippledSmoothLines = VKFeatureWords.flag (words, 10);
		vKPhysicalDeviceVulkan14Features.vertexAttributeInstanceRateDivisor = VKFeatureWords.flag (words, 11);
		vKPhysicalDeviceVulkan14Features.vertexAttributeInstanceRateZeroDivisor = VKFeatureWords.flag (words, 12);
		vKPhysicalDeviceVulkan14Features.indexTypeUint8 = VKFeatureWords.flag (words, 13);
		vKPhysicalDeviceVulkan14Features.dynamicRenderingLocalRead = VKFeatureWords.flag (words, 14);
		vKPhysicalDeviceVulkan14Features.maintenance5 = VKFeatureWords.flag (words, 15);
		vKPhysicalDeviceVulkan14Features.maintenance6 = VKFeatureWords.flag (words, 16);
		vKPhysicalDeviceVulkan14Features.pipelineProtectedAccess = VKFeatureWords.flag (words, 17);
		vKPhysicalDeviceVulkan14Features.pipelineRobustness = VKFeatureWords.flag (words, 18);
		vKPhysicalDeviceVulkan14Features.hostImageCopy = VKFeatureWords.flag (words, 19);
		vKPhysicalDeviceVulkan14Features.pushDescriptor = VKFeatureWords.flag (words, 20);
		return vKPhysicalDeviceVulkan14Features;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_VULKAN_1_4_FEATURES;
	}
}
