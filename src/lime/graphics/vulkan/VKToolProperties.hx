package lime.graphics.vulkan;

#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
#end

/**
	One entry reported by `VKPhysicalDevice.getToolProperties`.

	Vulkan 1.3 lets profiling / validation / tracing tools announce themselves
	through `vkGetPhysicalDeviceToolProperties`; each entry carries a name, the
	tool's own version string, a `VKObjectType`-independent bitmask of purposes
	(`VK.TOOL_PURPOSE_*`), and - for layered tools - the layer that owns it.
**/
class VKToolProperties
{
	public var name(default, null):String;
	public var version(default, null):String;
	public var purposes(default, null):Int;
	public var description(default, null):String;
	public var layer(default, null):String;

	public function new(name:String, version:String, purposes:Int, description:String, layer:String)
	{
		this.name = name;
		this.version = version;
		this.purposes = purposes;
		this.description = description;
		this.layer = layer;
	}

	public static function fromDynamic(data:Dynamic):VKToolProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKToolProperties(#if (!lime_doc_gen || lime_cffi) lime.system.CFFI.stringValue(data.name) #else cast data.name #end,
			#if (!lime_doc_gen || lime_cffi) lime.system.CFFI.stringValue(data.version) #else cast data.version #end, data.purposes,
			#if (!lime_doc_gen || lime_cffi) lime.system.CFFI.stringValue(data.description) #else cast data.description #end,
			#if (!lime_doc_gen || lime_cffi) lime.system.CFFI.stringValue(data.layer) #else cast data.layer #end);
	}
}
