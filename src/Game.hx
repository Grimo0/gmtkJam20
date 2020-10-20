import en.Hero;
import en.Entity;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;
	// public var fx : Fx;
	public var camera(default, null) : Camera;
	public var scroller(default, null) : h2d.Layers;
	public var level(default, null) : Level;
	public var hud(default, null) : ui.Hud;
	public var hero(default, null) : Hero;

	public var levelTimer(default, null) : Float;
	public var points : Int;
	public var combo : Int;
	public var highestCombo : Int;

	var curGameSpeed = 1.0;
	var slowMos : Map<String, {id : String, t : Float, f : Float}> = new Map();

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		// scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		camera = new Camera();
		// fx = new Fx();
		hud = new ui.Hud();
		level = new Level();

		Assets.musicLevel.play(true);

		Process.resizeAll();
	}

	public function startLevel(kind : Data.LevelsKind, animal : Data.AnimalKind) {
		points = 0;
		combo = 0;
		highestCombo = 0;

		if (hero != null) {
			hero.destroy();
		}

		level.setLevel(kind);
		
		levelTimer = level.current.timer;

		hero = new en.Hero(animal, Assets.animals.get(animal));

		hud.reset();
		camera.trackTarget(hero, true);
	}

	public function onCdbReload() {
		if (hero != null)
			hero.reset();
	}

	override function onResize() {
		super.onResize();

		Const.SCALE = Math.floor(w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID));
		
		scroller.setScale(Const.SCALE);
		camera.trackTarget(hero, true);
	}

	override function onDispose() {
		super.onDispose();

		// fx.destroy();
		for (e in Entity.ALL)
			e.destroy();
		gc();
		
		Assets.musicLevel.stop();
	}

	function gc() {
		if (Entity.GC == null || Entity.GC.length == 0)
			return;

		for (e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	public function addSlowMo(id : String, sec : Float, speedFactor = 0.3) {
		if (slowMos.exists(id)) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		} else
			slowMos.set(id, {id: id, t: sec, f: speedFactor});
	}

	function updateSlowMos() {
		// Timeout active slow-mos
		for (s in slowMos) {
			s.t -= utmod / Const.FPS;
			if (s.t <= 0)
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for (s in slowMos)
			targetGameSpeed *= s.f;
		curGameSpeed += (targetGameSpeed - curGameSpeed) * (targetGameSpeed > curGameSpeed ? 0.2 : 0.6);

		if (M.fabs(curGameSpeed - targetGameSpeed) <= 0.001)
			curGameSpeed = targetGameSpeed;
	}

	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	override function preUpdate() {
		super.preUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.preUpdate();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	override function update() {
		super.update();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.update();

		if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
			// Exit to main menu
			if (ca.bPressed()) {
				if (!cd.hasSetS("exitWarn", 3))
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					return Main.ME.startMainMenu();
			}

			// Restart
			if (ca.selectPressed())
				return Main.ME.startGame(level.current.id, hero.data.id);

			#if debug
			// Bounds
			if (ca.isKeyboardPressed(Key.B))
				ui.Console.ME.setFlag("bounds", !ui.Console.ME.hasFlag("bounds"));

			if (ca.isKeyboardPressed(Key.N))
				scroller.filter = scroller.filter == null ? new h2d.filter.ColorMatrix() : null;

			// Level list
			if (ca.isKeyboardPressed(Key.SHIFT)) {
				ui.Console.ME.runCommand("cls");
				for (l in Data.levels.all) {
					ui.Console.ME.log(l.id.toString(), l == level.current ? 0x00ff00 : null);
				}
			}

			// Animal list
			if (ca.isKeyboardPressed(Key.CTRL)) {
				ui.Console.ME.runCommand("cls");
				for (a in Data.animal.all) {
					ui.Console.ME.log(a.id.toString(), a == hero.data ? 0x00ff00 : null);
				}
			}

			if (ca.isKeyboardDown(Key.SHIFT)) {
				if (ca.isKeyboardPressed(Key.PGUP)) {
					var newIdx = level.currentIdx == 0 ? Data.levels.all.length - 1 : level.currentIdx - 1;
					startLevel(Data.levels.all[newIdx].id, hero.data.id);
				}
				if (ca.isKeyboardPressed(Key.PGDOWN)) {
					var newIdx = level.currentIdx == Data.levels.all.length - 1 ? 0 : level.currentIdx + 1;
					startLevel(Data.levels.all[newIdx].id, hero.data.id);
				}
			} else if (ca.isKeyboardDown(Key.CTRL)) {
				if (ca.isKeyboardPressed(Key.PGUP)) {
					if (hero != null) {
						hero.destroy();
					}

					var animalIdx = 0;
					for (a in Data.animal.all) {
						if (a == hero.data) break;
						animalIdx++;
					}
					var newIdx = animalIdx == 0 ? Data.animal.all.length - 1 : animalIdx - 1;
					var animalKind = Data.animal.all[newIdx].id;
					hero = new en.Hero(animalKind, Assets.animals.get(animalKind));

					hud.reset();
					camera.trackTarget(hero, true);
				}
				if (ca.isKeyboardPressed(Key.PGDOWN)) {
					if (hero != null) {
						hero.destroy();
					}

					var animalIdx = 0;
					for (a in Data.animal.all) {
						if (a == hero.data) break;
						animalIdx++;
					}
					var newIdx = animalIdx == Data.animal.all.length - 1 ? 0 : animalIdx + 1;
					var animalKind = Data.animal.all[newIdx].id;
					hero = new en.Hero(animalKind, Assets.animals.get(animalKind));

					hud.reset();
					camera.trackTarget(hero, true);
				}
			} else {
				if (ca.isKeyboardPressed(Key.PGUP)) {
					Const.SCALE++;
					scroller.setScale(Const.SCALE);
				}
				if (ca.isKeyboardPressed(Key.PGDOWN)) {
					Const.SCALE--;
					scroller.setScale(Const.SCALE);
				}
			}
			#end
		}

		// update timer
		levelTimer -= tmod / Const.FPS;

		if (levelTimer <= 0) {
			hero.hit(hero.life, null);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		setTimeMultiplier((0.2 + 0.8 * curGameSpeed) * (ucd.has("stopFrame") ? 0.3 : 1));
		Assets.objects.tmod = tmod;
		for (spr in Assets.animals) {
			spr.tmod = tmod;
		}
	}
}
