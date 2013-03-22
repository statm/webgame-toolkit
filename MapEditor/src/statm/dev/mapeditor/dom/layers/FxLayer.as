package statm.dev.mapeditor.dom.layers
{
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    public class FxLayer extends PlacementLayerBase
    {
        public function FxLayer(root:DomNode)
        {
            super(root);

            _name = "FX";
        }

        override public function toXML():XML
        {
            var result:XML = super.toXML();

            result.setName("fxLayer");

            return result;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            for each (var fxXML:XML in xml.children())
            {
                this.addItem(ItemFactory.createItemFromXML(fxXML));
            }
        }
    }
}
