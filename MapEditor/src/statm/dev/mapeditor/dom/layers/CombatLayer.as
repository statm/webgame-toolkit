package statm.dev.mapeditor.dom.layers
{
	import statm.dev.mapeditor.dom.DomNode;

	/**
	 * DOM 对象：战斗层。
	 *
	 * @author renjie.zh
	 *
	 */
	public class CombatLayer extends MaskLayerBase
	{
		public function CombatLayer(root : DomNode)
		{
			super(root);

			this._name = "战斗模式";
		}

		override public function toXML() : XML
		{
			var result : XML = super.toXML();

			result.setName("combatLayer");

			return result;
		}
	}
}
