package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new(x, y) {
		super(x, y);

		// Some default rendering for our character
		var g = new h2d.Graphics(spr);
		g.beginFill(0xff0000);
		g.drawRect(0, 0, 16, 4);

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
	}

	override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function update() { // the Entity main loop
		super.update();

		var moveLikeVehicule = true;
		var rotationSpeed = 0.02;
		var movementSpeed = 0.01;

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
				dx -= Math.cos(angle) * movementSpeed * tmod;
				dy -= Math.sin(angle) * movementSpeed * tmod;
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
	}
}
