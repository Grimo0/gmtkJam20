package ui;

import dn.Process;

class ScoreMenu extends Process {
	public static var ME : ScoreMenu;

	public var ca : dn.heaps.Controller.ControllerAccess;

	var nextLevel : Data.LevelsKind;
	
	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controller.createAccess("scoreMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.DP_UI);
		// root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		/* var comboUiLayer = new h2d.Layers();
		comboUiLayer.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.addChild(comboUiLayer); */

		// -- Title
		var titleTxt = new h2d.Text(Assets.fontLarge);
		titleTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		titleTxt.x = 350;
		titleTxt.y = 40;
		if (Game.ME.levelTimer < 0)
			titleTxt.text = Lang.t._("Time out");
		else if (Game.ME.hero.isDead())
			titleTxt.text = Lang.t._("You fainted");
		else
			titleTxt.text = Lang.t._("Escape complete!");
		titleTxt.x -= titleTxt.textWidth / 2;
		root.addChild(titleTxt);
		
		var y = titleTxt.y + lineHeight * 2;
		var scoreTotal = 0;

		// -- Score
		addScoreLine();
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = textColumnX;
		txt.y = y;
		txt.text = Lang.t._("Score");
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = scoreColumnX;
		txt.y = y;
		txt.text = Std.string(Game.ME.points);
		scoreTotal += Game.ME.points;
		root.addChild(txt);

		y += lineHeight;

		// -- Max combo
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = textColumnX;
		txt.y = y;
		txt.text = Lang.t._("Combo max");
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = resultColumnX;
		txt.y = y;
		txt.text = "x" + Game.ME.highestCombo;
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = scoreColumnX;
		txt.y = y;
		txt.text = "+" + Game.ME.highestCombo * Const.COMBO_BONUS;
		scoreTotal += Game.ME.highestCombo * Const.COMBO_BONUS;
		root.addChild(txt);

		y += lineHeight;

		// -- Time left
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = textColumnX;
		txt.y = y;
		txt.text = Lang.t._("Time left");
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = resultColumnX;
		txt.y = y;
		txt.text = Std.int(Game.ME.levelTimer) + "s";
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = scoreColumnX;
		txt.y = y;
		txt.text = "+" + Std.int(Game.ME.levelTimer) * Const.TIMER_BONUS_PER_SEC;
		scoreTotal += Std.int(Game.ME.levelTimer) * Const.TIMER_BONUS_PER_SEC;
		root.addChild(txt);

		y += lineHeight;

		// -- Life left
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = textColumnX;
		txt.y = y;
		txt.text = Lang.t._("Life left");
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = resultColumnX;
		txt.y = y;
		txt.text = Std.string(Game.ME.hero.life);
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = scoreColumnX;
		txt.y = y;
		txt.text = "+" + Game.ME.hero.life * Const.LIFE_BONUS;
		scoreTotal += Game.ME.hero.life * Const.LIFE_BONUS;
		root.addChild(txt);

		y += lineHeight;

		// -- Escape bonus
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = textColumnX;
		txt.y = y;
		if (Game.ME.levelTimer < 0)
			txt.text = Lang.t._("Time out");
		else if (Game.ME.hero.isDead())
			txt.text = Lang.t._("Dead");
		else
			txt.text = Lang.t._("Escaped");
		root.addChild(txt);

		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = scoreColumnX;
		txt.y = y;
		if (Game.ME.levelTimer < 0) {
			txt.text = "x" + Const.TIMER_OUT_MUL;
			scoreTotal *= Const.TIMER_OUT_MUL;
		} else if (Game.ME.hero.isDead()) {
			txt.text = "x" + Const.DEATH_MUL;
			scoreTotal = Std.int(scoreTotal * Const.DEATH_MUL);
		} else {
			txt.text = "x" + Const.ESCAPE_MUL;
			scoreTotal *= Const.ESCAPE_MUL;
		}
		root.addChild(txt);

		y += lineHeight;


		// -- Total
		var txt = new h2d.Text(Assets.fontLarge);
		txt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		txt.x = 350;
		txt.y = y;
		txt.text = Std.string(scoreTotal);
		txt.x -= txt.textWidth / 2;
		txt.rotation = M.frand(M.PI / 3) - M.PI / 6;
		txt.setScale(2);
		txt.addShader(new SineDeformShader(0.5, 0.001, 10));
		root.addChild(txt);


		// -- Animal sprite
		var animalLogo = Assets.ui.h_get(Game.ME.hero.data.id.toString() + "_splash", root);
		animalLogo.x = - animalLogo.tile.width * 2;
		animalLogo.y = (y - animalLogo.tile.height) / 2;
		animalLogo.setScale(2);
		// animalLogo.addShader(new SineDeformShader(0.5, 0.001, 10));
		root.addChild(animalLogo);
		
		// -- Buttons
		
		var currentLevelFound = false;
		for (level in Data.levels.all) {
			if (level.isTest) continue;
			if (currentLevelFound) {
				nextLevel = level;
				break;
			}
		}
		
		// TODO Back to menu
		// TODO Retry or next round
		
		Game.ME.pause();
		Game.ME.root.filter = new h2d.filter.Blur(100, 0.5, 1, 0.1);

		Process.resizeAll();
	}

	function addScoreLine(?name : String, ?result : String, ?score : String, y : Int) {
		final textColumnX = 100;
		final resultColumnX = 350;
		final scoreColumnX = 450;
		final lineHeight = 60;
	}

	override function onResize() {
		super.onResize();
		
		root.x = w() / 2; // Center the whole menu
	}
	
	override function update() {
		super.update();

		if (ca.aPressed()) {
			if (false) {// TODO Back to menu selected
				return Main.ME.startMainMenu();
			} else {
				Game.ME.startLevel();
			}
		}
	}
}