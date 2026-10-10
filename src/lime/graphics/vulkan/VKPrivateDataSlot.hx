package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A private data slot from Vulkan 1.3 - a place to hang an arbitrary 64-bit
	value on any Vulkan object the driver knows how to identify.

	Every method here needs the `privateData` device feature, so create the device
	with `VK.DEVICE_FEATURE_PRIVATE_DATA` in the feature list; without it the
	underlying PFNs are absent and every call fails harmlessly.

	Objects are addressed as an `objectType` (`VKObjectType.*`) plus the raw
	handle of that object, exactly as `vkSetPrivateData` expects.
**/
class VKPrivateDataSlot
{
	public var device(default, null):VKDevice;
	public var handle(default, null):Int64;

	@:allow(lime.graphics.vulkan.VKDevice)
	private function new(device:VKDevice, handle:Int64)
	{
		this.device = device;
		this.handle = handle;
	}

	/**
		Attaches `data` to the object described by `objectType` / `objectHandle`.

		Both handles are plain values here: on static targets `haxe.Int64` cannot
		be null, so this (like every other `Int64` entry point in this package)
		takes them as required arguments. Use `Int64.ofInt(0)` for "zero".
	**/
	public function setData(objectType:Int, objectHandle:Int64, data:Int64):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_set_private_data(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, objectType, objectHandle.high, objectHandle.low,
				handle.high, handle.low, data.high, data.low);
		}
		#end

		return false;
	}

	/**
		Reads back the payload attached to `objectType` / `objectHandle`.

		Returns `Int64.ofInt(0)` when nothing is stored (or the slot is invalid) —
		the same convention `VKSemaphore.getCounterValue()` uses, because
		`haxe.Int64` cannot hold null on static targets.
	**/
	public function getData(objectType:Int, objectHandle:Int64):Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_private_data(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, objectType, objectHandle.high, objectHandle.low,
				handle.high, handle.low);
			return VK.__makeHandle(data);
		}
		#end

		return Int64.ofInt(0);
	}

	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_destroy_private_data_slot(device.instance.context.__windowHandle, device.instance.handle.high,
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
