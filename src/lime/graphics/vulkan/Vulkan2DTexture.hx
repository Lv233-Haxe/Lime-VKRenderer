package lime.graphics.vulkan;

import haxe.io.Bytes;
import haxe.Int64;

/**
	A sampled RGBA texture owned by the Vulkan2DRenderer. Upload is a one-shot
	staging copy (same proven path as the smoke's texture upload).
**/
class Vulkan2DTexture
{
	public var height(default, null):Int;
	public var isValid(get, null):Bool;
	public var version:Int = -1;
	public var lastError(default, null):String;
	public var width(default, null):Int;

	@:allow(lime.graphics.vulkan.Vulkan2DRenderer)
	private var descriptorSet:VKDescriptorSet;
	private var image:VKImage;
	private var renderer:Vulkan2DRenderer;
	private var sampler:VKSampler;
	private var view:VKImageView;

	@:allow(lime.graphics.vulkan.Vulkan2DRenderer)
	private function new(renderer:Vulkan2DRenderer, width:Int, height:Int)
	{
		this.renderer = renderer;
		this.width = width;
		this.height = height;
		isValid = false;
		lastError = "";
	}

	private function get_isValid():Bool
	{
		return isValid;
	}

	@:allow(lime.graphics.vulkan.Vulkan2DRenderer)
	private function upload(pixels:Bytes):Bool
	{
		var device = renderer.device;

		image = device.createImage(width, height, VK.FORMAT_R8G8B8A8_UNORM,
			VK.IMAGE_USAGE_TRANSFER_DST_BIT | VK.IMAGE_USAGE_SAMPLED_BIT);

		if (image == null || image.allocateMemory(VK.MEMORY_PROPERTY_DEVICE_LOCAL_BIT) == null)
		{
			lastError = "Failed to create Vulkan 2D texture image: " + VK.getLastError();
			return false;
		}

		var staging = device.createStagingBuffer(Int64.ofInt(pixels.length), pixels);

		if (staging == null)
		{
			lastError = "Failed to create Vulkan 2D texture staging buffer: " + VK.getLastError();
			return false;
		}

		var commands = renderer.commandPool.allocateCommandBuffer();

		if (commands == null || !commands.reset() || !commands.begin(VK.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)
			|| !commands.pipelineBarrierImage(image, VK.IMAGE_LAYOUT_UNDEFINED, VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
				VK.PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK.PIPELINE_STAGE_TRANSFER_BIT, 0, VK.ACCESS_TRANSFER_WRITE_BIT,
				VK.IMAGE_ASPECT_COLOR_BIT)
			|| !commands.copyBufferToImage(staging, image, width, height)
			|| !commands.pipelineBarrierImage(image, VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK.IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
				VK.PIPELINE_STAGE_TRANSFER_BIT, VK.PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK.ACCESS_TRANSFER_WRITE_BIT,
				VK.ACCESS_SHADER_READ_BIT, VK.IMAGE_ASPECT_COLOR_BIT)
			|| !commands.end())
		{
			staging.dispose(true);
			lastError = "Failed to record Vulkan 2D texture upload: " + VK.getLastError();
			return false;
		}

		var fence = device.createFence(true);

		if (!fence.reset() || !device.graphicsQueue.submit(commands, fence) || !fence.waitForever())
		{
			staging.dispose(true);
			fence.dispose();
			lastError = "Failed to submit Vulkan 2D texture upload: " + VK.getLastError();
			return false;
		}

		fence.dispose();
		staging.dispose(true);

		view = image.createView(VK.FORMAT_R8G8B8A8_UNORM);
		sampler = device.createSampler(VK.FILTER_NEAREST, VK.SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, VK.SAMPLER_MIPMAP_MODE_NEAREST);
		// 每个纹理集都携带共享的 ortho UBO(binding 0)
		descriptorSet = view != null && sampler != null ? renderer.allocateDescriptorSet(view, sampler) : null;

		if (view == null || sampler == null || descriptorSet == null)
		{
			lastError = "Failed to create Vulkan 2D texture view/sampler/descriptor: " + VK.getLastError();
			return false;
		}

		isValid = true;
		return true;
	}

	public function dispose():Void
	{
		if (descriptorSet != null)
		{
			descriptorSet = null;
		}

		if (sampler != null)
		{
			sampler.dispose();
			sampler = null;
		}

		if (view != null)
		{
			view.dispose();
			view = null;
		}

		if (image != null)
		{
			image.dispose(true);
			image = null;
		}

		isValid = false;
	}
}
