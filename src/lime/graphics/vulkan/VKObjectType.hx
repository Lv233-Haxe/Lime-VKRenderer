package lime.graphics.vulkan;

/**
	`VkObjectType` values, extracted verbatim from the Vulkan SDK header.

	`VKPrivateDataSlot` uses these to identify the object a private payload is
	attached to; regenerate with `.workbuddy\scripts\vk_gen_object_type.py`
	when the SDK is upgraded instead of editing them by hand.
**/
class VKObjectType
{
	public static inline var UNKNOWN = 0;
	public static inline var INSTANCE = 1;
	public static inline var PHYSICAL_DEVICE = 2;
	public static inline var DEVICE = 3;
	public static inline var QUEUE = 4;
	public static inline var SEMAPHORE = 5;
	public static inline var COMMAND_BUFFER = 6;
	public static inline var FENCE = 7;
	public static inline var DEVICE_MEMORY = 8;
	public static inline var BUFFER = 9;
	public static inline var IMAGE = 10;
	public static inline var EVENT = 11;
	public static inline var QUERY_POOL = 12;
	public static inline var BUFFER_VIEW = 13;
	public static inline var IMAGE_VIEW = 14;
	public static inline var SHADER_MODULE = 15;
	public static inline var PIPELINE_CACHE = 16;
	public static inline var PIPELINE_LAYOUT = 17;
	public static inline var RENDER_PASS = 18;
	public static inline var PIPELINE = 19;
	public static inline var DESCRIPTOR_SET_LAYOUT = 20;
	public static inline var SAMPLER = 21;
	public static inline var DESCRIPTOR_POOL = 22;
	public static inline var DESCRIPTOR_SET = 23;
	public static inline var FRAMEBUFFER = 24;
	public static inline var COMMAND_POOL = 25;
	public static inline var DESCRIPTOR_UPDATE_TEMPLATE = 1000085000;
	public static inline var SAMPLER_YCBCR_CONVERSION = 1000156000;
	public static inline var PRIVATE_DATA_SLOT = 1000295000;
	public static inline var SURFACE_KHR = 1000000000;
	public static inline var SWAPCHAIN_KHR = 1000001000;
	public static inline var DISPLAY_KHR = 1000002000;
	public static inline var DISPLAY_MODE_KHR = 1000002001;
	public static inline var DEBUG_REPORT_CALLBACK_EXT = 1000011000;
	public static inline var VIDEO_SESSION_KHR = 1000023000;
	public static inline var VIDEO_SESSION_PARAMETERS_KHR = 1000023001;
	public static inline var CU_MODULE_NVX = 1000029000;
	public static inline var CU_FUNCTION_NVX = 1000029001;
	public static inline var DEBUG_UTILS_MESSENGER_EXT = 1000128000;
	public static inline var GPA_SESSION_AMD = 1000133000;
	public static inline var ACCELERATION_STRUCTURE_KHR = 1000150000;
	public static inline var VALIDATION_CACHE_EXT = 1000160000;
	public static inline var ACCELERATION_STRUCTURE_NV = 1000165000;
	public static inline var PERFORMANCE_CONFIGURATION_INTEL = 1000210000;
	public static inline var DEFERRED_OPERATION_KHR = 1000268000;
	public static inline var INDIRECT_COMMANDS_LAYOUT_NV = 1000277000;
	public static inline var CUDA_MODULE_NV = 1000307000;
	public static inline var CUDA_FUNCTION_NV = 1000307001;
	public static inline var BUFFER_COLLECTION_FUCHSIA = 1000366000;
	public static inline var MICROMAP_EXT = 1000396000;
	public static inline var TENSOR_ARM = 1000460000;
	public static inline var TENSOR_VIEW_ARM = 1000460001;
	public static inline var OPTICAL_FLOW_SESSION_NV = 1000464000;
	public static inline var SHADER_EXT = 1000482000;
	public static inline var PIPELINE_BINARY_KHR = 1000483000;
	public static inline var DATA_GRAPH_PIPELINE_SESSION_ARM = 1000507000;
	public static inline var EXTERNAL_COMPUTE_QUEUE_NV = 1000556000;
	public static inline var INDIRECT_COMMANDS_LAYOUT_EXT = 1000572000;
	public static inline var INDIRECT_EXECUTION_SET_EXT = 1000572001;
	public static inline var SHADER_INSTRUMENTATION_ARM = 1000607000;
}
