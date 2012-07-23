package statm.dev.mapeditor.dom.item
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import spark.components.Image;
	import spark.primitives.BitmapImage;
	
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.objects.BornPoint;
	import statm.dev.mapeditor.dom.objects.Item;
	import statm.dev.mapeditor.dom.objects.LinkDestPoint;
	import statm.dev.mapeditor.dom.objects.LinkPoint;
	import statm.dev.mapeditor.dom.objects.TeleportPoint;
	import statm.dev.mapeditor.dom.objects.Waypoint;
	import statm.dev.mapeditor.ui.UIResource;

	/**
	 * 物件工厂类。
	 *
	 * @author renjie.zh
	 *
	 */
	public class ItemFactory
	{
		public static var domRoot : DomNode;

		public static function createItemFromXML(itemXML : XML) : Item
		{
			var item : Item;

			switch (itemXML.name().localName)
			{
				case "teleportPoint":
					item = new TeleportPoint(domRoot);
					item.iconImage.source = Map(domRoot).iconList.getIcon(0);
					break;

				case "linkPoint":
					item = new LinkPoint(domRoot);
					item.iconImage.source = Map(domRoot).iconList.getIcon(1);
					break;

				case "linkDestPoint":
					item = new LinkDestPoint(domRoot);
					item.iconImage.source = Map(domRoot).iconList.getIcon(2);
					break;

				case "bornPoint":
					item = new BornPoint(domRoot);
					item.iconImage.source = Map(domRoot).iconList.getIcon(3);
					break;
				
				case "waypoint":
					item = new Waypoint(domRoot);
					item.iconImage.source = Map(domRoot).iconList.getIcon(4);
					break;
			}

			item.readXML(itemXML);

			return item;
		}

		public static function createItemFromDefinition(itemDef : ItemDefinition) : Item
		{
			var item : Item;
			var iconBitmapData : BitmapData = Map(domRoot).iconList.getIcon(itemDef.iconID);

			switch (itemDef.type)
			{
				case ItemType.TELEPORT_POINT:
					item = new TeleportPoint(domRoot);
					break;

				case ItemType.LINK_POINT:
					item = new LinkPoint(domRoot);
					break;

				case ItemType.LINK_DEST_POINT:
					item = new LinkDestPoint(domRoot);
					break;

				case ItemType.BORN_POINT:
					item = new BornPoint(domRoot);
					break;

				case ItemType.WAYPOINT:
					item = new Waypoint(domRoot);
					break;
			}

			item.iconImage.source = iconBitmapData;

			return item;
		}
	}
}
