package statm.dev.mapeditor.dom.layers
{
	import statm.dev.mapeditor.dom.DomNode;


	/**
	 * DOM 对象：行走半透明层。
	 *
	 * @author statm
	 *
	 */
	public class WalkingOpaqueLayer extends MaskLayerBase
	{
		public function WalkingOpaqueLayer(root : DomNode)
		{
			super(root);

			_name = "行走半透明";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("walkingOpaqueLayer");

			return result;
		}
	}
}
