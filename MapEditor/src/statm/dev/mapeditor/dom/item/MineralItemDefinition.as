package statm.dev.mapeditor.dom.item
{

    /**
     * 采集点物件定义。
     *
     * @author statm
     *
     */
    public class MineralItemDefinition extends ItemDefinitionBase
    {
        private var _mineralID:int;

        private var _mineralName:String = "采集点";

        private var _mineralAlias:String;

        public function MineralItemDefinition(mineralID:int = 0, mineralName:String = "", mineralAlias:String = "")
        {
            super(7, ItemType.MINERAL, "MINERAL");
            _mineralID = mineralID;
            _mineralName = mineralName;
            _mineralAlias = mineralAlias;
        }

        public function get mineralID():int
        {
            return _mineralID;
        }

        public function get mineralName():String
        {
            return _mineralName;
        }

        public function get mineralAlias():String
        {
            return _mineralAlias;
        }

        override public function get name():String
        {
            return mineralName + "(" + mineralID + ")";
        }

        override public function readXML(xml:XML):void
        {
            _mineralID = parseInt(xml.@mineralID);
            _mineralName = xml.@mineralName.toString();
            _mineralAlias = xml.@mineralAlias.toString();
        }

        override public function toXML():XML
        {
            return <itemDefinition type={_type} mineralID={_mineralID} mineralName={_mineralName} mineralAlias={_mineralAlias} iconID={_iconID}/>;
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
