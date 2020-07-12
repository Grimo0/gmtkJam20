package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public var data(default, null) : Data.Animal;

	public var speed(default, null) : Float;
	public var moved(default, null) : Bool;

	public function new(kind : Data.AnimalKind, ?x, ?y, ?spriteLib) {
		super(x, y, spriteLib);

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller

		data = Data.animal.get(kind);

		spr.anim.registerStateAnim("idle", 0);
		spr.anim.registerStateAnim("move", 1, function() return dx != 0 || dy != 0);
		// spr.anim.setStateAnimSpeed("move", );

		reset();
	}

	public function reset() {
		maxLife = data.lifePoints;
		life = maxLife;
		wid = spr.tile.width;
		hei = spr.tile.height;
		radius = data.radius;
		bumpStrength = data.bumpStrength;
		speed = data.minSpeed;
		frict = data.decelerationSpeed;
		moved = false;
		
		for (t in level.current.triggers) {
			if (t.id == Start) {
				setPosCell(t.x, t.y);
				level.root.add(spr, Const.DP_MAIN);
				break;
			}
		}
	}

	override function dispose() { // called on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function onCollide(e : Entity) {
		if (e == null || e == this) return;

		var b = e.as(Breakable);
		if (b == null) return;

		if (b.data.pointsToPlayer != 0) {
			hud.pointsGain(b.footX, b.footY, b.data.pointsToPlayer);
			game.points += b.data.pointsToPlayer;
		}

		b.onCollide(this);
		b.hit(1, this);
	}

	override function update() { // the Entity main loop
		var moveLikeVehicule = true;
		var rotationSpeed = data.turnSpeed;
		var movementSpeed = data.maxSpeed;//(data.maxSpeed - data.minSpeed) * data.accelerationSpeed + data.minSpeed;
		var backSpeed = data.backSpeed;

		if (moveLikeVehicule) {
			// Vehicule movement : Up accelerates in the current angle, right and left change that angle
			if (ca.leftDown()) {
				angle -= rotationSpeed * Math.PI * tmod;
			}
			if (ca.rightDown()) {
				angle += rotationSpeed * Math.PI * tmod;
			}

			if (ca.upDown()) {
				// Calculate the progression on x and y based on the angle
				dx += Math.cos(angle) * movementSpeed * tmod;
				dy += Math.sin(angle) * movementSpeed * tmod;
			}
			if (ca.downDown()) {
				dx -= Math.cos(angle) * backSpeed * tmod;
				dy -= Math.sin(angle) * backSpeed * tmod;
			}
		} else {
			// Normal movement (haut bas gauche droite)
			if (ca.leftDown())
				dx -= movementSpeed * tmod;
			if (ca.rightDown())
				dx += movementSpeed * tmod;
			if (ca.upDown())
				dy -= movementSpeed * tmod;
			if (ca.downDown())
				dy += movementSpeed * tmod;
		}

		super.update();
	}
}
