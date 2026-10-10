package lime.ui;

/**
	Selects the backdrop effect for a window, backed by
	SetWindowCompositionAttribute (Windows) — the window must be created with
	`transparent: true` so its frames carry an alpha channel, and only pixels
	drawn with alpha < 1 will reveal the backdrop.
**/
#if (haxe_ver >= 4.0) enum #else @:enum #end abstract WindowBlurMode(Int) from Int to Int
{
	/** No backdrop effect; the window is fully opaque. **/
	var NONE = 0;

	/** System blur behind the window (the stable Windows 10 "Aero" blur). **/
	var BLUR = 1;

	/**
		Acrylic blur (semi-transparent tint + noise + system blur). Known
		Windows limitation: while dragging, acrylic windows can lag one frame
		behind the cursor on some Windows 10 / 11 combinations.
	**/
	var ACRYLIC = 2;
}
