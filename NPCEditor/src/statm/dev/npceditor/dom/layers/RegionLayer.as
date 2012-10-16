package statm.dev.npceditor.dom.layers
{
	import statm.dev.npceditor.dom.DomNode;

	/**
	 * DOM 对象：地区层。
	 *
	 * @author statm
	 *
	 */
	public class RegionLayer extends MaskLayerBase
	{
		public function RegionLayer(root : DomNode)
		{
			super(root);

			_name = "地区";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("regionLayer");

			return result;
		}
	}
}
