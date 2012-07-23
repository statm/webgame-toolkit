package statm.dev.mapeditor.dom.layers
{
	import mx.collections.ArrayCollection;

	import statm.dev.mapeditor.dom.DomNode;

	/**
	 * DOM 对象：NPC 层。
	 *
	 * @author renjie.zh
	 *
	 */
	public class NPCLayer extends PlacementLayerBase
	{
		public function NPCLayer(root : DomNode)
		{
			super(root);

			_name = "NPC";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("NPCLayer");

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			// TODO: NYI
		}
	}
}
