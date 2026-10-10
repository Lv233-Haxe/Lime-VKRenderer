package lime.graphics.vulkan;

/**
	Information about one instance or device extension.
**/
class VKExtensionProperties
{
	public var name(default, null):String;
	public var specVersion(default, null):Int;

	public function new(name:String, specVersion:Int)
	{
		this.name = name;
		this.specVersion = specVersion;
	}

	public static function fromDynamic(data:Dynamic):VKExtensionProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKExtensionProperties(#if (!lime_doc_gen || lime_cffi) lime.system.CFFI.stringValue(data.name) #else cast data.name #end,
			data.specVersion);
	}
}
