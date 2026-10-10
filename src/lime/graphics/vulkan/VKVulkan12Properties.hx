package lime.graphics.vulkan;

import haxe.Int64;

/**
	`VkPhysicalDeviceVulkan12Properties` — Vulkan 1.2 properties.

	Obtained from `VKPhysicalDevice`; decode the object returned by the
	corresponding query with `fromDynamic`.

	@see docs/vulkan-progress.md
**/
class VKVulkan12Properties
{
	public var driverID(default, null):Int;
	public var driverName(default, null):String;
	public var driverInfo(default, null):String;
	public var conformanceVersionMajor(default, null):Int;
	public var conformanceVersionMinor(default, null):Int;
	public var conformanceVersionSubminor(default, null):Int;
	public var conformanceVersionPatch(default, null):Int;
	public var denormBehaviorIndependence(default, null):Int;
	public var roundingModeIndependence(default, null):Int;
	public var shaderSignedZeroInfNanPreserveFloat16(default, null):Bool;
	public var shaderSignedZeroInfNanPreserveFloat32(default, null):Bool;
	public var shaderSignedZeroInfNanPreserveFloat64(default, null):Bool;
	public var shaderDenormPreserveFloat16(default, null):Bool;
	public var shaderDenormPreserveFloat32(default, null):Bool;
	public var shaderDenormPreserveFloat64(default, null):Bool;
	public var shaderDenormFlushToZeroFloat16(default, null):Bool;
	public var shaderDenormFlushToZeroFloat32(default, null):Bool;
	public var shaderDenormFlushToZeroFloat64(default, null):Bool;
	public var shaderRoundingModeRTEFloat16(default, null):Bool;
	public var shaderRoundingModeRTEFloat32(default, null):Bool;
	public var shaderRoundingModeRTEFloat64(default, null):Bool;
	public var shaderRoundingModeRTZFloat16(default, null):Bool;
	public var shaderRoundingModeRTZFloat32(default, null):Bool;
	public var shaderRoundingModeRTZFloat64(default, null):Bool;
	public var maxUpdateAfterBindDescriptorsInAllPools(default, null):Int;
	public var shaderUniformBufferArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderSampledImageArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderStorageBufferArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderStorageImageArrayNonUniformIndexingNative(default, null):Bool;
	public var shaderInputAttachmentArrayNonUniformIndexingNative(default, null):Bool;
	public var robustBufferAccessUpdateAfterBind(default, null):Bool;
	public var quadDivergentImplicitLod(default, null):Bool;
	public var maxPerStageDescriptorUpdateAfterBindSamplers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindUniformBuffers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindStorageBuffers(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindSampledImages(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindStorageImages(default, null):Int;
	public var maxPerStageDescriptorUpdateAfterBindInputAttachments(default, null):Int;
	public var maxPerStageUpdateAfterBindResources(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindSamplers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindUniformBuffers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindUniformBuffersDynamic(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageBuffers(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageBuffersDynamic(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindSampledImages(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindStorageImages(default, null):Int;
	public var maxDescriptorSetUpdateAfterBindInputAttachments(default, null):Int;
	public var supportedDepthResolveModes(default, null):Int;
	public var supportedStencilResolveModes(default, null):Int;
	public var independentResolveNone(default, null):Bool;
	public var independentResolve(default, null):Bool;
	public var filterMinmaxSingleComponentFormats(default, null):Bool;
	public var filterMinmaxImageComponentMapping(default, null):Bool;
	public var maxTimelineSemaphoreValueDifference(default, null):Int64;
	public var framebufferIntegerColorSampleCounts(default, null):Int;

	public function new()
	{
	}

	public static function fromDynamic(data:Dynamic):VKVulkan12Properties
	{
		if (data == null)
		{
			return null;
		}

		var result = new VKVulkan12Properties();
		result.__load (data);
		return result;
	}

	private function __load(data:Dynamic):Void
	{
		driverID = data.driverID;
		driverName = data.driverName;
		driverInfo = data.driverInfo;
		// The C++ side flattens VkConformanceVersion into four ints
		// (conformanceVersionMajor/Minor/Subminor/Patch) - reading
		// `data.conformanceVersion.major` would touch a field that does not
		// exist, which is a hard crash under hxcpp.
		conformanceVersionMajor = data.conformanceVersionMajor;
		conformanceVersionMinor = data.conformanceVersionMinor;
		conformanceVersionSubminor = data.conformanceVersionSubminor;
		conformanceVersionPatch = data.conformanceVersionPatch;
		denormBehaviorIndependence = data.denormBehaviorIndependence;
		roundingModeIndependence = data.roundingModeIndependence;
		shaderSignedZeroInfNanPreserveFloat16 = (data.shaderSignedZeroInfNanPreserveFloat16 == true);
		shaderSignedZeroInfNanPreserveFloat32 = (data.shaderSignedZeroInfNanPreserveFloat32 == true);
		shaderSignedZeroInfNanPreserveFloat64 = (data.shaderSignedZeroInfNanPreserveFloat64 == true);
		shaderDenormPreserveFloat16 = (data.shaderDenormPreserveFloat16 == true);
		shaderDenormPreserveFloat32 = (data.shaderDenormPreserveFloat32 == true);
		shaderDenormPreserveFloat64 = (data.shaderDenormPreserveFloat64 == true);
		shaderDenormFlushToZeroFloat16 = (data.shaderDenormFlushToZeroFloat16 == true);
		shaderDenormFlushToZeroFloat32 = (data.shaderDenormFlushToZeroFloat32 == true);
		shaderDenormFlushToZeroFloat64 = (data.shaderDenormFlushToZeroFloat64 == true);
		shaderRoundingModeRTEFloat16 = (data.shaderRoundingModeRTEFloat16 == true);
		shaderRoundingModeRTEFloat32 = (data.shaderRoundingModeRTEFloat32 == true);
		shaderRoundingModeRTEFloat64 = (data.shaderRoundingModeRTEFloat64 == true);
		shaderRoundingModeRTZFloat16 = (data.shaderRoundingModeRTZFloat16 == true);
		shaderRoundingModeRTZFloat32 = (data.shaderRoundingModeRTZFloat32 == true);
		shaderRoundingModeRTZFloat64 = (data.shaderRoundingModeRTZFloat64 == true);
		maxUpdateAfterBindDescriptorsInAllPools = data.maxUpdateAfterBindDescriptorsInAllPools;
		shaderUniformBufferArrayNonUniformIndexingNative = (data.shaderUniformBufferArrayNonUniformIndexingNative == true);
		shaderSampledImageArrayNonUniformIndexingNative = (data.shaderSampledImageArrayNonUniformIndexingNative == true);
		shaderStorageBufferArrayNonUniformIndexingNative = (data.shaderStorageBufferArrayNonUniformIndexingNative == true);
		shaderStorageImageArrayNonUniformIndexingNative = (data.shaderStorageImageArrayNonUniformIndexingNative == true);
		shaderInputAttachmentArrayNonUniformIndexingNative = (data.shaderInputAttachmentArrayNonUniformIndexingNative == true);
		robustBufferAccessUpdateAfterBind = (data.robustBufferAccessUpdateAfterBind == true);
		quadDivergentImplicitLod = (data.quadDivergentImplicitLod == true);
		maxPerStageDescriptorUpdateAfterBindSamplers = data.maxPerStageDescriptorUpdateAfterBindSamplers;
		maxPerStageDescriptorUpdateAfterBindUniformBuffers = data.maxPerStageDescriptorUpdateAfterBindUniformBuffers;
		maxPerStageDescriptorUpdateAfterBindStorageBuffers = data.maxPerStageDescriptorUpdateAfterBindStorageBuffers;
		maxPerStageDescriptorUpdateAfterBindSampledImages = data.maxPerStageDescriptorUpdateAfterBindSampledImages;
		maxPerStageDescriptorUpdateAfterBindStorageImages = data.maxPerStageDescriptorUpdateAfterBindStorageImages;
		maxPerStageDescriptorUpdateAfterBindInputAttachments = data.maxPerStageDescriptorUpdateAfterBindInputAttachments;
		maxPerStageUpdateAfterBindResources = data.maxPerStageUpdateAfterBindResources;
		maxDescriptorSetUpdateAfterBindSamplers = data.maxDescriptorSetUpdateAfterBindSamplers;
		maxDescriptorSetUpdateAfterBindUniformBuffers = data.maxDescriptorSetUpdateAfterBindUniformBuffers;
		maxDescriptorSetUpdateAfterBindUniformBuffersDynamic = data.maxDescriptorSetUpdateAfterBindUniformBuffersDynamic;
		maxDescriptorSetUpdateAfterBindStorageBuffers = data.maxDescriptorSetUpdateAfterBindStorageBuffers;
		maxDescriptorSetUpdateAfterBindStorageBuffersDynamic = data.maxDescriptorSetUpdateAfterBindStorageBuffersDynamic;
		maxDescriptorSetUpdateAfterBindSampledImages = data.maxDescriptorSetUpdateAfterBindSampledImages;
		maxDescriptorSetUpdateAfterBindStorageImages = data.maxDescriptorSetUpdateAfterBindStorageImages;
		maxDescriptorSetUpdateAfterBindInputAttachments = data.maxDescriptorSetUpdateAfterBindInputAttachments;
		supportedDepthResolveModes = data.supportedDepthResolveModes;
		supportedStencilResolveModes = data.supportedStencilResolveModes;
		independentResolveNone = (data.independentResolveNone == true);
		independentResolve = (data.independentResolve == true);
		filterMinmaxSingleComponentFormats = (data.filterMinmaxSingleComponentFormats == true);
		filterMinmaxImageComponentMapping = (data.filterMinmaxImageComponentMapping == true);
		maxTimelineSemaphoreValueDifference = Int64.make (data.maxTimelineSemaphoreValueDifference.high, data.maxTimelineSemaphoreValueDifference.low);
		framebufferIntegerColorSampleCounts = data.framebufferIntegerColorSampleCounts;
	}
}
