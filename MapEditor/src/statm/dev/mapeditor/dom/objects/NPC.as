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
		public function NPC(root:DomNode, NPCDef:NPCItemDefinition = null)
		{
			super(root);
			_name = "NPC";
			_npcDef = NPCDef;
		}

		private var _npcDef:NPCItemDefinition;

		public function get npcDef():NPCItemDefinition
		{
			return _npcDef;
		}

		public function set npcDef(value:NPCItemDefinition):void
		{
			_npcDef = value;
		}

		private var _npcID:int;

		public function get npcID():int
		{
			return _npcID;
		}

		public function set npcID(value:int):void
		{
			_npcID = value;
		}

		override public function readXML(xml:XML):void
		{
			_npcID = parseInt(xml.@npcID);
			_npcDef = Map(root).itemDefinitionList.getNPCDefinitionByID(_npcID);

			this.x = xml.@x;
			this.y = xml.@y;
		}

		override public function toXML():XML
		{
			return <NPC x={x} y={y} npcID={_npcID}/>
		}
	}
}
