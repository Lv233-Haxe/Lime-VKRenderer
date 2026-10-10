package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceVulkan11Features` — 12 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_VULKAN_1_1_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceVulkan11Features
{
	public var storageBuffer16BitAccess(default, null):Bool;
	public var uniformAndStorageBuffer16BitAccess(default, null):Bool;
	public var storagePushConstant16(default, null):Bool;
	public var storageInputOutput16(default, null):Bool;
	public var multiview(default, null):Bool;
	public var multiviewGeometryShader(default, null):Bool;
	public var multiviewTessellationShader(default, null):Bool;
	public var variablePointersStorageBuffer(default, null):Bool;
	public var variablePointers(default, null):Bool;
	public var protectedMemory(default, null):Bool;
	public var samplerYcbcrConversion(default, null):Bool;
	public var shaderDrawParameters(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceVulkan11Features
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceVulkan11Features = new VKPhysicalDeviceVulkan11Features();
		vKPhysicalDeviceVulkan11Features.storageBuffer16BitAccess = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceVulkan11Features.uniformAndStorageBuffer16BitAccess = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceVulkan11Features.storagePushConstant16 = VKFeatureWords.flag (words, 2);
		vKPhysicalDeviceVulkan11Features.storageInputOutput16 = VKFeatureWords.flag (words, 3);
		vKPhysicalDeviceVulkan11Features.multiview = VKFeatureWords.flag (words, 4);
		vKPhysicalDeviceVulkan11Features.multiviewGeometryShader = VKFeatureWords.flag (words, 5);
		vKPhysicalDeviceVulkan11Features.multiviewTessellationShader = VKFeatureWords.flag (words, 6);
		vKPhysicalDeviceVulkan11Features.variablePointersStorageBuffer = VKFeatureWords.flag (words, 7);
		vKPhysicalDeviceVulkan11Features.variablePointers = VKFeatureWords.flag (words, 8);
		vKPhysicalDeviceVulkan11Features.protectedMemory = VKFeatureWords.flag (words, 9);
		vKPhysicalDeviceVulkan11Features.samplerYcbcrConversion = VKFeatureWords.flag (words, 10);
		vKPhysicalDeviceVulkan11Features.shaderDrawParameters = VKFeatureWords.flag (words, 11);
		return vKPhysicalDeviceVulkan11Features;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_VULKAN_1_1_FEATURES;
	}
}

