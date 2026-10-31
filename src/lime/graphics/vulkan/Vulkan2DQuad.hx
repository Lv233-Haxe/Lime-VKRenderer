package lime.graphics.vulkan;

/**
	One queued textured quad (data-only; expanded into vertices by the renderer).
**/
class Vulkan2DQuad
{
	public var a:Float;
	public var b:Float;
	public var g:Float;
	public var height:Float;
	public var r:Float;
	public var rotation:Float;
	public var texture:Vulkan2DTexture;
	public var u0:Float;
	public var u1:Float;
	public var v0:Float;
	public var v1:Float;
	public var width:Float;
	public var corners:Array<Float>; // 可选:8 float 直存四角(x0,y0..x3,y3),优先于 x/y/w/h/rotation
	public var x:Float;
	public var y:Float;

	public function new()
	{
		r = g = b = a = 1;
	}
}
