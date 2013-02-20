package statm.dev.mapeditor.dom.layers
{
    import mx.collections.ArrayCollection;

    import spark.components.Group;

    import statm.dev.mapeditor.dom.DomNode;

    public class RouteLayerContainer extends DomNode
    {
        public function RouteLayerContainer(root:DomNode)
        {
            super(root);

            _name = "路线";
            _children = new ArrayCollection();
        }

        public function addRouteLayer(layerName:String = "路线"):RouteLayer
        {
            var layer:RouteLayer = new RouteLayer(root);
            layer.parent = this;
            layer.layerName = layerName;
            var routeLayerDisplay:Group = new Group();
            layer.display = routeLayerDisplay;
            if (this.display)
            {
                this.display.addElement(routeLayerDisplay);
            }
            _children.addItem(layer);
            return layer;
        }

        override public function set display(d:Object):void
        {
            if (d != super.display)
            {
                super.display = d;

                for each (var routeLayer:RouteLayer in _children)
                {
                    if (routeLayer.display)
                    {
                        d.addElement(routeLayer.display);
                    }
                    else
                    {
                        var routeLayerDisplay:Group = new Group();
                        routeLayer.display = routeLayerDisplay;
                        d.addElement(routeLayerDisplay);
                    }
                }
            }
        }

        override public function readXML(xml:XML):void
        {
            _children.removeAll();

            for each (var routeLayerXML:XML in xml.children())
            {
                this.addRouteLayer().readXML(routeLayerXML);
            }
        }

        override public function toXML():XML
        {
            var result:XML = <routeLayers/>;

            for each (var routeLayer:RouteLayer in _children)
            {
                result.appendChild(routeLayer.toXML());
            }

            return result;
        }
    }
}
