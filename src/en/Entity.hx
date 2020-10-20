package en;

import ui.Hud;

class Entity {
	public static var ALL : Array<Entity> = [];
	public static var GC : Array<Entity> = [];

	// Shorthands properties
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var level(get, never) : Level;
	inline function get_level() return Game.ME.level;
	public var ftime(get, never) : Float;
	inline function get_ftime() return Game.ME.ftime;
	public var utmod(get, never) : Float;
	inline function get_utmod() return Game.ME.utmod;
	public var tmod(get, never) : Float;
	inline function get_tmod() return Game.ME.tmod;
	public var hud(get, never) : ui.Hud;
	inline function get_hud() return Game.ME.hud;

	// Main properties
	public var uid : Int;

	public var destroyed(default, null) = false;

	public var cd : dn.Cooldown;
	public var ucd : dn.Cooldown;

	// Base coordinates
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.5;
	public var yr = 0.5;
	public var angle = 0.;
	public var hei(default, set) : Float = Const.GRID;
	inline function set_hei(v) {
		invalidateDebugBounds = true;
		return hei = v;
	}
	public var wid(default, set) : Float = Const.GRID;
	inline function set_wid(v) {
		invalidateDebugBounds = true;
		return wid = v;
	}
	public var radius(default, set) : Float = Const.GRID * 0.5;
	inline function set_radius(v) {
		invalidateDebugBounds = true;
		return radius = v;
	}

	// Movements
	public var dx = 0.;
	public var dy = 0.;
	public var bdx = 0.;
	public var bdy = 0.;
	public var dxTotal(get, never) : Float;
	inline function get_dxTotal() return dx + bdx;
	public var dyTotal(get, never) : Float;
	inline function get_dyTotal() return dy + bdy;

	public var frict = 0.82;
	public var bumpFrict = 0.93;
	public var bumpStrength = 0.;

	public var footX(get, never) : Float;
	inline function get_footX() return (cx + xr) * Const.GRID;
	public var footY(get, never) : Float;
	inline function get_footY() return (cy + yr) * Const.GRID;
	public var prevFrameFootX : Float = -Const.INFINITE;
	public var prevFrameFootY : Float = -Const.INFINITE;

	// Display
	public var spr : HSprite;
	public var baseColor : h3d.Vector;
	public var blinkColor : h3d.Vector;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;
	public var sprSquashX = 1.0;
	public var sprSquashY = 1.0;
	public var visible = true;

	public var maxLife(default, null) : Int;
	public var life(default, null) : Int;

	var actions : Array<{id : String, cb : Void->Void, t : Float}> = [];

	// Debug
	var debugLabel : Null<h2d.Text>;
	var debugBounds : Null<h2d.Graphics>;
	var invalidateDebugBounds = false;

	public function new(?x : Int, ?y : Int, ?spriteLib : SpriteLib) {
		uid = Const.NEXT_UNIQ;
		ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		ucd = new dn.Cooldown(Const.FPS);

		if (x != null && y != null)
			setPosCell(x, y);

		spr = new HSprite(spriteLib);
		spr.colorAdd = new h3d.Vector();
		baseColor = new h3d.Vector();
		blinkColor = new h3d.Vector();
		spr.setCenterRatio(0.5, 0.5);

		if (ui.Console.ME.hasFlag("bounds"))
			enableBounds();
	}

	public function setPosCell(x : Int, y : Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		onPosManuallyChanged();
	}

	public function setPosPixel(x : Float, y : Float) {
		cx = Std.int(x / Const.GRID);
		cy = Std.int(y / Const.GRID);
		xr = (x - cx * Const.GRID) / Const.GRID;
		yr = (y - cy * Const.GRID) / Const.GRID;
		onPosManuallyChanged();
	}

	#if heapsOgmo
	public function setPosUsingOgmoEnt(oe : ogmo.Entity) {
		cx = Std.int(oe.x / Const.GRID);
		cy = Std.int(oe.y / Const.GRID);
		xr = (oe.x - cx * Const.GRID) / Const.GRID;
		yr = (oe.y - cy * Const.GRID) / Const.GRID;
		onPosManuallyChanged();
	}
	#end

	function onPosManuallyChanged() {
		if (M.dist(footX, footY, prevFrameFootX, prevFrameFootY) > Const.GRID * 2) {
			prevFrameFootX = footX;
			prevFrameFootY = footY;
		}
	}

	public function bump(x : Float, y : Float) {
		bdx += x;
		bdy += y;
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}

	public function is<T : Entity>(c : Class<T>) return Std.isOfType(this, c);

	public function as<T : Entity>(c : Class<T>) : T return Std.downcast(this, c);

	public inline function getMoveAng() return Math.atan2(dyTotal, dxTotal);

	public inline function distEntity(e : Entity)
		return M.dist(cx + xr, cy + yr, e.cx + e.xr, e.cy + e.yr);

	public inline function distCell(tcx : Int, tcy : Int, ?txr = 0.5, ?tyr = 0.5)
		return M.dist(cx + xr, cy + yr, tcx + txr, tcy + tyr);

	public inline function distPx(e : Entity)
		return M.dist(footX, footY, e.footX, e.footY);

	public inline function distPxFree(x : Float, y : Float)
		return M.dist(footX, footY, x, y);
	
	public inline function isDead() {
		return life <= 0;
	}

	public function hit(dmg : Int, from : Null<Entity>) {
		if (isDead() || dmg <= 0)
			return;

		life = M.iclamp(life - dmg, 0, maxLife);
		onDamage(dmg, from);
	}

	public function onDamage(dmg : Int, from : Null<Entity>) {}

	public inline function destroy() {
		if (!destroyed) {
			destroyed = true;
			GC.push(this);
		}
	}

	public function dispose() {
		ALL.remove(this);

		baseColor = null;
		blinkColor = null;

		spr.remove();
		spr = null;

		if (debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}

		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}

		cd.destroy();
		cd = null;
	}

	public inline function debug(?v : Dynamic, ?c = 0xffffff) {
		#if debug
		if (v == null && debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}
		if (v != null) {
			if (debugLabel == null)
				debugLabel = new h2d.Text(Assets.fontTiny, game.scroller);
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	public function disableBounds() {
		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}
	}

	public function enableBounds() {
		if (debugBounds == null) {
			debugBounds = new h2d.Graphics();
			game.scroller.add(debugBounds, Const.DP_TOP);
		}
		invalidateDebugBounds = true;
	}

	function renderBounds() {
		var c = Color.makeColorHsl((uid % 20) / 20, 1, 1);
		debugBounds.clear();

		// Box
		debugBounds.lineStyle(1, c, 0.5);
		debugBounds.drawRect(-wid / 2, -hei / 2, wid, hei);

		debugBounds.lineStyle(1, c, 0.8);
		debugBounds.drawRoundedRect(-radius, -radius, radius * 2, radius * 2, radius);

		// Radius
		debugBounds.lineStyle(1, c, 0.3);
		debugBounds.drawCircle(0, 0, radius);

		debugBounds.lineStyle(1, c, 0.5);
		debugBounds.drawCircle(0, 0, 1);
	}

	function chargeAction(id : String, sec : Float, cb : Void->Void) {
		if (isChargingAction(id))
			cancelAction(id);
		if (sec <= 0)
			cb();
		else
			actions.push({id: id, cb: cb, t: sec * Const.FPS});
	}

	public function isChargingAction(?id : String) {
		if (id == null)
			return actions.length > 0;

		for (a in actions)
			if (a.id == id)
				return true;

		return false;
	}

	public function cancelAction(?id : String) {
		if (id == null)
			actions = [];
		else {
			var i = 0;
			while (i < actions.length) {
				if (actions[i].id == id)
					actions.splice(i, 1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while (i < actions.length) {
			var a = actions[i];
			a.t -= tmod;
			if (a.t <= 0) {
				actions.splice(i, 1);
				if (!destroyed)
					a.cb();
			} else
				i++;
		}
	}

	public function blink(c : UInt) {
		blinkColor.setColor(c);
		cd.setS("keepBlink", 0.06);
	}

	public function setSquashX(v : Float) {
		sprSquashX = v;
		sprSquashY = 2 - v;
	}

	public function setSquashY(v : Float) {
		sprSquashX = 2 - v;
		sprSquashY = v;
	}

	public function preUpdate() {
		ucd.update(utmod);
		cd.update(tmod);
		updateActions();
	}

	public function postUpdate() {
		spr.x = footX;
		spr.y = footY;
		spr.rotation = angle;
		spr.scaleX = sprScaleX * sprSquashX;
		spr.scaleY = sprScaleY * sprSquashY;
		spr.visible = visible;

		sprSquashX += (1 - sprSquashX) * 0.2;
		sprSquashY += (1 - sprSquashY) * 0.2;

		// Blink
		if (!cd.has("keepBlink")) {
			blinkColor.r *= Math.pow(0.60, tmod);
			blinkColor.g *= Math.pow(0.55, tmod);
			blinkColor.b *= Math.pow(0.50, tmod);
		}

		// Color adds
		spr.colorAdd.load(baseColor);
		spr.colorAdd.r += blinkColor.r;
		spr.colorAdd.g += blinkColor.g;
		spr.colorAdd.b += blinkColor.b;

		// Debug label
		if (debugLabel != null) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth * 0.5);
			debugLabel.y = Std.int(footY + 1);
		}

		// Debug bounds
		if (debugBounds != null) {
			if (invalidateDebugBounds) {
				invalidateDebugBounds = false;
				renderBounds();
			}
			debugBounds.x = footX;
			debugBounds.y = footY;
		}
	}

	public function finalUpdate() {
		prevFrameFootX = footX;
		prevFrameFootY = footY;
	}

	public function fixedUpdate() {}

	public function onCollide(e : Entity) {}

	public function update() {
		var cellCheckR = M.fabs(radius * 2 / Const.GRID);
		var cellCheckD = Std.int(cellCheckR - 0.5);
		cellCheckR -= cellCheckD;

		// X
		var steps = M.ceil(M.fabs(dxTotal * tmod));
		var step = dxTotal * tmod / steps;
		while (steps > 0) {
			xr += step;

			// X collisions checks
			if (xr >= 1 - cellCheckR && level.hasColl(cx + cellCheckD, cy)) {
				onCollide(level.getBreakable(cx + cellCheckD, cy));
				bdx -= bumpStrength * tmod;
				xr = 1 - cellCheckR;
				dx = 0;
			} else if (xr <= cellCheckR && level.hasColl(cx - cellCheckD, cy)) {
				onCollide(level.getBreakable(cx - cellCheckD, cy));
				bdx += bumpStrength * tmod;
				xr = cellCheckR;
				dx = 0;
			}

			while (xr > 1) {
				xr--;
				cx++;
			}
			while (xr < 0) {
				xr++;
				cx--;
			}
			steps--;
		}
		dx *= Math.pow(frict, tmod);
		bdx *= Math.pow(bumpFrict, tmod);
		if (M.fabs(dx) <= 0.0005 * tmod)
			dx = 0;
		if (M.fabs(bdx) <= 0.0005 * tmod)
			bdx = 0;

		// Y
		var steps = M.ceil(M.fabs(dyTotal * tmod));
		var step = dyTotal * tmod / steps;
		while (steps > 0) {
			yr += step;

			// Y collisions checks
			if (yr >= 1 - cellCheckR && level.hasColl(cx, cy + cellCheckD)) {
				onCollide(level.getBreakable(cx, cy + cellCheckD));
				bdy -= bumpStrength * tmod;
				yr = 1 - cellCheckR;
				dy = 0;
			} else if (yr <= cellCheckR && level.hasColl(cx, cy - cellCheckD)) {
				onCollide(level.getBreakable(cx, cy - cellCheckD));
				bdy += bumpStrength * tmod;
				yr = cellCheckR;
				dy = 0;
			}

			while (yr > 1) {
				yr--;
				cy++;
			}
			while (yr < 0) {
				yr++;
				cy--;
			}
			steps--;
		}
		dy *= Math.pow(frict, tmod);
		bdy *= Math.pow(bumpFrict, tmod);
		if (M.fabs(dy) <= 0.0005 * tmod)
			dy = 0;
		if (M.fabs(bdy) <= 0.0005 * tmod)
			bdy = 0;

		#if debug
		if (ui.Console.ME.hasFlag("bounds") && debugBounds == null)
			enableBounds();

		if (!ui.Console.ME.hasFlag("bounds") && debugBounds != null)
			disableBounds();
		#end
	}
}
