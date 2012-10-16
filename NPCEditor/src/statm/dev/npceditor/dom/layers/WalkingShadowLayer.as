package statm.dev.npceditor.dom.layers
{
	import statm.dev.npceditor.app.AppState;
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.Map;
	import statm.dev.npceditor.dom.brush.Brush;
	import statm.dev.npceditor.dom.brush.BrushType;


	/**
	 * DOM 对象：行走半透明层。
	 *
	 * @author statm
	 *
	 */
	public class WalkingShadowLayer extends MaskLayerBase
	{
		public function WalkingShadowLayer(root : DomNode)
		{
			super(root);

			_name = "行走半透明";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("walkingShadowLayer");

			return result;
		}

		override public function setMask(gridX : int, gridY : int, mask : Brush) : void
		{
			// 只有当行走层已有标记时，才允许设置半透明。
			if (mask.type == BrushType.ERASE)
			{
				super.setMask(gridX, gridY, mask);
				return;
			}

			var map : Map = AppState.getCurrentMap();
			var walkingState : Brush = map.grids.walkingLayer.getMask(gridX, gridY);

			if (walkingState)
			{
				super.setMask(gridX, gridY, mask);
			}
		}
	}
}
