package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new(?x, ?y, ?spriteLib) {
		super(x, y, spriteLib);

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
		
		spr.anim.registerStateAnim("idle", 0);
		spr.anim.registerStateAnim("move", 1, function() return dx != 0 || dy != 0);
		// spr.anim.setStateAnimSpeed("move", );
		wid = spr.tile.width;
		hei = spr.tile.height;
	}

	override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function update() { // the Entity main loop
		var moveLikeVehicule = true;
		var rotationSpeed = 0.02;
		var movementSpeed = 0.1;
		var backSpeed = 0.001;

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
