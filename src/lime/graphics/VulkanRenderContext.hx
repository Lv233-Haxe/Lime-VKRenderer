package lime.graphics;

import haxe.Int64;
import lime.graphics.vulkan.VK;
import lime.graphics.vulkan.VKApiVersion;
import lime.graphics.vulkan.VKInstance;
import lime.graphics.vulkan.VKRenderer;
import lime.graphics.vulkan.VKSurface;
import lime.math.Vector2;
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
#end
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFIPointer;
#end
#if hl
import hl.Bytes as HLBytes;
import hl.NativeArray;
#end
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

/**
	The `VulkanRenderContext` exposes native Vulkan window bootstrap helpers when
	Vulkan is the render context type of the current `Window`.

	This context owns the window-specific pieces of Lime's Vulkan API:

	- required instance extensions for the current window
	- the current drawable size in pixels
	- Vulkan surface creation for an existing `VKInstance`
	- access to `vkGetInstanceProcAddr`
	- the loader's Vulkan API version (before any instance exists)

	Everything beyond bootstrap lives in `lime.graphics.vulkan.VK` and the
	related `VK*` classes, which cover Vulkan 1.0, 1.1 and 1.2 in full.
**/
@:access(lime._internal.backend.native.NativeCFFI)
class VulkanRenderContext
{
	public var type(default, null):RenderContextType;

	/**
		Vulkan API version supported by the loader, formatted as `major.minor.patch`
		(for example `"1.2.194"`).

		Resolved lazily on first read, so it costs nothing until used. Empty when
		the loader predates `vkEnumerateInstanceVersion` (Vulkan 1.0), in which
		case the loader is 1.0.
	**/
	public var version(get, never):String;

	private var __version:String;
	private var __versionQueried:Bool;

	private var __windowHandle:#if (!lime_doc_gen || lime_cffi) CFFIPointer #else Dynamic #end;

	@:allow(lime._internal.backend.native.NativeWindow)
	private function new(windowHandle:#if (!lime_doc_gen || lime_cffi) CFFIPointer #else Dynamic #end)
	{
		__windowHandle = windowHandle;
		__version = "";
		__versionQueried = false;
		type = VULKAN;
	}

	/**
		Creates a managed `VKInstance` for this window.

		Shorthand for `VK.createInstance (window.context.vulkan, applicationName)`.
	**/
	public function createInstance(applicationName:String = "Lime"):VKInstance
	{
		return VK.createInstance(this, applicationName);
	}

	/**
		Queries the Vulkan API version supported by the loader.

		Unlike `VKInstance.getApiVersion()` this works before any instance exists —
		it only touches the loader — so it is the earliest point at which an
		application can decide which feature level to target.
	**/
	public function getApiVersion():VKApiVersion
	{
		#if (!macro && lime_cffi && lime_vulkan)
		return VKApiVersion.fromDynamic(NativeCFFI.lime_vk_enumerate_instance_version(__windowHandle));
		#end

		return null;
	}

	/**
		Creates a `VKSurface` for the current window using an existing `VKInstance`.

		Equivalent to `instance.createSurface (this)`; returns `null` when the
		instance is `null` or the surface could not be created.
	**/
	public function createSurface(instance:VKInstance):VKSurface
	{
		return (instance != null) ? instance.createSurface(this) : null;
	}

	private function get_version():String
	{
		if (!__versionQueried)
		{
			__versionQueried = true;

			var apiVersion = getApiVersion();
			if (apiVersion != null)
			{
				__version = apiVersion.toString();
			}
		}

		return __version;
	}

	/**
		Gets the current drawable size in pixels for the Vulkan surface.
	**/
	public function getDrawableSize(result:Vector2 = null):Vector2
	{
		if (result == null) result = new Vector2();

		#if (!macro && lime_cffi)
		var size:Dynamic = NativeCFFI.lime_window_get_vulkan_drawable_size(__windowHandle);
		if (size != null)
		{
			result.x = size.width;
			result.y = size.height;
			return result;
		}
		#end

		result.x = 0;
		result.y = 0;
		return result;
	}

	/**
		Returns the list of Vulkan instance extensions required to create a
		surface for this window.
	**/
	public function getInstanceExtensions():Array<String>
	{
		#if (!macro && lime_cffi)
		#if hl
		var bytes:NativeArray<HLBytes> = cast NativeCFFI.lime_window_get_vulkan_instance_extensions(__windowHandle);
		if (bytes != null)
		{
			var extensions = new Array<String>();
			for (i in 0...bytes.length)
			{
				extensions[i] = CFFI.stringValue(bytes[i]);
			}
			return extensions;
		}
		#else
		var extensions:Array<String> = cast NativeCFFI.lime_window_get_vulkan_instance_extensions(__windowHandle);
		if (extensions != null)
		{
			return extensions;
		}
		#end
		#end

		return [];
	}

	/**
		Returns the native address of SDL's `vkGetInstanceProcAddr` function.
	**/
	public function getInstanceProcAddr():Int64
	{
		#if (!macro && lime_cffi)
		var handleData:Dynamic = NativeCFFI.lime_window_get_vulkan_instance_proc_addr(__windowHandle);
		if (handleData != null)
		{
			return Int64.make(handleData.high, handleData.low);
		}
		#end

		return Int64.ofInt(0);
	}

	/**
		Creates Lime's validation Vulkan swapchain renderer for the current window.

		This renderer exists for smoke tests and samples while the public `VK`
		surface grows into the full rendering API.
		The renderer respects the current Lime `vsyncMode` preference when it
		chooses a swapchain present mode.
	**/
	public function createRenderer(applicationName:String = "Lime"):VKRenderer
	{
		#if (!macro && lime_cffi)
		var handle = NativeCFFI.lime_vulkan_renderer_create(__windowHandle, applicationName);
		if (handle != null)
		{
			return new VKRenderer(handle);
		}
		#end

		return null;
	}
}
