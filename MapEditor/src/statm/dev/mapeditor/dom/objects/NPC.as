package statm.dev.mapeditor.dom.objects
{
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.item.NPCItemDefinition;


	/**
	 * DOM 对象：NPC。
	 *
	 * @author statm
	 *
	 */
	public class NPC extends Item
	{
		public function NPC(root : DomNode, NPCDef : NPCItemDefinition = null)
		{
			super(root);
			_name = "NPC";
			_npcDef = NPCDef;
		}

		private var _npcDef : NPCItemDefinition;

		override public function readXML(xml : XML) : void
		{
			this.x = xml.@x;
			this.y = xml.@y;

			_npcDef = Map(root).itemDefinitionList.getNPCDefinitionByID(parseInt(xml.@npcID));
		}

		override public function toXML() : XML
		{
			return <NPC x={x} y={y} npcID={_npcDef.npcID}/>
		}
	}
}
