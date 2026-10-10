package lime.graphics.vulkan;

/**
	A three-component integer extent, used for values such as image granularity.
**/
class VKExtent3D
{
	public var depth(default, null):Int;
	public var height(default, null):Int;
	public var width(default, null):Int;

	public function new(width:Int, height:Int, depth:Int = 1)
	{
		this.width = width;
		this.height = height;
		this.depth = depth;
	}

	public static function fromDynamic(data:Dynamic):VKExtent3D
	{
		if (data == null)
		{
			return null;
		}

		return new VKExtent3D(data.width, data.height, data.depth);
	}
}
