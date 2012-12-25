package statm.dev.mapeditor.mediators
{
    import flash.events.Event;
    import flash.geom.Point;

    import mx.collections.ArrayList;
    import mx.events.FlexEvent;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    import statm.dev.mapeditor.app.AppNotificationCode;
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.brush.Brush;
    import statm.dev.mapeditor.dom.item.ItemDefinitionBase;
    import statm.dev.mapeditor.dom.item.ItemFactory;
    import statm.dev.mapeditor.dom.layers.BgLayer;
    import statm.dev.mapeditor.dom.layers.CombatLayer;
    import statm.dev.mapeditor.dom.layers.Grids;
    import statm.dev.mapeditor.dom.layers.Items;
    import statm.dev.mapeditor.dom.layers.MineralLayer;
    import statm.dev.mapeditor.dom.layers.MobLayer;
    import statm.dev.mapeditor.dom.layers.NPCLayer;
    import statm.dev.mapeditor.dom.layers.RegionLayer;
    import statm.dev.mapeditor.dom.layers.TransportPoints;
    import statm.dev.mapeditor.dom.layers.WalkingLayer;
    import statm.dev.mapeditor.dom.layers.WalkingShadowLayer;
    import statm.dev.mapeditor.dom.layers.WaypointLayer;
    import statm.dev.mapeditor.dom.objects.BornPoint;
    import statm.dev.mapeditor.dom.objects.LinkDestPoint;
    import statm.dev.mapeditor.dom.objects.LinkPoint;
    import statm.dev.mapeditor.dom.objects.Mineral;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.NPC;
    import statm.dev.mapeditor.dom.objects.TeleportPoint;
    import statm.dev.mapeditor.modules.PropertyPanel;


    /**
     * 属性面板 Mediator。
     *
     * @author statm
     *
     */
    public class PropertyPanelMediator extends Mediator
    {
        public static const NAME:String = "PropertyPanelMediator";

        public function PropertyPanelMediator(mediatorName:String = null, viewComponent:Object = null)
        {
            super(mediatorName, viewComponent);
            viewComponent.addEventListener("submit", submitProperties);
            viewComponent.addEventListener("submit", submitProperties, true);
            viewComponent.addEventListener(FlexEvent.CONTENT_CREATION_COMPLETE, deferredSetupHandler, true);
            viewComponent.addEventListener("newDestPoint", newDestPointHandler);
        }

        override public function listNotificationInterests():Array
        {
            return [ AppNotificationCode.MAP_DATA_READY, AppNotificationCode.SELECTION_CHANGED, AppNotificationCode.MAP_DATA_CHANGED ];
        }

        override public function handleNotification(notification:INotification):void
        {
            switch (notification.getName())
            {
                case AppNotificationCode.MAP_DATA_READY:
                    setBrushList();
                    break;

                case AppNotificationCode.SELECTION_CHANGED:
                    showSelectionProperties();
                    break;

                case AppNotificationCode.MAP_DATA_CHANGED:
                    handlePropertyChange(notification.getBody() as String);
                    break;
            }
        }

        private function showSelectionProperties():void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:PropertyPanel = PropertyPanel(viewComponent);
            var selection:DomNode = AppState.getCurrentSelection();

            if (!selection && !currentMap)
            {
                panel.currentState = "blank";
            }
            else if (!selection && currentMap)
            {
                // 无选择时不应该触发这个函数
                throw new Error("状态错: !selection && currentMap");
            }
            else if (selection is Map)
            {
                panel.currentState = "mapProps";

                panel.tiMapID.text = currentMap.mapID.toString();
                panel.tiMapName.text = currentMap.mapName;
                panel.tiMapLevel.text = currentMap.levelLimit.toString();
                panel.tiSmallMapSizeW.text = currentMap.smallMapWidth.toString();
                panel.tiSmallMapSizeH.text = currentMap.smallMapHeight.toString();
            }
            else if (selection is BgLayer)
            {
                panel.currentState = "bgProps";

                panel.tiMapBgPath.text = BgLayer(selection).bgPath;
            }
            else if (selection is Grids)
            {
                panel.currentState = "gridProps";

                panel.nsGridBlockR.value = currentMap.grids.gridSize.x;
                panel.nsGridBlockC.value = currentMap.grids.gridSize.y;
                panel.ctGridAnchor.setCoord(currentMap.grids.gridAnchor.x, currentMap.grids.gridAnchor.y);
            }
            else if (selection is RegionLayer)
            {
                panel.currentState = "regionLayerEditing";
            }
            else if (selection is WalkingLayer)
            {
                panel.currentState = "walkingLayerEditing";
            }
            else if (selection is WalkingShadowLayer)
            {
                panel.currentState = "walkingShadowLayerEditing";
            }
            else if (selection is CombatLayer)
            {
                panel.currentState = "combatLayerEditing";
            }
            else if ((selection is Items) || (selection is NPCLayer) || (selection is MobLayer) || (selection is MineralLayer) || (selection is TransportPoints) || (selection is WaypointLayer))
            {
                panel.currentState = "itemLayerEditing";
            }
            else if (selection is TransportPoints)
            {
                panel.currentState = "transportLayerProps";
            }
            else if (selection is TeleportPoint)
            {
                panel.currentState = "teleportPointProps";
                panel.ctTeleportPointCoord.setCoord(TeleportPoint(selection).x, TeleportPoint(selection).y);
                panel.nsTeleportPoint.setNations(TeleportPoint(selection).allowNations);
            }
            else if (selection is LinkPoint)
            {
                panel.currentState = "linkPointProps";
                panel.ctLinkPointCoord.setCoord(LinkPoint(selection).x, LinkPoint(selection).y);
            }
            else if (selection is BornPoint)
            {
                panel.currentState = "bornPointProps";
                panel.ctBornPointCoord.setCoord(BornPoint(selection).x, BornPoint(selection).y);
                panel.nsBornPoint.setNations(BornPoint(selection).allowNations);
            }
            else if (selection is LinkDestPoint)
            {
                panel.currentState = "linkDestPointProps";
                panel.ctLinkDestPointCoord.setCoord(LinkDestPoint(selection).x, LinkDestPoint(selection).y);
                panel.tiLinkDestPointMapID.text = LinkDestPoint(selection).mapID.toString();
                panel.nsLinkDestPoint.setNations(LinkDestPoint(selection).allowNations);
            }
            else if (selection is NPC)
            {
                panel.currentState = "npcProps";
                if (NPC(selection).npcDef)
                {
                    panel.lblNPCName.text = NPC(selection).npcDef.npcName;
                }
                else
                {
                    panel.lblNPCName.text = "";
                }
                panel.lblNPCID.text = NPC(selection).npcID.toString();
                panel.ctNPCCoord.setCoord(NPC(selection).x, NPC(selection).y);
            }
            else if (selection is Mob)
            {
                panel.currentState = "mobProps";
                if (Mob(selection).mobDef)
                {
                    panel.lblMobName.text = Mob(selection).mobDef.mobName;
                }
                else
                {
                    panel.lblMobName.text = "";
                }
                panel.lblMobID.text = Mob(selection).mobID.toString();
                panel.ctMobCoord.setCoord(Mob(selection).x, Mob(selection).y);
                panel.tiMobDelay.text = Mob(selection).delay.toString();
                panel.cbxMobBattleEnabled.selected = Mob(selection).battleEnabled;
                panel.cbxMobAutoBattle.selected = Mob(selection).autoBattle;
                panel.cbxMobAutoMove.selected = Mob(selection).autoMove;
                panel.tiMobRespawnTime.text = Mob(selection).respawnTime.toString();
                panel.tiMobStandByTime.text = Mob(selection).standByTime.toString();
                panel.tiMobMoveSpeed.text = Mob(selection).moveSpeed.toString();
            }
            else if (selection is Mineral)
            {
                panel.currentState = "mineralProps";
                if (Mineral(selection).mineralDef)
                {
                    panel.lblMineralName.text = Mineral(selection).mineralDef.mineralName;
                }
                else
                {
                    panel.lblMineralName.text = "";
                }
                panel.lblMineralID.text = Mineral(selection).mineralID.toString();
                panel.ctMineralCoord.setCoord(Mineral(selection).x, Mineral(selection).y);
            }
            else
            {
                panel.currentState = "blank";
            }
        }

        private function submitProperties(event:Event):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:PropertyPanel = PropertyPanel(viewComponent);
            var selection:DomNode = AppState.getCurrentSelection();

            switch (panel.currentState)
            {
                case "mapProps":
                    currentMap.mapID = int(panel.tiMapID.text);
                    currentMap.mapName = panel.tiMapName.text;
                    currentMap.levelLimit = int(panel.tiMapLevel.text);
                    currentMap.smallMapWidth = int(panel.tiSmallMapSizeW.text);
                    currentMap.smallMapHeight = int(panel.tiSmallMapSizeH.text);
                    break;

                case "bgProps":
                    currentMap.bgLayer.bgPath = panel.tiMapBgPath.text;
                    break;

                case "gridProps":
                    currentMap.grids.gridSize = new Point(panel.nsGridBlockR.value, panel.nsGridBlockC.value);
                    currentMap.grids.gridAnchor = panel.ctGridAnchor.getCoord();
                    break;

                case "walkingLayerEditing":
                    if (panel.walkingMaskList.selectedItem)
                    {
                        AppState.startDrawingMask(panel.walkingMaskList.selectedItem);
                    }
                    break;

                case "walkingShadowLayerEditing":
                    if (panel.walkingShadowMaskList.selectedItem)
                    {
                        AppState.startDrawingMask(panel.walkingShadowMaskList.selectedItem);
                    }
                    break;

                case "combatLayerEditing":
                    if (panel.combatMaskList.selectedItem)
                    {
                        AppState.startDrawingMask(panel.combatMaskList.selectedItem);
                    }
                    break;

                case "itemLayerEditing":
                    if (panel.itemsList.selectedItem)
                    {
                        AppState.startDrawingItem(panel.itemsList.selectedItem);
                    }
                    break;

                case "teleportPointProps":
                    TeleportPoint(selection).allowNations = panel.nsTeleportPoint.getNations();
                    TeleportPoint(selection).x = panel.ctTeleportPointCoord.getCoord().x;
                    TeleportPoint(selection).y = panel.ctTeleportPointCoord.getCoord().y;
                    break;

                case "bornPointProps":
                    BornPoint(selection).allowNations = panel.nsBornPoint.getNations();
                    BornPoint(selection).x = panel.ctBornPointCoord.getCoord().x;
                    BornPoint(selection).y = panel.ctBornPointCoord.getCoord().y;
                    break;

                case "linkPointProps":
                    LinkPoint(selection).x = panel.ctLinkPointCoord.getCoord().x;
                    LinkPoint(selection).y = panel.ctLinkPointCoord.getCoord().y;
                    break;

                case "linkDestPointProps":
                    LinkDestPoint(selection).mapID = parseInt(panel.tiLinkDestPointMapID.text);
                    LinkDestPoint(selection).allowNations = panel.nsLinkDestPoint.getNations();
                    LinkDestPoint(selection).x = panel.ctLinkDestPointCoord.getCoord().x;
                    LinkDestPoint(selection).y = panel.ctLinkDestPointCoord.getCoord().y;
                    break;

                case "npcProps":
                    NPC(selection).x = panel.ctNPCCoord.getCoord().x;
                    NPC(selection).y = panel.ctNPCCoord.getCoord().y;
                    break;

                case "mobProps":
                    Mob(selection).delay = int(panel.tiMobDelay.text);
                    Mob(selection).battleEnabled = panel.cbxMobBattleEnabled.selected;
                    Mob(selection).autoBattle = panel.cbxMobAutoBattle.selected;
                    Mob(selection).autoMove = panel.cbxMobAutoMove.selected;
                    Mob(selection).respawnTime = int(panel.tiMobRespawnTime.text);
                    Mob(selection).standByTime = int(panel.tiMobStandByTime.text);
                    Mob(selection).moveSpeed = int(panel.tiMobMoveSpeed.text);
                    Mob(selection).x = panel.ctMobCoord.getCoord().x;
                    Mob(selection).y = panel.ctMobCoord.getCoord().y;
                    break;

                case "mineralProps":
                    Mineral(selection).x = panel.ctMineralCoord.getCoord().x;
                    Mineral(selection).y = panel.ctMineralCoord.getCoord().y;
                    break;
            }
        }

        private function handlePropertyChange(type:String):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:PropertyPanel = PropertyPanel(viewComponent);

            if (!currentMap)
            {
                return;
            }

            switch (type)
            {
                case MapEditingActions.GRID_ANCHOR:
                    if (panel.currentState == "gridProps")
                    {
                        panel.ctGridAnchor.setCoord(currentMap.grids.gridAnchor.x, currentMap.grids.gridAnchor.y);
                    }
                    break;

                case MapEditingActions.OBJECT_PROPS:
                    showSelectionProperties();
                    break;
            }
        }

        private function setBrushList():void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:PropertyPanel = PropertyPanel(viewComponent);
            var list:Array;

            if (!currentMap)
            {
                return;
            }

            if (panel.regionMaskList)
            {
                list = currentMap.brushList.regionBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.regionMaskList.dataProvider = new ArrayList(list);
            }

            if (panel.walkingMaskList)
            {
                list = currentMap.brushList.walkingBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.walkingMaskList.dataProvider = new ArrayList(list);
            }

            if (panel.walkingShadowMaskList)
            {
                list = currentMap.brushList.walkingShadowBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.walkingShadowMaskList.dataProvider = new ArrayList(list);
            }

            if (panel.combatMaskList)
            {
                list = currentMap.brushList.combatBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.combatMaskList.dataProvider = new ArrayList(list);
            }

            if (panel.itemsList)
            {
                panel.itemsList.dataProvider = currentMap.itemDefinitionList.itemDefinitions;
                panel.filterItems();
            }
        }

        private function deferredSetupHandler(event:FlexEvent):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:PropertyPanel = PropertyPanel(viewComponent);
            var list:Array;

            if (!currentMap)
            {
                return;
            }

            if (event.target == panel.regionFormItem)
            {
                list = currentMap.brushList.regionBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.regionMaskList.dataProvider = new ArrayList(list);
            }
            else if (event.target == panel.walkingFormItem)
            {
                list = currentMap.brushList.walkingBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.walkingMaskList.dataProvider = new ArrayList(list);
            }
            else if (event.target == panel.walkingShadowFormItem)
            {
                list = currentMap.brushList.walkingShadowBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.walkingShadowMaskList.dataProvider = new ArrayList(list);
            }
            else if (event.target == panel.combatFormItem)
            {
                list = currentMap.brushList.combatBrushes.toArray();
                list.unshift(Brush.ERASE);
                panel.combatMaskList.dataProvider = new ArrayList(list);
            }
            else if (event.target == panel.itemsFormItem)
            {
                panel.itemsList.dataProvider = currentMap.itemDefinitionList.itemDefinitions;
                panel.filterItems();
            }
        }

        private function newDestPointHandler(event:Event):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var linkPoint:LinkPoint = LinkPoint(AppState.getCurrentSelection());
            var newDestPoint:LinkDestPoint = LinkDestPoint(ItemFactory.createItemFromDefinition(ItemDefinitionBase(currentMap.itemDefinitionList.itemDefinitions.source[2])));
            newDestPoint.x = linkPoint.x;
            newDestPoint.y = linkPoint.y - 1;
            newDestPoint.mapID = currentMap.mapID;
            if (newDestPoint.y < 0)
            {
                newDestPoint.y = linkPoint.y + 1;
            }
            currentMap.items.addItem(newDestPoint);
        }
    }
}
