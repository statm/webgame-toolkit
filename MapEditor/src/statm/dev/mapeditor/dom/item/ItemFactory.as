package statm.dev.mapeditor.dom.item
{
    import flash.display.BitmapData;

    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.objects.BornPoint;
    import statm.dev.mapeditor.dom.objects.Decoration;
    import statm.dev.mapeditor.dom.objects.Fx;
    import statm.dev.mapeditor.dom.objects.Item;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;
    import statm.dev.mapeditor.dom.objects.Mark;
    import statm.dev.mapeditor.dom.objects.Mineral;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.NPC;
    import statm.dev.mapeditor.dom.objects.RoutePoint;
    import statm.dev.mapeditor.dom.objects.TeleportPoint;
    import statm.dev.mapeditor.dom.objects.Waypoint;

    /**
     * 物件工厂类。
     *
     * @author statm
     *
     */
    public class ItemFactory
    {
        public static var domRoot:DomNode;

        public static function createItemFromXML(itemXML:XML):Item
        {
            var item:Item;

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

                case "NPC":
                    item = new NPC(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(5);
                    break;

                case "mob":
                    item = new Mob(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(8);
                    break;

                case "mineral":
                    item = new Mineral(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(7);
                    break;

                case "mark":
                    item = new Mark(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(9);
                    break;

                case "routePoint":
                    item = new RoutePoint(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(10);
                    break;

                case "fx":
                    item = new Fx(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(10);
                    break;

                case "decoration":
                    item = new Decoration(domRoot);
                    item.iconImage.source = Map(domRoot).iconList.getIcon(8);
                    break;
            }

            item.readXML(itemXML);

            return item;
        }

        public static function createItemFromDefinition(itemDef:ItemDefinitionBase):Item
        {
            var item:Item;
            var iconBitmapData:BitmapData = Map(domRoot).iconList.getIcon(itemDef.iconID);

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

                case ItemType.NPC:
                    item = new NPC(domRoot, NPCItemDefinition(itemDef));
                    break;

                case ItemType.MOB:
                    item = new Mob(domRoot, MobItemDefinition(itemDef));
                    break;

                case ItemType.MINERAL:
                    item = new Mineral(domRoot, MineralItemDefinition(itemDef));
                    break;

                case ItemType.MARK:
                    item = new Mark(domRoot);
                    break;

                case ItemType.ROUTE_POINT:
                    item = new RoutePoint(domRoot);
                    break;

                case ItemType.FX:
                    item = new Fx(domRoot, FxItemDefinition(itemDef));
                    break;

                case ItemType.DECORATION:
                    item = new Decoration(domRoot, DecorationItemDefinition(itemDef));
                    break;
            }

            item.iconImage.source = iconBitmapData;

            return item;
        }
    }
}
