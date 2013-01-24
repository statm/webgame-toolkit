package statm.dev.mapeditor.dom.layers
{
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.item.ItemFactory;

    /**
     * DOM 对象：标记点层
     *
     * @author statm
     *
     */
    public class MarkLayer extends PlacementLayerBase
    {
        public function MarkLayer(root:DomNode)
        {
            super(root);
            _name = "标记点";
        }

        override public function toXML():XML
        {
			var result:XML = super.toXML();
			result.setName("markLayer");
			
			return result;
        }
		
		override public function readXML(xml:XML):void
		{
			ItemFactory.domRoot = root;
			for each (var markXML:XML in xml.children())
			{
				this.addItem(ItemFactory.createItemFromXML(markXML));
			}
		}
    }
}
