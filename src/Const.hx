class Const {
	public static var FPS = 60;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = -1; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = -1; // -1 to disable auto-scaling on height
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var UI_SCALE = 1.0;
	public static var AUTO_SCALE_UI_TARGET_HEI = 720; // -1 to disable auto-scaling on height
	public static var GRID = 16;
	public static var MAX_CELLS_PER_WIDTH = 25;

	public static var COMBO_BONUS = 100;
	public static var TIMER_BONUS_PER_SEC = 10;
	public static var LIFE_BONUS = 10;
	public static var TIMER_OUT_MUL = 0;
	public static var DEATH_MUL = 0.5;
	public static var ESCAPE_MUL = 2;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get, never) : Int;
	static inline function get_NEXT_UNIQ()
		return _uniq++;

	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_HUD = _inc++;
	public static var DP_UI = _inc++;
}
