package lime.graphics.vulkan;

import haxe.Int64;

/**
	The Vulkan API version supported by the loader or an instance.

	Returned by `VKInstance.getApiVersion()`. The loader has supported this query
	since Vulkan 1.1, so on an older loader the call fails and the result is
	`null`.
**/
class VKApiVersion
{
	public var major(default, null):Int;
	public var minor(default, null):Int;
	public var patch(default, null):Int;
	public var raw(default, null):Int64;
	public var variant(default, null):Int;

	public function new(major:Int, minor:Int, patch:Int, variant:Int, raw:Int64)
	{
		this.major = major;
		this.minor = minor;
		this.patch = patch;
		this.variant = variant;
		this.raw = raw;
	}

	/**
		Returns `true` when this version is at least `major.minor.patch`.
	**/
	public function atLeast(major:Int, minor:Int, patch:Int = 0):Bool
	{
		if (this.major != major)
		{
			return this.major > major;
		}
		if (this.minor != minor)
		{
			return this.minor > minor;
		}
		return this.patch >= patch;
	}

	public static function fromDynamic(data:Dynamic):VKApiVersion
	{
		if (data == null)
		{
			return null;
		}

		return new VKApiVersion(data.major, data.minor, data.patch, data.variant, Int64.make(data.raw.high, data.raw.low));
	}

	public function toString():String
	{
		return major + "." + minor + "." + patch;
	}
}
