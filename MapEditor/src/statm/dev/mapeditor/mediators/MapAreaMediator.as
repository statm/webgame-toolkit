package statm.dev.mapeditor.mediators
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.events.EffectEvent;
    import mx.events.FlexEvent;

    import spark.effects.easing.Sine;
    import spark.primitives.BitmapImage;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    import statm.dev.mapeditor.app.AppNotificationCode;
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.DomObject;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.brush.Brush;
    import statm.dev.mapeditor.dom.item.ItemDefinitionBase;
    import statm.dev.mapeditor.dom.item.ItemFactory;
    import statm.dev.mapeditor.dom.objects.Item;
    import statm.dev.mapeditor.modules.MapArea;
    import statm.dev.mapeditor.utils.GridUtils;
    import statm.dev.mapeditor.utils.InertiaTracker;
    import statm.dev.mapeditor.utils.assert;


    /**
     * 地图编辑区 Mediator。
     *
     * @author statm
     *
     */
    public class MapAreaMediator extends Mediator
    {
        public static const NAME:String = "MapAreaMediator";

        public function MapAreaMediator(mediatorName:String = null, viewComponent:Object = null)
        {
            super(mediatorName, viewComponent);

            viewComponent.mapImage.addEventListener(FlexEvent.READY, mapImage_readyHandler);
            viewComponent.mapScroller.addEventListener(Event.RESIZE, mapScroller_resizeHandler);
            viewComponent.mapScroller.addEventListener(MouseEvent.MOUSE_DOWN, mapScroller_mouseDownHandler);

            viewComponent.mapMovingEffect.addEventListener(EffectEvent.EFFECT_UPDATE, mapMovingEffect_updateHandler);
        }

        override public function listNotificationInterests():Array
        {
            return [ AppNotificationCode.MAP_DATA_READY, AppNotificationCode.MAP_DATA_CHANGED, AppNotificationCode.VIEWPORT_CHANGED, AppNotificationCode.MAP_FILE_CLOSED, AppNotificationCode.SELECTION_CHANGED ];
        }

        override public function handleNotification(notification:INotification):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var mapArea:MapArea = MapArea(viewComponent);
            var viewport:Rectangle = AppState.getViewport();
            var selection:DomNode = AppState.getCurrentSelection();

            switch (notification.getName())
            {
                case AppNotificationCode.MAP_DATA_READY:
                    if (currentMap)
                    {
                        currentMap.display = mapArea;
                        currentMap.bgLayer.display = mapArea.mapImage;
                        currentMap.grids.display = mapArea.grids;
                        currentMap.grids.walkingLayer.display = mapArea.walkingLayer;
                        currentMap.grids.walkingShadowLayer.display = mapArea.walkingShadowLayer;
                        currentMap.grids.regionLayer.display = mapArea.regionLayer;
                        currentMap.grids.combatLayer.display = mapArea.combatLayer;
                        currentMap.items.display = mapArea.items;
                        currentMap.items.npcLayer.display = mapArea.NPCLayer;
                        currentMap.items.mobLayer.display = mapArea.mobLayer;
                        currentMap.items.transportPoints.display = mapArea.transportLayer;
                        currentMap.items.waypoints.display = mapArea.waypointLayer;

                        mapArea.setMapBg(currentMap.bgLayer.bgPath);
                        AppState.setViewport(new Rectangle(0, 0, mapArea.mapScroller.width, mapArea.mapScroller.height));

                        GridUtils.drawGrids(mapArea.gridDisplay, currentMap.grids.gridSize.y, currentMap.grids.gridSize.x);

                        mapArea.grids.move(currentMap.grids.gridAnchor.x, currentMap.grids.gridAnchor.y);
                    }
                    break;

                case AppNotificationCode.MAP_DATA_CHANGED:
                    if (!currentMap)
                    {
                        return;
                    }

                    var action:String = notification.getBody() as String;
                    if (action == MapEditingActions.MAP_BG)
                    {
                        mapArea.setMapBg(currentMap.bgLayer.bgPath);
                        AppState.setViewport(new Rectangle(0, 0, mapArea.mapScroller.width, mapArea.mapScroller.height));
                    }
                    else if (action == MapEditingActions.GRID_SIZE)
                    {
                        GridUtils.drawGrids(mapArea.gridDisplay, currentMap.grids.gridSize.y, currentMap.grids.gridSize.x);
                    }
                    else if (action == MapEditingActions.GRID_ANCHOR)
                    {
                        mapArea.grids.move(currentMap.grids.gridAnchor.x, currentMap.grids.gridAnchor.y);
                    }
                    break;

                case AppNotificationCode.VIEWPORT_CHANGED:
                    applyViewportChange();
                    break;

                case AppNotificationCode.SELECTION_CHANGED:
                    if (selection && selection is DomObject && selection.display.visible)
                    {
                        ensureObjOnScreen(DomObject(selection));
                    }
                    break;

                case AppNotificationCode.MAP_FILE_CLOSED:
                    mapArea.mapImage.source = null;
                    mapArea.gridDisplay.clear();
                    mapArea.walkingLayer.clear();
                    mapArea.walkingShadowLayer.clear();
                    mapArea.regionLayer.clear();
                    mapArea.combatLayer.clear();
                    mapArea.maskDrawingLayer.clear();
                    mapArea.transportLayer.removeAllElements();
                    mapArea.waypointLayer.removeAllElements();
                    mapArea.NPCLayer.removeAllElements();
                    mapArea.mobLayer.removeAllElements();
                    AppState.stopDrawingMask();
                    AppState.stopDrawingItem();
                    break;
            }
        }

        private function mapImage_readyHandler(event:FlexEvent):void
        {
            AppState.setMapSize(new Point(event.currentTarget.sourceWidth, event.currentTarget.sourceHeight));
        }

        private function mapScroller_resizeHandler(event:Event):void
        {
            var mapSize:Point = AppState.getMapSize();
            var viewport:Rectangle = AppState.getViewport();
            var mapArea:MapArea = MapArea(viewComponent);

            if (!mapSize)
            {
                return;
            }

            if (!viewport)
            {
                AppState.setViewport(new Rectangle(0, 0, mapArea.mapScroller.width, mapArea.mapScroller.height));
            }
            else
            {
                viewport.x = Math.min(mapSize.x - mapArea.mapScroller.width, viewport.x);
                viewport.y = Math.min(mapSize.y - mapArea.mapScroller.height, viewport.y);
                viewport.width = mapArea.mapScroller.width;
                viewport.height = mapArea.mapScroller.height;

                AppState.setViewport(viewport);
            }
        }

        private function applyViewportChange():void
        {
            var mapSize:Point = AppState.getMapSize();
            var viewport:Rectangle = AppState.getViewport();

            if (!mapSize || !viewport)
            {
                return;
            }

            MapArea(viewComponent).mapScrollingGroup.horizontalScrollPosition = viewport.x;
            MapArea(viewComponent).mapScrollingGroup.verticalScrollPosition = viewport.y;
        }

        private function mapScroller_mouseDownHandler(event:MouseEvent):void
        {
            var mapArea:MapArea = MapArea(viewComponent);
            var map:Map = AppState.getCurrentMap();

            if (mapArea.mapMovingEffect.isPlaying)
            {
                mapArea.mapMovingEffect.stop();
            }

            if ((!AppState.isMovingViewport() && !AppState.isDrawingMask() && !AppState.isMovingGrid() && !AppState.isDrawingItem() && !AppState.isMovingItem()) || !map)
            {
                return;
            }

            inertiaTracker.startTracking(mapArea);
            mapArea.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            mapArea.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);

            var gridCoord:Point = GridUtils.globalToGrid(new Point(mapArea.mapScrollingGroup.mouseX - mapArea.grids.x, mapArea.mapScrollingGroup.mouseY - mapArea.grids.y));

            if (AppState.isMovingViewport())
            {
                dragAnchor = new Point(event.stageX, event.stageY);
            }
            else if (AppState.isMovingGrid())
            {
                dragAnchor = new Point(event.stageX, event.stageY);
            }
            else if (AppState.isMovingItem())
            {
                dragAnchor = gridCoord;
            }
            else if (AppState.isDrawingMask())
            {
                if (AppState.getCurrentMap().grids.gridRange.contains(gridCoord.x, gridCoord.y))
                {
                    var brush:Brush = AppState.getCurrentBrush();
                    AppState.getCurrentMaskLayer().setMask(gridCoord.x, gridCoord.y, brush);
                    GridUtils.drawMaskBit(mapArea.maskDrawingLayer, gridCoord.x, gridCoord.y, brush);
                }

                dragAnchor = gridCoord;
            }
            else if (AppState.isDrawingItem())
            {
                if (AppState.getCurrentMap().grids.gridRange.contains(gridCoord.x, gridCoord.y))
                {
                    var itemDef:ItemDefinitionBase = AppState.getCurrentItemDef();

                    var previewPos:Point = GridUtils.gridToGlobal(gridCoord);
                    var itemPreview:BitmapImage = new BitmapImage();
                    itemPreview.source = map.iconList.getIcon(itemDef.iconID);
                    itemPreview.x = previewPos.x;
                    itemPreview.y = previewPos.y;

                    mapArea.itemDrawingLayer.addElement(itemPreview);
                }

                dragAnchor = gridCoord;
            }
        }

        private var dragAnchor:Point;

        private var lastMaskRectangle:Rectangle;

        private function stage_mouseMoveHandler(event:MouseEvent):void
        {
            if (!AppState.isMovingViewport() && !AppState.isDrawingMask() && !AppState.isMovingGrid() && !AppState.isDrawingItem() && !AppState.isMovingItem())
            {
                viewComponent.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
                viewComponent.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
                return;
            }

            var mapSize:Point = AppState.getMapSize();
            var viewport:Rectangle = AppState.getViewport();
            var mapArea:MapArea = MapArea(viewComponent);
            var currentMap:Map = AppState.getCurrentMap();
            var selection:DomNode = AppState.getCurrentSelection();
            var gridCoord:Point = GridUtils.globalToGrid(new Point(mapArea.mapScrollingGroup.mouseX - mapArea.grids.x, mapArea.mapScrollingGroup.mouseY - mapArea.grids.y));

            if (AppState.isMovingViewport())
            {
                moveViewport(mapArea.mapScrollingGroup.horizontalScrollPosition - (event.stageX - dragAnchor.x) * 2, mapArea.mapScrollingGroup.verticalScrollPosition - (event.stageY - dragAnchor.y) * 2);

                dragAnchor.x = event.stageX;
                dragAnchor.y = event.stageY;
            }
            else if (AppState.isMovingGrid())
            {
                var delta:Point = new Point(event.stageX - dragAnchor.x, event.stageY - dragAnchor.y);

                var nextDragAnchorX:int = event.stageX;
                var nextDragAnchorY:int = event.stageY;

                var gridX:int = currentMap.grids.gridAnchor.x + event.stageX - dragAnchor.x;
                var gridY:int = currentMap.grids.gridAnchor.y + event.stageY - dragAnchor.y;

                gridX = (gridX < 0 ? 0 : gridX);
                gridY = (gridY < 0 ? 0 : gridY);

                currentMap.grids.gridAnchor = new Point(gridX, gridY);

                if (nextDragAnchorX < 0)
                {
                    nextDragAnchorX = 0;
                }
                if (nextDragAnchorY < 0)
                {
                    nextDragAnchorY = 0;
                }

                dragAnchor.x = nextDragAnchorX;
                dragAnchor.y = nextDragAnchorY;
            }
            else if (AppState.isDrawingMask())
            {
                var rectX:int = Math.min(gridCoord.x, dragAnchor.x);
                var rectY:int = Math.min(gridCoord.y, dragAnchor.y);
                var rectW:int = Math.abs(gridCoord.x - dragAnchor.x) + 1;
                var rectH:int = Math.abs(gridCoord.y - dragAnchor.y) + 1;

                var maskRectangle:Rectangle = new Rectangle(rectX, rectY, rectW, rectH);

                if (!lastMaskRectangle || !maskRectangle.equals(lastMaskRectangle))
                {
                    mapArea.maskDrawingLayer.clear();
                    GridUtils.drawMaskRect(mapArea.maskDrawingLayer, maskRectangle.intersection(currentMap.grids.gridRange), AppState.getCurrentBrush());
                    lastMaskRectangle = maskRectangle;
                }
            }
            else if (AppState.isMovingItem())
            {
                // 要选择一个 DOM 对象
                assert(selection && (selection is DomObject));

                if (gridCoord.x < 0)
                {
                    gridCoord.x = 0;
                }
                if (gridCoord.x > currentMap.grids.gridRange.width - 1)
                {
                    gridCoord.x = currentMap.grids.gridRange.width - 1;
                }
                if (gridCoord.y < 0)
                {
                    gridCoord.y = 0;
                }
                if (gridCoord.y > currentMap.grids.gridRange.height - 1)
                {
                    gridCoord.y = currentMap.grids.gridRange.height - 1;
                }

                if (gridCoord.equals(dragAnchor))
                {
                    return;
                }

                if (AppState.getCurrentMap().grids.gridRange.contains(gridCoord.x, gridCoord.y))
                {
                    var selectedObject:DomObject = DomObject(selection);
                    selectedObject.x = gridCoord.x;
                    selectedObject.y = gridCoord.y;
                }
                dragAnchor.x = gridCoord.x;
                dragAnchor.y = gridCoord.y;
            }
            else if (AppState.isDrawingItem())
            {
                if (gridCoord.x < 0)
                {
                    gridCoord.x = 0;
                }
                if (gridCoord.x > currentMap.grids.gridRange.width - 1)
                {
                    gridCoord.x = currentMap.grids.gridRange.width - 1;
                }
                if (gridCoord.y < 0)
                {
                    gridCoord.y = 0;
                }
                if (gridCoord.y > currentMap.grids.gridRange.height - 1)
                {
                    gridCoord.y = currentMap.grids.gridRange.height - 1;
                }

                if (AppState.getCurrentMap().grids.gridRange.contains(gridCoord.x, gridCoord.y))
                {
                    var previewPos:Point = GridUtils.gridToGlobal(gridCoord);

                    if (mapArea.itemDrawingLayer.numElements > 0)
                    {
                        var preview:BitmapImage = BitmapImage(mapArea.itemDrawingLayer.getElementAt(0));
                        preview.x = previewPos.x;
                        preview.y = previewPos.y;
                    }
                    else
                    {
                        var itemDef:ItemDefinitionBase = AppState.getCurrentItemDef();

                        var itemPreview:BitmapImage = new BitmapImage();
                        itemPreview.source = currentMap.iconList.getIcon(itemDef.iconID);
                        itemPreview.x = previewPos.x;
                        itemPreview.y = previewPos.y;

                        mapArea.itemDrawingLayer.addElement(itemPreview);
                    }

                    dragAnchor = gridCoord;
                }
            }
        }

        private function stage_mouseUpHandler(event:MouseEvent):void
        {
            var mapArea:MapArea = MapArea(viewComponent);
            var currentMap:Map = AppState.getCurrentMap();

            if (AppState.isMovingViewport())
            {
                AppState.stopMovingViewport();
                if (inertiaTracker.getInertialSpeed().length > INERTIA_THRESHOLD)
                {
                    inertialMove(inertiaTracker.getInertialSpeed());
                }
            }
            else if (AppState.isMovingGrid())
            {
                AppState.stopMovingGrid();
            }
            else if (AppState.isMovingItem())
            {
                AppState.stopMovingItem();
            }
            else if (AppState.isDrawingMask())
            {
                if (lastMaskRectangle)
                {
                    AppState.getCurrentMaskLayer().setMaskRect(lastMaskRectangle.intersection(currentMap.grids.gridRange), AppState.getCurrentBrush());
                }
                mapArea.maskDrawingLayer.clear();
            }
            else if (AppState.isDrawingItem())
            {
                mapArea.itemDrawingLayer.removeAllElements();

                if (AppState.getCurrentMap().grids.gridRange.contains(dragAnchor.x, dragAnchor.y))
                {
                    ItemFactory.domRoot = currentMap;
                    var newItem:Item = ItemFactory.createItemFromDefinition(AppState.getCurrentItemDef());
                    newItem.x = dragAnchor.x;
                    newItem.y = dragAnchor.y;
                    currentMap.items.addItem(newItem);
                    AppState.setCurrentSelection(newItem);
                }
            }

            mapArea.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            mapArea.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);

            dragAnchor = null;
            lastMaskRectangle = null;
        }

        private function validateViewport(viewport:Rectangle):void
        {
            var mapArea:MapArea = MapArea(viewComponent);

            viewport.x = Math.round(viewport.x);
            viewport.y = Math.round(viewport.y);

            if (viewport.x < 0)
            {
                viewport.x = 0;
            }

            if (viewport.y < 0)
            {
                viewport.y = 0;
            }

            if (viewport.x > mapArea.mapScrollingGroup.contentWidth - mapArea.mapScrollingGroup.width)
            {
                viewport.x = mapArea.mapScrollingGroup.contentWidth - mapArea.mapScrollingGroup.width;
            }

            if (viewport.y > mapArea.mapScrollingGroup.contentHeight - mapArea.mapScrollingGroup.height)
            {
                viewport.y = mapArea.mapScrollingGroup.contentHeight - mapArea.mapScrollingGroup.height;
            }
        }

        private var inertiaTracker:InertiaTracker = new InertiaTracker();

        private const INERTIA_THRESHOLD:int = 20;

        private function inertialMove(speedVector:Point):void
        {
            var viewport:Rectangle = AppState.getViewport();
            var mapArea:MapArea = MapArea(viewComponent);

            if (mapArea.mapMovingEffect.isPlaying)
            {
                mapArea.mapMovingEffect.stop();
            }

            mapArea.mapMovingPathX.valueTo = viewport.x - speedVector.x * 7;
            mapArea.mapMovingPathY.valueTo = viewport.y - speedVector.y * 7;
            mapArea.mapMovingEffect.easer = new Sine(0.03);
            mapArea.mapMovingEffect.duration = 800;
            mapArea.mapMovingEffect.play([ viewport ]);
        }

        private function mapMovingEffect_updateHandler(event:EffectEvent):void
        {
            var viewport:Rectangle = AppState.getViewport();

            validateViewport(viewport);
            AppState.setViewport(viewport);
        }

        private function moveViewport(x:int, y:int, animate:Boolean = false):void
        {
            var viewport:Rectangle = AppState.getViewport();
            var mapArea:MapArea = MapArea(viewComponent);

            if (mapArea.mapMovingEffect.isPlaying)
            {
                mapArea.mapMovingEffect.stop();
            }

            if (animate)
            {
                var delta:Point = new Point(x - viewport.x, y - viewport.y);

                mapArea.mapMovingPathX.valueTo = x;
                mapArea.mapMovingPathY.valueTo = y;
                mapArea.mapMovingEffect.easer = new Sine(0.5);
                mapArea.mapMovingEffect.duration = Math.min(500, Math.log(delta.length / 150) * Math.LOG10E * 150 + 300);
                mapArea.mapMovingEffect.play([ viewport ]);
            }
            else
            {
                viewport.x = x;
                viewport.y = y;

                validateViewport(viewport);
                AppState.setViewport(viewport);
            }
        }

        private function ensureObjOnScreen(obj:DomObject):void
        {
            var viewport:Rectangle = AppState.getViewport();
            var mapArea:MapArea = MapArea(viewComponent);

            var itemPos:Point = GridUtils.gridToGlobal(new Point(obj.x, obj.y));
            itemPos.offset(mapArea.grids.x, mapArea.grids.y);

            var itemRect:Rectangle = new Rectangle(itemPos.x + obj.border.x, itemPos.y + obj.border.y, obj.border.width, obj.border.height);

            if (!viewport.containsRect(itemRect))
            {
                var delta:Point = calculateViewportDelta(viewport, itemRect);

                moveViewport(viewport.x + delta.x, viewport.y + delta.y, true);
            }
        }

        private function calculateViewportDelta(viewport:Rectangle, target:Rectangle):Point
        {
            var delta:Point = new Point();

            if (target.left < viewport.left)
            {
                delta.x = target.left - viewport.left;
            }
            else if (target.right > viewport.right)
            {
                delta.x = target.right - viewport.right;
            }

            if (target.top < viewport.top)
            {
                delta.y = target.top - viewport.top;
            }
            else if (target.bottom > viewport.bottom)
            {
                delta.y = target.bottom - viewport.bottom;
            }

            return delta;
        }
    }
}
