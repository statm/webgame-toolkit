package statm.dev.mapeditor.ui
{

	/**
	 * 所有 UI 资源。
	 *
	 * @author renjie.zh
	 *
	 */
	public final class UIResource
	{
		// 掩码图标
		[Embed(source = "../../../../assets/brushIcons/erase.png")]
		public static const ERASE_ICON : Class;

		[Embed(source = "../../../../assets/brushIcons/walk.png")]
		public static const WALK_ICON : Class;

		[Embed(source = "../../../../assets/brushIcons/walk_opaque.png")]
		public static const WALK_OPAQUE_ICON : Class;

		[Embed(source = "../../../../assets/brushIcons/pve.png")]
		public static const PVE_ICON : Class;

		[Embed(source = "../../../../assets/brushIcons/pve+pvp.png")]
		public static const PVE_AND_PVP_ICON : Class;

		[Embed(source = "../../../../assets/brushIcons/pvp.png")]
		public static const PVP_ICON : Class;

		// 特殊物件图标
		[Embed(source = "../../../../assets/transportIcons/B.png")]
		public static const BORN_POINT_ICON : Class;

		[Embed(source = "../../../../assets/transportIcons/D.png")]
		public static const LINK_DEST_POINT_ICON : Class;

		[Embed(source = "../../../../assets/transportIcons/L.png")]
		public static const LINK_POINT_ICON : Class;

		[Embed(source = "../../../../assets/transportIcons/T.png")]
		public static const TELEPORT_POINT_ICON : Class;

		[Embed(source = "../../../../assets/transportIcons/W.png")]
		public static const WAYPOINT_ICON : Class;
	}
}
