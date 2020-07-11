package ui;

import hxd.fmt.grd.Data.Gradient;
import h2d.filter.ColorMatrix;

class SineDeformShader extends hxsl.Shader {

	static var SRC = {
		//@:import h3d.shader.Base2d;

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
			//pixelColor = texture.get(calculatedUV);
		}

	};

	public function new( frequency = 10., amplitude = 0.01, speed = 1. ) {
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

	inline function get_game()
		return Game.ME;

	public var fx(get, never) : Fx;

	inline function get_fx()
		return Game.ME.fx;

	public var level(get, never) : Level;

	inline function get_level()
		return Game.ME.level;

	var flow : h2d.Flow;
	var invalidated = true;
	
	public var levelTimer : Float;
	public var levelTimerDisplay : Float;

	var levelTimerHud = new h2d.Text(hxd.res.DefaultFont.get());
	
	var dureePopup : Float;
	var scoreTf : h2d.Text;
	var comboUiLayer : h2d.Layers;
	var idCouleur : Int;
	var couleurs : Array<Int>;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);

		comboUiLayer = new h2d.Layers();
		root.add(comboUiLayer, Const.DP_UI);

		levelTimer = 0.0;
		levelTimerHud.scale(3);
		levelTimerHud.dropShadow = { dx : 0.5, dy : 0.5, color : 0xFF0000, alpha : 0.8 };
		levelTimerHud.x = 0;
		levelTimerHud.y = -50;
		Game.ME.scroller.add(levelTimerHud, Const.DP_UI);

		dureePopup = -1;

		couleurs = [0xff4017, 0x4fff17, 0x17fffb, 0x1753ff, 0xa717ff, 0xFFFFFF, 0xfbff17, 0xff17f8, 0xffb917, 0xFFFFFF, 0xFFFFFF];
	}

	public function pointsGain(x=0, y=0, pts=1000) {
		dureePopup = 0.0;

		scoreTf = new h2d.Text(hxd.res.DefaultFont.get());
		scoreTf.scale(3);
		scoreTf.dropShadow = { dx : 0.5, dy : 0.5, color : 0xFF0000, alpha : 0.8 };
		scoreTf.text = "+" + pts + " points";
		scoreTf.textAlign = Center;
		idCouleur = Math.round(Math.random() * 10);
		scoreTf.textColor = couleurs[idCouleur];
		scoreTf.x = x;
		scoreTf.y = y;
		scoreTf.rotation = Math.random()-0.5;
		scoreTf.addShader(new SineDeformShader(0.1,0.002,3));
		for (l in comboUiLayer) {
			l.alpha -= 0.2;
			//l.filter = new ColorMatrix(Gradient);
		}
		comboUiLayer.add(scoreTf, Const.DP_UI);
		// destroy message after few seconds
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

		// timer
		levelTimer += utmod;
		levelTimerDisplay = Math.ceil(levelTimer)/100;

		levelTimerHud.text = levelTimerDisplay + "s";


		// score popups
		if (dureePopup >= 0) {
			dureePopup += tmod;
		}
		if (dureePopup > 70) {
			comboUiLayer.removeChildren();

			dureePopup = -1;
		}
	}
}
