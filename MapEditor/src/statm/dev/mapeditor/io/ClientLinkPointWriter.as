package statm.dev.mapeditor.io
{
    import statm.dev.mapeditor.dom.DomObject;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;

    /**
     * 输出客户端的连接点配置文件。
     *
     * @author statm
     *
     */
    public class ClientLinkPointWriter
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
            xmlResult = <linkPointList/>;

            for each (var node:DomObject in map.items.transportPoints.children)
            {
                if (node is LinkPoint)
                {
                    xmlResult.appendChild(generateLinkPoint(LinkPoint(node)));
                }
            }
        }

        private function generateLinkPoint(lp:LinkPoint):XML
        {
            var result:XML = <linkPoint>
                    <mapID>{map.mapID}</mapID>
                    <position col={lp.x} row={lp.y}/>
                </linkPoint>;

            var destinationListNode:XML = <destinationList/>;

            for each (var ldp:LinkDestPoint in lp.children)
            {
                destinationListNode.appendChild(generateLinkDestPoint(ldp));
            }

            result.appendChild(destinationListNode);

            return result;
        }

        private function generateLinkDestPoint(ldp:LinkDestPoint):XML
        {
            var result:XML = <teleporter>
                    <mapID>{ldp.mapID}</mapID>
                    <position col={ldp.x} row={ldp.y}/>
                </teleporter>;

            var allowNationNode:XML = <allowNation/>;

            for each (var nation:String in ldp.allowNations)
            {
                allowNationNode.appendChild(<nation>{nation}</nation>);
            }

            result.appendChild(allowNationNode);

            return result;
        }
    }
}
