package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;

    import spark.components.Group;
    import spark.components.Label;

    import statm.dev.mapeditor.dom.DomNode;

    public class RoutePoint extends Item
    {
        private var lblName:Label;

        public function RoutePoint(root:DomNode)
        {
            super(root);

            _name = "路径节点";
            lblName = new Label();

            var group:Group = new Group();
            group.width = 31;
            group.addElement(iconImage);
            lblName.y = -17;
            lblName.horizontalCenter = 0;
            lblName.setStyle("color", 0xFFFFFF);
            lblName.setStyle("fontSize", 14);
            lblName.filters = [ new GlowFilter(0x000000, 1., 5., 5., 8)];
            lblName.mouseEnabled = false;
			lblName.text = "路径节点";
            group.addElement(lblName);
            this.display = group;
        }

        override public function readXML(xml:XML):void
        {
            this.x = xml.@x;
            this.y = xml.@y;
        }

        override public function toXML():XML
        {
            return <routePoint x={x} y={y}/>;
        }
    }
}
