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
	var playerHealthTxt : h2d.Text;

	var popupTime : Float;
	var comboUiLayer : h2d.Layers;

	public function new() {
		super(Game.ME);

		createRootInLayers(Main.ME.root, Const.DP_UI);
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
		scoreTxt.x = 40;
		scoreTxt.y = 40;
		scoreTxt.rotation = -0.1;
		// scoreTxt.addShader(new SineDeformShader(0.1, 0.002, 3));
		root.add(scoreTxt, Const.DP_UI);

		// Timer
		timerTxt = new h2d.Text(Assets.fontLarge);
		timerTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		timerTxt.x = 40;
		timerTxt.y = scoreTxt.y + scoreTxt.textHeight * 0.8;
		timerTxt.rotation = 0.05;
		// timerTxt.addShader(new SineDeformShader(0.1, 0.002, 3));
		root.add(timerTxt, Const.DP_UI);

		// Combo ui
		popupTime = 0;
		comboUiLayer = new h2d.Layers();
		game.scroller.add(comboUiLayer, Const.DP_UI);

		// HealthPoints
		playerHealthTxt = new h2d.Text(Assets.fontLarge);
		playerHealthTxt.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0xFF0000,
			alpha: 0.8
		};
		playerHealthTxt.x = 40;
		playerHealthTxt.y = timerTxt.y + timerTxt.textHeight * 0.8;
		playerHealthTxt.rotation = 0.2;
		// playerHealthTxt.addShader(new SineDeformShader(0.1, 0.002, 3));
		root.add(playerHealthTxt, Const.DP_UI);
	}

	public function pointsGain(x = 70.0, y = 50.0, pts = 1000) {
		// Display a popup with the points won, after collision.
		// The message is after few seconds.
		popupTime = 50.;

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
		var levelTimerDisplay = Std.int(game.levelTimer * 10) / 10;
		timerTxt.text = levelTimerDisplay + "s";

		// total score hud
		scoreTxt.text = "Score : " + game.points + " points";
		
		// health points hud
		playerHealthTxt.text = "Health : " + game.healthPoints + " lives";

		// score popups
		if (popupTime > 0) {
			popupTime -= tmod;

			if (popupTime <= 0) {
				comboUiLayer.removeChildren();
				popupTime = 0;
			}
		}
	}
}
