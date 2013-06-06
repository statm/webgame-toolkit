package statm.dev.mapeditor.io
{
    import flash.utils.Dictionary;

    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.DomObject;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.brush.Brush;
    import statm.dev.mapeditor.dom.layers.CombatLayer;
    import statm.dev.mapeditor.dom.layers.MobLayer;
    import statm.dev.mapeditor.dom.layers.RegionLayer;
    import statm.dev.mapeditor.dom.layers.RouteLayer;
    import statm.dev.mapeditor.dom.layers.WalkingLayer;
    import statm.dev.mapeditor.dom.objects.BornPoint;
    import statm.dev.mapeditor.dom.objects.Decoration;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;
    import statm.dev.mapeditor.dom.objects.Mark;
    import statm.dev.mapeditor.dom.objects.Mineral;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.NPC;
    import statm.dev.mapeditor.dom.objects.RoutePoint;
    import statm.dev.mapeditor.dom.objects.TeleportPoint;
    import statm.dev.mapeditor.utils.GridUtils;

    /**
     * 将地图文件输出为服务器端 XML 格式。
     *
     * @author statm
     *
     */
    public class ServerWriter
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
            xmlResult = <worldMapModel>
                    <version>{AppState.xmlUID}</version>
                    <id>{map.mapID}</id>
                    <name>{map.mapName}</name>
                    <maxCol>{map.grids.gridSize.x * GridUtils.BLOCK_DIMENSION}</maxCol>
                    <maxRow>{map.grids.gridSize.y * GridUtils.BLOCK_DIMENSION}</maxRow>
                    <gridX>{map.grids.gridAnchor.x}</gridX>
                    <gridY>{map.grids.gridAnchor.y}</gridY>
                    <image>{getImageName()}</image>
                    <levelLimit>{map.levelLimit}</levelLimit>
                    {generateTileAndPlanLists()}
                    {generateTransportPoints()}
                    {generateRoutes()}
                    {generateNPC()}
                    {generateMobs()}
                    {generateMinerals()}
                    {generateDecorations()}
                </worldMapModel>;
        }

        private function getImageName():String
        {
            if (!map.bgLayer.bgPath || map.bgLayer.bgPath.length == 0)
            {
                return "";
            }

            return "image/" + map.mapName + ".jpg";
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
            var combatLayer:CombatLayer = map.grids.combatLayer;

            var regionBrushID:int;
            var walkingBrushID:int;
            var combatBrushID:int;

            for (var i:int = 0; i < maxX; i++)
            {
                for (var j:int = 0; j < maxY; j++)
                {
                    var regionBrush:Brush = regionLayer.getMask(i, j);
                    var walkingBrush:Brush = walkingLayer.getMask(i, j);
                    var combatBrush:Brush = combatLayer.getMask(i, j);

                    regionBrushID = (regionBrush ? regionBrush.id : -1);
                    walkingBrushID = (walkingBrush ? walkingBrush.id : -1);
                    combatBrushID = (combatBrush ? combatBrush.id : -1);

                    if (regionBrushID == -1 && walkingBrushID == -1 && combatBrushID == -1)
                    {
                        continue;
                    }

                    hashString = regionBrushID + "|" + walkingBrushID + "|" + combatBrushID;

                    var plan:TilePlan = currentTilePlans[hashString] as TilePlan;

                    if (!plan)
                    {
                        plan = new TilePlan();
                        plan.id = ++planCount;
                        plan.region = regionBrush;
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
            var result:XML = <tilePlanModelList/>;

            for each (var plan:TilePlan in currentTilePlans)
            {
                result.appendChild(plan.toXML());
            }

            return result;
        }

        private function generateTileList():XML
        {
            var result:XML = <tileModelList/>;

            for (var key:String in currentTiles)
            {
                var coordArray:Array = key.split(",");
                var x:int = parseInt(coordArray[0]);
                var y:int = parseInt(coordArray[1]);

                result.appendChild(<tileModel><planID>{currentTiles[key]}</planID><position col={x} row={y}/></tileModel>);
            }

            return result;
        }

        private function generateTransportPoints():XMLList
        {
            var tpResult:XML = <teleporterList/>;
            var lpResult:XML = <linkPointList/>;
            var bpResult:XML = <bornPointList/>;

            for each (var node:DomObject in map.items.transportPoints.children)
            {
                if (node is TeleportPoint)
                {
                    tpResult.appendChild(generateTeleportPoint(TeleportPoint(node)));
                }
                else if (node is LinkPoint)
                {
                    lpResult.appendChild(generateLinkPoint(LinkPoint(node)));
                }
                else if (node is BornPoint)
                {
                    bpResult.appendChild(generateBornPoint(BornPoint(node)));
                }
            }

            return tpResult + lpResult + bpResult;
        }

        private function generateTeleportPoint(tp:TeleportPoint):XML
        {
            var result:XML = <teleporter>
                    <mapID>{map.mapID}</mapID>
                    <position col={tp.x} row={tp.y}/>
                    <allowNation/>
                </teleporter>;

            for each (var nation:String in tp.allowNations)
            {
                result.allowNation.appendChild(<nation>{nation}</nation>);
            }

            return result;
        }

        private function generateLinkPoint(lp:LinkPoint):XML
        {
            var result:XML = <linkPoint>
                    <source col={lp.x} row={lp.y}/>
                    <destinationList/>
                </linkPoint>;

            for each (var ldp:LinkDestPoint in lp.children)
            {
                result.destinationList.appendChild(generateLinkDestPoint(ldp));
            }

            return result;
        }

        private function generateLinkDestPoint(ldp:LinkDestPoint):XML
        {
            var result:XML = <teleporter>
                    <mapID>{ldp.mapID}</mapID>
                    <position col={ldp.x} row={ldp.y}/>
                    <allowNation/>
                </teleporter>;

            for each (var nation:String in ldp.allowNations)
            {
                result.allowNation.appendChild(<nation>{nation}</nation>);
            }

            return result;
        }

        private function generateBornPoint(bp:BornPoint):XML
        {
            var result:XML = <bornPoint>
                    <position col={bp.x} row={bp.y}/>
                    <allowNation/>
                </bornPoint>;

            for each (var nation:String in bp.allowNations)
            {
                result.allowNation.appendChild(<nation>{nation}</nation>);
            }

            return result;
        }

        private function generateRoutes():XML
        {
            var result:XML = <patrolPathList/>;

            for each (var routeLayer:RouteLayer in map.items.routeLayerContainer.children)
            {
                if (routeLayer.children.length > 2)
                {
                    var layerXML:XML = <patrolPath>
                            <pathName>{routeLayer.layerName}</pathName>
                            <worldID>{map.mapID}</worldID>
                            <goalList/>
                        </patrolPath>;

                    for each (var routePoint:RoutePoint in routeLayer.children)
                    {
                        var pointXML:XML = <goal col={routePoint.x} row={routePoint.y}/>;
                        layerXML.goalList.appendChild(pointXML);
                    }

                    result.appendChild(layerXML);
                }
            }

            return result;
        }

        private function generateNPC():XML
        {
            var result:XML = <actionScopeList></actionScopeList>;

            for each (var npc:NPC in map.items.npcLayer.children)
            {
                if (!npc.npcDef)
                {
                    log += "无法找到 NPC 描述。(NPC_ID=" + npc.npcID + ", pos=" + npc.x + "," + npc.y + ")" + "\n";
                    continue;
                }

                var nations:XML = <nationSet/>;
                for each (var nation:String in npc.npcDef.nationSet)
                {
                    nations.appendChild(<nation>{nation}</nation>);
                }
                result.appendChild(<actionScope>
                                       <worldID>{map.mapID}</worldID>
                                       <siteName>{npc.npcDef.npcAlias}</siteName>
                                       <scopeType>NPC</scopeType>
                                       <position col={npc.x} row={npc.y}/>
                                       {nations}
                                   </actionScope>);
            }

            for each (var mark:Mark in map.items.markLayer.children)
            {
                if (mark.type == Mark.MOB_SPAWN)
                {
                    result.appendChild(<actionScope>
                                           <worldID>{map.mapID}</worldID>
                                           <siteName>{mark.markName}</siteName>
                                           <scopeType>MONSTER_BORN</scopeType>
                                           <position col={mark.x} row={mark.y}/>
                                           <nationSet>
                                               <nation>WU</nation>
                                               <nation>SHU</nation>
                                               <nation>WEI</nation>
                                           </nationSet>
                                       </actionScope>);
                }
            }

            return result;
        }

        private function generateMobs():XML
        {
            var result:XML = <monsterRobotsList/>;

            for each (var mobLayer:MobLayer in map.items.mobLayerContainer.children)
            {
                var layerResult:XML = <monsterRobots/>;

                for each (var mob:Mob in mobLayer.children)
                {
                    if (!mob.mobDef)
                    {
                        log += "无法找到怪物描述。(MOB_ID=" + mob.mobID + ", pos=" + mob.x + "," + mob.y + ")" + "\n";
                        continue;
                    }

                    layerResult.appendChild(<monsterRobot>
                                                <monsterSquad>{mob.mobDef.mobAlias}</monsterSquad>
                                                <delay>{mob.delay}</delay>
                                                <beBattled>{mob.battleEnabled}</beBattled>
                                                <autoBattle>{mob.autoBattle}</autoBattle>
                                                <autoMove>{mob.autoMove}</autoMove>
                                                <refreshTime>{mob.respawnTime}</refreshTime>
                                                <standByTime>{mob.standByTime}</standByTime>
                                                <moveSpeed>{mob.moveSpeed}</moveSpeed>
                                                <patrolRange>{mob.patrolRange}</patrolRange>
                                                <enterPosition col={mob.x} row={mob.y}/>
                                                <task>{mob.task}</task>
                                            </monsterRobot>);
                }

                result.appendChild(layerResult);
            }

            return result;
        }

        private function generateMinerals():XML
        {
            var result:XML = <suppliesRobotList/>;

            for each (var mineral:Mineral in map.items.mineralLayer.children)
            {
                if (!mineral.mineralDef)
                {
                    log += "无法找到采集点描述。(MINERAL_ID=" + mineral.mineralID + ", pos=" + mineral.x + "," + mineral.y + ")" + "\n";
                    continue;
                }

                result.appendChild(<suppliesRobot>
                                       <supplies>{mineral.mineralDef.mineralAlias}</supplies>
                                       <refreshTime>{mineral.respawnTime}</refreshTime>
                                       <enterPosition col={mineral.x} row={mineral.y}/>
                                   </suppliesRobot>);
            }

            return result;
        }

        private function generateDecorations():XML
        {
            var result:XML = <decorationActorList/>;

            for each (var decoration:Decoration in map.items.decorationLayer.children)
            {
                if (!decoration.decorationDef)
                {
                    log += "无法找到装饰物描述。(DECOR_ID=" + decoration.decorationID + ", pos=" + decoration.x + "," + decoration.y + ")" + "\n";
                    continue;
                }

                result.appendChild(<decorationActor>
                                       <decoration>{decoration.decorationDef.decorationAlias}</decoration>
                                       <enterPosition col={decoration.x} row={decoration.y}/>
                                   </decorationActor>);
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

    public var combat:Brush;

    public function toXML():XML
    {
        var result:XML = <tilePlanModel>
                <id>{id}</id>
                <siteID>{(region && region.data) ? region.data : "1"}</siteID>
                <walkStateLimit>{(walking && walking.data) ? XML(walking.data) : ""}</walkStateLimit>
                <battleTypeLimit>{(combat && combat.data) ? XML(combat.data) : ""}</battleTypeLimit>
            </tilePlanModel>;

        return result;
    }
}
