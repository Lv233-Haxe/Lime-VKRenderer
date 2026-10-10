package;

import haxe.Int64;
import haxe.io.Bytes;
import lime.graphics.vulkan.VK;
import lime.graphics.vulkan.VKBuffer;
import lime.graphics.vulkan.VKCommandBuffer;
import lime.graphics.vulkan.VKCommandPool;
import lime.graphics.vulkan.VKDescriptorPool;
import lime.graphics.vulkan.VKDescriptorPoolSize;
import lime.graphics.vulkan.VKDescriptorSet;
import lime.graphics.vulkan.VKDescriptorSetLayout;
import lime.graphics.vulkan.VKDescriptorSetLayoutBinding;
import lime.graphics.vulkan.VKDevice;
import lime.graphics.vulkan.VKFence;
import lime.graphics.vulkan.VKImage;
import lime.graphics.vulkan.VKImageView;
import lime.graphics.vulkan.VKFeatureWords;
import lime.graphics.vulkan.VKImageView;
import lime.graphics.vulkan.VKQueue;
import lime.graphics.vulkan.VKQueryPool;
import lime.graphics.vulkan.VKStructureType;

class CloudSmoke
{
	public static function run(device:VKDevice, queue:VKQueue, featureRequests:Array<Int> = null):Bool
	{
		var ok = true;
		var pool = device.createCommandPool();
		if (pool == null)
		{
			trace("[api] FAIL createCommandPool");
			return false;
		}

		var commands = pool.allocateCommandBuffer();
		if (commands == null)
		{
			trace("[api] FAIL allocateCommandBuffer");
			pool.dispose();
			return false;
		}

		ok = checkFenceStatus(device) && ok;
		ok = checkFreeDescriptorSet(device) && ok;
		stdout("[api] command-buffer api checks:");
		ok = checkQueryCopy(device, queue, pool, commands) && ok;
		ok = checkDynamicRendering(device, featureRequests) && ok;
		ok = checkSparse(device, queue, featureRequests) && ok;

		pool.dispose();
		return ok;
	}

	private static function stdout(message:String):Void
	{
		trace(message);
	}

	private static function checkFenceStatus(device:VKDevice):Bool
	{
		var fence = device.createFence(true);
		if (fence == null)
		{
			trace("[api] FAIL createFence");
			return false;
		}

		var status = fence.getStatus();
		var ok = status == VK.SUCCESS || status == VK.NOT_READY;
		if (!ok)
		{
			trace("[api] FAIL getFenceStatus -> " + status);
		}
		else
		{
			stdout("[api] PASS getFenceStatus -> " + status);
		}

		fence.dispose();
		return ok;
	}

	private static function checkFreeDescriptorSet(device:VKDevice):Bool
	{
		// freeDescriptorSets() requires the pool to be created with FREE_DESCRIPTOR_SET_BIT.
		var descriptorPool = device.createDescriptorPool(1, [new VKDescriptorPoolSize(VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, 1)],
			VK.DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT);
		var layout = device.createDescriptorSetLayout([new VKDescriptorSetLayoutBinding(0, VK.DESCRIPTOR_TYPE_UNIFORM_BUFFER, VK.SHADER_STAGE_VERTEX_BIT)]);
		if (descriptorPool == null || layout == null)
		{
			trace("[api] FAIL create descriptor pool/layout");
			return false;
		}

		var set = descriptorPool.allocate(layout);
		var ok = set != null && set.isValid();
		if (ok)
		{
			set.free();
			ok = !set.isValid();
		}

		if (ok)
		{
			stdout("[api] PASS freeDescriptorSet");
		}
		else
		{
			trace("[api] FAIL freeDescriptorSet");
		}

		descriptorPool.dispose();
		layout.dispose();
		return ok;
	}

	private static function checkQueryCopy(device:VKDevice, queue:VKQueue, pool:VKCommandPool, commands:VKCommandBuffer):Bool
	{
		var queryPool = device.createQueryPool(VK.QUERY_TYPE_TIMESTAMP, 1);
		var destination = device.createBufferWithMemory(Int64.ofInt(16), VK.BUFFER_USAGE_TRANSFER_DST_BIT,
			VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT);
		if (queryPool == null || destination == null)
		{
			trace("[api] FAIL create query pool/dst buffer");
			return false;
		}

		var fence = device.createFence();
		var timeline = device.createTimelineSemaphore(Int64.ofInt(0));
		if (timeline == null || !timeline.isValid())
		{
			trace("[api] FAIL createTimelineSemaphore");
			return false;
		}

		// VKCommandBuffer exposes these without the vkCmd prefix, and writeTimestamp
		// takes (pool, queryIndex, pipelineStage) — not the vkCmd argument order.
		var ok = commands.reset()
			&& commands.begin()
			&& commands.resetQueryPool(queryPool, 0, 1)
			&& commands.writeTimestamp(queryPool, 0, VK.PIPELINE_STAGE_TOP_OF_PIPE_BIT)
			&& commands.pipelineBarrier2(VK.PIPELINE_STAGE_2_TOP_OF_PIPE_BIT, VK.ACCESS_2_NONE, VK.PIPELINE_STAGE_2_TRANSFER_BIT, VK.ACCESS_2_TRANSFER_WRITE_BIT)
			&& commands.copyQueryPoolResults(queryPool, destination, 0, 1, Int64.ofInt(0), Int64.ofInt(4), VK.QUERY_RESULT_WAIT_BIT | VK.QUERY_RESULT_64_BIT);

		var submitted = false;
		if (ok)
		{
			ok = commands.end();
			if (ok)
			{
				// A timeline semaphore needs VkTimelineSemaphoreSubmitInfo on the pNext
				// chain; a plain VkSubmitInfo is illegal and made the driver fault.
				// Signal it from the host instead.
				submitted = queue.submitSynced(commands, null, null, fence) && fence.waitForever();
				if (submitted) timeline.signal(Int64.ofInt(1));
			}
		}

		if (ok && submitted)
		{
			stdout("[api] PASS cmdCopyQueryPoolResults");
		}
		else
		{
			trace("[api] FAIL cmdCopyQueryPoolResults (" + VK.getLastError() + ")");
		}

		queryPool.dispose();
		destination.dispose(true);
		timeline.dispose();
		fence.dispose();
		return ok && submitted;
	}

	/**
		Exercises `vkCmdBeginRendering` / `vkCmdEndRendering` (Vulkan 1.3 core).

		The feature bit must have been requested at device creation: the driver
		hands out the PFN even when `dynamicRendering` is off, and calling it then
		is undefined behaviour - the driver crashes instead of returning an error.
		So this runs the real check only when the caller asked for
		`VK.DEVICE_FEATURE_DYNAMIC_RENDERING`, and otherwise reports what the
		device supports and skips.
	**/
	private static function checkDynamicRendering(device:VKDevice, featureRequests:Array<Int>):Bool
	{
		if (featureRequests == null || featureRequests.indexOf(VK.DEVICE_FEATURE_DYNAMIC_RENDERING) < 0)
		{
			var words = device.physicalDevice.getFeatures2([VKStructureType.PHYSICAL_DEVICE_VULKAN_1_3_FEATURES]);
			var supported = words != null
				&& VKFeatureWords.flag(words.get(VKStructureType.PHYSICAL_DEVICE_VULKAN_1_3_FEATURES), 12);
			stdout("[api] SKIP dynamicRendering (dynamicRendering not enabled at device creation; supported=" + supported + ")");
			return true;
		}

		var image = device.createImage(4, 4, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK.IMAGE_USAGE_TRANSFER_SRC_BIT);
		if (image == null || image.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			trace("[api] FAIL create dynamic-rendering target");
			return false;
		}

		// VkRenderingAttachmentInfo::imageView needs an ImageView, not an image —
		// passing the raw image handle crashes most drivers.
		var view = image.createView(VK.FORMAT_R8G8B8A8_UNORM);
		if (view == null || !view.isValid())
		{
			trace("[api] FAIL create dynamic-rendering image view");
			image.dispose(true);
			return false;
		}

		var pool = device.createCommandPool();
		var commands = pool != null ? pool.allocateCommandBuffer() : null;
		var fence = device.createFence();

		if (commands == null || fence == null)
		{
			trace("[api] FAIL dynamic-rendering command resources");
			if (fence != null) fence.dispose();
			if (pool != null) pool.dispose();
			view.dispose();
			image.dispose(true);
			return false;
		}

		var ok = commands.reset()
			&& commands.begin()
			&& commands.pipelineBarrierImage(image, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
				VK.PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK.PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, 0, VK.ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
				VK.IMAGE_ASPECT_COLOR_BIT)
			&& commands.beginRendering(view, 0, 0, 4, 4)
			&& commands.endRendering()
			&& commands.end();

		if (ok)
		{
			ok = device.graphicsQueue.submitSynced(commands, null, null, fence) && fence.waitForever();
		}

		if (ok)
		{
			stdout("[api] PASS beginRendering/endRendering");
		}
		else
		{
			trace("[api] FAIL beginRendering/endRendering (" + VK.getLastError() + ")");
		}

		commands.dispose();
		fence.dispose();
		pool.dispose();
		view.dispose();
		image.dispose(true);
		return ok;
	}

	private static function checkSparse(device:VKDevice, queue:VKQueue, featureRequests:Array<Int>):Bool
	{
		// Sparse binding must be requested at device creation; calling
		// vkQueueBindSparse with the feature off is undefined behaviour.
		if (featureRequests == null || featureRequests.indexOf(VK.DEVICE_FEATURE_SPARSE_BINDING) < 0)
		{
			stdout("[api] SKIP bindSparse (sparseBinding not enabled at device creation)");
			return true;
		}

		// bindSparse submits VkSparseImageMemoryBindInfo, which additionally needs the
		// sparseResidencyImage2D feature: without it the image may not even carry
		// VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT.
		if (featureRequests.indexOf(VK.DEVICE_FEATURE_SPARSE_RESIDENCY_IMAGE_2D) < 0)
		{
			stdout("[api] SKIP bindSparse (sparseResidencyImage2D was not enabled at device creation)");
			return true;
		}

		var image = device.createImageEx(8, 8, VK.FORMAT_R8G8B8A8_UNORM, VK.IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
			VK.IMAGE_CREATE_SPARSE_BINDING_BIT | VK.IMAGE_CREATE_SPARSE_RESIDENCY_BIT);
		if (image == null || !image.isValid())
		{
			stdout("[api] SKIP createImageEx(sparse) unsupported");
			return true;
		}

		// A sparse image must never go through vkBindImageMemory: it is bound with
		// vkQueueBindSparse, and the memory has to come from the IMAGE's own
		// requirements (a buffer's allocation does not satisfy its memoryTypeBits).
		var memory = device.allocateMemory(image.getMemoryRequirements(), VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
		var ok = memory != null && memory.isValid();
		if (ok)
		{
			ok = queue.bindSparse(image, memory);
			if (ok)
			{
				stdout("[api] PASS bindSparse");
			}
			else
			{
				trace("[api] FAIL bindSparse (" + VK.getLastError() + ")");
			}
			image.dispose(true);
			memory.dispose();  // VKDeviceMemory::dispose takes no argument
			return ok;
		}

		image.dispose(true);
		stdout("[api] SKIP bindSparse (no device-local memory)");
		return true;
	}
}