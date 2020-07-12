package ui;

import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca : dn.heaps.Controller.ControllerAccess;

	var animalLayer : h2d.Layers;
	var levelLayer : h2d.Layers;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("mainMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		// -- Animals
		animalLayer = new h2d.Layers();
		animalLayer.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.add(animalLayer, Const.DP_UI);

		for (animal in Data.animal.all) {
			var lifePointUi = Assets.ui.h_get(animal.id.toString() + "_splash", 0, 0, animalLayer);
			lifePointUi.x = 160 + 35 * i;
			lifePointUi.y = 95;
			lifePointUi.scale(1);
		}

		// -- Levels
		levelLayer = new h2d.Layers();
		levelLayer.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering
		root.add(levelLayer, Const.DP_UI);


		Assets.musicIntro.play(true);

		Process.resizeAll();
		trace("is ready.");
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	override function update() {
		super.update();

		#if hl
		// Exit
		if (ca.bPressed()) {
			if (!cd.hasSetS("exitWarn", 3))
				trace(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
		}
		#end
	}
}
