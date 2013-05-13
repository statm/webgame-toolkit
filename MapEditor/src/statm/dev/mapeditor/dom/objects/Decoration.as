package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;

    import mx.controls.Label;

    import spark.components.Group;

    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.item.DecorationItemDefinition;

    public class Decoration extends Item
    {
        private var lblName:Label;

        public function Decoration(root:DomNode, decorationDef:DecorationItemDefinition = null)
        {
            super(root);
            _name = "装饰物";
            lblName = new Label();
            this.decorationDef = decorationDef;

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

        private var _decorationDef:DecorationItemDefinition;

        public function get decorationDef():DecorationItemDefinition
        {
            return _decorationDef;
        }

        public function set decorationDef(value:DecorationItemDefinition):void
        {
            _decorationDef = value;
            value && (_decorationID = value.decorationID);
            value && (lblName.text = value.decorationName);
        }

        private var _decorationID:int;

        public function get decorationID():int
        {
            return _decorationID;
        }

        public function set decorationID(value:int):void
        {
            _decorationID = value;
            decorationDef = Map(root).itemDefinitionList.getDecorationDefinitionByID(_decorationID);
        }

        override public function readXML(xml:XML):void
        {
            this.decorationID = parseInt(xml.@decorationID);

            this.x = xml.@x;
            this.y = xml.@y;
        }

        override public function toXML():XML
        {
            return <decoration x={x} y={y} decorationID={_decorationID}/>;
        }
    }
}
