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

	public var collMap : Map<Int, Bool>;

	public function new() {
		super(Game.ME);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		collMap = new Map();
	}

	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function hasCollision(cx, cy) : Bool
		return !isValid(cx, cy) ? true : collMap.get(coordId(cx, cy));

	public function setColl(x, y, v : Bool) {
		collMap.set(coordId(x, y), v);
	}

	override function init() {
		super.init();

		if (root != null)
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

		// Add level layers to the root
		var lIdx = 0;
		for (layer in cdb.layers) {
			if (layer.name == "collision") {
				for (t in CdbHelper.getLayerPoints(current.layers[lIdx].data, wid))
					setColl(t.cx, t.cy, true);
			}
			root.addChild(layer.content);
			lIdx++;
		}

		// Update camera zoom
		Const.SCALE = Math.floor(Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID));

		for (t in current.triggers) {
			if (t.id == Data.Levels_triggers_id.Start) {
				Game.ME.hero.setPosCell(t.x, t.y);
			}
		}
	}

	override function onResize() {
		super.onResize();

		// Update camera zoom
		Const.SCALE = Math.floor(Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID));
	}

	public function render() {}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}
