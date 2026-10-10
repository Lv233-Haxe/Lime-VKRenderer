package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan buffer view, which exposes a range of a `VKBuffer` as a texel buffer.

	Create one through `VKBuffer.createView()`.
**/
class VKBufferView
{
	public var buffer(default, null):VKBuffer;
	public var device(default, null):VKDevice;
	public var format(default, null):Int;
	public var handle(default, null):Int64;
	public var offset(default, null):Int;
	public var range(default, null):Int;

	@:allow(lime.graphics.vulkan.VKBuffer)
	private function new(buffer:VKBuffer, handle:Int64, format:Int, offset:Int, range:Int)
	{
		this.buffer = buffer;
		this.device = buffer != null ? buffer.device : null;
		this.handle = handle;
		this.format = format;
		this.offset = offset;
		this.range = range;
	}

	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			NativeCFFI.lime_vk_destroy_buffer_view(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
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
