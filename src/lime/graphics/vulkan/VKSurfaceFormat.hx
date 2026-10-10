package lime.graphics.vulkan;

/**
	One format the surface accepts (`VkSurfaceFormatKHR`).

	Returned by `VKPhysicalDevice.getSurfaceFormats()`. Pick the entry whose
	`format` matches the colour space your 2D pipeline writes to
	(`VK.FORMAT_B8G8R8A8_UNORM` / `_SRGB` in practice), and pass that `format`
	to `VKDevice.createSwapchain()` and to the render pass you build for it.
**/
class VKSurfaceFormat
{
	public var colorSpace(default, null):Int;
	public var format(default, null):Int;

	public function new(format:Int, colorSpace:Int)
	{
		this.format = format;
		this.colorSpace = colorSpace;
	}

	public static function fromDynamic(data:Dynamic):VKSurfaceFormat
	{
		if (data == null)
		{
			return null;
		}

		return new VKSurfaceFormat(data.format, data.colorSpace);
	}
}
