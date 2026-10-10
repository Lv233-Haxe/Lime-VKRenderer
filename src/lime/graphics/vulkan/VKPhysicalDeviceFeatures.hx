package lime.graphics.vulkan;

/**
	Boolean feature set reported by a physical device.

	This mirrors the Vulkan 1.0 `VkPhysicalDeviceFeatures` structure. Query it
	with `VKPhysicalDevice.getFeatures()` and check a flag before relying on the
	corresponding optional feature.
**/
class VKPhysicalDeviceFeatures
{
	public var robustBufferAccess(default, null):Bool;
	public var fullDrawIndexUint32(default, null):Bool;
	public var imageCubeArray(default, null):Bool;
	public var independentBlend(default, null):Bool;
	public var geometryShader(default, null):Bool;
	public var tessellationShader(default, null):Bool;
	public var sampleRateShading(default, null):Bool;
	public var dualSrcBlend(default, null):Bool;
	public var logicOp(default, null):Bool;
	public var multiDrawIndirect(default, null):Bool;
	public var drawIndirectFirstInstance(default, null):Bool;
	public var depthClamp(default, null):Bool;
	public var depthBiasClamp(default, null):Bool;
	public var fillModeNonSolid(default, null):Bool;
	public var depthBounds(default, null):Bool;
	public var wideLines(default, null):Bool;
	public var largePoints(default, null):Bool;
	public var alphaToOne(default, null):Bool;
	public var multiViewport(default, null):Bool;
	public var samplerAnisotropy(default, null):Bool;
	public var textureCompressionETC2(default, null):Bool;
	public var textureCompressionASTC_LDR(default, null):Bool;
	public var textureCompressionBC(default, null):Bool;
	public var occlusionQueryPrecise(default, null):Bool;
	public var pipelineStatisticsQuery(default, null):Bool;
	public var vertexPipelineStoresAndAtomics(default, null):Bool;
	public var fragmentStoresAndAtomics(default, null):Bool;
	public var shaderTessellationAndGeometryPointSize(default, null):Bool;
	public var shaderImageGatherExtended(default, null):Bool;
	public var shaderStorageImageExtendedFormats(default, null):Bool;
	public var shaderStorageImageMultisample(default, null):Bool;
	public var shaderStorageImageReadWithoutFormat(default, null):Bool;
	public var shaderStorageImageWriteWithoutFormat(default, null):Bool;
	public var shaderUniformBufferArrayDynamicIndexing(default, null):Bool;
	public var shaderSampledImageArrayDynamicIndexing(default, null):Bool;
	public var shaderStorageBufferArrayDynamicIndexing(default, null):Bool;
	public var shaderStorageImageArrayDynamicIndexing(default, null):Bool;
	public var shaderClipDistance(default, null):Bool;
	public var shaderCullDistance(default, null):Bool;
	public var shaderFloat64(default, null):Bool;
	public var shaderInt64(default, null):Bool;
	public var shaderInt16(default, null):Bool;
	public var shaderResourceResidency(default, null):Bool;
	public var shaderResourceMinLod(default, null):Bool;
	public var sparseBinding(default, null):Bool;
	public var sparseResidencyBuffer(default, null):Bool;
	public var sparseResidencyImage2D(default, null):Bool;
	public var sparseResidencyImage3D(default, null):Bool;
	public var sparseResidency2Samples(default, null):Bool;
	public var sparseResidency4Samples(default, null):Bool;
	public var sparseResidency8Samples(default, null):Bool;
	public var sparseResidency16Samples(default, null):Bool;
	public var sparseResidencyAliased(default, null):Bool;
	public var variableMultisampleRate(default, null):Bool;
	public var inheritedQueries(default, null):Bool;

	public function new()
	{
	}

	public static function fromDynamic(data:Dynamic):VKPhysicalDeviceFeatures
	{
		if (data == null)
		{
			return null;
		}

		var features = new VKPhysicalDeviceFeatures();
		features.__load(data);
		return features;
	}

	private function __load(data:Dynamic):Void
	{
		robustBufferAccess = (data.robustBufferAccess == true);
		fullDrawIndexUint32 = (data.fullDrawIndexUint32 == true);
		imageCubeArray = (data.imageCubeArray == true);
		independentBlend = (data.independentBlend == true);
		geometryShader = (data.geometryShader == true);
		tessellationShader = (data.tessellationShader == true);
		sampleRateShading = (data.sampleRateShading == true);
		dualSrcBlend = (data.dualSrcBlend == true);
		logicOp = (data.logicOp == true);
		multiDrawIndirect = (data.multiDrawIndirect == true);
		drawIndirectFirstInstance = (data.drawIndirectFirstInstance == true);
		depthClamp = (data.depthClamp == true);
		depthBiasClamp = (data.depthBiasClamp == true);
		fillModeNonSolid = (data.fillModeNonSolid == true);
		depthBounds = (data.depthBounds == true);
		wideLines = (data.wideLines == true);
		largePoints = (data.largePoints == true);
		alphaToOne = (data.alphaToOne == true);
		multiViewport = (data.multiViewport == true);
		samplerAnisotropy = (data.samplerAnisotropy == true);
		textureCompressionETC2 = (data.textureCompressionETC2 == true);
		textureCompressionASTC_LDR = (data.textureCompressionASTC_LDR == true);
		textureCompressionBC = (data.textureCompressionBC == true);
		occlusionQueryPrecise = (data.occlusionQueryPrecise == true);
		pipelineStatisticsQuery = (data.pipelineStatisticsQuery == true);
		vertexPipelineStoresAndAtomics = (data.vertexPipelineStoresAndAtomics == true);
		fragmentStoresAndAtomics = (data.fragmentStoresAndAtomics == true);
		shaderTessellationAndGeometryPointSize = (data.shaderTessellationAndGeometryPointSize == true);
		shaderImageGatherExtended = (data.shaderImageGatherExtended == true);
		shaderStorageImageExtendedFormats = (data.shaderStorageImageExtendedFormats == true);
		shaderStorageImageMultisample = (data.shaderStorageImageMultisample == true);
		shaderStorageImageReadWithoutFormat = (data.shaderStorageImageReadWithoutFormat == true);
		shaderStorageImageWriteWithoutFormat = (data.shaderStorageImageWriteWithoutFormat == true);
		shaderUniformBufferArrayDynamicIndexing = (data.shaderUniformBufferArrayDynamicIndexing == true);
		shaderSampledImageArrayDynamicIndexing = (data.shaderSampledImageArrayDynamicIndexing == true);
		shaderStorageBufferArrayDynamicIndexing = (data.shaderStorageBufferArrayDynamicIndexing == true);
		shaderStorageImageArrayDynamicIndexing = (data.shaderStorageImageArrayDynamicIndexing == true);
		shaderClipDistance = (data.shaderClipDistance == true);
		shaderCullDistance = (data.shaderCullDistance == true);
		shaderFloat64 = (data.shaderFloat64 == true);
		shaderInt64 = (data.shaderInt64 == true);
		shaderInt16 = (data.shaderInt16 == true);
		shaderResourceResidency = (data.shaderResourceResidency == true);
		shaderResourceMinLod = (data.shaderResourceMinLod == true);
		sparseBinding = (data.sparseBinding == true);
		sparseResidencyBuffer = (data.sparseResidencyBuffer == true);
		sparseResidencyImage2D = (data.sparseResidencyImage2D == true);
		sparseResidencyImage3D = (data.sparseResidencyImage3D == true);
		sparseResidency2Samples = (data.sparseResidency2Samples == true);
		sparseResidency4Samples = (data.sparseResidency4Samples == true);
		sparseResidency8Samples = (data.sparseResidency8Samples == true);
		sparseResidency16Samples = (data.sparseResidency16Samples == true);
		sparseResidencyAliased = (data.sparseResidencyAliased == true);
		variableMultisampleRate = (data.variableMultisampleRate == true);
		inheritedQueries = (data.inheritedQueries == true);
	}
}
