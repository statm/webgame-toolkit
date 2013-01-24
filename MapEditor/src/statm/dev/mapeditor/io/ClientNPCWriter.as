package statm.dev.mapeditor.io
{
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.objects.NPC;

    public class ClientNPCWriter
    {
        private var map:Map

        private var xmlResult:XML;

        private var log:String = "";

        public function read(map:Map):void
        {
            reset();
            this.map = map;
            parseMap();
        }

        public function flush():XML
        {
            return xmlResult;
        }

        private function reset():void
        {

        }

        private function parseMap():void
        {
            xmlResult = <NPCList/>;

            for each (var npc:NPC in map.items.npcLayer.children)
            {
                xmlResult.appendChild(<NPC id={npc.npcID} mapID={map.mapID} col={npc.x} row={npc.y}/>);
            }
        }
    }
}
