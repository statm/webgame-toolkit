package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;
    
    import spark.components.Group;
    import spark.components.Label;
    
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.item.FxItemDefinition;

    public class Fx extends Item
    {
        private var lblName:Label;

        public function Fx(root:DomNode, fxDef:FxItemDefinition = null)
        {
            super(root);
            _name = "特效";
            lblName = new Label();
            this.fxDef = fxDef;

            var group:Group = new Group();
            group.width = 31;
            group.addElement(iconImage);
            lblName.y = -17;
            lblName.horizontalCenter = 0;
            lblName.setStyle("color", 0xFFFFFF);
            lblName.setStyle("fontSize", 14);
            lblName.filters = [ new GlowFilter(0x000000, 1., 5., 5., 8)];
            lblName.mouseEnabled = false;
            group.addElement(lblName);
            this.display = group;
        }

        private var _fxDef:FxItemDefinition;

        public function get fxDef():FxItemDefinition
        {
            return _fxDef;
        }

        public function set fxDef(value:FxItemDefinition):void
        {
            _fxDef = value;
            value && (_fxID = value.fxID);
            value && (lblName.text = value.fxName);
        }

        private var _fxID:int;

        public function get fxID():int
        {
            return _fxID;
        }

        public function set fxID(value:int):void
        {
            _fxID = value;
			fxDef = Map(root).itemDefinitionList.getFxDefinitionByID(_fxID);
        }

        override public function readXML(xml:XML):void
        {
            this.fxID = parseInt(xml.@fxID);

            this.x = xml.@x;
            this.y = xml.@y;
        }

        override public function toXML():XML
        {
            return <fx x={x} y={y} fxID={_fxID}/>
        }
    }
}
