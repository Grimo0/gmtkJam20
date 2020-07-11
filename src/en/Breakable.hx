package en;

enum BreakableState {
	NORMAL;
	BROKEN;
}

class Breakable extends Entity {
	public var state(default, set) = BreakableState.NORMAL;
	public function set_state(s : BreakableState) {
		if (state != s) {
			if (s == BreakableState.BROKEN) {
				collide = false;
				var g = new h2d.Graphics(spr);
				g.beginFill(0x0000ff);
				g.drawRect(0, 0, wid, hei);
			}
		}
		return state = s;
	}

	public function new(?x, ?y) {
		super(x, y);

		var g = new h2d.Graphics(spr);
		g.beginFill(0x00ff00);
		g.drawRect(0, 0, wid, hei);
	}
}
