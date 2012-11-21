package statm.dev.mapeditor.dom.layers
{
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.item.ItemFactory;


	/**
	 * DOM 对象：传送层。
	 *
	 * @author statm
	 *
	 */
	public class TransportPoints extends PlacementLayerBase
	{
		public function TransportPoints(root : DomNode)
		{
			super(root);
			_name = "传送";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("transportLayer");

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			ItemFactory.domRoot = root;

			for each (var pointXML : XML in xml.children())
			{
				this.addItem(ItemFactory.createItemFromXML(pointXML));
			}
		}
	}
}
