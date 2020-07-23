package ui;

import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca : dn.heaps.Controller.ControllerAccess;

	var animalLayers : h2d.Layers;
	var animals : Array<Data.AnimalKind>;
	var currentAnimal(null, set) : Int = -1;
	function set_currentAnimal(v : Int) {
		if (currentAnimal >= 0) {
			var prevKind = animals[currentAnimal];
			var prevSpr = cast(animalLayers.getObjectByName(prevKind.toString()), HSprite);
			var sprIdx = animalLayers.getChildIndex(prevSpr);
			sprIdx = sprIdx + 1 < animals.length ? sprIdx + 1 : 0;
			var spr = cast(animalLayers.getChildAt(sprIdx), HSprite);
			prevSpr.setScale(spr.scaleX);
			prevSpr.color.load(spr.color);
		}

		if (v >= 0) {
			var kind = animals[v];
			var spr = cast(animalLayers.getObjectByName(kind.toString()), HSprite);
			spr.setScale(1);
			spr.color.set(1, 1, 1);
			animalLayers.over(spr);
		}

		return currentAnimal = v;
	}

	var levelLayers : h2d.Layers;
	var levels : Array<Data.LevelsKind>;
	var currentLevel(null, set) : Int = -1;
	function set_currentLevel(v : Int) {
		if (currentLevel >= 0) {
			var prevKind = levels[currentLevel];
			var prevSpr = cast(levelLayers.getObjectByName(prevKind.toString()), HSprite);
			var sprIdx = levelLayers.getChildIndex(prevSpr);
			sprIdx = sprIdx + 1 < levels.length ? sprIdx + 1 : 0;
			var spr = cast(levelLayers.getChildAt(sprIdx), HSprite);
			prevSpr.setScale(spr.scaleX);
			prevSpr.color.load(spr.color);
		}

		if (v >= 0) {
			var kind = levels[v];
			var spr = cast(levelLayers.getObjectByName(kind.toString()), HSprite);
			spr.setScale(2);
			spr.color.set(1, 1, 1);
			levelLayers.over(spr);
		}

		return currentLevel = v;
	}

	var logoLayers : h2d.Layers;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("mainMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		// -- Animals
		animalLayers = new h2d.Layers();
		root.add(animalLayers, Const.DP_UI);

		animals = new Array();
		var offsetX = 0;
		for (animal in Data.animal.all) {
			animals.push(animal.id);
			var animalSpr = Assets.ui.h_get(animal.id.toString() + "_splash", 0.5, 0.5, animalLayers);
			animalSpr.name = animal.id.toString();
			animalSpr.x = offsetX;
			offsetX += Std.int(animalSpr.tile.width * 0.65);
			animalSpr.y = 0;
			animalSpr.setScale(0.5);
			animalSpr.color.scale3(0.7);
		}

		// -- Levels
		levelLayers = new h2d.Layers();
		root.add(levelLayers, Const.DP_UI);

		levels = new Array();
		var offsetY = 0;
		for (level in Data.levels.all) {
			if (level.isTest) continue;
			levels.push(level.id);
			var levelIconName = Assets.ui.exists(level.id.toString()) ? level.id.toString() : "levelplaceholder";
			var levelSpr = Assets.ui.h_get(levelIconName, 0.5, 0.5, levelLayers);
			levelSpr.name = level.id.toString();
			levelSpr.x = 0;
			levelSpr.y = offsetY;
			offsetY += Std.int(levelSpr.tile.height * 2);
			levelSpr.setScale(1.5);
			levelSpr.color.scale3(0.7);
		}

		// -- Logo
		logoLayers = new h2d.Layers();
		root.add(logoLayers, Const.DP_UI);
		Assets.ui.h_get("logo", 0.5, 0.5, logoLayers);

		currentLevel = 0;

		Assets.musicIntro.play(true);

		Process.resizeAll();
	}

	override function onDispose() {
		super.onDispose();
		Assets.musicIntro.stop();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);

		var animalLayersBounds = animalLayers.getSize();
		animalLayers.x = 0.75 * w() - animalLayersBounds.width * 0.5;
		animalLayers.y = 0.6 * h() - animalLayersBounds.height * 0.5;

		var levelLayersBounds = levelLayers.getSize();
		levelLayers.x = 0.25 * w() - levelLayersBounds.width * 0.5;
		levelLayers.y = 0.6 * h() - levelLayersBounds.height * 0.5;

		var logoLayersBounds = logoLayers.getSize();
		logoLayers.x = 0.5 * w();
		logoLayers.y = 0.25 * h() - logoLayersBounds.height * 0.5;
	}

	override function update() {
		super.update();

		// Exit
		if (ca.bPressed()) {
			if (currentAnimal >= 0) {
				currentAnimal = -1;
				currentLevel = currentLevel;
			}
			#if hl
			else if (!cd.hasSetS("exitWarn", 3))
				trace(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
			#end

			hxd.Res.sfx.back.play();
			return;
		}

		// Validate
		if (ca.startPressed()) {
			var level = levels[currentLevel];
			if (currentAnimal < 0) {
				var levelSpr = cast(levelLayers.getObjectByName(level.toString()), HSprite);
				levelSpr.color.scale3(0.7);

				currentAnimal = 0;
			} else {
				var animal = animals[currentAnimal];
				Main.ME.startGame(level, animal);
			}

			hxd.Res.sfx.validate.play();
			return;
		}

		if (currentAnimal < 0) {
			// Change level
			if (ca.downPressed()) {
				var newIdx = currentLevel == levels.length - 1 ? 0 : currentLevel + 1;
				currentLevel = newIdx;
				hxd.Res.sfx.select.play(0.3);
			}
			if (ca.upPressed()) {
				var newIdx = currentLevel == 0 ? levels.length - 1 : currentLevel - 1;
				currentLevel = newIdx;
				hxd.Res.sfx.select.play(0.3);
			}
		} else {
			// Change animal
			if (ca.rightPressed()) {
				var newIdx = currentAnimal == animals.length - 1 ? 0 : currentAnimal + 1;
				currentAnimal = newIdx;
				hxd.Res.sfx.select.play(0.3);
			}
			if (ca.leftPressed()) {
				var newIdx = currentAnimal == 0 ? animals.length - 1 : currentAnimal - 1;
				currentAnimal = newIdx;
				hxd.Res.sfx.select.play(0.3);
			}
		}
	}
}
