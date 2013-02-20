package statm.dev.mapeditor.dom.objects
{
    import mx.graphics.SolidColorStroke;
    
    import spark.primitives.Line;
    
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.DomObject;
    import statm.dev.mapeditor.dom.layers.WaypointLayer;


    /**
     * DOM 对象：路点之间的连线。
     *
     * @author statm
     *
     */
    public class WaypointConnection extends DomObject
    {
        public function WaypointConnection(root:DomNode)
        {
            super(root);
            line = new Line();
            line.stroke = new SolidColorStroke(0x0066CC, 3.5);
            this.display = line;
            _name = "路点连线";
        }

        public var endPoints:Array;

        public var line:Line;

        override public function select():void
        {
            super.select();
            WaypointLayer(parent).light();
        }

        override public function deselect():void
        {
            super.deselect();
            WaypointLayer(parent).dim();
        }
    }
}
