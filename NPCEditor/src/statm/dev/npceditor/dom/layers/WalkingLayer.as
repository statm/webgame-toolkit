package statm.dev.npceditor.dom.layers
{
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.brush.Brush;
	import statm.dev.npceditor.dom.brush.BrushList;

	/**
	 * DOM 对象：行走层。
	 *
	 * @author statm
	 *
	 */
	public class WalkingLayer extends MaskLayerBase
	{
		public function WalkingLayer(root : DomNode)
		{
			super(root);

			_name = "行走模式";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("walkingLayer");

			return result;
		}
	}
}
