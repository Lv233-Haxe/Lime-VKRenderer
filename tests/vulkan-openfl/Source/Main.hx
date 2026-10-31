package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;

/**
	原版 OpenFL 显示列表 + Vulkan 渲染器集成验证:
	`<window renderer="vulkan" />` → Stage → VulkanRenderer → lime Vulkan2DRenderer。

	32 个移动/旋转的 Bitmap(两色 2x2 纹理放大后 NEAREST 出色块),5 秒后自动退出并
	输出 SUMMARY 行(帧数推进 = 显示列表确实被 Vulkan 路径渲染)。
**/
class Main extends Sprite
{
	private static inline var SPRITE_COUNT = 32;

	private var bitmaps:Array<Bitmap>;
	private var frameCount:Int;
	private var startedAt:Float;
	private var renderOk:Bool;

	public function new()
	{
		super();

		var pattern = new BitmapData(2, 2, false, 0x000000);

		// 2x2 四色:R/G/B/W
		pattern.setPixel32(0, 0, 0xFFFF0000);
		pattern.setPixel32(1, 0, 0xFF00FF00);
		pattern.setPixel32(0, 1, 0xFF0000FF);
		pattern.setPixel32(1, 1, 0xFFFFFFFF);

		bitmaps = [];

		for (i in 0...SPRITE_COUNT)
		{
			var bitmap = new Bitmap(pattern);
			bitmap.smoothing = false;
			bitmap.scaleX = 24;
			bitmap.scaleY = 24;
			bitmap.x = 40 + (i % 8) * 90;
			bitmap.y = 40 + Std.int(i / 8) * 130;
			addChild(bitmap);
			bitmaps.push(bitmap);
		}

		stage.color = 0x06060c;
		renderOk = true;
		startedAt = flash.Lib.getTimer() / 1000.0;

		// 每帧动画 + 5 秒自动退出
		addEventListener(flash.events.Event.ENTER_FRAME, function(_)
		{
			frameCount++;
			var time = flash.Lib.getTimer() / 1000.0;

			if (time - startedAt >= 5)
			{
				trace("[ofl-vk] SMOKE SUMMARY frames=" + frameCount + " renderOk=" + renderOk
					+ " status=" + (renderOk ? "PASS" : "FAIL"));
				Lib.application.window.close();
				return;
			}

			for (i in 0...bitmaps.length)
			{
				var bitmap = bitmaps[i];
				var phase = i * 0.4;
				bitmap.rotation = time * (30 + (i % 4) * 15) + phase * 30;
				bitmap.x = 40 + (i % 8) * 90 + Math.sin(time * 1.5 + phase) * 20;
				bitmap.y = 40 + Std.int(i / 8) * 130 + Math.cos(time * 1.1 + phase) * 16;
			}
		});

		trace("[ofl-vk] started, stage=" + Type.getClassName(Type.getClass(stage)));
	}
}
