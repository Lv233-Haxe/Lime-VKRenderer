package lime.graphics.vulkan;

/**
	`VkPhysicalDeviceSubgroupSizeControlProperties` - the subgroup size range a
	device supports and the stages that allow pinning it (Vulkan 1.3 core,
	originally `VK_EXT_subgroup_size_control`).

	Obtained from `VKPhysicalDevice.getSubgroupSizeControlProperties()`. To pin a
	stage's subgroup size, enable `VK.DEVICE_FEATURE_SUBGROUP_SIZE_CONTROL` at
	device creation, check the stage bit against `requiredSubgroupSizeStages`,
	then set `VKGraphicsPipelineInfo.vertexRequiredSubgroupSize` /
	`fragmentRequiredSubgroupSize` or pass `requiredSubgroupSize` to
	`VKDevice.createComputePipeline()`.
**/
class VKSubgroupSizeControlProperties
{
	/**
		Inclusive minimum subgroup size supported by this device.
	**/
	public var minSubgroupSize(default, null):Int;

	/**
		Inclusive maximum subgroup size supported by this device.
	**/
	public var maxSubgroupSize(default, null):Int;

	/**
		Maximum number of subgroups in a compute workgroup.
	**/
	public var maxComputeWorkgroupSubgroups(default, null):Int;

	/**
		Bitmask of `VK_SHADER_STAGE_*_BIT` stages that accept a required
		subgroup size. A stage not in this mask must not receive one.
	**/
	public var requiredSubgroupSizeStages(default, null):Int;

	public function new(minSubgroupSize:Int, maxSubgroupSize:Int, maxComputeWorkgroupSubgroups:Int,
			requiredSubgroupSizeStages:Int)
	{
		this.minSubgroupSize = minSubgroupSize;
		this.maxSubgroupSize = maxSubgroupSize;
		this.maxComputeWorkgroupSubgroups = maxComputeWorkgroupSubgroups;
		this.requiredSubgroupSizeStages = requiredSubgroupSizeStages;
	}

	public static function fromDynamic(data:Dynamic):VKSubgroupSizeControlProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKSubgroupSizeControlProperties(data.minSubgroupSize, data.maxSubgroupSize,
			data.maxComputeWorkgroupSubgroups, data.requiredSubgroupSizeStages);
	}
}
