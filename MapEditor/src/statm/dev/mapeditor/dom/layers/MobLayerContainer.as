package statm.dev.mapeditor.dom.layers
{
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.events.CloseEvent;
    import mx.events.PropertyChangeEvent;
    
    import spark.components.Group;
    
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.objects.Item;
    import statm.dev.mapeditor.dom.objects.Mob;

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

        public function removeMobLayer(mobLayer:MobLayer):void
        {
            if (!(mobLayer.parent == this
                && this.display.contains(mobLayer.display)
                && _children.contains(mobLayer)))
            {
                return;
            }

            if (mobLayer.children.length > 0)
            {
                Alert.show("怪物层中仍包含对象，确定删除？", "注意", Alert.YES | Alert.NO, null, function(event:CloseEvent):void
                {
                    if (event.detail == Alert.YES)
                    {
                        doRemoveMobLayer(mobLayer);
                    }
                });
            }
            else
            {
                doRemoveMobLayer(mobLayer);
            }
        }

        private function doRemoveMobLayer(mobLayer:MobLayer):void
        {
            this.display.removeElement(mobLayer.display);
            _children.removeItemAt(_children.getItemIndex(mobLayer));
            reassignLayerID();
        }

        private function reassignLayerID():void
        {
            var l:int = _children.length;

            for (var i:int = 0; i < l; i++)
            {
				var mobLayer:MobLayer = MobLayer(_children.getItemAt(i));
				var oldName:String = mobLayer.name;
                mobLayer.setLayerID(i + 1);
				mobLayer.dispatchEvent(PropertyChangeEvent.createUpdateEvent(mobLayer, "name", oldName, mobLayer.name));
            }
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
