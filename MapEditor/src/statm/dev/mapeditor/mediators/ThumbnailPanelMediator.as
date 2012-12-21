package statm.dev.mapeditor.mediators
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.events.FlexEvent;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    import statm.dev.mapeditor.app.AppNotificationCode;
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.modules.ThumbnailPanel;


    /**
     * 缩略图面板 Mediator。
     *
     * @author statm
     *
     */
    public class ThumbnailPanelMediator extends Mediator
    {
        public static const NAME:String = "ThumbnailPanelMediator";

        public function ThumbnailPanelMediator(mediatorName:String = null, viewComponent:Object = null)
        {
            super(mediatorName, viewComponent);
            viewComponent.thumbImg.addEventListener(FlexEvent.READY, thumbImg_readyHandler);
            viewComponent.thumbImg.addEventListener(MouseEvent.MOUSE_DOWN, thumbImg_clickAndDragHandler);
        }

        override public function listNotificationInterests():Array
        {
            return [ AppNotificationCode.MAP_DATA_READY, AppNotificationCode.MAP_DATA_CHANGED, AppNotificationCode.VIEWPORT_CHANGED, AppNotificationCode.MAP_FILE_CLOSED ];
        }

        override public function handleNotification(notification:INotification):void
        {
            var currentMap:Map = AppState.getCurrentMap();
            var panel:ThumbnailPanel = ThumbnailPanel(viewComponent);

            switch (notification.getName())
            {
                case AppNotificationCode.MAP_DATA_READY:
                    panel.setThumbBg(currentMap.bgLayer.bgPath);
                    applyViewportChange();
                    break;

                case AppNotificationCode.MAP_DATA_CHANGED:
                    if (currentMap && notification.getBody() == MapEditingActions.MAP_BG)
                    {
                        panel.setThumbBg(currentMap.bgLayer.bgPath);
                    }
                    break;

                case AppNotificationCode.VIEWPORT_CHANGED:
                    applyViewportChange();
                    break;

                case AppNotificationCode.MAP_FILE_CLOSED:
                    panel.viewportIndicator.visible = false;
                    panel.thumbImg.source = null;
                    break;
            }
        }

        private var indicatorBound:Rectangle;

        private function applyViewportChange():void
        {
            var panel:ThumbnailPanel = ThumbnailPanel(viewComponent);
            var mapSize:Point = AppState.getMapSize();
            var viewport:Rectangle = AppState.getViewport();

            if (!mapSize || !viewport)
            {
                return;
            }

            var imgScaleRatio:Number = Math.min(panel.thumbImg.width / panel.thumbImg.sourceWidth, panel.thumbImg.height / panel.thumbImg.sourceHeight);
            var imgOffsetX:int = (panel.thumbImg.width - panel.thumbImg.sourceWidth * imgScaleRatio) / 2;
            var imgOffsetY:int = (panel.thumbImg.height - panel.thumbImg.sourceHeight * imgScaleRatio) / 2;

            panel.viewportIndicator.visible = true;
            panel.viewportIndicator.x = int(viewport.x * imgScaleRatio + imgOffsetX);
            panel.viewportIndicator.y = int(viewport.y * imgScaleRatio + imgOffsetY);
            panel.viewportIndicator.width = int(viewport.width * imgScaleRatio);
            panel.viewportIndicator.height = int(viewport.height * imgScaleRatio);

            indicatorBound = indicatorBound || new Rectangle();

            indicatorBound.x = imgOffsetX;
            indicatorBound.y = imgOffsetY;
            indicatorBound.width = panel.thumbImg.sourceWidth * imgScaleRatio;
            indicatorBound.height = panel.thumbImg.sourceHeight * imgScaleRatio;
        }

        private function thumbImg_readyHandler(event:FlexEvent):void
        {
            applyViewportChange();
        }

        private function thumbImg_clickAndDragHandler(event:MouseEvent):void
        {
            var panel:ThumbnailPanel = ThumbnailPanel(viewComponent);

            if (!panel.thumbImg.source)
            {
                return;
            }
            var indicatorX:int = panel.thumbnailGroup.mouseX - panel.viewportIndicator.width / 2;
            var indicatorY:int = panel.thumbnailGroup.mouseY - panel.viewportIndicator.height / 2;

            if (indicatorX < indicatorBound.x)
            {
                indicatorX = indicatorBound.x;
            }
            if (indicatorX + panel.viewportIndicator.width > indicatorBound.right)
            {
                indicatorX = indicatorBound.right - panel.viewportIndicator.width;
            }
            if (indicatorY < indicatorBound.y)
            {
                indicatorY = indicatorBound.y;
            }
            if (indicatorY + panel.viewportIndicator.height > indicatorBound.bottom)
            {
                indicatorY = indicatorBound.bottom - panel.viewportIndicator.height;
            }

            var imgScaleRatio:Number = Math.min(panel.thumbImg.width / panel.thumbImg.sourceWidth, panel.thumbImg.height / panel.thumbImg.sourceHeight);
            var imgOffsetX:int = (panel.thumbImg.width - panel.thumbImg.sourceWidth * imgScaleRatio) / 2;
            var imgOffsetY:int = (panel.thumbImg.height - panel.thumbImg.sourceHeight * imgScaleRatio) / 2;

            var currentViewport:Rectangle = AppState.getViewport();
            currentViewport.x = int((indicatorX - imgOffsetX) / imgScaleRatio);
            currentViewport.y = int((indicatorY - imgOffsetY) / imgScaleRatio);
            AppState.setViewport(currentViewport);

            if (event.type == MouseEvent.MOUSE_DOWN)
            {
                panel.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbImg_clickAndDragHandler);
                panel.stage.addEventListener(MouseEvent.MOUSE_UP, stage_dragStopHandler);
            }
        }

        private function stage_dragStopHandler(event:MouseEvent):void
        {
            var panel:ThumbnailPanel = ThumbnailPanel(viewComponent);
            panel.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbImg_clickAndDragHandler);
            panel.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_dragStopHandler);
        }
    }
}
