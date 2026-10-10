package lime.graphics.vulkan;

import haxe.Int64;
import haxe.io.Bytes;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan query pool for occlusion, pipeline statistics and timestamps.
**/
class VKQueryPool
{
	public var device(default, null):VKDevice;
	public var handle(default, null):Int64;
	public var queryCount(default, null):Int;
	public var queryType(default, null):Int;

	@:allow(lime.graphics.vulkan.VKDevice)
	private function new(device:VKDevice, handle:Int64, queryType:Int, queryCount:Int)
	{
		this.device = device;
		this.handle = handle;
		this.queryType = queryType;
		this.queryCount = queryCount;
	}

	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_destroy_query_pool(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
			handle = Int64.ofInt(0);
		}
		#end
	}

	public inline function get():Int64
	{
		return handle;
	}

	public function getResults(bytes:Bytes, firstQuery:Int = 0, queryCount:Int = -1, stride:Int = 4, flags:Int = 0):Bool
	{
		if (queryCount < 0) queryCount = this.queryCount;
		if (stride <= 0) stride = 4;

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && bytes != null)
		{
			return NativeCFFI.lime_vk_get_query_pool_results(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, bytes, firstQuery, queryCount, stride, flags);
		}
		#end

		return false;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}

	public function reset(firstQuery:Int = 0, queryCount:Int = -1):Bool
	{
		if (queryCount < 0) queryCount = this.queryCount;

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_reset_query_pool(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, firstQuery, queryCount);
			return true;
		}
		#end

		return false;
	}
}