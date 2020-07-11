package en;

enum BreakableState {
	NORMAL;
	BROKEN;
}

class Breakable extends Entity {
	public var data(default, null) : Data.Object;

	public var state(default, set) = BreakableState.NORMAL;
	public function set_state(s : BreakableState) {
		if (state != s) {
			if (s == BreakableState.BROKEN) {
				collide = false;
				
				spr.groupName = data.id.toString() + "1";
			}
		}
		return state = s;
	}

	public function new(d : Data.Object, ?x, ?y, ?spriteLib) {
		super(x, y, spriteLib);

		data = d;

		spr.set(data.id.toString());
		wid = spr.tile.width;
		hei = spr.tile.height;
	}
}
