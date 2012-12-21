package statm.dev.mapeditor.utils
{
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    /**
     * 惯性速度测量。
     *
     * @author statm
     *
     */
    public class InertiaTracker
    {
        public function InertiaTracker():void
        {
            super();
        }

        private var host:InteractiveObject;

        public function startTracking(target:InteractiveObject):void
        {
            this.host = target;
            anchor = new Point(target.stage.mouseX, target.stage.mouseY);

            target.stage.addEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
            target.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        }

        private var anchor:Point;

        private var speedX:Number = 0;

        private var speedY:Number = 0;

        private function stage_enterFrameHandler(event:Event):void
        {
            var newPoint:Point = new Point(host.stage.mouseX, host.stage.mouseY);
            speedX = newPoint.x - anchor.x;
            speedY = newPoint.y - anchor.y;
            anchor = newPoint;
        }

        private function stage_mouseUpHandler(event:MouseEvent):void
        {
            host.stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
            host.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        }

        public function getInertialSpeed():Point
        {
            return new Point(speedX, speedY);
        }
    }
}
