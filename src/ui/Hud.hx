package ui;

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

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
	}

	public function pointsGain(x=0, y=0, pts=1000) {
		var tf = new h2d.Text(hxd.res.DefaultFont.get());
		tf.scale(3);
		tf.dropShadow = { dx : 0.5, dy : 0.5, color : 0xFF0000, alpha : 0.8 };
		tf.text = "+" + pts + " points";
		tf.textAlign = Center;
		tf.x = x;
		tf.y = y;
		tf.addShader(new SineDeformShader(0.1,0.002,3));
		Game.ME.scroller.add(tf, Const.DP_UI);
		// destroy message after few seconds
		trace("ok");
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
}
