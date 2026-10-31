package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceVulkan13Features` — 15 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_VULKAN_1_3_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceVulkan13Features
{
	public var robustImageAccess(default, null):Bool;
	public var inlineUniformBlock(default, null):Bool;
	public var descriptorBindingInlineUniformBlockUpdateAfterBind(default, null):Bool;
	public var pipelineCreationCacheControl(default, null):Bool;
	public var privateData(default, null):Bool;
	public var shaderDemoteToHelperInvocation(default, null):Bool;
	public var shaderTerminateInvocation(default, null):Bool;
	public var subgroupSizeControl(default, null):Bool;
	public var computeFullSubgroups(default, null):Bool;
	public var synchronization2(default, null):Bool;
	public var textureCompressionASTC_HDR(default, null):Bool;
	public var shaderZeroInitializeWorkgroupMemory(default, null):Bool;
	public var dynamicRendering(default, null):Bool;
	public var shaderIntegerDotProduct(default, null):Bool;
	public var maintenance4(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceVulkan13Features
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceVulkan13Features = new VKPhysicalDeviceVulkan13Features();
		vKPhysicalDeviceVulkan13Features.robustImageAccess = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceVulkan13Features.inlineUniformBlock = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceVulkan13Features.descriptorBindingInlineUniformBlockUpdateAfterBind = VKFeatureWords.flag (words, 2);
		vKPhysicalDeviceVulkan13Features.pipelineCreationCacheControl = VKFeatureWords.flag (words, 3);
		vKPhysicalDeviceVulkan13Features.privateData = VKFeatureWords.flag (words, 4);
		vKPhysicalDeviceVulkan13Features.shaderDemoteToHelperInvocation = VKFeatureWords.flag (words, 5);
		vKPhysicalDeviceVulkan13Features.shaderTerminateInvocation = VKFeatureWords.flag (words, 6);
		vKPhysicalDeviceVulkan13Features.subgroupSizeControl = VKFeatureWords.flag (words, 7);
		vKPhysicalDeviceVulkan13Features.computeFullSubgroups = VKFeatureWords.flag (words, 8);
		vKPhysicalDeviceVulkan13Features.synchronization2 = VKFeatureWords.flag (words, 9);
		vKPhysicalDeviceVulkan13Features.textureCompressionASTC_HDR = VKFeatureWords.flag (words, 10);
		vKPhysicalDeviceVulkan13Features.shaderZeroInitializeWorkgroupMemory = VKFeatureWords.flag (words, 11);
		vKPhysicalDeviceVulkan13Features.dynamicRendering = VKFeatureWords.flag (words, 12);
		vKPhysicalDeviceVulkan13Features.shaderIntegerDotProduct = VKFeatureWords.flag (words, 13);
		vKPhysicalDeviceVulkan13Features.maintenance4 = VKFeatureWords.flag (words, 14);
		return vKPhysicalDeviceVulkan13Features;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_VULKAN_1_3_FEATURES;
	}
}
