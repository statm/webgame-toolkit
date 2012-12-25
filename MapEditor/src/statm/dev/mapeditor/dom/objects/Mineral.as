package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;
    
    import spark.components.Group;
    import spark.components.Label;
    
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.item.MineralItemDefinition;

    public class Mineral extends Item
    {
		private var lblName:Label;
		
        public function Mineral(root:DomNode, mineralDef:MineralItemDefinition = null)
        {
            super(root);
            _name = "采集点";
			lblName = new Label();
			this.mineralDef = mineralDef;
			
			var group:Group = new Group();
			group.width = 31;
			group.addElement(iconImage);
			lblName.y = -17;
			lblName.horizontalCenter = 0;
			lblName.setStyle("color", 0xFFFFFF);
			lblName.setStyle("fontSize", 14);
			lblName.filters = [new GlowFilter(0x000000, 1., 5., 5., 8)];
			lblName.mouseEnabled = false;
			group.addElement(lblName);
			this.display = group;
        }

        private var _mineralDef:MineralItemDefinition;

        public function get mineralDef():MineralItemDefinition
        {
            return _mineralDef;
        }

        public function set mineralDef(value:MineralItemDefinition):void
        {
            _mineralDef = value;
            value && (_mineralID = value.mineralID);
			value && (lblName.text = value.mineralName);
        }

        private var _mineralID:int;

        public function get mineralID():int
        {
            return _mineralID;
        }

        public function set mineralID(value:int):void
        {
            _mineralID = value;
            mineralDef = Map(root).itemDefinitionList.getMineralDefinitionByID(_mineralID);
        }

        private var _respawnTme:int = 10000;

        public function get respawnTime():int
        {
            return _respawnTme;
        }

        public function set respawnTime(value:int):void
        {
            if (value != _respawnTme)
            {
                _respawnTme = value;
                _mineralDef && (_mineralDef.defaultProps.respawnTime = value);
                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        override public function readXML(xml:XML):void
        {
            this.mineralID = parseInt(xml.@mineralID);

            this.x = xml.@x;
            this.y = xml.@y;
            this.respawnTime = xml.@respawnTime;
        }

        override public function toXML():XML
        {
            return <mineral x={x} y={y} mineralID={_mineralID} respawnTime={_respawnTme}/>;
        }
    }
}
