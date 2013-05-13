package statm.dev.mapeditor.dom.layers
{
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    public class DecorationLayer extends PlacementLayerBase
    {
        public function DecorationLayer(root:DomNode)
        {
            super(root);
            _name = "装饰物";
        }

        override public function toXML():XML
        {
            var result:XML = super.toXML();

            result.setName("decorationLayer");

            return result;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            for each (var decorationXML:XML in xml.children())
            {
                this.addItem(ItemFactory.createItemFromXML(decorationXML));
            }
        }
    }
}
