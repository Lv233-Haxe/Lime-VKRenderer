package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
class VKRenderPass
{
	public var colorFormat(default, null):Int;
	public var depthStencilFormat(default, null):Int;
	public var device(default, null):VKDevice;
	public var handle(default, null):Int64;
	public var hasResolve(default, null):Bool;
	public var resolveFormat(default, null):Int;
	public var samples(default, null):Int;

	@:allow(lime.graphics.vulkan.VKDevice)
	private function new(device:VKDevice, handle:Int64, colorFormat:Int, depthStencilFormat:Int, samples:Int, resolveFormat:Int)
	{
		this.device = device;
		this.handle = handle;
		this.colorFormat = colorFormat;
		this.depthStencilFormat = depthStencilFormat;
		this.samples = samples;
		this.resolveFormat = resolveFormat;
		this.hasResolve = resolveFormat != VK.FORMAT_UNDEFINED;
	}

	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_destroy_render_pass(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
			handle = Int64.ofInt(0);
		}
		#end
	}

	/**
		Returns the render area granularity for this render pass.

		A render area that does not align to this granularity is still valid, but may
		be slower on some implementations.
	**/
	public function getRenderAreaGranularity():VKExtent2D
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_render_area_granularity(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low);
			return VKExtent2D.fromDynamic(data);
		}
		#end

		return null;
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
