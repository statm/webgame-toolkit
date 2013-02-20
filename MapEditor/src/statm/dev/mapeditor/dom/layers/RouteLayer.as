package statm.dev.mapeditor.dom.layers
{
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    public class RouteLayer extends PlacementLayerBase
    {
        public function RouteLayer(root:DomNode)
        {
            super(root);

            _name = "路线";
        }

        private var _layerName:String;

        public function get layerName():String
        {
            return _layerName;
        }

        public function set layerName(value:String):void
        {
			if (value != _layerName)
			{
				_layerName = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
        }

        override public function toXML():XML
        {
            var result:XML = super.toXML();
            result.name = _layerName;

            result.setName("routeLayer");

            return result;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            for each (var routePointXML:XML in xml.children())
            {
                this.addItem(ItemFactory.createItemFromXML(routePointXML));
            }
			this.layerName = xml.@name;
        }
    }
}
