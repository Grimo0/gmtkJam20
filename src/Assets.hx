import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;

	public static var tiles : SpriteLib;
	public static var objects : SpriteLib;
	public static var penguin : SpriteLib;

	static var initDone = false;

	public static function init() {
		if (initDone)
			return;

		initDone = true;

		// -- Resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

		// Hot reloading
		#if debug
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.data.watch(function() {
			Main.ME.delayer.cancelById("cdb");

			Main.ME.delayer.addS("cdb", function() {
				Data.load(hxd.Res.data.entry.getBytes().toString());
				if (Game.ME != null)
					Game.ME.onCdbReload();
			}, 0.2);
		});
		#end

		// -- Database
		Data.load(hxd.Res.data.entry.getText());

		// -- Fonts
		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();

		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
		
		objects = dn.heaps.assets.Atlas.load("atlas/spritesheet.atlas");

		penguin = dn.heaps.assets.Atlas.load("atlas/penguin.atlas");
		penguin.defineAnim("idle", "0");
		penguin.defineAnim("move", "0-3(10)");
	}
}
