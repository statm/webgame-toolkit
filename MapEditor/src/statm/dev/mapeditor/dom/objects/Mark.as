package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;
    
    import spark.components.Group;
    import spark.components.Label;
    
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;

    public class Mark extends Item
    {
        public static const MOB:String = "MONSTER";

        public static const MINERAL:String = "SUPPLIES";

        public static const MOB_SPAWN:String = "MONSTER_BORN";
		
		public static const MELEE_ENTR:String = "MELEE_BORN";

        private var lblName:Label;

        public function Mark(root:DomNode)
        {
            super(root);
            _name = "标记点";
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
            group.addElement(lblName);
            this.display = group;
        }

        private var _markName:String = "";

        public function get markName():String
        {
            return _markName;
        }

        public function set markName(value:String):void
        {
            if (value != _markName)
            {
                _markName = value;
                lblName.text = value;
                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        private var _type:String = "";

        public function get type():String
        {
            return _type;
        }

        public function set type(value:String):void
        {
            if (value != _type)
            {
                _type = value;
                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        private var _level:int = 0;

        public function get level():int
        {
            return _level;
        }

        public function set level(value:int):void
        {
            if (value != _level)
            {
                _level = value;
                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }
		
        override public function readXML(xml:XML):void
        {
            this.markName = xml.@markName;
            this.x = xml.@x;
            this.y = xml.@y;
            this.type = xml.@type;
			this.level = int(xml.@level);
        }

        override public function toXML():XML
        {
            return <mark x={x} y={y} markName={_markName} type={_type} level={_level}/>;
        }
    }
}
