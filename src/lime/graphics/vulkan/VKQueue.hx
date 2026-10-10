package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan queue retrieved from a `VKDevice`.
**/
class VKQueue
{
	public var device(default, null):VKDevice;
	public var familyIndex(default, null):Int;
	public var handle(default, null):Int64;
	public var index(default, null):Int;

	@:allow(lime.graphics.vulkan.VKDevice)
	private function new(device:VKDevice, handle:Int64, familyIndex:Int, index:Int)
	{
		this.device = device;
		this.handle = handle;
		this.familyIndex = familyIndex;
		this.index = index;
	}

	public inline function get():Int64
	{
		return handle;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}

	public function bindSparse(image:VKImage, memory:VKDeviceMemory, memoryOffset:Int64 = null, aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT,
			mipLevel:Int = 0, arrayLayer:Int = 0, offsetX:Int = 0, offsetY:Int = 0, offsetZ:Int = 0, width:Int = 0, height:Int = 0, depth:Int = 1,
			flags:Int = 0):Bool
	{
		if (memoryOffset == null) memoryOffset = Int64.ofInt(0);
		if (width <= 0) width = image != null ? image.width : 0;
		if (height <= 0) height = image != null ? image.height : 0;
		var state = [aspectMask, mipLevel, arrayLayer, offsetX, offsetY, offsetZ, width, height, depth, memoryOffset.high, memoryOffset.low,
			flags];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid() && memory != null && memory.isValid())
		{
			return NativeCFFI.lime_vk_queue_bind_sparse(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low, memory.handle.high, memory.handle.low,
				state);
		}
		#end

		return false;
	}

	/**
		Presents an acquired swapchain image on this queue.
	**/
	public function present(swapchain:VKSwapchain, imageIndex:Int, waitSemaphore:VKSemaphore = null):Int
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && swapchain != null && swapchain.isValid())
		{
			var waitSemaphoreHandle = (waitSemaphore != null && waitSemaphore.isValid()) ? waitSemaphore.handle : Int64.ofInt(0);
			return NativeCFFI.lime_vk_queue_present(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, swapchain.handle.high, swapchain.handle.low, imageIndex,
				waitSemaphoreHandle.high, waitSemaphoreHandle.low);
		}
		#end

		return VK.ERROR_INITIALIZATION_FAILED;
	}

	/**
		Submits one command buffer to this queue. A fence may be provided to track
		completion from the CPU.
	**/
	public function submit(commandBuffer:VKCommandBuffer, fence:VKFence = null):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && commandBuffer != null && commandBuffer.isValid())
		{
			var fenceHigh = (fence != null && fence.isValid()) ? fence.handle.high : 0;
			var fenceLow = (fence != null && fence.isValid()) ? fence.handle.low : 0;

			return NativeCFFI.lime_vk_queue_submit(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, commandBuffer.handle.high, commandBuffer.handle.low, fenceHigh, fenceLow);
		}
		#end

		return false;
	}

	/**
		Submits one command buffer with optional acquire/render/present sync.
		This preserves the simple `submit(commandBuffer, fence)` path while
		exposing the explicit wait/signal pieces renderers need per frame.
	**/
	/**
		Submits one command buffer through the Vulkan 1.3 `vkQueueSubmit2` path.

		Needs the `synchronization2` feature. This convenience form carries no
		semaphores - use `submit2Ex` when you need wait/signal semaphores.
	**/
	public function submit2(commandBuffer:VKCommandBuffer, fence:VKFence = null, flags:Int = 0):Bool
	{
		var commands = (commandBuffer != null && commandBuffer.isValid())
			? [commandBuffer.handle.high, commandBuffer.handle.low, 0] : null;
		return submit2Ex(null, commands, null, fence, flags);
	}

	/**
		Full `vkQueueSubmit2` wrapper.

		Each list uses a flat int encoding (64-bit values split into `high`, `low`):

		- `waitSemaphores` / `signalSemaphores`: **7 ints per entry** -
		  `semaphoreH, semaphoreL, valueH, valueL, stageH, stageL, deviceIndex`
		- `commandBuffers`: **3 ints per entry** - `commandBufferH, commandBufferL, deviceMask`

		Unlike `vkQueueSubmit`, this submits exactly **one** `VkSubmitInfo2` per
		call; call it repeatedly to submit several batches.
	**/
	public function submit2Ex(waitSemaphores:Array<Int>, commandBuffers:Array<Int>, signalSemaphores:Array<Int>, fence:VKFence = null,
			flags:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && commandBuffers != null && commandBuffers.length >= 3)
		{
			var fenceHigh = (fence != null && fence.isValid()) ? fence.handle.high : 0;
			var fenceLow = (fence != null && fence.isValid()) ? fence.handle.low : 0;

			return NativeCFFI.lime_vk_queue_submit_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, flags, waitSemaphores,
				commandBuffers, signalSemaphores, fenceHigh, fenceLow);
		}
		#end

		return false;
	}

	public function submitSynced(commandBuffer:VKCommandBuffer, waitSemaphore:VKSemaphore = null, signalSemaphore:VKSemaphore = null, fence:VKFence = null,
			waitStageMask:Int = VK.PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && commandBuffer != null && commandBuffer.isValid())
		{
			var waitHandle = waitSemaphore != null && waitSemaphore.isValid() ? waitSemaphore.handle : Int64.ofInt(0);
			var signalHandle = signalSemaphore != null && signalSemaphore.isValid() ? signalSemaphore.handle : Int64.ofInt(0);
			var fenceHandle = fence != null && fence.isValid() ? fence.handle : Int64.ofInt(0);
			var state = [
				waitHandle.high,
				waitHandle.low,
				waitStageMask,
				signalHandle.high,
				signalHandle.low,
				fenceHandle.high,
				fenceHandle.low
			];

			return NativeCFFI.lime_vk_queue_submit_synced(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, commandBuffer.handle.high, commandBuffer.handle.low, state);
		}
		#end

		return false;
	}

	/**
		Blocks until this queue has completed all submitted work.
	**/
	public function waitIdle():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_queue_wait_idle(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}
}
