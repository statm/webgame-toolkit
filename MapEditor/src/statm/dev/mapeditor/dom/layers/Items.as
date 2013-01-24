package statm.dev.mapeditor.dom.layers
{
    import mx.collections.ArrayCollection;
    
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;
    import statm.dev.mapeditor.dom.objects.BornPoint;
    import statm.dev.mapeditor.dom.objects.Item;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;
    import statm.dev.mapeditor.dom.objects.Mark;
    import statm.dev.mapeditor.dom.objects.Mineral;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.NPC;
    import statm.dev.mapeditor.dom.objects.TeleportPoint;
    import statm.dev.mapeditor.dom.objects.Waypoint;


    /**
     * DOM 对象：物件层（文件夹）。
     *
     * @author statm
     *
     */
    public class Items extends DomNode
    {
        public function Items(root:DomNode)
        {
            super(root);

            _name = "物件";
            _parent = root;
            _children = new ArrayCollection([ _npcLayer = new NPCLayer(root), _mobLayerContainer = new MobLayerContainer(root), _transportPoints = new TransportPoints(root), _waypoints = new WaypointLayer(root), _mineralLayer = new MineralLayer(root), _markLayer = new MarkLayer(root)]);
            _npcLayer.parent = _mobLayerContainer.parent = _transportPoints.parent = _waypoints.parent = _mineralLayer.parent = _markLayer.parent = this;
        }

        private var _npcLayer:NPCLayer;

        public function get npcLayer():NPCLayer
        {
            return _npcLayer;
        }

        private var _mobLayerContainer:MobLayerContainer;

        public function get mobLayerContainer():MobLayerContainer
        {
            return _mobLayerContainer;
        }

        private var _transportPoints:TransportPoints;

        public function get transportPoints():TransportPoints
        {
            return _transportPoints;
        }

        private var _waypoints:WaypointLayer;

        public function get waypoints():WaypointLayer
        {
            return _waypoints;
        }

        private var _mineralLayer:MineralLayer;

        public function get mineralLayer():MineralLayer
        {
            return _mineralLayer;
        }

        private var _markLayer:MarkLayer;

        public function get markLayer():MarkLayer
        {
            return _markLayer;
        }

        public function addItem(item:Item):void
        {
            var selection:DomNode = AppState.getCurrentSelection();
            if ((item is TeleportPoint) || (item is LinkPoint) || (item is BornPoint))
            {
                transportPoints.addItem(item);
            }
            else if (item is LinkDestPoint)
            {
                if (selection && (selection is LinkPoint))
                {
                    LinkPoint(selection).addLinkDestination(LinkDestPoint(item));
                }
                else
                {
                    throw new Error("添加连接目标点时出错：未选定正确的目标");
                }
            }
            else if (item is Waypoint)
            {
                waypoints.addWaypoint(Waypoint(item));
            }
            else if (item is NPC)
            {
                npcLayer.addItem(item);
            }
            else if (item is Mob)
            {
                if (selection is MobLayer)
                {
                    MobLayer(selection).addItem(item);
                }
            }
            else if (item is Mineral)
            {
                mineralLayer.addItem(item);
            }
            else if (item is Mark)
            {
                markLayer.addItem(item);
            }
        }

        override public function deselect():void
        {
            AppState.stopDrawingItem();
        }

        override public function toXML():XML
        {
            var results:XML = <items/>;

            results.appendChild(npcLayer.toXML()).appendChild(mobLayerContainer.toXML()).appendChild(transportPoints.toXML()).appendChild(waypoints.toXML()).appendChild(mineralLayer.toXML()).appendChild(markLayer.toXML());

            return results;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            xml.transportLayer[0] && this.transportPoints.readXML(xml.transportLayer[0]);
            xml.waypointLayer[0] && this.waypoints.readXML(xml.waypointLayer[0]);
            xml.NPCLayer[0] && this.npcLayer.readXML(xml.NPCLayer[0]);
            xml.mobLayers[0] && this.mobLayerContainer.readXML(xml.mobLayers[0]);
            xml.mineralLayer[0] && this.mineralLayer.readXML(xml.mineralLayer[0]);
            xml.markLayer[0] && this.markLayer.readXML(xml.markLayer[0]);
        }
    }
}
