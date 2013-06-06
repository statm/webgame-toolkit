package statm.dev.mapeditor.io
{
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.brush.Brush;
    import statm.dev.mapeditor.dom.layers.CombatLayer;
    import statm.dev.mapeditor.dom.layers.RegionLayer;
    import statm.dev.mapeditor.dom.layers.WalkingLayer;
    import statm.dev.mapeditor.dom.layers.WalkingShadowLayer;
    import statm.dev.mapeditor.dom.objects.Fx;
    import statm.dev.mapeditor.dom.objects.Waypoint;
    import statm.dev.mapeditor.utils.GridUtils;

    /**
     * 将地图文件输出为客户端 XML 格式。
     *
     * @author statm
     *
     */
    public class ClientMapWriter
    {
        private var map:Map;

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
            xmlResult = <worldMap>
                    <version>{AppState.xmlUID}</version>
                    <id>{map.mapID}</id>
                    <name>{map.mapName}</name>
                    <maxCol>{map.grids.gridSize.x * GridUtils.BLOCK_DIMENSION}</maxCol>
                    <maxRow>{map.grids.gridSize.y * GridUtils.BLOCK_DIMENSION}</maxRow>
                    <gridX>{map.grids.gridAnchor.x}</gridX>
                    <gridY>{map.grids.gridAnchor.y}</gridY>
                    <image>{getImageName()}</image>
                    <imageSize width={map.bgLayer.display.width} height={map.bgLayer.display.height}/>
                    <smallImageSize width={map.smallMapWidth} height={map.smallMapHeight}/>
                    <levelLimit>{map.levelLimit}</levelLimit>
                    {generateTileAndPlanLists()}
                    {generateWaypoints()}
                    {generateFx()}
                </worldMap>;
        }

        private function getImageName():String
        {
            if (!map.bgLayer.bgPath || map.bgLayer.bgPath.length == 0)
            {
                return "";
            }

            return new File(map.bgLayer.bgPath).name.split(".")[0];
        }

        private function generateTileAndPlanLists():XMLList
        {
            traverseTiles();

            var planList:XML = generateTilePlanList();
            var tileList:XML = generateTileList();

            return tileList + planList;
        }

        private var currentTilePlans:Dictionary = new Dictionary();

        private var currentTiles:Dictionary = new Dictionary();

        private function traverseTiles():void
        {
            var planCount:int = 0;

            var maxX:int = map.grids.gridSize.x * GridUtils.BLOCK_DIMENSION;
            var maxY:int = map.grids.gridSize.y * GridUtils.BLOCK_DIMENSION;

            var hashString:String;

            var regionLayer:RegionLayer = map.grids.regionLayer;
            var walkingLayer:WalkingLayer = map.grids.walkingLayer;
            var walkingShadowLayer:WalkingShadowLayer = map.grids.walkingShadowLayer;
            var combatLayer:CombatLayer = map.grids.combatLayer;

            var regionBrushID:int;
            var walkingBrushID:int;
            var walkingShadowBrushID:int;
            var combatBrushID:int;

            for (var i:int = 0; i < maxX; i++)
            {
                for (var j:int = 0; j < maxY; j++)
                {
                    var regionBrush:Brush = regionLayer.getMask(i, j);
                    var walkingBrush:Brush = walkingLayer.getMask(i, j);
                    var walkingShadowBrush:Brush = walkingShadowLayer.getMask(i, j);
                    var combatBrush:Brush = combatLayer.getMask(i, j);

                    regionBrushID = (regionBrush ? regionBrush.id : -1);
                    walkingBrushID = (walkingBrush ? walkingBrush.id : -1);
                    walkingShadowBrushID = (walkingShadowBrush ? walkingShadowBrush.id : -1);
                    combatBrushID = (combatBrush ? combatBrush.id : -1);

                    // 特殊逻辑：如果阴影层有标记，而行走层无标记，则阴影层的标记无效。
                    if (walkingBrushID == -1 && walkingShadowBrushID != -1)
                    {
                        walkingBrush = null;
                        walkingBrushID = -1;
                    }

                    if (regionBrushID == -1 && walkingBrushID == -1 && walkingShadowBrushID == -1 && combatBrushID == -1)
                    {
                        continue;
                    }

                    hashString = regionBrushID + "|" + walkingBrushID + "|" + walkingShadowBrushID + "|" + combatBrushID;

                    var plan:TilePlan = currentTilePlans[hashString] as TilePlan;

                    if (!plan)
                    {
                        plan = new TilePlan();
                        plan.id = ++planCount;
                        plan.region = regionBrush;
                        plan.walkingShadow = walkingShadowBrush;
                        plan.walking = walkingBrush;
                        plan.combat = combatBrush;

                        currentTilePlans[hashString] = plan;
                    }

                    currentTiles[i + "," + j] = plan.id;
                }
            }
        }

        private function generateTilePlanList():XML
        {
            var result:XML = <tilePlanList/>;

            for each (var plan:TilePlan in currentTilePlans)
            {
                result.appendChild(plan.toXML());
            }

            return result;
        }

        private function generateTileList():XML
        {
            var result:XML = <tileList/>;

            for (var key:String in currentTiles)
            {
                var coordArray:Array = key.split(",");
                var x:int = parseInt(coordArray[0]);
                var y:int = parseInt(coordArray[1]);

                result.appendChild(<tile pID={currentTiles[key]} p={x * 1000 + y}/>);
            }

            return result;
        }

        private function generateWaypoints():XML
        {
            var result:XML = <waypointList/>;

            for each (var waypoint:Waypoint in map.items.waypoints.children)
            {
                var waypointXML:XML = <waypoint p={waypoint.x * 1000 + waypoint.y}/>;

                for each (var wp:Waypoint in waypoint.adjacentWaypoints)
                {
                    waypointXML.appendChild(<adjacency p={wp.x * 1000 + wp.y}/>);
                }

                result.appendChild(waypointXML);
            }

            return result;
        }

        private function generateFx():XML
        {
            var result:XML = <sceneFxList/>;

            for each (var fx:Fx in map.items.fxLayer.children)
            {
                var fxXML:XML = <sceneFx id={fx.fxID} x={fx.x} y={fx.y}/>;
                result.appendChild(fxXML);
            }

            return result;
        }

        public function getLog():String
        {
            return log;
        }
    }
}
import statm.dev.mapeditor.dom.brush.Brush;

class TilePlan
{
    public var id:int;

    public var region:Brush;

    public var walking:Brush;

    public var walkingShadow:Brush;

    public var combat:Brush;

    public function toXML():XML
    {
        var result:XML = <tilePlan id={id} siteID={(region && region.data) ? region.data : "1"} walkShadow={(walkingShadow && walkingShadow.data) ? walkingShadow.data : "false"}>
                <walkStateLimit>{(walking && walking.data) ? XML(walking.data) : ""}</walkStateLimit>
                <battleTypeLimit>{(combat && combat.data) ? XML(combat.data) : ""}</battleTypeLimit>
            </tilePlan>;

        return result;
    }
}
