package lime.graphics.vulkan;

/**
	Result of `VKDevice.isDescriptorSetLayoutSupported()`.

	The main use is checking a bindless (`UPDATE_AFTER_BIND`) layout against the
	implementation's limits *before* creating it — creation itself could otherwise
	fail with no useful diagnostic.
**/
class VKDescriptorSetLayoutSupport
{
	public var supported(default, null):Bool;

	public function new(supported:Bool)
	{
		this.supported = supported;
	}

	public static function fromDynamic(data:Dynamic):VKDescriptorSetLayoutSupport
	{
		if (data == null)
		{
			return null;
		}

		return new VKDescriptorSetLayoutSupport(data.supported == true);
	}
}
