package lime.graphics.vulkan;

/**
	Information about one instance or device layer.
**/
class VKLayerProperties
{
	public var description(default, null):String;
	public var implementationVersion(default, null):Int;
	public var name(default, null):String;
	public var specVersion(default, null):Int;

	public function new(name:String, specVersion:Int, implementationVersion:Int, description:String)
	{
		this.name = name;
		this.specVersion = specVersion;
		this.implementationVersion = implementationVersion;
		this.description = description;
	}

	public static function fromDynamic(data:Dynamic):VKLayerProperties
	{
		if (data == null)
		{
			return null;
		}

		#if (!lime_doc_gen || lime_cffi)
		return new VKLayerProperties(lime.system.CFFI.stringValue(data.name), data.specVersion, data.implementationVersion,
			lime.system.CFFI.stringValue(data.description));
		#else
		return new VKLayerProperties(cast data.name, data.specVersion, data.implementationVersion, cast data.description);
		#end
	}
}
