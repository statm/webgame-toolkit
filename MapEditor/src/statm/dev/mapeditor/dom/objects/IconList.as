package statm.dev.mapeditor.dom.objects
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import statm.dev.mapeditor.io.IXMLSerializable;
	import statm.dev.mapeditor.ui.UIResource;
	import statm.dev.mapeditor.utils.BitmapCODECUtils;


	/**
	 * 物件图标列表。
	 *
	 * @author statm
	 *
	 */
	public class IconList implements IXMLSerializable
	{
		public static const ICON_WIDTH : int = 50;

		public static const ICON_HEIGHT : int = 50;

		private var _list : Dictionary = new Dictionary();

		public function IconList() : void
		{
			addBuiltinIcons();
		}

		private function addBuiltinIcons() : void
		{
			addIcon(0, new UIResource.TELEPORT_POINT_ICON().bitmapData);
			addIcon(1, new UIResource.LINK_POINT_ICON().bitmapData);
			addIcon(2, new UIResource.LINK_DEST_POINT_ICON().bitmapData);
			addIcon(3, new UIResource.BORN_POINT_ICON().bitmapData);
			addIcon(4, new UIResource.WAYPOINT_ICON().bitmapData);
		}

		private function addIcon(id : int, icon : BitmapData) : void
		{
			_list[id] = icon;
		}

		public function getIcon(id : int) : BitmapData
		{
			return _list[id];
		}

		public function toXML() : XML
		{
			var result : XML = <iconList/>;

			for (var id : String in _list)
			{
				if (parseInt(id) < 5)
				{
					continue;
				}

				var iconXML : XML = <icon id={id}/>;
				iconXML.bitmap = XML("<bitmap><![CDATA[" + BitmapCODECUtils.encode(_list[id]) + "]]></bitmap>");
				result.appendChild(iconXML);
			}

			return result;
		}

		public function readXML(xml : XML) : void
		{
			_list = new Dictionary();

			addBuiltinIcons();

			for each (var iconXML : XML in xml.icon)
			{
				_list[iconXML.id] = BitmapCODECUtils.decode(iconXML.bitmap.toString(), ICON_WIDTH, ICON_HEIGHT);
			}
		}
	}
}
