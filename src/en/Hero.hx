package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public var data(default, null) : Data.Animal;

	public function new(kind : Data.AnimalKind, ?x, ?y, ?spriteLib) {
		super(x, y, spriteLib);

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller

		data = Data.animal.get(kind);

		spr.anim.registerStateAnim("idle", 0);
		spr.anim.registerStateAnim("move", 1, function() return dx != 0 || dy != 0);
		// spr.anim.setStateAnimSpeed("move", );

		maxLife = data.lifePoints;
		wid = spr.tile.width;
		hei = spr.tile.height;
		radius = data.radius;
		bumpStrength = data.bumpStrength;
	}

	override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function onCollide(e : Entity) {
		if (e == null || e == this) return;

		var b = e.as(Breakable);
		if (b == null) return;

		hud.pointsGain(b.footX, b.footY, b.pointsToPlayer);
		game.points += b.pointsToPlayer;

		b.onCollide(this);
		b.hit(1, this);
	}

	override function update() { // the Entity main loop
		var moveLikeVehicule = true;
		var rotationSpeed = data.turnSpeed;
		var movementSpeed = data.maxSpeed;
		var backSpeed = data.backSpeed;

		if (moveLikeVehicule) {
			// Vehicule movement : Up accelerates in the current angle, right and left change that angle
			if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT)) {
				angle -= rotationSpeed * Math.PI * tmod;
			}
			if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT)) {
				angle += rotationSpeed * Math.PI * tmod;
			}

			if (ca.upDown() || ca.isKeyboardDown(hxd.Key.UP)) {
				// Calculate the progression on x and y based on the angle
				dx += Math.cos(angle) * movementSpeed * tmod;
				dy += Math.sin(angle) * movementSpeed * tmod;
			}
			if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN)) {
				dx -= Math.cos(angle) * backSpeed * tmod;
				dy -= Math.sin(angle) * backSpeed * tmod;
			}
		} else {
			// Normal movement (haut bas gauche droite)
			if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT))
				dx -= movementSpeed * tmod;
			if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT))
				dx += movementSpeed * tmod;
			if (ca.upDown() || ca.isKeyboardDown(hxd.Key.UP))
				dy -= movementSpeed * tmod;
			if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN))
				dy += movementSpeed * tmod;
		}

		super.update();
	}
}
