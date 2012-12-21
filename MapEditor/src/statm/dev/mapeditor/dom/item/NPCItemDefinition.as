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

        private var _npcAlias:String = "";

        private var _npcSkinID:int;

        private var _nationSet:Array = [];

        public function NPCItemDefinition(npcID:int = 0, npcName:String = "", npcAlias:String = "", npcSkinID:int = 0, nationSet:Array = null)
        {
            super(5, ItemType.NPC, "NPC");
            _npcID = npcID;
            _npcName = npcName;
            _npcAlias = npcAlias;
            _npcSkinID = npcSkinID;
            nationSet && (_nationSet = nationSet);
        }

        public function get npcID():int
        {
            return _npcID;
        }

        public function get npcName():String
        {
            return _npcName;
        }

        public function get npcAlias():String
        {
            return _npcAlias;
        }

        public function get npcSkinID():int
        {
            return _npcSkinID;
        }

        public function get nationSet():Array
        {
            return _nationSet;
        }

        override public function get name():String
        {
            return npcName + "(" + npcID + ")"
        }

        override public function readXML(xml:XML):void
        {
            _npcID = parseInt(xml.@npcID);
            _npcName = xml.@npcName;
            _npcAlias = xml.@npcAlias;
            _npcSkinID = parseInt(xml.@npcSkinID);
            _nationSet = xml.@nationSet.split(",");
        }

        override public function toXML():XML
        {
            return <itemDefinition type={_type} npcID={_npcID} npcName={_npcName} npcAlias={_npcAlias} npcSkinID={_npcSkinID} iconID={_iconID} nationSet={_nationSet.join(",")}/>;
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
