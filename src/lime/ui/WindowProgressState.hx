package lime.ui;

/**
	Selects the state of a window's taskbar/dock progress indicator, backed by
	SDL_SetWindowProgressState (SDL 3.2.8+).
**/
#if (haxe_ver >= 4.0) enum #else @:enum #end abstract WindowProgressState(Int) from Int to Int
{
	/** No progress bar is shown. **/
	var NONE = 0;

	/** The progress bar is shown in an indeterminate state. **/
	var INDETERMINATE = 1;

	/** The progress bar is shown in a normal state. **/
	var NORMAL = 2;

	/** The progress bar is shown in a paused state. **/
	var PAUSED = 3;

	/** The progress bar is shown in an error state. **/
	var ERROR = 4;
}
