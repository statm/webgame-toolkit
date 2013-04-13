package statm.dev.mapeditor.dom.item
{

    /**
     * 怪物物件定义。
     *
     * @author statm
     *
     */
    public class MobItemDefinition extends ItemDefinitionBase
    {
        private var _mobID:int;

        private var _mobName:String = "怪物";

        private var _mobAlias:String;

        private var _battleType:String;

        public function MobItemDefinition(mobID:int = 0, mobName:String = "", mobAlias:String = "", battleType:String = "")
        {
            super(8, ItemType.MOB, "怪物");
            _mobID = mobID;
            _mobName = mobName;
            _mobAlias = mobAlias;
            _battleType = battleType;
        }

        public function get mobID():int
        {
            return _mobID;
        }

        public function get mobName():String
        {
            return _mobName;
        }

        public function get mobAlias():String
        {
            return _mobAlias;
        }

        public function get battleType():String
        {
            return _battleType;
        }

        override public function get name():String
        {
            return mobName + "(" + mobID + ")" + battleType;
        }

        override public function readXML(xml:XML):void
        {
            _mobID = parseInt(xml.@mobID);
            _mobName = xml.@mobName.toString();
            _mobAlias = xml.@mobAlias.toString();
			_battleType = xml.@battleType.toString();
        }

        override public function toXML():XML
        {
            return <itemDefinition type={_type} mobID={_mobID} mobName={_mobName} mobAlias={_mobAlias} battleType={_battleType} iconID={_iconID}/>;
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
