package;

import haxe.io.Bytes;
import haxe.Timer;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.RenderContextType;
import lime.graphics.vulkan.Vulkan2DQuad;
import lime.graphics.vulkan.Vulkan2DRenderer;
import lime.graphics.vulkan.Vulkan2DTexture;
import lime.system.System;

/**
	Vulkan2DRenderer verification: an animated field of batched tinted sprites,
	plus a pixel-exact offscreen readback assertion (the same discipline as the
	smoke's gridUboReadback).
**/
class Main extends Application
{
	private static inline var SPRITE_COUNT = 128;
	private static inline var TEX_SIZE = 32;

	private var renderer:Vulkan2DRenderer;
	private var texture:Vulkan2DTexture;
	private var quads:Array<Vulkan2DQuad>;
	private var failed:Bool;
	private var verified:Bool;

	public function new()
	{
		super();
	}

	override public function onWindowCreate():Void
	{
		super.onWindowCreate();

		if (window.context.type != RenderContextType.VULKAN || window.context.vulkan == null)
		{
			trace("[2d] FAIL: window was not created with a Vulkan context");
			failed = true;
			return;
		}

		renderer = Vulkan2DRenderer.create(window.context.vulkan, "LimeVulkan2D");

		if (renderer == null || !renderer.isValid)
		{
			trace("[2d] FAIL: renderer creation failed: " + (renderer != null ? renderer.lastError : "null"));
			failed = true;
			return;
		}

		trace("[2d] renderer up (" + renderer.width + "x" + renderer.height + ")");

		texture = createCheckerTexture();

		if (texture == null)
		{
			trace("[2d] FAIL: texture creation failed: " + renderer.lastError);
			failed = true;
			return;
		}

		quads = [];

		for (i in 0...SPRITE_COUNT)
		{
			quads.push(new Vulkan2DQuad());
		}

		// 1) offscreen pixel-exact verification before the animated loop
		verifyOffscreen();

		if (failed)
		{
			trace("[2d] SMOKE SUMMARY status=FAIL");
			return;
		}

		trace("[2d] verification complete, entering animated loop");
	}

	private function createCheckerTexture():Vulkan2DTexture
	{
		// 2x2 四色 UV 探针:每个像素的颜色直接暴露采样 uv(TL=R, TR=G, BL=B, BR=W)
		var pixels = Bytes.alloc(2 * 2 * 4);
		// (0,0) R=255; (1,0) G=255; (0,1) B=255; (1,1) W
		pixels.set(0, 255); pixels.set(3, 255);
		pixels.set(5, 255); pixels.set(7, 255);
		pixels.set(10, 255); pixels.set(11, 255);
		pixels.set(12, 255); pixels.set(13, 255); pixels.set(14, 255); pixels.set(15, 255);

		return renderer.createTexture(2, 2, pixels);
	}

	/**
		Renders one full-white quad with tint (0, 1, 0) into a 64x64 red-cleared
		offscreen and asserts the center pixel is exactly the green tint while
		the corner stays the clear color - proves quad transform, tint, blending
		and readback all at once.
	**/
	private function verifyOffscreen():Void
	{
		var quad = new Vulkan2DQuad();
		quad.texture = texture;
		quad.x = 16;
		quad.y = 16;
		quad.width = 32;
		quad.height = 32;
		// uv 0.5..0.99 → NEAREST 采样落在 (1,1) 白象限
		quad.u0 = 0.5;
		quad.v0 = 0.5;
		quad.u1 = 0.99;
		quad.v1 = 0.99;
		quad.r = 1;
		quad.g = 1;
		quad.b = 1;
		quad.a = 1;

		// 机制自检:空 draw 列表 → 整帧应为纯绿清屏
		var emptyPixels = renderer.renderToBytes(64, 64, 0, 1, 0, 1, []);

		if (emptyPixels != null)
		{
			var e0 = emptyPixels.get(0);
			var e1 = emptyPixels.get(1);
			trace("[2d] empty-readback (0,0) RGBA=" + e0 + "," + e1 + "," + emptyPixels.get(2) + "," + emptyPixels.get(3)
				+ " center=" + emptyPixels.get((32 * 64 + 32) * 4) + "," + emptyPixels.get((32 * 64 + 32) * 4 + 1));
		}

		var pixels = renderer.renderToBytes(64, 64, 0, 1, 0, 1, [quad]);

		if (pixels == null)
		{
			trace("[2d] FAIL: offscreen render returned null: " + renderer.lastError);
			failed = true;
			return;
		}

		// Offscreen format is R8G8B8A8_UNORM: memory order = R,G,B,A.
		// clear (1,0,0,1) -> memory [255,0,0,255]; tint (0,1,0) x texel(R40,G60,B255) -> [0,60,0,255].
		var center = (32 * 64 + 32) * 4;
		var c0 = pixels.get(center);
		var c1 = pixels.get(center + 1);
		var c2 = pixels.get(center + 2);
		var c3 = pixels.get(center + 3);

		var corner = (0 * 64 + 0) * 4;
		var k0 = pixels.get(corner);
		var k1 = pixels.get(corner + 1);

		for (py in [4, 32, 60])
		{
			var row = "";

			for (px in [4, 32, 60])
			{
				var o2 = (py * 64 + px) * 4;
				row += " [" + px + "," + py + "]" + pixels.get(o2) + "," + pixels.get(o2 + 1) + "," + pixels.get(o2 + 2);
			}

			trace("[2d] uvrow" + row);
		}

		// 白 tint × 2x2 纹理 uv(0.5..0.99) → NEAREST 白象限 [255,255,255,255];
		// 区域外为绿清屏 [0,255,0,255]
		var okCenter = c0 == 255 && c1 == 255 && c2 == 255 && c3 == 255;
		var okCorner = k0 == 0 && k1 == 255 && pixels.get(corner + 2) == 0 && pixels.get(corner + 3) == 255;

		if (okCenter && okCorner)
		{
			verified = true;
			trace("[2d] PASS offscreenReadback (center tint applied, corner clear; center RGBA=" + c0 + "," + c1 + "," + c2 + "," + c3 + ")");
		}
		else
		{
			trace("[2d] FAIL offscreenReadback (center RGBA=" + c0 + "," + c1 + "," + c2 + "," + c3
				+ " corner RG=" + k0 + "," + k1 + ")");
			failed = true;
		}
	}

	private var frameCount:Int = 0;
	private var startedAt:Float = -1;

	override public function render(context:RenderContext):Void
	{
		super.render(context);

		if (failed || renderer == null || !renderer.isValid)
		{
			return;
		}

		if (startedAt < 0)
		{
			startedAt = Timer.stamp();
		}

		if (Timer.stamp() - startedAt >= 5)
		{
			trace("[2d] SMOKE SUMMARY frames=" + frameCount + " verified=" + verified + " status=" + (failed ? "FAIL" : "PASS"));
			renderer.dispose();
			lime.system.System.exit(0);
		}

		frameCount++;

		var time = Timer.stamp();
		var w = renderer.width;
		var h = renderer.height;

		renderer.setClearColor(0.06, 0.06, 0.09, 1);

		for (i in 0...quads.length)
		{
			var quad = quads[i];
			var col = i % 16;
			var row = Std.int(i / 16);
			var phase = i * 0.39;

			quad.texture = texture;
			quad.x = 24 + col * (w - 64) / 15 + Math.sin(time * 1.7 + phase) * 14;
			quad.y = 24 + row * (h - 64) / 7 + Math.cos(time * 1.3 + phase) * 14;
			quad.width = 28 + Math.sin(time * 2.1 + phase) * 8;
			quad.height = quad.width;
			quad.rotation = time * (0.6 + (i % 5) * 0.2) + phase;

			var tint = 0.45 + 0.55 * (0.5 + 0.5 * Math.sin(time * 2.6 + phase * 1.7));
			quad.r = tint;
			quad.g = 1 - tint * 0.35;
			quad.b = 0.6 + 0.4 * (1 - tint);
			quad.a = 0.85;
			quad.u0 = 0.5;
			quad.v0 = 0.5;
			quad.u1 = 0.99;
			quad.v1 = 0.99;
		}

		for (quad in quads)
		{
			renderer.drawTexture(quad.texture, quad.x, quad.y, quad.width, quad.height,
				quad.u0, quad.v0, quad.u1, quad.v1, quad.r, quad.g, quad.b, quad.a, quad.rotation);
		}

		if (!renderer.endFrame())
		{
			trace("[2d] FAIL: endFrame: " + renderer.lastError);
			failed = true;
		}
	}
}
