package ui;


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