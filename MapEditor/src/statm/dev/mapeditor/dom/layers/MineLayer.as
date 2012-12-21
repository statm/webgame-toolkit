package statm.dev.mapeditor.dom.layers
{
    import mx.collections.ArrayCollection;

    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    /**
     * DOM 对象：采集点层
     *
     * @author statm
     *
     */
    public class MineLayer extends PlacementLayerBase
    {
        public function MineLayer(root:DomNode)
        {
            super(root);
            _name = "采集点";
        }

        override public function toXML():XML
        {
            var result:XML = super.toXML();

            result.setName("mineLayer");

            return result;
        }

        override public function readXML(xml:XML):void
        {
            ItemFactory.domRoot = root;
            // TODO
        }
    }
}
