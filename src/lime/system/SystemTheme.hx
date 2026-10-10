package lime.system;

/**
	Selects the system UI theme reported by the platform, backed by
	SDL_GetSystemTheme (SDL 3.2+).
**/
#if (haxe_ver >= 4.0) enum #else @:enum #end abstract SystemTheme(Int) from Int to Int
{
	/** The system theme can't be determined. **/
	var UNKNOWN = 0;

	/** The system uses a light-colored theme. **/
	var LIGHT = 1;

	/** The system uses a dark-colored theme. **/
	var DARK = 2;
}
