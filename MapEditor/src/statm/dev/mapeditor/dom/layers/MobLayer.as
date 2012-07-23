package statm.dev.mapeditor.dom.layers
{
	import mx.collections.ArrayCollection;
	
	import statm.dev.mapeditor.dom.DomNode;

	/**
	 * DOM 对象：怪物层。
	 *
	 * @author renjie.zh
	 *
	 */
	public class MobLayer extends PlacementLayerBase
	{
		public function MobLayer(root : DomNode)
		{
			super(root);

			_name = "怪物";
		}
		
		override public function toXML() : XML
		{
			var result : XML = super.toXML();
			
			result.setName("mobLayer");
			
			return result;
		}
		
		
		override public function readXML(xml : XML) : void
		{
			// TODO: NYI
		}
	}
}
