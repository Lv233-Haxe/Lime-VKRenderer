package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan 1.1 YCbCr conversion (immutable sampler half).

	Needed to sample an image whose format carries subsampled chroma — most often
	a video frame imported from a decoder. The conversion describes the colour
	model and range, the component swizzle and the chroma reconstruction filter;
	it is then attached to a `VKSampler` through
	`VkSamplerYcbcrConversionInfo`.
**/
class VKSamplerYcbcrConversion
{
	public var device(default, null):VKDevice;
	public var handle(default, null):Int64;

	@:allow(lime.graphics.vulkan.VKDevice)
	private function new(device:VKDevice, handle:Int64)
	{
		this.device = device;
		this.handle = handle;
	}

	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_destroy_sampler_ycbcr_conversion(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low);
			handle = Int64.ofInt(0);
		}
		#end
	}

	public inline function get():Int64
	{
		return handle;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}
}
