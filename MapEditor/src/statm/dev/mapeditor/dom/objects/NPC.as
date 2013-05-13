package statm.dev.mapeditor.dom.objects
{
    import flash.filters.GlowFilter;

    import spark.components.Group;
    import spark.components.Label;

    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.item.NPCItemDefinition;


    /**
     * DOM 对象：NPC。
     *
     * @author statm
     *
     */
    public class NPC extends Item
    {
        private var lblName:Label;

        public function NPC(root:DomNode, NPCDef:NPCItemDefinition = null)
        {
            super(root);
            _name = "NPC";
            lblName = new Label();
            this.npcDef = NPCDef;

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

        private var _npcDef:NPCItemDefinition;

        public function get npcDef():NPCItemDefinition
        {
            return _npcDef;
        }

        public function set npcDef(value:NPCItemDefinition):void
        {
            _npcDef = value;
            value && (_npcID = value.npcID);
            value && (lblName.text = value.npcName);
        }

        private var _npcID:int;

        public function get npcID():int
        {
            return _npcID;
        }

        public function set npcID(value:int):void
        {
            _npcID = value;
            npcDef = Map(root).itemDefinitionList.getNPCDefinitionByID(_npcID);
        }

        private var _ignoreOnMap:Boolean = false;

        public function get ignoreOnMap():Boolean
        {
            return _ignoreOnMap;
        }

        public function set ignoreOnMap(value:Boolean):void
        {
            if (value != _ignoreOnMap)
            {
                _ignoreOnMap = value;
                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        override public function readXML(xml:XML):void
        {
            this.npcID = parseInt(xml.@npcID);

            this.x = xml.@x;
            this.y = xml.@y;

            this.ignoreOnMap = (xml.@ignoreOnMap.toString() == "true");
        }

        override public function toXML():XML
        {
            return <NPC x={x} y={y} npcID={_npcID} ignoreOnMap={_ignoreOnMap}/>
        }
    }
}
