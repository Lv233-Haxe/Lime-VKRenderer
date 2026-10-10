package lime.graphics.vulkan;

import haxe.Int64;
import lime.graphics.VulkanRenderContext;
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
#end
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	Entry point for Lime's Vulkan API surface.

	Like `lime.graphics.opengl.GL`, this class is the public place for low-level
	graphics API access. Vulkan is explicit by design, so the API is organized
	around handles and lifecycle objects instead of GL-style global state.
**/
class VK
{
	public static inline var SUCCESS = 0;
	public static inline var NOT_READY = 1;
	public static inline var TIMEOUT = 2;
	public static inline var EVENT_SET = 3;
	public static inline var EVENT_RESET = 4;
	public static inline var INCOMPLETE = 5;
	public static inline var SUBOPTIMAL_KHR = 1000001003;
	public static inline var ERROR_INITIALIZATION_FAILED = -3;
	public static inline var ERROR_OUT_OF_DATE_KHR = -1000001004;

	public static inline var KHR_SWAPCHAIN_EXTENSION_NAME = "VK_KHR_swapchain";

	public static inline var PHYSICAL_DEVICE_TYPE_OTHER = 0;
	public static inline var PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU = 1;
	public static inline var PHYSICAL_DEVICE_TYPE_DISCRETE_GPU = 2;
	public static inline var PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU = 3;
	public static inline var PHYSICAL_DEVICE_TYPE_CPU = 4;

	public static inline var QUEUE_GRAPHICS_BIT = 0x00000001;
	public static inline var QUEUE_COMPUTE_BIT = 0x00000002;
	public static inline var QUEUE_TRANSFER_BIT = 0x00000004;
	public static inline var QUEUE_SPARSE_BINDING_BIT = 0x00000008;

	public static inline var IMAGE_CREATE_SPARSE_BINDING_BIT = 0x00000001;
	public static inline var IMAGE_CREATE_SPARSE_RESIDENCY_BIT = 0x00000002;
	public static inline var IMAGE_CREATE_SPARSE_ALIASED_BIT = 0x00000004;
	public static inline var IMAGE_CREATE_CUBE_COMPATIBLE_BIT = 0x00000010;

	public static inline var COMMAND_POOL_CREATE_TRANSIENT_BIT = 0x00000001;
	public static inline var COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT = 0x00000002;
	public static inline var COMMAND_POOL_CREATE_PROTECTED_BIT = 0x00000004;

	public static inline var COMMAND_BUFFER_LEVEL_PRIMARY = 0;
	public static inline var COMMAND_BUFFER_LEVEL_SECONDARY = 1;

	public static inline var COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT = 0x00000001;
	public static inline var COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT = 0x00000002;
	public static inline var COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT = 0x00000004;

	public static inline var COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT = 0x00000001;

	public static inline var FENCE_CREATE_SIGNALED_BIT = 0x00000001;

	public static inline var SEMAPHORE_TYPE_BINARY = 0;
	public static inline var SEMAPHORE_TYPE_TIMELINE = 1;

	public static inline var DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT = 0x00000001;

	public static inline var FORMAT_UNDEFINED = 0;
	public static inline var FORMAT_R8_UNORM = 9;
	public static inline var FORMAT_R8G8_UNORM = 16;
	public static inline var FORMAT_R8G8B8A8_UNORM = 37;
	public static inline var FORMAT_R8G8B8A8_SRGB = 43;
	public static inline var FORMAT_B8G8R8A8_UNORM = 44;
	public static inline var FORMAT_B8G8R8A8_SRGB = 50;
	public static inline var FORMAT_R16G16B16A16_SFLOAT = 97;
	public static inline var FORMAT_R32_SFLOAT = 100;
	public static inline var FORMAT_R32G32_SFLOAT = 103;
	public static inline var FORMAT_R32G32B32_SFLOAT = 106;
	public static inline var FORMAT_R32G32B32A32_SFLOAT = 109;
	public static inline var FORMAT_D16_UNORM = 124;
	public static inline var FORMAT_X8_D24_UNORM_PACK32 = 125;
	public static inline var FORMAT_D32_SFLOAT = 126;
	public static inline var FORMAT_S8_UINT = 127;
	public static inline var FORMAT_D24_UNORM_S8_UINT = 129;
	public static inline var FORMAT_D32_SFLOAT_S8_UINT = 130;

	public static inline var COLOR_SPACE_SRGB_NONLINEAR_KHR = 0;

	// vulkan_core.h: VK_SHARING_MODE_EXCLUSIVE = 0, VK_SHARING_MODE_CONCURRENT = 1
	public static inline var SHARING_MODE_EXCLUSIVE = 0;
	public static inline var SHARING_MODE_CONCURRENT = 1;

	// vulkan_core.h: VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR = 0x00000001
	public static inline var COMPOSITE_ALPHA_OPAQUE_BIT_KHR = 0x00000001;

	public static inline var PRESENT_MODE_IMMEDIATE_KHR = 0;
	public static inline var PRESENT_MODE_MAILBOX_KHR = 1;
	public static inline var PRESENT_MODE_FIFO_KHR = 2;
	public static inline var PRESENT_MODE_FIFO_RELAXED_KHR = 3;

	public static inline var BUFFER_USAGE_TRANSFER_SRC_BIT = 0x00000001;
	public static inline var BUFFER_USAGE_TRANSFER_DST_BIT = 0x00000002;
	public static inline var BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT = 0x00000004;
	public static inline var BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT = 0x00000008;
	public static inline var BUFFER_USAGE_UNIFORM_BUFFER_BIT = 0x00000010;
	public static inline var BUFFER_USAGE_STORAGE_BUFFER_BIT = 0x00000020;
	public static inline var BUFFER_USAGE_INDEX_BUFFER_BIT = 0x00000040;
	public static inline var BUFFER_USAGE_VERTEX_BUFFER_BIT = 0x00000080;
	public static inline var BUFFER_USAGE_INDIRECT_BUFFER_BIT = 0x00000100;

	public static inline var MEMORY_PROPERTY_DEVICE_LOCAL_BIT = 0x00000001;
	public static inline var MEMORY_PROPERTY_HOST_VISIBLE_BIT = 0x00000002;
	public static inline var MEMORY_PROPERTY_HOST_COHERENT_BIT = 0x00000004;
	public static inline var MEMORY_PROPERTY_HOST_CACHED_BIT = 0x00000008;
	public static inline var MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT = 0x00000010;

	public static inline var IMAGE_TYPE_1D = 0;
	public static inline var IMAGE_TYPE_2D = 1;
	public static inline var IMAGE_TYPE_3D = 2;

	public static inline var IMAGE_TILING_OPTIMAL = 0;
	public static inline var IMAGE_TILING_LINEAR = 1;

	public static inline var IMAGE_USAGE_TRANSFER_SRC_BIT = 0x00000001;
	public static inline var IMAGE_USAGE_TRANSFER_DST_BIT = 0x00000002;
	public static inline var IMAGE_USAGE_SAMPLED_BIT = 0x00000004;
	public static inline var IMAGE_USAGE_STORAGE_BIT = 0x00000008;
	public static inline var IMAGE_USAGE_COLOR_ATTACHMENT_BIT = 0x00000010;
	public static inline var IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT = 0x00000020;
	public static inline var IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT = 0x00000040;
	public static inline var IMAGE_USAGE_INPUT_ATTACHMENT_BIT = 0x00000080;

	public static inline var IMAGE_ASPECT_COLOR_BIT = 0x00000001;
	public static inline var IMAGE_ASPECT_DEPTH_BIT = 0x00000002;
	public static inline var IMAGE_ASPECT_STENCIL_BIT = 0x00000004;
	public static inline var IMAGE_ASPECT_METADATA_BIT = 0x00000008;

	public static inline var COLOR_COMPONENT_R_BIT = 0x00000001;
	public static inline var COLOR_COMPONENT_G_BIT = 0x00000002;
	public static inline var COLOR_COMPONENT_B_BIT = 0x00000004;
	public static inline var COLOR_COMPONENT_A_BIT = 0x00000008;
	public static inline var COLOR_COMPONENT_RGBA_BITS = COLOR_COMPONENT_R_BIT | COLOR_COMPONENT_G_BIT | COLOR_COMPONENT_B_BIT | COLOR_COMPONENT_A_BIT;

	public static inline var IMAGE_LAYOUT_UNDEFINED = 0;
	public static inline var IMAGE_LAYOUT_GENERAL = 1;
	public static inline var IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL = 2;
	public static inline var IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL = 3;
	public static inline var IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL = 4;
	public static inline var IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL = 5;
	public static inline var IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL = 6;
	public static inline var IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL = 7;
	public static inline var IMAGE_LAYOUT_PREINITIALIZED = 8;
	public static inline var IMAGE_LAYOUT_PRESENT_SRC_KHR = 1000001002;

	public static inline var IMAGE_VIEW_TYPE_1D = 0;
	public static inline var IMAGE_VIEW_TYPE_2D = 1;
	public static inline var IMAGE_VIEW_TYPE_3D = 2;
	public static inline var IMAGE_VIEW_TYPE_CUBE = 3;
	public static inline var IMAGE_VIEW_TYPE_1D_ARRAY = 4;
	public static inline var IMAGE_VIEW_TYPE_2D_ARRAY = 5;
	public static inline var IMAGE_VIEW_TYPE_CUBE_ARRAY = 6;

	public static inline var PIPELINE_STAGE_TOP_OF_PIPE_BIT = 0x00000001;
	public static inline var PIPELINE_STAGE_DRAW_INDIRECT_BIT = 0x00000002;
	public static inline var PIPELINE_STAGE_VERTEX_INPUT_BIT = 0x00000004;
	public static inline var PIPELINE_STAGE_VERTEX_SHADER_BIT = 0x00000008;
	public static inline var PIPELINE_STAGE_FRAGMENT_SHADER_BIT = 0x00000080;
	public static inline var PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT = 0x00000100;
	public static inline var PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT = 0x00000200;
	public static inline var PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT = 0x00000400;
	public static inline var PIPELINE_STAGE_TRANSFER_BIT = 0x00001000;
	public static inline var PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT = 0x00002000;
	public static inline var PIPELINE_STAGE_HOST_BIT = 0x00004000;
	public static inline var PIPELINE_STAGE_ALL_GRAPHICS_BIT = 0x00008000;
	public static inline var PIPELINE_STAGE_ALL_COMMANDS_BIT = 0x00010000;

	public static inline var ACCESS_INDIRECT_COMMAND_READ_BIT = 0x00000001;
	public static inline var ACCESS_INDEX_READ_BIT = 0x00000002;
	public static inline var ACCESS_VERTEX_ATTRIBUTE_READ_BIT = 0x00000004;
	public static inline var ACCESS_UNIFORM_READ_BIT = 0x00000008;
	public static inline var ACCESS_INPUT_ATTACHMENT_READ_BIT = 0x00000010;
	public static inline var ACCESS_SHADER_READ_BIT = 0x00000020;
	public static inline var ACCESS_SHADER_WRITE_BIT = 0x00000040;
	public static inline var ACCESS_COLOR_ATTACHMENT_READ_BIT = 0x00000080;
	public static inline var ACCESS_COLOR_ATTACHMENT_WRITE_BIT = 0x00000100;
	public static inline var ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT = 0x00000200;
	public static inline var ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT = 0x00000400;
	public static inline var ACCESS_TRANSFER_READ_BIT = 0x00000800;
	public static inline var ACCESS_TRANSFER_WRITE_BIT = 0x00001000;
	public static inline var ACCESS_HOST_READ_BIT = 0x00002000;
	public static inline var ACCESS_HOST_WRITE_BIT = 0x00004000;
	public static inline var ACCESS_MEMORY_READ_BIT = 0x00008000;
	public static inline var ACCESS_MEMORY_WRITE_BIT = 0x00010000;

	public static inline var SHADER_STAGE_VERTEX_BIT = 0x00000001;
	public static inline var SHADER_STAGE_TESSELLATION_CONTROL_BIT = 0x00000002;
	public static inline var SHADER_STAGE_TESSELLATION_EVALUATION_BIT = 0x00000004;
	public static inline var SHADER_STAGE_GEOMETRY_BIT = 0x00000008;
	public static inline var SHADER_STAGE_FRAGMENT_BIT = 0x00000010;
	public static inline var SHADER_STAGE_COMPUTE_BIT = 0x00000020;
	public static inline var SHADER_STAGE_ALL_GRAPHICS = 0x0000001F;
	public static inline var SHADER_STAGE_ALL = 0x7FFFFFFF;

	public static inline var DESCRIPTOR_TYPE_SAMPLER = 0;
	public static inline var DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER = 1;
	public static inline var DESCRIPTOR_TYPE_SAMPLED_IMAGE = 2;
	public static inline var DESCRIPTOR_TYPE_STORAGE_IMAGE = 3;
	public static inline var DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER = 4;
	public static inline var DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER = 5;
	public static inline var DESCRIPTOR_TYPE_UNIFORM_BUFFER = 6;
	public static inline var DESCRIPTOR_TYPE_STORAGE_BUFFER = 7;
	public static inline var DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC = 8;
	public static inline var DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC = 9;
	public static inline var DESCRIPTOR_TYPE_INPUT_ATTACHMENT = 10;

	/**
		Update-after-bind-style inline uniform block descriptor (Vulkan 1.3 core,
		originally `VK_EXT_inline_uniform_block`); a binding of this type is a
		uniform buffer whose storage lives inside the descriptor set itself.
	**/
	public static inline var DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK = 1000138000;

	public static inline var PRIMITIVE_TOPOLOGY_POINT_LIST = 0;
	public static inline var PRIMITIVE_TOPOLOGY_LINE_LIST = 1;
	public static inline var PRIMITIVE_TOPOLOGY_LINE_STRIP = 2;
	public static inline var PRIMITIVE_TOPOLOGY_TRIANGLE_LIST = 3;
	public static inline var PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP = 4;
	public static inline var PRIMITIVE_TOPOLOGY_TRIANGLE_FAN = 5;

	public static inline var POLYGON_MODE_FILL = 0;
	public static inline var POLYGON_MODE_LINE = 1;
	public static inline var POLYGON_MODE_POINT = 2;

	public static inline var CULL_MODE_NONE = 0;
	public static inline var CULL_MODE_FRONT_BIT = 0x00000001;
	public static inline var CULL_MODE_BACK_BIT = 0x00000002;
	public static inline var CULL_MODE_FRONT_AND_BACK = 0x00000003;

	public static inline var FRONT_FACE_COUNTER_CLOCKWISE = 0;
	public static inline var FRONT_FACE_CLOCKWISE = 1;

	public static inline var COMPARE_OP_NEVER = 0;
	public static inline var COMPARE_OP_LESS = 1;
	public static inline var COMPARE_OP_EQUAL = 2;
	public static inline var COMPARE_OP_LESS_OR_EQUAL = 3;
	public static inline var COMPARE_OP_GREATER = 4;
	public static inline var COMPARE_OP_NOT_EQUAL = 5;
	public static inline var COMPARE_OP_GREATER_OR_EQUAL = 6;
	public static inline var COMPARE_OP_ALWAYS = 7;

	public static inline var STENCIL_OP_KEEP = 0;
	public static inline var STENCIL_OP_ZERO = 1;
	public static inline var STENCIL_OP_REPLACE = 2;
	public static inline var STENCIL_OP_INCREMENT_AND_CLAMP = 3;
	public static inline var STENCIL_OP_DECREMENT_AND_CLAMP = 4;
	public static inline var STENCIL_OP_INVERT = 5;
	public static inline var STENCIL_OP_INCREMENT_AND_WRAP = 6;
	public static inline var STENCIL_OP_DECREMENT_AND_WRAP = 7;

	// VkStencilFaceFlagBits (values verified against vulkan_core.h)
	public static inline var STENCIL_FACE_FRONT_BIT = 0x00000001;
	public static inline var STENCIL_FACE_BACK_BIT = 0x00000002;
	public static inline var STENCIL_FACE_FRONT_AND_BACK = 0x00000003;

	public static inline var BLEND_FACTOR_ZERO = 0;
	public static inline var BLEND_FACTOR_ONE = 1;
	public static inline var BLEND_FACTOR_SRC_COLOR = 2;
	public static inline var BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 3;
	public static inline var BLEND_FACTOR_DST_COLOR = 4;
	public static inline var BLEND_FACTOR_ONE_MINUS_DST_COLOR = 5;
	public static inline var BLEND_FACTOR_SRC_ALPHA = 6;
	public static inline var BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 7;
	public static inline var BLEND_FACTOR_DST_ALPHA = 8;
	public static inline var BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 9;
	public static inline var BLEND_FACTOR_CONSTANT_COLOR = 10;
	public static inline var BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR = 11;
	public static inline var BLEND_FACTOR_CONSTANT_ALPHA = 12;
	public static inline var BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA = 13;
	public static inline var BLEND_FACTOR_SRC_ALPHA_SATURATE = 14;

	public static inline var BLEND_OP_ADD = 0;
	public static inline var BLEND_OP_SUBTRACT = 1;
	public static inline var BLEND_OP_REVERSE_SUBTRACT = 2;
	public static inline var BLEND_OP_MIN = 3;
	public static inline var BLEND_OP_MAX = 4;

	public static inline var DYNAMIC_STATE_VIEWPORT = 0;
	public static inline var DYNAMIC_STATE_SCISSOR = 1;
	public static inline var DYNAMIC_STATE_LINE_WIDTH = 2;
	public static inline var DYNAMIC_STATE_DEPTH_BIAS = 3;
	public static inline var DYNAMIC_STATE_BLEND_CONSTANTS = 4;
	public static inline var DYNAMIC_STATE_DEPTH_BOUNDS = 5;
	public static inline var DYNAMIC_STATE_STENCIL_COMPARE_MASK = 6;
	public static inline var DYNAMIC_STATE_STENCIL_WRITE_MASK = 7;
	public static inline var DYNAMIC_STATE_STENCIL_REFERENCE = 8;
	public static inline var DYNAMIC_STATE_VIEWPORT_BIT = 0x00000001;
	public static inline var DYNAMIC_STATE_SCISSOR_BIT = 0x00000002;

	public static inline var SAMPLE_COUNT_1_BIT = 0x00000001;
	public static inline var SAMPLE_COUNT_2_BIT = 0x00000002;
	public static inline var SAMPLE_COUNT_4_BIT = 0x00000004;
	public static inline var SAMPLE_COUNT_8_BIT = 0x00000008;
	public static inline var SAMPLE_COUNT_16_BIT = 0x00000010;
	public static inline var SAMPLE_COUNT_32_BIT = 0x00000020;
	public static inline var SAMPLE_COUNT_64_BIT = 0x00000040;

	public static inline var INDEX_TYPE_UINT16 = 0;
	public static inline var INDEX_TYPE_UINT32 = 1;
	public static inline var INDEX_TYPE_UINT8_KHR = 1000265000;

	public static inline var ATTACHMENT_LOAD_OP_LOAD = 0;
	public static inline var ATTACHMENT_LOAD_OP_CLEAR = 1;
	public static inline var ATTACHMENT_LOAD_OP_DONT_CARE = 2;
	public static inline var ATTACHMENT_STORE_OP_STORE = 0;
	public static inline var ATTACHMENT_STORE_OP_DONT_CARE = 1;

	public static inline var FILTER_NEAREST = 0;
	public static inline var FILTER_LINEAR = 1;
	public static inline var SAMPLER_MIPMAP_MODE_NEAREST = 0;
	public static inline var SAMPLER_MIPMAP_MODE_LINEAR = 1;
	public static inline var SAMPLER_ADDRESS_MODE_REPEAT = 0;
	public static inline var SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT = 1;
	public static inline var SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE = 2;
	public static inline var SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER = 3;

	public static inline var PIPELINE_BIND_POINT_GRAPHICS = 0;
	public static inline var SUBPASS_CONTENTS_INLINE = 0;
	public static inline var SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS = 1;
	public static inline var VERTEX_INPUT_RATE_VERTEX = 0;
	public static inline var VERTEX_INPUT_RATE_INSTANCE = 1;

	public static inline var QUERY_TYPE_OCCLUSION = 0;
	public static inline var QUERY_TYPE_PIPELINE_STATISTICS = 1;
	public static inline var QUERY_TYPE_TIMESTAMP = 2;

	public static inline var QUERY_CONTROL_PRECISE_BIT = 0x00000001;

	public static inline var QUERY_RESULT_64_BIT = 0x00000001;
	public static inline var QUERY_RESULT_WAIT_BIT = 0x00000002;
	public static inline var QUERY_RESULT_WITH_AVAILABILITY_BIT = 0x00000004;
	public static inline var QUERY_RESULT_PARTIAL_BIT = 0x00000008;

	public static inline var PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT = 0x00000001;
	public static inline var PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT = 0x00000002;
	public static inline var PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT = 0x00000004;
	public static inline var PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT = 0x00000010;
	public static inline var PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT = 0x00000400;

	public static inline var FORMAT_FEATURE_SAMPLED_IMAGE_BIT = 0x00000001;
	public static inline var FORMAT_FEATURE_STORAGE_IMAGE_BIT = 0x00000002;
	public static inline var FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT = 0x00000004;
	public static inline var FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT = 0x00000008;
	public static inline var FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT = 0x00000010;
	public static inline var FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT = 0x00000020;
	public static inline var FORMAT_FEATURE_VERTEX_BUFFER_BIT = 0x00000040;
	public static inline var FORMAT_FEATURE_COLOR_ATTACHMENT_BIT = 0x00000080;
	public static inline var FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT = 0x00000100;
	public static inline var FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT = 0x00000200;
	public static inline var FORMAT_FEATURE_BLIT_SRC_BIT = 0x00000400;
	public static inline var FORMAT_FEATURE_BLIT_DST_BIT = 0x00000800;
	public static inline var FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT = 0x00001000;
	public static inline var FORMAT_FEATURE_TRANSFER_SRC_BIT = 0x00004000;
	public static inline var FORMAT_FEATURE_TRANSFER_DST_BIT = 0x00008000;

	// ---- VkFormat (generated by .workbuddy/scripts/vk_gen_format_constants.py) ----
	public static inline var FORMAT_A1B5G5R5_UNORM_PACK16 = 1000470000;
	public static inline var FORMAT_A1B5G5R5_UNORM_PACK16_KHR = 1000470000;
	public static inline var FORMAT_A1R5G5B5_UNORM_PACK16 = 8;
	public static inline var FORMAT_A2B10G10R10_SINT_PACK32 = 69;
	public static inline var FORMAT_A2B10G10R10_SNORM_PACK32 = 65;
	public static inline var FORMAT_A2B10G10R10_SSCALED_PACK32 = 67;
	public static inline var FORMAT_A2B10G10R10_UINT_PACK32 = 68;
	public static inline var FORMAT_A2B10G10R10_UNORM_PACK32 = 64;
	public static inline var FORMAT_A2B10G10R10_USCALED_PACK32 = 66;
	public static inline var FORMAT_A2R10G10B10_SINT_PACK32 = 63;
	public static inline var FORMAT_A2R10G10B10_SNORM_PACK32 = 59;
	public static inline var FORMAT_A2R10G10B10_SSCALED_PACK32 = 61;
	public static inline var FORMAT_A2R10G10B10_UINT_PACK32 = 62;
	public static inline var FORMAT_A2R10G10B10_UNORM_PACK32 = 58;
	public static inline var FORMAT_A2R10G10B10_USCALED_PACK32 = 60;
	public static inline var FORMAT_A4B4G4R4_UNORM_PACK16 = 1000340001;
	public static inline var FORMAT_A4B4G4R4_UNORM_PACK16_EXT = 1000340001;
	public static inline var FORMAT_A4R4G4B4_UNORM_PACK16 = 1000340000;
	public static inline var FORMAT_A4R4G4B4_UNORM_PACK16_EXT = 1000340000;
	public static inline var FORMAT_A8B8G8R8_SINT_PACK32 = 56;
	public static inline var FORMAT_A8B8G8R8_SNORM_PACK32 = 52;
	public static inline var FORMAT_A8B8G8R8_SRGB_PACK32 = 57;
	public static inline var FORMAT_A8B8G8R8_SSCALED_PACK32 = 54;
	public static inline var FORMAT_A8B8G8R8_UINT_PACK32 = 55;
	public static inline var FORMAT_A8B8G8R8_UNORM_PACK32 = 51;
	public static inline var FORMAT_A8B8G8R8_USCALED_PACK32 = 53;
	public static inline var FORMAT_A8_UNORM = 1000470001;
	public static inline var FORMAT_A8_UNORM_KHR = 1000470001;
	public static inline var FORMAT_ASTC_10x10_SFLOAT_BLOCK = 1000066011;
	public static inline var FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT = 1000066011;
	public static inline var FORMAT_ASTC_10x10_SRGB_BLOCK = 180;
	public static inline var FORMAT_ASTC_10x10_UNORM_BLOCK = 179;
	public static inline var FORMAT_ASTC_10x5_SFLOAT_BLOCK = 1000066008;
	public static inline var FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT = 1000066008;
	public static inline var FORMAT_ASTC_10x5_SRGB_BLOCK = 174;
	public static inline var FORMAT_ASTC_10x5_UNORM_BLOCK = 173;
	public static inline var FORMAT_ASTC_10x6_SFLOAT_BLOCK = 1000066009;
	public static inline var FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT = 1000066009;
	public static inline var FORMAT_ASTC_10x6_SRGB_BLOCK = 176;
	public static inline var FORMAT_ASTC_10x6_UNORM_BLOCK = 175;
	public static inline var FORMAT_ASTC_10x8_SFLOAT_BLOCK = 1000066010;
	public static inline var FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT = 1000066010;
	public static inline var FORMAT_ASTC_10x8_SRGB_BLOCK = 178;
	public static inline var FORMAT_ASTC_10x8_UNORM_BLOCK = 177;
	public static inline var FORMAT_ASTC_12x10_SFLOAT_BLOCK = 1000066012;
	public static inline var FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT = 1000066012;
	public static inline var FORMAT_ASTC_12x10_SRGB_BLOCK = 182;
	public static inline var FORMAT_ASTC_12x10_UNORM_BLOCK = 181;
	public static inline var FORMAT_ASTC_12x12_SFLOAT_BLOCK = 1000066013;
	public static inline var FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT = 1000066013;
	public static inline var FORMAT_ASTC_12x12_SRGB_BLOCK = 184;
	public static inline var FORMAT_ASTC_12x12_UNORM_BLOCK = 183;
	public static inline var FORMAT_ASTC_3x3x3_SFLOAT_BLOCK_EXT = 1000288002;
	public static inline var FORMAT_ASTC_3x3x3_SRGB_BLOCK_EXT = 1000288001;
	public static inline var FORMAT_ASTC_3x3x3_UNORM_BLOCK_EXT = 1000288000;
	public static inline var FORMAT_ASTC_4x3x3_SFLOAT_BLOCK_EXT = 1000288005;
	public static inline var FORMAT_ASTC_4x3x3_SRGB_BLOCK_EXT = 1000288004;
	public static inline var FORMAT_ASTC_4x3x3_UNORM_BLOCK_EXT = 1000288003;
	public static inline var FORMAT_ASTC_4x4_SFLOAT_BLOCK = 1000066000;
	public static inline var FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT = 1000066000;
	public static inline var FORMAT_ASTC_4x4_SRGB_BLOCK = 158;
	public static inline var FORMAT_ASTC_4x4_UNORM_BLOCK = 157;
	public static inline var FORMAT_ASTC_4x4x3_SFLOAT_BLOCK_EXT = 1000288008;
	public static inline var FORMAT_ASTC_4x4x3_SRGB_BLOCK_EXT = 1000288007;
	public static inline var FORMAT_ASTC_4x4x3_UNORM_BLOCK_EXT = 1000288006;
	public static inline var FORMAT_ASTC_4x4x4_SFLOAT_BLOCK_EXT = 1000288011;
	public static inline var FORMAT_ASTC_4x4x4_SRGB_BLOCK_EXT = 1000288010;
	public static inline var FORMAT_ASTC_4x4x4_UNORM_BLOCK_EXT = 1000288009;
	public static inline var FORMAT_ASTC_5x4_SFLOAT_BLOCK = 1000066001;
	public static inline var FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT = 1000066001;
	public static inline var FORMAT_ASTC_5x4_SRGB_BLOCK = 160;
	public static inline var FORMAT_ASTC_5x4_UNORM_BLOCK = 159;
	public static inline var FORMAT_ASTC_5x4x4_SFLOAT_BLOCK_EXT = 1000288014;
	public static inline var FORMAT_ASTC_5x4x4_SRGB_BLOCK_EXT = 1000288013;
	public static inline var FORMAT_ASTC_5x4x4_UNORM_BLOCK_EXT = 1000288012;
	public static inline var FORMAT_ASTC_5x5_SFLOAT_BLOCK = 1000066002;
	public static inline var FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT = 1000066002;
	public static inline var FORMAT_ASTC_5x5_SRGB_BLOCK = 162;
	public static inline var FORMAT_ASTC_5x5_UNORM_BLOCK = 161;
	public static inline var FORMAT_ASTC_5x5x4_SFLOAT_BLOCK_EXT = 1000288017;
	public static inline var FORMAT_ASTC_5x5x4_SRGB_BLOCK_EXT = 1000288016;
	public static inline var FORMAT_ASTC_5x5x4_UNORM_BLOCK_EXT = 1000288015;
	public static inline var FORMAT_ASTC_5x5x5_SFLOAT_BLOCK_EXT = 1000288020;
	public static inline var FORMAT_ASTC_5x5x5_SRGB_BLOCK_EXT = 1000288019;
	public static inline var FORMAT_ASTC_5x5x5_UNORM_BLOCK_EXT = 1000288018;
	public static inline var FORMAT_ASTC_6x5_SFLOAT_BLOCK = 1000066003;
	public static inline var FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT = 1000066003;
	public static inline var FORMAT_ASTC_6x5_SRGB_BLOCK = 164;
	public static inline var FORMAT_ASTC_6x5_UNORM_BLOCK = 163;
	public static inline var FORMAT_ASTC_6x5x5_SFLOAT_BLOCK_EXT = 1000288023;
	public static inline var FORMAT_ASTC_6x5x5_SRGB_BLOCK_EXT = 1000288022;
	public static inline var FORMAT_ASTC_6x5x5_UNORM_BLOCK_EXT = 1000288021;
	public static inline var FORMAT_ASTC_6x6_SFLOAT_BLOCK = 1000066004;
	public static inline var FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT = 1000066004;
	public static inline var FORMAT_ASTC_6x6_SRGB_BLOCK = 166;
	public static inline var FORMAT_ASTC_6x6_UNORM_BLOCK = 165;
	public static inline var FORMAT_ASTC_6x6x5_SFLOAT_BLOCK_EXT = 1000288026;
	public static inline var FORMAT_ASTC_6x6x5_SRGB_BLOCK_EXT = 1000288025;
	public static inline var FORMAT_ASTC_6x6x5_UNORM_BLOCK_EXT = 1000288024;
	public static inline var FORMAT_ASTC_6x6x6_SFLOAT_BLOCK_EXT = 1000288029;
	public static inline var FORMAT_ASTC_6x6x6_SRGB_BLOCK_EXT = 1000288028;
	public static inline var FORMAT_ASTC_6x6x6_UNORM_BLOCK_EXT = 1000288027;
	public static inline var FORMAT_ASTC_8x5_SFLOAT_BLOCK = 1000066005;
	public static inline var FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT = 1000066005;
	public static inline var FORMAT_ASTC_8x5_SRGB_BLOCK = 168;
	public static inline var FORMAT_ASTC_8x5_UNORM_BLOCK = 167;
	public static inline var FORMAT_ASTC_8x6_SFLOAT_BLOCK = 1000066006;
	public static inline var FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT = 1000066006;
	public static inline var FORMAT_ASTC_8x6_SRGB_BLOCK = 170;
	public static inline var FORMAT_ASTC_8x6_UNORM_BLOCK = 169;
	public static inline var FORMAT_ASTC_8x8_SFLOAT_BLOCK = 1000066007;
	public static inline var FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT = 1000066007;
	public static inline var FORMAT_ASTC_8x8_SRGB_BLOCK = 172;
	public static inline var FORMAT_ASTC_8x8_UNORM_BLOCK = 171;
	public static inline var FORMAT_B10G11R11_UFLOAT_PACK32 = 122;
	public static inline var FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16 = 1000156011;
	public static inline var FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR = 1000156011;
	public static inline var FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16 = 1000156021;
	public static inline var FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR = 1000156021;
	public static inline var FORMAT_B16G16R16G16_422_UNORM = 1000156028;
	public static inline var FORMAT_B16G16R16G16_422_UNORM_KHR = 1000156028;
	public static inline var FORMAT_B4G4R4A4_UNORM_PACK16 = 3;
	public static inline var FORMAT_B5G5R5A1_UNORM_PACK16 = 7;
	public static inline var FORMAT_B5G6R5_UNORM_PACK16 = 5;
	public static inline var FORMAT_B8G8R8A8_SINT = 49;
	public static inline var FORMAT_B8G8R8A8_SNORM = 45;
	public static inline var FORMAT_B8G8R8A8_SSCALED = 47;
	public static inline var FORMAT_B8G8R8A8_UINT = 48;
	public static inline var FORMAT_B8G8R8A8_USCALED = 46;
	public static inline var FORMAT_B8G8R8G8_422_UNORM = 1000156001;
	public static inline var FORMAT_B8G8R8G8_422_UNORM_KHR = 1000156001;
	public static inline var FORMAT_B8G8R8_SINT = 35;
	public static inline var FORMAT_B8G8R8_SNORM = 31;
	public static inline var FORMAT_B8G8R8_SRGB = 36;
	public static inline var FORMAT_B8G8R8_SSCALED = 33;
	public static inline var FORMAT_B8G8R8_UINT = 34;
	public static inline var FORMAT_B8G8R8_UNORM = 30;
	public static inline var FORMAT_B8G8R8_USCALED = 32;
	public static inline var FORMAT_BC1_RGBA_SRGB_BLOCK = 134;
	public static inline var FORMAT_BC1_RGBA_UNORM_BLOCK = 133;
	public static inline var FORMAT_BC1_RGB_SRGB_BLOCK = 132;
	public static inline var FORMAT_BC1_RGB_UNORM_BLOCK = 131;
	public static inline var FORMAT_BC2_SRGB_BLOCK = 136;
	public static inline var FORMAT_BC2_UNORM_BLOCK = 135;
	public static inline var FORMAT_BC3_SRGB_BLOCK = 138;
	public static inline var FORMAT_BC3_UNORM_BLOCK = 137;
	public static inline var FORMAT_BC4_SNORM_BLOCK = 140;
	public static inline var FORMAT_BC4_UNORM_BLOCK = 139;
	public static inline var FORMAT_BC5_SNORM_BLOCK = 142;
	public static inline var FORMAT_BC5_UNORM_BLOCK = 141;
	public static inline var FORMAT_BC6H_SFLOAT_BLOCK = 144;
	public static inline var FORMAT_BC6H_UFLOAT_BLOCK = 143;
	public static inline var FORMAT_BC7_SRGB_BLOCK = 146;
	public static inline var FORMAT_BC7_UNORM_BLOCK = 145;
	public static inline var FORMAT_D16_UNORM_S8_UINT = 128;
	public static inline var FORMAT_E5B9G9R9_UFLOAT_PACK32 = 123;
	public static inline var FORMAT_EAC_R11G11_SNORM_BLOCK = 156;
	public static inline var FORMAT_EAC_R11G11_UNORM_BLOCK = 155;
	public static inline var FORMAT_EAC_R11_SNORM_BLOCK = 154;
	public static inline var FORMAT_EAC_R11_UNORM_BLOCK = 153;
	public static inline var FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK = 150;
	public static inline var FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK = 149;
	public static inline var FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK = 152;
	public static inline var FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK = 151;
	public static inline var FORMAT_ETC2_R8G8B8_SRGB_BLOCK = 148;
	public static inline var FORMAT_ETC2_R8G8B8_UNORM_BLOCK = 147;
	public static inline var FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16 = 1000156010;
	public static inline var FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR = 1000156010;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16 = 1000156013;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR = 1000156013;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16 = 1000156015;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR = 1000156015;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16 = 1000330001;
	public static inline var FORMAT_G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16_EXT = 1000330001;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 = 1000156012;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR = 1000156012;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 = 1000156014;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR = 1000156014;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 = 1000156016;
	public static inline var FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR = 1000156016;
	public static inline var FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16 = 1000156020;
	public static inline var FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR = 1000156020;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16 = 1000156023;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR = 1000156023;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16 = 1000156025;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR = 1000156025;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16 = 1000330002;
	public static inline var FORMAT_G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16_EXT = 1000330002;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 = 1000156022;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR = 1000156022;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 = 1000156024;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR = 1000156024;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 = 1000156026;
	public static inline var FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR = 1000156026;
	public static inline var FORMAT_G14X2_B14X2R14X2_2PLANE_420_UNORM_3PACK16_ARM = 1000609012;
	public static inline var FORMAT_G14X2_B14X2R14X2_2PLANE_422_UNORM_3PACK16_ARM = 1000609013;
	public static inline var FORMAT_G16B16G16R16_422_UNORM = 1000156027;
	public static inline var FORMAT_G16B16G16R16_422_UNORM_KHR = 1000156027;
	public static inline var FORMAT_G16_B16R16_2PLANE_420_UNORM = 1000156030;
	public static inline var FORMAT_G16_B16R16_2PLANE_420_UNORM_KHR = 1000156030;
	public static inline var FORMAT_G16_B16R16_2PLANE_422_UNORM = 1000156032;
	public static inline var FORMAT_G16_B16R16_2PLANE_422_UNORM_KHR = 1000156032;
	public static inline var FORMAT_G16_B16R16_2PLANE_444_UNORM = 1000330003;
	public static inline var FORMAT_G16_B16R16_2PLANE_444_UNORM_EXT = 1000330003;
	public static inline var FORMAT_G16_B16_R16_3PLANE_420_UNORM = 1000156029;
	public static inline var FORMAT_G16_B16_R16_3PLANE_420_UNORM_KHR = 1000156029;
	public static inline var FORMAT_G16_B16_R16_3PLANE_422_UNORM = 1000156031;
	public static inline var FORMAT_G16_B16_R16_3PLANE_422_UNORM_KHR = 1000156031;
	public static inline var FORMAT_G16_B16_R16_3PLANE_444_UNORM = 1000156033;
	public static inline var FORMAT_G16_B16_R16_3PLANE_444_UNORM_KHR = 1000156033;
	public static inline var FORMAT_G8B8G8R8_422_UNORM = 1000156000;
	public static inline var FORMAT_G8B8G8R8_422_UNORM_KHR = 1000156000;
	public static inline var FORMAT_G8_B8R8_2PLANE_420_UNORM = 1000156003;
	public static inline var FORMAT_G8_B8R8_2PLANE_420_UNORM_KHR = 1000156003;
	public static inline var FORMAT_G8_B8R8_2PLANE_422_UNORM = 1000156005;
	public static inline var FORMAT_G8_B8R8_2PLANE_422_UNORM_KHR = 1000156005;
	public static inline var FORMAT_G8_B8R8_2PLANE_444_UNORM = 1000330000;
	public static inline var FORMAT_G8_B8R8_2PLANE_444_UNORM_EXT = 1000330000;
	public static inline var FORMAT_G8_B8_R8_3PLANE_420_UNORM = 1000156002;
	public static inline var FORMAT_G8_B8_R8_3PLANE_420_UNORM_KHR = 1000156002;
	public static inline var FORMAT_G8_B8_R8_3PLANE_422_UNORM = 1000156004;
	public static inline var FORMAT_G8_B8_R8_3PLANE_422_UNORM_KHR = 1000156004;
	public static inline var FORMAT_G8_B8_R8_3PLANE_444_UNORM = 1000156006;
	public static inline var FORMAT_G8_B8_R8_3PLANE_444_UNORM_KHR = 1000156006;
	public static inline var FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG = 1000054004;
	public static inline var FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG = 1000054000;
	public static inline var FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG = 1000054005;
	public static inline var FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG = 1000054001;
	public static inline var FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG = 1000054006;
	public static inline var FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG = 1000054002;
	public static inline var FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG = 1000054007;
	public static inline var FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG = 1000054003;
	public static inline var FORMAT_R10X6G10X6B10X6A10X6_UINT_4PACK16_ARM = 1000609002;
	public static inline var FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16 = 1000156009;
	public static inline var FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR = 1000156009;
	public static inline var FORMAT_R10X6G10X6_UINT_2PACK16_ARM = 1000609001;
	public static inline var FORMAT_R10X6G10X6_UNORM_2PACK16 = 1000156008;
	public static inline var FORMAT_R10X6G10X6_UNORM_2PACK16_KHR = 1000156008;
	public static inline var FORMAT_R10X6_UINT_PACK16_ARM = 1000609000;
	public static inline var FORMAT_R10X6_UNORM_PACK16 = 1000156007;
	public static inline var FORMAT_R10X6_UNORM_PACK16_KHR = 1000156007;
	public static inline var FORMAT_R12X4G12X4B12X4A12X4_UINT_4PACK16_ARM = 1000609005;
	public static inline var FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16 = 1000156019;
	public static inline var FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR = 1000156019;
	public static inline var FORMAT_R12X4G12X4_UINT_2PACK16_ARM = 1000609004;
	public static inline var FORMAT_R12X4G12X4_UNORM_2PACK16 = 1000156018;
	public static inline var FORMAT_R12X4G12X4_UNORM_2PACK16_KHR = 1000156018;
	public static inline var FORMAT_R12X4_UINT_PACK16_ARM = 1000609003;
	public static inline var FORMAT_R12X4_UNORM_PACK16 = 1000156017;
	public static inline var FORMAT_R12X4_UNORM_PACK16_KHR = 1000156017;
	public static inline var FORMAT_R14X2G14X2B14X2A14X2_UINT_4PACK16_ARM = 1000609008;
	public static inline var FORMAT_R14X2G14X2B14X2A14X2_UNORM_4PACK16_ARM = 1000609011;
	public static inline var FORMAT_R14X2G14X2_UINT_2PACK16_ARM = 1000609007;
	public static inline var FORMAT_R14X2G14X2_UNORM_2PACK16_ARM = 1000609010;
	public static inline var FORMAT_R14X2_UINT_PACK16_ARM = 1000609006;
	public static inline var FORMAT_R14X2_UNORM_PACK16_ARM = 1000609009;
	public static inline var FORMAT_R16G16B16A16_SINT = 96;
	public static inline var FORMAT_R16G16B16A16_SNORM = 92;
	public static inline var FORMAT_R16G16B16A16_SSCALED = 94;
	public static inline var FORMAT_R16G16B16A16_UINT = 95;
	public static inline var FORMAT_R16G16B16A16_UNORM = 91;
	public static inline var FORMAT_R16G16B16A16_USCALED = 93;
	public static inline var FORMAT_R16G16B16_SFLOAT = 90;
	public static inline var FORMAT_R16G16B16_SINT = 89;
	public static inline var FORMAT_R16G16B16_SNORM = 85;
	public static inline var FORMAT_R16G16B16_SSCALED = 87;
	public static inline var FORMAT_R16G16B16_UINT = 88;
	public static inline var FORMAT_R16G16B16_UNORM = 84;
	public static inline var FORMAT_R16G16B16_USCALED = 86;
	public static inline var FORMAT_R16G16_S10_5_NV = 1000464000;
	public static inline var FORMAT_R16G16_SFIXED5_NV = 1000464000;
	public static inline var FORMAT_R16G16_SFLOAT = 83;
	public static inline var FORMAT_R16G16_SINT = 82;
	public static inline var FORMAT_R16G16_SNORM = 78;
	public static inline var FORMAT_R16G16_SSCALED = 80;
	public static inline var FORMAT_R16G16_UINT = 81;
	public static inline var FORMAT_R16G16_UNORM = 77;
	public static inline var FORMAT_R16G16_USCALED = 79;
	public static inline var FORMAT_R16_SFLOAT = 76;
	public static inline var FORMAT_R16_SFLOAT_FPENCODING_BFLOAT16_ARM = 1000460001;
	public static inline var FORMAT_R16_SINT = 75;
	public static inline var FORMAT_R16_SNORM = 71;
	public static inline var FORMAT_R16_SSCALED = 73;
	public static inline var FORMAT_R16_UINT = 74;
	public static inline var FORMAT_R16_UNORM = 70;
	public static inline var FORMAT_R16_USCALED = 72;
	public static inline var FORMAT_R32G32B32A32_SINT = 108;
	public static inline var FORMAT_R32G32B32A32_UINT = 107;
	public static inline var FORMAT_R32G32B32_SINT = 105;
	public static inline var FORMAT_R32G32B32_UINT = 104;
	public static inline var FORMAT_R32G32_SINT = 102;
	public static inline var FORMAT_R32G32_UINT = 101;
	public static inline var FORMAT_R32_SINT = 99;
	public static inline var FORMAT_R32_UINT = 98;
	public static inline var FORMAT_R4G4B4A4_UNORM_PACK16 = 2;
	public static inline var FORMAT_R4G4_UNORM_PACK8 = 1;
	public static inline var FORMAT_R5G5B5A1_UNORM_PACK16 = 6;
	public static inline var FORMAT_R5G6B5_UNORM_PACK16 = 4;
	public static inline var FORMAT_R64G64B64A64_SFLOAT = 121;
	public static inline var FORMAT_R64G64B64A64_SINT = 120;
	public static inline var FORMAT_R64G64B64A64_UINT = 119;
	public static inline var FORMAT_R64G64B64_SFLOAT = 118;
	public static inline var FORMAT_R64G64B64_SINT = 117;
	public static inline var FORMAT_R64G64B64_UINT = 116;
	public static inline var FORMAT_R64G64_SFLOAT = 115;
	public static inline var FORMAT_R64G64_SINT = 114;
	public static inline var FORMAT_R64G64_UINT = 113;
	public static inline var FORMAT_R64_SFLOAT = 112;
	public static inline var FORMAT_R64_SINT = 111;
	public static inline var FORMAT_R64_UINT = 110;
	public static inline var FORMAT_R8G8B8A8_SINT = 42;
	public static inline var FORMAT_R8G8B8A8_SNORM = 38;
	public static inline var FORMAT_R8G8B8A8_SSCALED = 40;
	public static inline var FORMAT_R8G8B8A8_UINT = 41;
	public static inline var FORMAT_R8G8B8A8_USCALED = 39;
	public static inline var FORMAT_R8G8B8_SINT = 28;
	public static inline var FORMAT_R8G8B8_SNORM = 24;
	public static inline var FORMAT_R8G8B8_SRGB = 29;
	public static inline var FORMAT_R8G8B8_SSCALED = 26;
	public static inline var FORMAT_R8G8B8_UINT = 27;
	public static inline var FORMAT_R8G8B8_UNORM = 23;
	public static inline var FORMAT_R8G8B8_USCALED = 25;
	public static inline var FORMAT_R8G8_SINT = 21;
	public static inline var FORMAT_R8G8_SNORM = 17;
	public static inline var FORMAT_R8G8_SRGB = 22;
	public static inline var FORMAT_R8G8_SSCALED = 19;
	public static inline var FORMAT_R8G8_UINT = 20;
	public static inline var FORMAT_R8G8_USCALED = 18;
	public static inline var FORMAT_R8_BOOL_ARM = 1000460000;
	public static inline var FORMAT_R8_SFLOAT_FPENCODING_FLOAT8E4M3_ARM = 1000460002;
	public static inline var FORMAT_R8_SFLOAT_FPENCODING_FLOAT8E5M2_ARM = 1000460003;
	public static inline var FORMAT_R8_SINT = 14;
	public static inline var FORMAT_R8_SNORM = 10;
	public static inline var FORMAT_R8_SRGB = 15;
	public static inline var FORMAT_R8_SSCALED = 12;
	public static inline var FORMAT_R8_UINT = 13;
	public static inline var FORMAT_R8_USCALED = 11;
	// ---- end VkFormat ----



	public static inline var MEMORY_HEAP_DEVICE_LOCAL_BIT = 0x00000001;

	public static inline var SPARSE_IMAGE_FORMAT_SINGLE_MIPTAIL_BIT = 0x00000001;
	public static inline var SPARSE_IMAGE_FORMAT_ALIGNED_MIP_SIZE_BIT = 0x00000002;
	public static inline var SPARSE_IMAGE_FORMAT_NONSTANDARD_BLOCK_SIZE_BIT = 0x00000004;

	// --- Vulkan 1.1 / 1.2 (bindless + GPU-driven batching) ---

	public static inline var DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT = 0x00000001;
	public static inline var DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT = 0x00000002;
	public static inline var DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT = 0x00000004;
	public static inline var DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT = 0x00000008;

	public static inline var DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT = 0x00000002;
	public static inline var DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT = 0x00000002;

	public static inline var BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT = 0x00020000;

	public static inline var MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT = 0x00000002;
	public static inline var MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT = 0x00000004;

	public static inline var QUEUE_PROTECTED_BIT = 0x00000010;

	public static inline var DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET = 0;
	public static inline var DESCRIPTOR_UPDATE_TEMPLATE_TYPE_PUSH_DESCRIPTORS_KHR = 1;

	public static inline var RESOLVE_MODE_NONE = 0;
	public static inline var RESOLVE_MODE_SAMPLE_ZERO_BIT = 0x00000001;
	public static inline var RESOLVE_MODE_AVERAGE_BIT = 0x00000002;
	public static inline var RESOLVE_MODE_MIN_BIT = 0x00000004;
	public static inline var RESOLVE_MODE_MAX_BIT = 0x00000008;

	public static inline var PEER_MEMORY_FEATURE_COPY_SRC_BIT = 0x00000001;
	public static inline var PEER_MEMORY_FEATURE_COPY_DST_BIT = 0x00000002;
	public static inline var PEER_MEMORY_FEATURE_GENERIC_SRC_BIT = 0x00000004;
	public static inline var PEER_MEMORY_FEATURE_GENERIC_DST_BIT = 0x00000008;

	public static inline var EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT = 0x00000001;
	public static inline var EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT = 0x00000002;
	public static inline var EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT = 0x00000004;

	public static inline var EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT = 0x00000001;
	public static inline var EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT = 0x00000002;
	public static inline var EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT = 0x00000001;
	public static inline var EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT = 0x00000002;

	public static inline var EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT = 0x00000001;
	public static inline var EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT = 0x00000002;
	public static inline var EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_BIT = 0x00000004;
	public static inline var EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT = 0x00000200;
	public static inline var EXTERNAL_MEMORY_HANDLE_TYPE_ANDROID_HARDWARE_BUFFER_BIT_ANDROID = 0x00000400;

	public static inline var EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT = 0x00000001;
	public static inline var EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_FD_BIT = 0x00000002;
	public static inline var EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT = 0x00000001;
	public static inline var EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_FD_BIT = 0x00000002;

	public static inline var SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY = 0;
	public static inline var SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_IDENTITY = 1;
	public static inline var SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709 = 2;
	public static inline var SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_601 = 3;
	public static inline var SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_2020 = 4;

	public static inline var SAMPLER_YCBCR_RANGE_ITU_FULL = 0;
	public static inline var SAMPLER_YCBCR_RANGE_ITU_NARROW = 1;

	public static inline var COMPONENT_SWIZZLE_IDENTITY = 0;
	public static inline var COMPONENT_SWIZZLE_ZERO = 1;
	public static inline var COMPONENT_SWIZZLE_ONE = 2;
	public static inline var COMPONENT_SWIZZLE_R = 3;
	public static inline var COMPONENT_SWIZZLE_G = 4;
	public static inline var COMPONENT_SWIZZLE_B = 5;
	public static inline var COMPONENT_SWIZZLE_A = 6;

	public static inline var CHROMA_LOCATION_COSITED_EVEN = 0;
	public static inline var CHROMA_LOCATION_MIDPOINT = 1;

	// --- 设备特性请求 id（传给 VKPhysicalDevice.createDeviceWithFeatures）---
	// 1.0 可选特性任何 Vulkan 版本都可开；17+ 需要 1.2 设备（经 promoted 结构体链）。

	// --- Vulkan 1.3 synchronization2 掩码（VkPipelineStageFlags2 / VkAccessFlags2）---
	// 注意：Lime 的 pipelineBarrier2 用 Int 传掩码，因此只能表达 32 位以内的位。
	// 高位（如 VK_ACCESS_2_SHADER_SAMPLED_READ_BIT = 1<<32）无法通过当前 CFFI 传递。

	public static inline var PIPELINE_STAGE_2_NONE = 0;
	public static inline var PIPELINE_STAGE_2_TOP_OF_PIPE_BIT = 0x00000001;
	public static inline var PIPELINE_STAGE_2_DRAW_INDIRECT_BIT = 0x00000002;
	public static inline var PIPELINE_STAGE_2_VERTEX_INPUT_BIT = 0x00000004;
	public static inline var PIPELINE_STAGE_2_VERTEX_SHADER_BIT = 0x00000008;
	public static inline var PIPELINE_STAGE_2_EARLY_FRAGMENT_TESTS_BIT = 0x00000040;
	public static inline var PIPELINE_STAGE_2_FRAGMENT_SHADER_BIT = 0x00000080;
	public static inline var PIPELINE_STAGE_2_LATE_FRAGMENT_TESTS_BIT = 0x00000100;
	public static inline var PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT = 0x00000400;
	public static inline var PIPELINE_STAGE_2_COMPUTE_SHADER_BIT = 0x00000800;
	public static inline var PIPELINE_STAGE_2_TRANSFER_BIT = 0x00001000;
	public static inline var PIPELINE_STAGE_2_ALL_GRAPHICS_BIT = 0x00008000;
	public static inline var PIPELINE_STAGE_2_ALL_COMMANDS_BIT = 0x00010000;
	public static inline var PIPELINE_STAGE_2_HOST_BIT = 0x00004000;

	public static inline var ACCESS_2_NONE = 0;
	public static inline var ACCESS_2_INDIRECT_COMMAND_READ_BIT = 0x00000001;
	public static inline var ACCESS_2_INDEX_READ_BIT = 0x00000002;
	public static inline var ACCESS_2_VERTEX_ATTRIBUTE_READ_BIT = 0x00000004;
	public static inline var ACCESS_2_UNIFORM_READ_BIT = 0x00000008;
	public static inline var ACCESS_2_INPUT_ATTACHMENT_READ_BIT = 0x00000010;
	public static inline var ACCESS_2_SHADER_READ_BIT = 0x00000020;
	public static inline var ACCESS_2_SHADER_WRITE_BIT = 0x00000040;
	public static inline var ACCESS_2_COLOR_ATTACHMENT_READ_BIT = 0x00000080;
	public static inline var ACCESS_2_COLOR_ATTACHMENT_WRITE_BIT = 0x00000100;
	public static inline var ACCESS_2_DEPTH_STENCIL_ATTACHMENT_READ_BIT = 0x00000200;
	public static inline var ACCESS_2_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT = 0x00000400;
	public static inline var ACCESS_2_TRANSFER_READ_BIT = 0x00000800;
	public static inline var ACCESS_2_TRANSFER_WRITE_BIT = 0x00001000;
	public static inline var ACCESS_2_HOST_READ_BIT = 0x00002000;
	public static inline var ACCESS_2_HOST_WRITE_BIT = 0x00004000;
	public static inline var ACCESS_2_MEMORY_READ_BIT = 0x00008000;
	public static inline var ACCESS_2_MEMORY_WRITE_BIT = 0x00010000;

	public static inline var DEVICE_FEATURE_SPARSE_BINDING = 1;
	public static inline var DEVICE_FEATURE_SAMPLER_ANISOTROPY = 2;
	public static inline var DEVICE_FEATURE_DEPTH_CLAMP = 3;
	public static inline var DEVICE_FEATURE_FILL_MODE_NON_SOLID = 4;
	public static inline var DEVICE_FEATURE_WIDE_LINES = 5;
	public static inline var DEVICE_FEATURE_DEPTH_BOUNDS = 6;
	public static inline var DEVICE_FEATURE_MULTI_VIEWPORT = 7;
	public static inline var DEVICE_FEATURE_INDEPENDENT_BLEND = 8;
	public static inline var DEVICE_FEATURE_DUAL_SRC_BLEND = 9;
	public static inline var DEVICE_FEATURE_LOGIC_OP = 10;
	public static inline var DEVICE_FEATURE_GEOMETRY_SHADER = 11;
	public static inline var DEVICE_FEATURE_TESSELLATION_SHADER = 12;
	public static inline var DEVICE_FEATURE_OCCLUSION_QUERY_PRECISE = 13;
	public static inline var DEVICE_FEATURE_PIPELINE_STATISTICS_QUERY = 14;
	public static inline var DEVICE_FEATURE_SHADER_TESSELLATION_AND_GEOMETRY_POINT_SIZE = 15;
	public static inline var DEVICE_FEATURE_ALPHA_TO_ONE = 16;
	public static inline var DEVICE_FEATURE_VARIABLE_POINTERS = 17;
	public static inline var DEVICE_FEATURE_MULTIVIEW = 18;
	public static inline var DEVICE_FEATURE_PROTECTED_MEMORY = 19;
	public static inline var DEVICE_FEATURE_SAMPLER_YCBCR_CONVERSION = 20;
	public static inline var DEVICE_FEATURE_SHADER_DRAW_PARAMETERS = 21;
	public static inline var DEVICE_FEATURE_STORAGE_BUFFER_16BIT_ACCESS = 22;
	public static inline var DEVICE_FEATURE_TIMELINE_SEMAPHORE = 23;
	public static inline var DEVICE_FEATURE_BUFFER_DEVICE_ADDRESS = 24;
	public static inline var DEVICE_FEATURE_BUFFER_DEVICE_ADDRESS_CAPTURE_REPLAY = 25;
	public static inline var DEVICE_FEATURE_DRAW_INDIRECT_COUNT = 26;
	public static inline var DEVICE_FEATURE_DESCRIPTOR_INDEXING = 27;
	public static inline var DEVICE_FEATURE_HOST_QUERY_RESET = 28;
	public static inline var DEVICE_FEATURE_IMAGELESS_FRAMEBUFFER = 29;
	public static inline var DEVICE_FEATURE_SEPARATE_DEPTH_STENCIL_LAYOUTS = 30;
	public static inline var DEVICE_FEATURE_SCALAR_BLOCK_LAYOUT = 31;
	public static inline var DEVICE_FEATURE_UNIFORM_BUFFER_STANDARD_LAYOUT = 32;
	public static inline var DEVICE_FEATURE_SHADER_SUBGROUP_EXTENDED_TYPES = 33;
	public static inline var DEVICE_FEATURE_SAMPLER_FILTER_MINMAX = 34;
	public static inline var DEVICE_FEATURE_STORAGE_BUFFER_8BIT_ACCESS = 35;
	public static inline var DEVICE_FEATURE_SHADER_FLOAT16 = 36;
	public static inline var DEVICE_FEATURE_SHADER_INT8 = 37;
	public static inline var DEVICE_FEATURE_VULKAN_MEMORY_MODEL = 38;
	public static inline var DEVICE_FEATURE_SHADER_OUTPUT_VIEWPORT_INDEX = 39;
	public static inline var DEVICE_FEATURE_SHADER_OUTPUT_LAYER = 40;

	// ---- Vulkan 1.3 device features (VkPhysicalDeviceVulkan13Features) ----
	// Ids map 1:1 to that struct's VkBool32 fields in declaration order.
	public static inline var DEVICE_FEATURE_ROBUST_IMAGE_ACCESS = 41;
	public static inline var DEVICE_FEATURE_INLINE_UNIFORM_BLOCK = 42;
	public static inline var DEVICE_FEATURE_DESCRIPTOR_BINDING_INLINE_UNIFORM_BLOCK_UPDATE_AFTER_BIND = 43;
	public static inline var DEVICE_FEATURE_PIPELINE_CREATION_CACHE_CONTROL = 44;
	public static inline var DEVICE_FEATURE_PRIVATE_DATA = 45;
	public static inline var DEVICE_FEATURE_SHADER_DEMOTE_TO_HELPER_INVOCATION = 46;
	public static inline var DEVICE_FEATURE_SHADER_TERMINATE_INVOCATION = 47;
	public static inline var DEVICE_FEATURE_SUBGROUP_SIZE_CONTROL = 48;
	public static inline var DEVICE_FEATURE_COMPUTE_FULL_SUBGROUPS = 49;
	public static inline var DEVICE_FEATURE_SYNCHRONIZATION2 = 50;
	public static inline var DEVICE_FEATURE_TEXTURE_COMPRESSION_ASTC_HDR = 51;
	public static inline var DEVICE_FEATURE_SHADER_ZERO_INITIALIZE_WORKGROUP_MEMORY = 52;
	public static inline var DEVICE_FEATURE_DYNAMIC_RENDERING = 53;
	public static inline var DEVICE_FEATURE_SHADER_INTEGER_DOT_PRODUCT = 54;
	public static inline var DEVICE_FEATURE_MAINTENANCE4 = 55;
	// Sparse image residency: required before an image may carry
	// VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT and be bound with VkSparseImageMemoryBindInfo.
	public static inline var DEVICE_FEATURE_SPARSE_RESIDENCY_IMAGE_2D = 56;

	public static inline var DEVICE_FEATURE_CORE_COUNT = 16;

	public static inline var IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL = 1000241000;
	public static inline var IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL = 1000241001;
	public static inline var IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL = 1000241002;
	public static inline var IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL = 1000241003;

	// ---- VkToolPurposeFlagBits (reported by VKPhysicalDevice.getToolProperties) ----
	public static inline var TOOL_PURPOSE_VALIDATION_BIT = 0x00000001;
	public static inline var TOOL_PURPOSE_PROFILING_BIT = 0x00000002;
	public static inline var TOOL_PURPOSE_TRACING_BIT = 0x00000004;
	public static inline var TOOL_PURPOSE_ADDITIONAL_FEATURES_BIT = 0x00000008;
	public static inline var TOOL_PURPOSE_MODIFYING_FEATURES_BIT = 0x00000010;
	public static inline var TOOL_PURPOSE_DEBUG_REPORTING_BIT_EXT = 0x00000020;
	public static inline var TOOL_PURPOSE_DEBUG_MARKERS_BIT_EXT = 0x00000040;

	/**
		Creates a managed `VkInstance` for the current Lime Vulkan window.
	**/
	public static function createInstance(context:VulkanRenderContext, applicationName:String = "Lime"):VKInstance
	{
		if (context == null)
		{
			return null;
		}

		#if (!macro && lime_cffi)
		var handleData:Dynamic = NativeCFFI.lime_vk_create_instance(context.__windowHandle, applicationName);
		if (handleData != null)
		{
			var handle = __makeHandle(handleData);
			if (!__isZero(handle))
			{
				return new VKInstance(context, handle);
			}
		}
		#end

		return null;
	}

	/**
		Returns the last bootstrap-layer Vulkan error surfaced by Lime.
	**/
	public static function getLastError():String
	{
		#if (!macro && lime_cffi)
		var value:Dynamic = NativeCFFI.lime_vk_get_last_error();
		if (value != null)
		{
			return CFFI.stringValue(value);
		}
		#end

		return "";
	}

	/**
		Queries a chain of Vulkan feature structs from a physical device.

		`structTypes` is a list of `VKStructureType.*_FEATURES` values. Every Vulkan
		feature struct is `{ sType, pNext, VkBool32 ... }`, so the reply is decoded
		into a `sType -> word array` map; feed a slice to the matching typed class:

		```haxe
		var features = VK.getPhysicalDeviceFeatures2 (device, [
			VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES
		]);
		var indexing = VKPhysicalDeviceDescriptorIndexingFeatures.fromWords (
			features.get (VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES));
		```

		Requires Vulkan 1.1. Returns `null` when the query is unavailable, so
		callers on a 1.0-only loader still get a clean failure.
	**/
	public static function getPhysicalDeviceFeatures2(physicalDevice:VKPhysicalDevice, structTypes:Array<Int>):Map<Int, Array<Int>>
	{
		if (physicalDevice == null || structTypes == null || structTypes.length == 0)
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var instance = physicalDevice.instance;
		if (instance != null && instance.isValid() && !__isZero(physicalDevice.handle))
		{
			var packed:Dynamic = NativeCFFI.lime_vk_get_physical_device_features2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, physicalDevice.handle.high, physicalDevice.handle.low, structTypes);

			if (packed == null)
			{
				return null;
			}

			var length:Int = untyped packed.length;
			var words = new Array<Int>();
			for (i in 0...length)
			{
				words.push(untyped packed[i]);
			}

			return VKFeatureWords.decode(words);
		}
		#end

		return null;
	}

	/**
		Picks a preferred physical device from an enumerated device list.
		This currently prefers graphics-capable devices, optionally requiring
		present support, and favors discrete GPUs by default.
	**/
	public static function pickPhysicalDevice(devices:Array<VKPhysicalDevice>, requirePresent:Bool = false, preferDiscrete:Bool = true):VKPhysicalDevice
	{
		if (devices == null || devices.length == 0)
		{
			return null;
		}

		var bestDevice:VKPhysicalDevice = null;
		var bestScore = -1;

		for (device in devices)
		{
			var score = __scorePhysicalDevice(device, requirePresent, preferDiscrete);
			if (score > bestScore)
			{
				bestScore = score;
				bestDevice = device;
			}
		}

		return bestDevice;
	}

	public static inline function versionString(version:Int):String
	{
		var major = version >>> 22;
		var minor = (version >>> 12) & 0x3FF;
		var patch = version & 0xFFF;
		return major + "." + minor + "." + patch;
	}

	@:allow(lime.graphics.VulkanRenderContext)
	@:allow(lime.graphics.vulkan.VKBuffer)
	@:allow(lime.graphics.vulkan.VKCommandBuffer)
	@:allow(lime.graphics.vulkan.VKCommandPool)
	@:allow(lime.graphics.vulkan.VKDescriptorPool)
	@:allow(lime.graphics.vulkan.VKDescriptorSet)
	@:allow(lime.graphics.vulkan.VKDescriptorSetLayout)
	@:allow(lime.graphics.vulkan.VKDevice)
	@:allow(lime.graphics.vulkan.VKDeviceMemory)
	@:allow(lime.graphics.vulkan.VKEvent)
	@:allow(lime.graphics.vulkan.VKFence)
	@:allow(lime.graphics.vulkan.VKFramebuffer)
	@:allow(lime.graphics.vulkan.VKImage)
	@:allow(lime.graphics.vulkan.VKImageView)
	@:allow(lime.graphics.vulkan.VKInstance)
	@:allow(lime.graphics.vulkan.VKMemoryRequirements)
	@:allow(lime.graphics.vulkan.VKPhysicalDevice)
	@:allow(lime.graphics.vulkan.VKPrivateDataSlot)
	@:allow(lime.graphics.vulkan.VKPipeline)
	@:allow(lime.graphics.vulkan.VKPipelineCache)
	@:allow(lime.graphics.vulkan.VKPipelineLayout)
	@:allow(lime.graphics.vulkan.VKQueue)
	@:allow(lime.graphics.vulkan.VKQueryPool)
	@:allow(lime.graphics.vulkan.VKRenderPass)
	@:allow(lime.graphics.vulkan.VKSampler)
	@:allow(lime.graphics.vulkan.VKSemaphore)
	@:allow(lime.graphics.vulkan.VKShaderModule)
	@:allow(lime.graphics.vulkan.VKSwapchain)
	private static function __makeHandle(value:Dynamic):Int64
	{
		if (value == null)
		{
			return Int64.ofInt(0);
		}

		return Int64.make(value.high, value.low);
	}

	@:allow(lime.graphics.VulkanRenderContext)
	@:allow(lime.graphics.vulkan.VKBuffer)
	@:allow(lime.graphics.vulkan.VKCommandBuffer)
	@:allow(lime.graphics.vulkan.VKCommandPool)
	@:allow(lime.graphics.vulkan.VKDescriptorPool)
	@:allow(lime.graphics.vulkan.VKDescriptorSet)
	@:allow(lime.graphics.vulkan.VKDescriptorSetLayout)
	@:allow(lime.graphics.vulkan.VKDevice)
	@:allow(lime.graphics.vulkan.VKDeviceMemory)
	@:allow(lime.graphics.vulkan.VKEvent)
	@:allow(lime.graphics.vulkan.VKFence)
	@:allow(lime.graphics.vulkan.VKFramebuffer)
	@:allow(lime.graphics.vulkan.VKImage)
	@:allow(lime.graphics.vulkan.VKImageView)
	@:allow(lime.graphics.vulkan.VKInstance)
	@:allow(lime.graphics.vulkan.VKMemoryRequirements)
	@:allow(lime.graphics.vulkan.VKQueue)
	@:allow(lime.graphics.vulkan.VKQueryPool)
	@:allow(lime.graphics.vulkan.VKPipeline)
	@:allow(lime.graphics.vulkan.VKPipelineCache)
	@:allow(lime.graphics.vulkan.VKPipelineLayout)
	@:allow(lime.graphics.vulkan.VKRenderPass)
	@:allow(lime.graphics.vulkan.VKSampler)
	@:allow(lime.graphics.vulkan.VKSemaphore)
	@:allow(lime.graphics.vulkan.VKShaderModule)
	@:allow(lime.graphics.vulkan.VKSwapchain)
	@:allow(lime.graphics.vulkan.VKBufferView)
	@:allow(lime.graphics.vulkan.VKDescriptorUpdateTemplate)
	@:allow(lime.graphics.vulkan.VKPhysicalDevice)
	@:allow(lime.graphics.vulkan.VKPrivateDataSlot)
	@:allow(lime.graphics.vulkan.VKSamplerYcbcrConversion)
	private static inline function __isZero(handle:Int64):Bool
	{
		return handle.high == 0 && handle.low == 0;
	}

	private static function __scorePhysicalDevice(device:VKPhysicalDevice, requirePresent:Bool, preferDiscrete:Bool):Int
	{
		if (device == null || !device.hasQueueFamily(true, requirePresent))
		{
			return -1;
		}

		var score = 0;

		switch (device.deviceType)
		{
			case PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:
				score += preferDiscrete ? 400 : 250;
			case PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU:
				score += preferDiscrete ? 300 : 400;
			case PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:
				score += 150;
			case PHYSICAL_DEVICE_TYPE_CPU:
				score += 100;
			default:
				score += 50;
		}

		var primaryQueue = device.getQueueFamily(true, requirePresent);
		if (primaryQueue != null)
		{
			score += primaryQueue.queueCount * 2;
			if (primaryQueue.supportsTransfer) score += 4;
			if (primaryQueue.supportsCompute) score += 2;
		}

		score += device.queueFamilies.length;
		return score;
	}
}
