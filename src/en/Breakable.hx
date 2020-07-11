package en;

class Breakable extends Entity {
	public var data(default, null) : Data.Object;

	public function new(d : Data.Object, ?x, ?y, ?spriteLib) {
		super(x, y, spriteLib);

		data = d;

		spr.set(data.id.toString());
		wid = spr.tile.width;
		hei = spr.tile.height;

		maxLife = data.objectHealth;
		life = data.objectHealth;
		pointsToPlayer = data.pointsToPlayer;
	}

	override public function onDamage(dmg : Int, from : Null<Entity>) {
		if (life <= 0) {
			spr.set(data.id.toString(), 1);
			level.setColl(cx, cy, false);
		}
	}

	override function onCollide(e : Entity) {
		if (e == null || e == this) return;

		if (data.damageToPlayer > 0)
			e.hit(data.damageToPlayer, this);
	}
}
