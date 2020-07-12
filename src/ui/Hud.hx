package ui;

import hxd.fmt.grd.Data.Gradient;
import h2d.filter.ColorMatrix;

class SineDeformShader extends hxsl.Shader {
	static var SRC = {
		// @:import h3d.shader.Base2d;
		@global var time : Float;
		@param var speed : Float;
		@param var frequency : Float;
		@param var amplitude : Float;
		var calculatedUV : Vec2;
		var absolutePosition : Vec4;
		var pixelColor : Vec4;
		var textureColor : Vec4;
		function fragment() {
			calculatedUV.x += sin(absolutePosition.y * frequency + time * speed + absolutePosition.x * 0.1) * amplitude;
			// pixelColor = texture.get(calculatedUV);
		}
	};

	public function new(frequency = 10., amplitude = 0.01, speed = 1.) {
		super();
		this.frequency = frequency;
		this.amplitude = amplitude;
		this.speed = speed;
	}

	// calculatedUV.y += sin(calculatedUV.y * frequency + time * speed) * amplitude; // wave deform
	// pixelColor = texture.get(calculatedUV);
}

class Hud extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return Game.ME.fx;
	public var level(get, never) : Level;
	inline function get_level() return Game.ME.level;

	var invalidated = true;
	var colors : Array<Int>;

	var timerTxt : h2d.Text;
	var scoreTxt : h2d.Text;
	var comboTxt : h2d.Text;
	var lifePointsUi : h2d.Layers;
	var updateHp : Int;
	var animalLogo : HSprite;

	var popupTime : Float;
	var comboUiLayer : h2d.Layers;

	public function new() {
		super(Game.ME);

		createRootInLayers(Game.ME.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

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
		root.add(scoreTxt, Const.DP_UI);

		// combo
		comboTxt = new h2d.Text(Assets.fontLarge);
		comboTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		comboTxt.x = 150;
		comboTxt.y = 190;
		comboTxt.rotation = -0.1;
		root.add(comboTxt, Const.DP_UI);

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
		root.add(timerTxt, Const.DP_UI);

		// Combo ui
		popupTime = 0;
		comboUiLayer = new h2d.Layers();
		comboUiLayer.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		game.scroller.add(comboUiLayer, Const.DP_UI);

		// HealthPoints
		lifePointsUi = new h2d.Layers();
		root.add(lifePointsUi, Const.DP_UI);
		updateHp = 0;

		animalLogo = null;
	}

	public function reset() {
		if (game.hero == null) return;

		comboUiLayer.removeChildren();
		popupTime = 0;

		updateHearts();
		updateHp = game.hero.life;

		// Animal logo
		animalLogo = Assets.ui.h_get(game.hero.data.id.toString(), 0, 0, root);
		animalLogo.x = 40;
		animalLogo.y = 65;
		animalLogo.scale(2);
	}

	public inline function updateHearts() {
		lifePointsUi.removeChildren();
		for (i in 0...game.hero.life) {
			var lifePointUi = Assets.ui.h_get("life", 0, 0, lifePointsUi);
			lifePointUi.x = 160 + 35 * i;
			lifePointUi.y = 95;
		}
		updateHp = game.hero.life;
	}

	public function pointsGain(x = 70.0, y = 50.0, pts = 1000) {
		// Display a popup with the points won, after collision.
		// The message is after few seconds.
		popupTime = 100.;

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
		scoreTf.addShader(new SineDeformShader(0.05, 0.002, 3));

		var cpt = 1.2;
		for (l in comboUiLayer) {
			l.alpha -= 0.2;
			cpt += 0.25;
		}
		scoreTf.scale(cpt);
		comboUiLayer.add(scoreTf, Const.DP_UI);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate()
		invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		if (invalidated) {
			invalidated = false;
			render();
		}
	}

	override function update() {
		super.update();

		// timer hud
		var levelTimerDisplay = Std.int(game.levelTimer * 100) / 100;
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
			var numberCombo = 0;
			for (a in comboUiLayer) {
				numberCombo += 1;
			}
			if (numberCombo > 0) {
				comboTxt.text = "Combo : " + numberCombo;
			}
		}
		else if (comboTxt.text != "") {
			comboTxt.text = "";
		}
	}
}
