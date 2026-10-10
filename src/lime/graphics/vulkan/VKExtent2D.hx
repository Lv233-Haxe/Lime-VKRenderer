package lime.graphics.vulkan;

/**
	A two-component integer extent, used for values such as render area granularity.
**/
class VKExtent2D
{
	public var height(default, null):Int;
	public var width(default, null):Int;

	public function new(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;
	}

	public static function fromDynamic(data:Dynamic):VKExtent2D
	{
		if (data == null)
		{
			return null;
		}

		return new VKExtent2D(data.width, data.height);
	}
}
