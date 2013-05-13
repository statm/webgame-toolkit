package statm.dev.mapeditor.dom.item
{

    public class DecorationItemDefinition extends ItemDefinitionBase
    {
        private var _decorationID:int;

        private var _decorationName:String = "装饰物";

        private var _decorationAlias:String;

        public function DecorationItemDefinition(id:int = 0, alias:String = "", name:String = "")
        {
            super(8, ItemType.DECORATION, "装饰物");
            _decorationID = id;
            _decorationAlias = alias;
            _decorationName = name;
        }

        public function get decorationID():int
        {
            return _decorationID;
        }

        public function get decorationName():String
        {
            return _decorationName;
        }

        public function get decorationAlias():String
        {
            return _decorationAlias;
        }

        override public function get name():String
        {
            return decorationName + "(" + decorationID + ")";
        }

        override public function readXML(xml:XML):void
        {
            _decorationID = parseInt(xml.@decorationID);
            _decorationName = xml.@decorationName.toString();
            _decorationAlias = xml.@decorationAlias.toString();
        }

        override public function toXML():XML
        {
            return <itemDefinition type={_type} decorationID={_decorationID} decorationName={_decorationName} decorationAlias={_decorationAlias} iconID={_iconID}/>;
        }
    }
}
