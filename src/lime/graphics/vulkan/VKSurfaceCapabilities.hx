package lime.graphics.vulkan;

/**
	Surface capabilities for a physical device + window pair
	(`VkSurfaceCapabilitiesKHR`).

	Returned by `VKPhysicalDevice.getSurfaceCapabilities()`. Query this before
	creating a swapchain: it tells you the legal image-count range, the extent
	the window actually wants, and which composite/usage flags are allowed.
**/
class VKSurfaceCapabilities
{
	/**
		Extent the surface currently wants.

		When either component is `0xFFFFFFFF` the surface size is decided by the
		swapchain, and the extent must be clamped into
		`[minImageExtent, maxImageExtent]` yourself — use `resolveExtent()`.
	**/
	public var currentExtent(default, null):VKExtent2D;

	/**
		Transform currently applied to the surface contents, if any.
	**/
	public var currentTransform(default, null):Int;

	public var maxImageArrayLayers(default, null):Int;
	public var maxImageCount(default, null):Int;
	public var maxImageExtent(default, null):VKExtent2D;
	public var minImageCount(default, null):Int;
	public var minImageExtent(default, null):VKExtent2D;

	/**
		`VK.COMPOSITE_ALPHA_*` bitmask.
	**/
	public var supportedCompositeAlpha(default, null):Int;

	/**
		`VK.SURFACE_TRANSFORM_*` bitmask.
	**/
	public var supportedTransforms(default, null):Int;

	/**
		`VK.IMAGE_USAGE_*` bitmask the swapchain images may be created with.
	**/
	public var supportedUsageFlags(default, null):Int;

	public function new(minImageCount:Int, maxImageCount:Int, currentExtent:VKExtent2D, minImageExtent:VKExtent2D, maxImageExtent:VKExtent2D,
			maxImageArrayLayers:Int, supportedTransforms:Int, currentTransform:Int, supportedCompositeAlpha:Int, supportedUsageFlags:Int)
	{
		this.minImageCount = minImageCount;
		this.maxImageCount = maxImageCount;
		this.currentExtent = currentExtent;
		this.minImageExtent = minImageExtent;
		this.maxImageExtent = maxImageExtent;
		this.maxImageArrayLayers = maxImageArrayLayers;
		this.supportedTransforms = supportedTransforms;
		this.currentTransform = currentTransform;
		this.supportedCompositeAlpha = supportedCompositeAlpha;
		this.supportedUsageFlags = supportedUsageFlags;
	}

	/**
		Returns a legal swapchain extent for the requested size.

		Follows the `vkGetPhysicalDeviceSurfaceCapabilitiesKHR` rules: a concrete
		`currentExtent` wins outright, otherwise the request is clamped into
		`[minImageExtent, maxImageExtent]`.
	**/
	public function resolveExtent(width:Int, height:Int):VKExtent2D
	{
		if (currentExtent != null && currentExtent.width != 0xFFFFFFFF && currentExtent.height != 0xFFFFFFFF)
		{
			return new VKExtent2D(currentExtent.width, currentExtent.height);
		}

		var minW = (minImageExtent != null) ? minImageExtent.width : 1;
		var minH = (minImageExtent != null) ? minImageExtent.height : 1;
		var maxW = (maxImageExtent != null) ? maxImageExtent.width : width;
		var maxH = (maxImageExtent != null) ? maxImageExtent.height : height;

		var clampedWidth = width < minW ? minW : (width > maxW ? maxW : width);
		var clampedHeight = height < minH ? minH : (height > maxH ? maxH : height);

		return new VKExtent2D(clampedWidth, clampedHeight);
	}

	public static function fromDynamic(data:Dynamic):VKSurfaceCapabilities
	{
		if (data == null)
		{
			return null;
		}

		return new VKSurfaceCapabilities(data.minImageCount, data.maxImageCount, VKExtent2D.fromDynamic(data.currentExtent),
			VKExtent2D.fromDynamic(data.minImageExtent), VKExtent2D.fromDynamic(data.maxImageExtent), data.maxImageArrayLayers,
			data.supportedTransforms, data.currentTransform, data.supportedCompositeAlpha, data.supportedUsageFlags);
	}
}
