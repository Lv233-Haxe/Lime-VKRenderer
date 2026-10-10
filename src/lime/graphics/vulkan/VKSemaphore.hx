package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan semaphore used for GPU/GPU synchronization.
**/
class VKSemaphore
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
			NativeCFFI.lime_vk_destroy_semaphore(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
			handle = Int64.ofInt(0);
		}
		#end
	}

	public inline function get():Int64
	{
		return handle;
	}

	public function getCounterValue():Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return VK.__makeHandle(NativeCFFI.lime_vk_get_semaphore_counter_value(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low));
		}
		#end
		return Int64.ofInt(0);
	}

	public function signal(value:Int64):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_signal_semaphore(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, value.high, value.low);
		}
		#end
		return false;
	}

	public function wait(value:Int64, timeout:Int64 = null):Bool
	{
		if (timeout == null)
		{
			timeout = Int64.make(-1, -1);
		}

		var state = [0, handle.high, handle.low, value.high, value.low];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_wait_semaphores(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, state, timeout.high, timeout.low);
		}
		#end
		return false;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}
}
