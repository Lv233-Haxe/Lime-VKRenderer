package lime.graphics.vulkan;

import haxe.Int64;
import lime.graphics.VulkanRenderContext;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A lightweight managed `VkInstance` wrapper created through `VK.createInstance`.
**/
class VKInstance
{
	public var context(default, null):VulkanRenderContext;
	public var handle(default, null):Int64;

	@:allow(lime.graphics.vulkan.VK)
	private function new(context:VulkanRenderContext, handle:Int64)
	{
		this.context = context;
		this.handle = handle;
	}

	/**
		Creates a `VKSurface` for the current window using this instance.
	**/
	public function createSurface(contextOverride:VulkanRenderContext = null):VKSurface
	{
		var activeContext = (contextOverride != null) ? contextOverride : context;

		if (activeContext == null || VK.__isZero(handle))
		{
			return null;
		}

		#if (!macro && lime_cffi)
		var surfaceData:Dynamic = NativeCFFI.lime_window_create_vulkan_surface(activeContext.__windowHandle, handle.high, handle.low);
		if (surfaceData != null)
		{
			return new VKSurface(activeContext, this, surfaceData.high, surfaceData.low);
		}
		#end

		return null;
	}

	/**
		Destroys the managed `VkInstance`.
	**/
	public function dispose():Void
	{
		#if (!macro && lime_cffi)
		if (context != null && !VK.__isZero(handle))
		{
			NativeCFFI.lime_vk_destroy_instance(context.__windowHandle, handle.high, handle.low);
			handle = Int64.ofInt(0);
		}
		#end
	}

	/**
		Enumerates physical devices visible to this instance. If a surface is
		provided, queue family presentation support is populated for that surface.
	**/
	public function enumeratePhysicalDevices(surface:VKSurface = null):Array<VKPhysicalDevice>
	{
		var devices = new Array<VKPhysicalDevice>();

		if (context == null || VK.__isZero(handle))
		{
			return devices;
		}

		#if (!macro && lime_cffi)
		var result:Dynamic = NativeCFFI.lime_vk_get_physical_devices(context.__windowHandle, handle.high, handle.low, surface != null ? surface.high : 0,
			surface != null ? surface.low : 0);

		if (result != null)
		{
			var length:Int = untyped result.length;
			for (i in 0...length)
			{
				devices.push(new VKPhysicalDevice(this, untyped result[i]));
			}
		}
		#end

		return devices;
	}

	/**
		Selects a preferred physical device using Lime's lightweight heuristics.
	**/
	public function pickPhysicalDevice(surface:VKSurface = null, preferDiscrete:Bool = true):VKPhysicalDevice
	{
		return VK.pickPhysicalDevice(enumeratePhysicalDevices(surface), surface != null && surface.isValid(), preferDiscrete);
	}

	/**
		Returns the Vulkan API version supported by the loader.

		This is `vkEnumerateInstanceVersion` (Vulkan 1.1 core); on a 1.0-only
		loader the call fails and `null` is returned.
	**/
	public function getApiVersion():VKApiVersion
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (context != null)
		{
			// vkEnumerateInstanceVersion is a global command, so this also works
			// before the instance itself is usable.
			return VKApiVersion.fromDynamic(NativeCFFI.lime_vk_enumerate_instance_version(context.__windowHandle));
		}
		#end

		return null;
	}

	/**
		Enumerates the instance extensions available on this system, optionally
		filtered to those provided by the named implicit layer.
	**/
	public function getExtensions(layerName:String = null):Array<VKExtensionProperties>
	{
		var extensions = new Array<VKExtensionProperties>();

		#if (!macro && lime_cffi)
		// vkEnumerateInstanceExtensionProperties is a global command: it needs the
		// loader, not this instance, so it works before the instance exists.
		if (context != null)
		{
			var result:Dynamic = NativeCFFI.lime_vk_enumerate_instance_extension_properties(context.__windowHandle, layerName);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					extensions.push(VKExtensionProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return extensions;
	}

	/**
		Enumerates the instance layers available on this system.
	**/
	public function getLayers():Array<VKLayerProperties>
	{
		var layers = new Array<VKLayerProperties>();

		#if (!macro && lime_cffi)
		if (context != null)
		{
			var result:Dynamic = NativeCFFI.lime_vk_enumerate_instance_layer_properties(context.__windowHandle);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					layers.push(VKLayerProperties.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return layers;
	}

	/**
		Enumerates physical-device groups (Vulkan 1.1).

		Each group is a set of devices that can be driven by one logical device.
		A plain single-GPU machine yields one group holding one device.
	**/
	public function enumeratePhysicalDeviceGroups():Array<VKPhysicalDeviceGroupProperties>
	{
		var groups = new Array<VKPhysicalDeviceGroupProperties>();

		if (context == null || VK.__isZero(handle))
		{
			return groups;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		var result:Dynamic = NativeCFFI.lime_vk_enumerate_physical_device_groups(context.__windowHandle, handle.high, handle.low);
		if (result != null)
		{
			var length:Int = untyped result.length;
			for (i in 0...length)
			{
				groups.push(VKPhysicalDeviceGroupProperties.fromDynamic(untyped result[i]));
			}
		}
		#end

		return groups;
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
