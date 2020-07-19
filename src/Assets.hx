import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;

	public static var ui : SpriteLib;
	public static var objects : SpriteLib;
	public static var animals : Map<Data.AnimalKind, SpriteLib>;

	public static var musicIntro : dn.heaps.Sfx;
	public static var musicLevel : dn.heaps.Sfx;

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

		for (s in hxd.Res.load("sfx"))
			s.toSound().getData();

		dn.heaps.Sfx.muteGroup(0); // HACK
		dn.heaps.Sfx.setGroupVolume(0, 0.6);

		musicIntro = new dn.heaps.Sfx(hxd.Res.music.MenuIntro);
		musicIntro.groupId = 1;
		musicLevel = new dn.heaps.Sfx(hxd.Res.music.Level);
		musicLevel.groupId = 1;

		// -- Database
		Data.load(hxd.Res.data.entry.getText());

		// -- Fonts
		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();

		// -- Atlases
		ui = dn.heaps.assets.Atlas.load("atlas/ui.atlas");

		objects = dn.heaps.assets.Atlas.load("atlas/spritesheet.atlas");

		animals = new Map();

		var penguin = dn.heaps.assets.Atlas.load("atlas/penguin.atlas");
		animals.set(Data.AnimalKind.penguin, penguin);
		penguin.defineAnim("idle", "0");
		penguin.defineAnim("move", "0-3");
		penguin.defineAnim("dead", "0-2");

		var plant = dn.heaps.assets.Atlas.load("atlas/plant.atlas");
		animals.set(Data.AnimalKind.plant, plant);
		plant.defineAnim("idle", "0-2");
		plant.defineAnim("move", "0-3");
		plant.defineAnim("dead", "0-2");

		var penguin2 = dn.heaps.assets.Atlas.load("atlas/penguin2.atlas");
		animals.set(Data.AnimalKind.penguin2, penguin2);
		penguin2.defineAnim("idle", "0");
		penguin2.defineAnim("move", "0-3");
		penguin2.defineAnim("dead", "0-2");

		var plant2 = dn.heaps.assets.Atlas.load("atlas/plant2.atlas");
		animals.set(Data.AnimalKind.plant2, plant2);
		plant2.defineAnim("idle", "0-2");
		plant2.defineAnim("move", "0-3");
		plant2.defineAnim("dead", "0-2");
	}
}
