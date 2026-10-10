package lime.graphics.vulkan;

import haxe.Int64;

/**
	`VkPhysicalDeviceProperties2` — the Vulkan 1.1 property query.

	Carries the core `VkPhysicalDeviceProperties` subset plus the two 1.1 property
	structs chained onto it (`maintenance3`, `multiview`).

	The float limits (`timestampPeriod`, `maxSamplerAnisotropy`) arrive as decimal
	text from C++ — hxcpp's NEKO_COMPATIBLE CFFI has no double allocator — and are
	parsed here, so the Haxe surface stays `Float`.

	@see docs/vulkan-progress.md
**/
class VKPhysicalDeviceProperties2
{
	public var deviceName(default, null):String;
	public var apiVersion(default, null):Int;
	public var driverVersion(default, null):Int;
	public var vendorID(default, null):Int;
	public var deviceID(default, null):Int;
	public var deviceType(default, null):Int;
	public var maxImageDimension1D(default, null):Int;
	public var maxImageDimension2D(default, null):Int;
	public var maxImageDimension3D(default, null):Int;
	public var maxImageArrayLayers(default, null):Int;
	public var maxUniformBufferRange(default, null):Int;
	public var maxStorageBufferRange(default, null):Int;
	public var maxPushConstantsSize(default, null):Int;
	public var bufferImageGranularity(default, null):Int64;
	public var maxBoundDescriptorSets(default, null):Int;
	public var maxPerStageDescriptorSamplers(default, null):Int;
	public var maxPerStageDescriptorSampledImages(default, null):Int;
	public var maxDescriptorSetSamplers(default, null):Int;
	public var maxDescriptorSetSampledImages(default, null):Int;
	public var maxVertexInputAttributes(default, null):Int;
	public var maxVertexInputBindings(default, null):Int;
	public var maxFragmentOutputAttachments(default, null):Int;
	public var maxComputeSharedMemorySize(default, null):Int;
	public var maxComputeWorkGroupCount0(default, null):Int;
	public var maxComputeWorkGroupCount1(default, null):Int;
	public var maxComputeWorkGroupCount2(default, null):Int;
	public var maxComputeWorkGroupInvocations(default, null):Int;
	public var maxComputeWorkGroupSize0(default, null):Int;
	public var maxComputeWorkGroupSize1(default, null):Int;
	public var maxComputeWorkGroupSize2(default, null):Int;
	public var maxFramebufferWidth(default, null):Int;
	public var maxFramebufferHeight(default, null):Int;
	public var maxFramebufferLayers(default, null):Int;
	public var maxColorAttachments(default, null):Int;
	public var maxViewportWidth(default, null):Int;
	public var maxViewportHeight(default, null):Int;
	public var maxSamplerAnisotropy(default, null):Float;
	public var timestampPeriod(default, null):Float;
	public var minMemoryMapAlignment(default, null):Int64;
	public var nonCoherentAtomSize(default, null):Int64;
	public var optimalBufferCopyOffsetAlignment(default, null):Int64;
	public var minUniformBufferOffsetAlignment(default, null):Int64;
	public var minStorageBufferOffsetAlignment(default, null):Int64;
	public var framebufferColorSampleCounts(default, null):Int;
	public var framebufferDepthSampleCounts(default, null):Int;
	public var framebufferStencilSampleCounts(default, null):Int;
	public var framebufferNoAttachmentsSampleCounts(default, null):Int;
	public var residencyStandard2DBlockShape(default, null):Bool;
	public var residencyAlignedMipSize(default, null):Bool;
	public var residencyNonResidentStrict(default, null):Bool;
	public var maintenance3(default, null):VKMaintenance3Properties;
	public var multiview(default, null):VKMultiviewProperties;

	public function new()
	{
	}

	public static function fromDynamic(data:Dynamic):VKPhysicalDeviceProperties2
	{
		if (data == null)
		{
			return null;
		}

		var result = new VKPhysicalDeviceProperties2();
		result.__load (data);
		return result;
	}

	private function __load(data:Dynamic):Void
	{
		deviceName = data.deviceName;
		apiVersion = data.apiVersion;
		driverVersion = data.driverVersion;
		vendorID = data.vendorID;
		deviceID = data.deviceID;
		deviceType = data.deviceType;
		maxImageDimension1D = data.maxImageDimension1D;
		maxImageDimension2D = data.maxImageDimension2D;
		maxImageDimension3D = data.maxImageDimension3D;
		maxImageArrayLayers = data.maxImageArrayLayers;
		maxUniformBufferRange = data.maxUniformBufferRange;
		maxStorageBufferRange = data.maxStorageBufferRange;
		maxPushConstantsSize = data.maxPushConstantsSize;
		bufferImageGranularity = Int64.make (data.bufferImageGranularity.high, data.bufferImageGranularity.low);
		maxBoundDescriptorSets = data.maxBoundDescriptorSets;
		maxPerStageDescriptorSamplers = data.maxPerStageDescriptorSamplers;
		maxPerStageDescriptorSampledImages = data.maxPerStageDescriptorSampledImages;
		maxDescriptorSetSamplers = data.maxDescriptorSetSamplers;
		maxDescriptorSetSampledImages = data.maxDescriptorSetSampledImages;
		maxVertexInputAttributes = data.maxVertexInputAttributes;
		maxVertexInputBindings = data.maxVertexInputBindings;
		maxFragmentOutputAttachments = data.maxFragmentOutputAttachments;
		maxComputeSharedMemorySize = data.maxComputeSharedMemorySize;
		maxComputeWorkGroupCount0 = data.maxComputeWorkGroupCount0;
		maxComputeWorkGroupCount1 = data.maxComputeWorkGroupCount1;
		maxComputeWorkGroupCount2 = data.maxComputeWorkGroupCount2;
		maxComputeWorkGroupInvocations = data.maxComputeWorkGroupInvocations;
		maxComputeWorkGroupSize0 = data.maxComputeWorkGroupSize0;
		maxComputeWorkGroupSize1 = data.maxComputeWorkGroupSize1;
		maxComputeWorkGroupSize2 = data.maxComputeWorkGroupSize2;
		maxFramebufferWidth = data.maxFramebufferWidth;
		maxFramebufferHeight = data.maxFramebufferHeight;
		maxFramebufferLayers = data.maxFramebufferLayers;
		maxColorAttachments = data.maxColorAttachments;
		maxViewportWidth = data.maxViewportWidth;
		maxViewportHeight = data.maxViewportHeight;
		maxSamplerAnisotropy = Std.parseFloat (data.maxSamplerAnisotropy);
		timestampPeriod = Std.parseFloat (data.timestampPeriod);
		minMemoryMapAlignment = Int64.make (data.minMemoryMapAlignment.high, data.minMemoryMapAlignment.low);
		nonCoherentAtomSize = Int64.make (data.nonCoherentAtomSize.high, data.nonCoherentAtomSize.low);
		optimalBufferCopyOffsetAlignment = Int64.make (data.optimalBufferCopyOffsetAlignment.high, data.optimalBufferCopyOffsetAlignment.low);
		minUniformBufferOffsetAlignment = Int64.make (data.minUniformBufferOffsetAlignment.high, data.minUniformBufferOffsetAlignment.low);
		minStorageBufferOffsetAlignment = Int64.make (data.minStorageBufferOffsetAlignment.high, data.minStorageBufferOffsetAlignment.low);
		framebufferColorSampleCounts = data.framebufferColorSampleCounts;
		framebufferDepthSampleCounts = data.framebufferDepthSampleCounts;
		framebufferStencilSampleCounts = data.framebufferStencilSampleCounts;
		framebufferNoAttachmentsSampleCounts = data.framebufferNoAttachmentsSampleCounts;
		residencyStandard2DBlockShape = (data.residencyStandard2DBlockShape == true);
		residencyAlignedMipSize = (data.residencyAlignedMipSize == true);
		residencyNonResidentStrict = (data.residencyNonResidentStrict == true);
		maintenance3 = VKMaintenance3Properties.fromDynamic (data.maintenance3);
		multiview = VKMultiviewProperties.fromDynamic (data.multiview);
	}
}
