package statm.dev.mapeditor.dom.item
{

    /**
     * 特效物件定义。
     *
     * @author statm
     *
     */
    public class FxItemDefinition extends ItemDefinitionBase
    {
        private var _fxID:int;

        private var _fxName:String = "特效";

        public function FxItemDefinition(fxID:int = 0, fxName:String = "")
        {
            super(10, ItemType.FX, "特效");
            _fxID = fxID;
            _fxName = fxName;
        }

        public function get fxID():int
        {
            return _fxID;
        }

        public function get fxName():String
        {
            return _fxName;
        }

        override public function get name():String
        {
            return fxName + "(" + fxID + ")";
        }

        override public function readXML(xml:XML):void
        {
            _fxID = parseInt(xml.@fxID);
            _fxName = xml.@fxName.toString();
        }
		
		override public function toXML():XML
		{
			return <itemDefinition type={_type} fxID={_fxID} fxName={_fxName} iconID={_iconID}/>;
		}
    }
}
