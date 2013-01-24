package statm.dev.mapeditor.dom.layers
{
    import mx.collections.ArrayCollection;

    import spark.components.Group;

    import statm.dev.mapeditor.dom.DomNode;

    public class MobLayerContainer extends DomNode
    {
        public function MobLayerContainer(root:DomNode)
        {
            super(root);

            _name = "怪物";
            _children = new ArrayCollection();
            addMobLayer();
        }

        public function addMobLayer():MobLayer
        {
            var layer:MobLayer = new MobLayer(root, _children.length + 1);
			layer.parent = this;
            var mobLayerDisplay:Group = new Group();
            layer.display = mobLayerDisplay;
            if (this.display)
            {
                this.display.addElement(mobLayerDisplay);
            }
            _children.addItem(layer);
            return layer;
        }

        public function getAllMobs():ArrayCollection
        {
            var result:ArrayCollection = new ArrayCollection();
            for each (var mobLayer:MobLayer in _children)
            {
                result.addAll(mobLayer.children);
            }

            return result;
        }

        override public function set display(d:Object):void
        {
            if (d != super.display)
            {
                super.display = d;

                for each (var mobLayer:MobLayer in _children)
                {
                    if (mobLayer.display)
                    {
                        d.addElement(mobLayer.display);
                    }
                    else
                    {
                        var mobLayerDisplay:Group = new Group();
                        mobLayer.display = mobLayerDisplay;
                        d.addElement(mobLayerDisplay);
                    }
                }
            }
        }

        override public function readXML(xml:XML):void
        {
            _children.removeAll();

            for each (var mobLayerXML:XML in xml.children())
            {
                this.addMobLayer().readXML(mobLayerXML);
            }
        }

        override public function toXML():XML
        {
            var result:XML = <mobLayers/>;

            for each (var mobLayer:MobLayer in _children)
            {
                result.appendChild(mobLayer.toXML());
            }

            return result;
        }
    }
}
