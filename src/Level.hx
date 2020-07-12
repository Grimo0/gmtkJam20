import en.Breakable;
import dn.CdbHelper;

class Level extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return game.fx;

	public var current(default, null) : Data.Levels;
	public var currentIdx(default, null) : Int;

	public var wid(get, never) : Int;
	inline function get_wid() return current.width;
	public var hei(get, never) : Int;
	inline function get_hei() return current.height;

	var collMap : Map<Int, Bool>;
	var breakables : Map<Int, Breakable>;

	public function new() {
		super(game);

		createRootInLayers(game.scroller, Const.DP_BG);

		collMap = new Map();
		breakables = new Map();
	}

	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function hasColl(cx, cy) : Bool
		return !isValid(cx, cy) ? true : collMap.get(coordId(cx, cy));

	public inline function setColl(x, y, v : Bool) {
		collMap.set(coordId(x, y), v);
	}

	public inline function getBreakable(x, y) {
		return breakables.get(coordId(x, y));
	}

	public inline function setBreakable(x, y, v : Breakable) {
		breakables.set(coordId(x, y), v);
		setColl(x, y, breakables != null);
	}

	override function init() {
		super.init();

		if (root != null && current != null)
			initLevel();
	}

	public function setLevel(id : Data.LevelsKind) {
		current = Data.levels.get(id);
		currentIdx = 0;
		for (l in Data.levels.all) {
			if (l.id == current.id) {
				break;
			}
			currentIdx++;
		}

		initLevel();
	}

	public function initLevel() {
		var cdb = new h2d.CdbLevel(Data.levels, currentIdx);
		cdb.redraw();

		collMap.clear();
		breakables.clear();
		root.removeChildren();

		// Add level layers to the root & add collisions
		var lIdx = 0;
		for (layer in cdb.layers) {
			if (layer.name == "collision") {
				for (t in CdbHelper.getLayerPoints(current.layers[lIdx].data, wid))
					setColl(t.cx, t.cy, true);
			}
			root.addChildAt(layer.content, layer.name == "over" ? Const.DP_FRONT : Const.DP_BG);
			lIdx++;
		}

		for (o in current.objects) {
			var b = new Breakable(o.object, o.x, o.y, Assets.objects);
			root.add(b.spr, Const.DP_MAIN);
			setBreakable(o.x, o.y, b);
		}

		// Update camera zoom
		Const.SCALE = Math.floor(game.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID));
	}

	override function onResize() {
		super.onResize();

		// Update camera zoom
		Const.SCALE = Math.floor(game.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID));
	}

	public function render() {}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}
