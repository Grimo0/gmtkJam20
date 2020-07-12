import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s : h2d.Scene) {
		super();
		ME = this;

		createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff << 24 | 0x111133;
		#if (hl && !debug)
		engine.fullScreen = true;
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontTiny, s);
		Lang.init("en");

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(AXIS_LEFT_Y_POS, Key.UP, Key.Z, Key.W);
		controller.bind(AXIS_LEFT_Y_NEG, Key.DOWN, Key.S);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(B, Key.ESCAPE);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.ENTER, Key.N);

		// Focus helper (process that suspend the game when the focus is lost)
		// TODO: Implement our own Focus Helper
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);

		// Start
		delayer.addF(startGame, 1);
	}

	public function startGame() {
		if (Game.ME != null) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 1);
		} else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if (Const.AUTO_SCALE_TARGET_WID > 0)
			Const.SCALE = M.ceil(w() / Const.AUTO_SCALE_TARGET_WID);
		else if (Const.AUTO_SCALE_TARGET_HEI > 0)
			Const.SCALE = M.ceil(h() / Const.AUTO_SCALE_TARGET_HEI);

		if (Const.AUTO_SCALE_UI_TARGET_HEI > 0)
			Const.UI_SCALE = Math.max(1., h() / Const.AUTO_SCALE_UI_TARGET_HEI);
	}

	override function update() {
		Assets.ui.tmod = tmod;
		super.update();
	}
}
