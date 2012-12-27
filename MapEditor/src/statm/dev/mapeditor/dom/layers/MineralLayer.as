package statm.dev.mapeditor.dom.layers
{
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    /**
     * DOM 对象：采集点层
     *
     * @author statm
     *
     */
    public class MineralLayer extends PlacementLayerBase
    {
        public function MineralLayer(root:DomNode)
        {
            super(root);
            _name = "采集点";
        }

        override public function toXML():XML
        {
            var result:XML = super.toXML();

            result.setName("mineralLayer");

            return result;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            for each (var mineralXML:XML in xml.children())
			{
				this.addItem(ItemFactory.createItemFromXML(mineralXML));
			}
        }
    }
}
