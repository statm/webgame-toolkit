package statm.dev.mapeditor.dom.item
{

	/**
	 * NPC 物件定义。
	 *
	 * @author statm
	 *
	 */
	public class NPCItemDefinition extends ItemDefinitionBase
	{
		private var _npcID:int;

		private var _npcName:String = "NPC";

		private var _npcSkinID:int;

		public function NPCItemDefinition(npcID:int = 0, npcName:String = "", npcSkinID:int = 0)
		{
			super(5, ItemType.NPC, "NPC");
			_npcID = npcID;
			_npcName = npcName;
			_npcSkinID = npcSkinID;
		}

		public function get npcID():int
		{
			return _npcID;
		}

		public function get npcName():String
		{
			return _npcName;
		}

		public function get npcSkinID():int
		{
			return _npcSkinID;
		}

		override public function get name():String
		{
			return npcName + "(" + npcID + ")"
		}

		override public function readXML(xml:XML):void
		{
			_npcID = xml.@npcID;
			_npcName = xml.@npcName;
			_npcSkinID = xml.@npcSkinID;
		}

		override public function toXML():XML
		{
			return <itemDefinition type={_type} npcID={_npcID} npcName={_npcName} npcSkinID={_npcSkinID} iconID={_iconID}/>;
		}

		private var _defaultProps:Object = {};

		public function get defaultProps():Object
		{
			return _defaultProps;
		}

		public function set defaultProps(value:Object):void
		{
			_defaultProps = value;
		}
	}
}
