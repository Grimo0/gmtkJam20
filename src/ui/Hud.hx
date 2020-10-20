package ui;

import hxd.fmt.grd.Data.Gradient;
import h2d.filter.ColorMatrix;

class Hud extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;

	var colors : Array<Int>;

	var timerTxt : h2d.Text;
	var scoreTxt : h2d.Text;
	var comboTxt : h2d.Text;
	var lifePointsUi : h2d.Layers;
	var updateHp : Int;

	var popupTime : Float;
	var comboUiLayer : h2d.Layers;

	public function new() {
		super(game);

		createRootInLayers(game.root, Const.DP_HUD);

		colors = [
			0xff4017, 0x4fff17, 0x17fffb, 0x1753ff, 0xa717ff, 0xFFFFFF, 0xfbff17, 0xff17f8, 0xffb917, 0xFFFFFF, 0xFFFFFF
		];

		// Score
		scoreTxt = new h2d.Text(Assets.fontLarge);
		scoreTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		scoreTxt.x = 150;
		scoreTxt.y = 40;
		scoreTxt.rotation = -0.1;
		scoreTxt.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.addChild(scoreTxt);

		// HealthPoints
		lifePointsUi = new h2d.Layers();
		lifePointsUi.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.addChild(lifePointsUi);
		updateHp = 0;

		// Timer
		timerTxt = new h2d.Text(Assets.fontLarge);
		timerTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		timerTxt.x = 155;
		timerTxt.y = 125;
		timerTxt.rotation = 0.12;
		timerTxt.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.addChild(timerTxt);

		// combo
		comboTxt = new h2d.Text(Assets.fontPixel);
		comboTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		comboTxt.x = 40;
		comboTxt.y = 200;
		comboTxt.rotation = -0.1;
		comboTxt.addShader(new SineDeformShader(0.05, 0.002, 3));
		root.addChild(comboTxt);

		// score popups ui
		popupTime = 0;
		comboUiLayer = new h2d.Layers();
		comboUiLayer.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		game.scroller.add(comboUiLayer, Const.DP_UI);
	}

	public function reset() {
		if (game.hero == null) return;

		comboUiLayer.removeChildren();
		popupTime = 0;

		updateHearts();
		updateHp = game.hero.life;

		// Animal logo
		var animalLogo = Assets.ui.h_get(game.hero.data.id.toString(), root);
		animalLogo.x = 40;
		animalLogo.y = 65;
		animalLogo.scale(2);
		animalLogo.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
	}

	public inline function updateHearts() {
		lifePointsUi.removeChildren();
		for (i in 0...game.hero.life) {
			var lifePointUi = Assets.ui.h_get("life", lifePointsUi);
			lifePointUi.x = 160 + 35 * i;
			lifePointUi.y = 95;
		}
		updateHp = game.hero.life;
	}

	public function pointsGain(x, y, pts) {
		// Display a popup with the points won, after collision.
		// The message is destroyed after few seconds.
		popupTime = 10. * Const.FPS;

		var scoreTf = new h2d.Text(Assets.fontPixel);
		scoreTf.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0xFF0000,
			alpha: 0.8
		};
		if (pts > 0) {
			scoreTf.text = "+" + pts;
		}
		else if (pts < 0) {
			scoreTf.text = Std.string(pts);
		}
		scoreTf.textAlign = Center;
		var colorId = Std.int(Math.random() * colors.length);
		scoreTf.textColor = colors[colorId];
		scoreTf.x = x;
		scoreTf.y = y;
		scoreTf.rotation = Math.random() - 0.5;
		scoreTf.addShader(new SineDeformShader(0.05, 0.001, 10));

		var cpt = 1.2 + M.fmin(comboUiLayer.numChildren, 8) * 0.25;
		for (l in comboUiLayer) {
			l.alpha -= 0.2;
			if (l.alpha <= 0) {
				l.remove();
				break;
			}
		}
		scoreTf.setScale(cpt);
		comboUiLayer.addChild(scoreTf);

		comboTxt.setScale(M.fclamp(cpt, 3, 6));

		game.combo++;
		if (game.combo > game.highestCombo)
			game.highestCombo = game.combo;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		comboTxt.y = (game.h() - comboTxt.textHeight) / 2;
	}

	override function update() {
		super.update();

		// timer hud
		var levelTimerDisplay = Std.int(game.levelTimer);
		timerTxt.text = levelTimerDisplay + "s";

		// total score hud
		scoreTxt.text = "Score : " + game.points + " points";

		// health points hud
		if (updateHp != game.hero.life) {
			updateHearts();
		}

		// score popups
		if (popupTime > 0) {
			popupTime -= tmod;

			if (popupTime <= 0) {
				comboUiLayer.removeChildren();
				popupTime = 0;
			}

			// combo points hud
			var numberCombo = comboUiLayer.numChildren;
			if (numberCombo > 0) {
				comboTxt.text = "Combo x" + numberCombo;
			}
		}
		else if (comboTxt.text != "") {
			comboTxt.text = "";
		}
	}
}
