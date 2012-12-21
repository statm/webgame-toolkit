package statm.dev.mapeditor.dom
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;

    import mx.core.IVisualElement;
    import mx.graphics.SolidColorStroke;

    import spark.components.Group;
    import spark.primitives.Rect;
    import spark.primitives.supportClasses.GraphicElement;

    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.utils.GridUtils;

    /**
     * DOM 物件。
     *
     * @author statm
     *
     */
    public class DomObject extends DomNode
    {
        public function DomObject(root:DomNode)
        {
            super(root);
            displayGroup = new Group();
            displayGroup.mouseEnabledWhereTransparent = false;
            displayGroup.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            _selectionRect = new Rect();
            _selectionRect.stroke = new SolidColorStroke(0xFF9900, 2);
        }

        protected var _x:int;

        protected var _y:int;

        public function get x():int
        {
            return _x;
        }

        public function set x(value:int):void
        {
            if (value != _x)
            {
                _x = value;

                if (displayGroup)
                {
                    displayGroup.x = value * GridUtils.GRID_WIDTH;
                }

                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        public function get y():int
        {
            return _y;
        }

        public function set y(value:int):void
        {
            if (value != _y)
            {
                _y = value;

                if (displayGroup)
                {
                    displayGroup.y = value * GridUtils.GRID_HEIGHT;
                }

                this.notifyChange(MapEditingActions.OBJECT_PROPS);
            }
        }

        protected var displayGroup:Group;

        override public function get display():Object
        {
            return displayGroup;
        }

        override public function set display(d:Object):void
        {
            displayGroup.removeAllElements();
            displayGroup.addElement(IVisualElement(d));

            d.x = 0;
            d.y = 0;
            _display = d;

            displayGroup.x = _x * GridUtils.GRID_WIDTH;
            displayGroup.y = _y * GridUtils.GRID_HEIGHT;
        }

        protected function mouseDownHandler(event:MouseEvent):void
        {
            if (AppState.isMovingViewport() || AppState.isMovingGrid() || AppState.isDrawingMask())
            {
                return;
            }

            AppState.setCurrentSelection(this);
            AppState.startMovingItem();
        }

        protected var _border:Rectangle = new Rectangle(0, 0, GridUtils.GRID_WIDTH + 1, GridUtils.GRID_HEIGHT + 1);

        public function get border():Rectangle
        {
            return _border;
        }

        protected var _selectionRect:Rect;

        override public function select():void
        {
            if (_display)
            {
                if (_display is DisplayObject)
                {
                    DisplayObject(_display).filters = [ new GlowFilter(0xFF9900)];
                }
                else if (_display is GraphicElement)
                {
                    GraphicElement(_display).filters = [ new GlowFilter(0xFF9900)];
                }
            }

            _selectionRect.x = _border.x;
            _selectionRect.y = _border.y;
            _selectionRect.width = _border.width;
            _selectionRect.height = _border.height;
            displayGroup.addElement(_selectionRect);
        }

        override public function deselect():void
        {
            if (_display)
            {
                if (_display is DisplayObject)
                {
                    DisplayObject(_display).filters = [];
                }
                else if (_display is GraphicElement)
                {
                    GraphicElement(_display).filters = [];
                }
            }

            displayGroup.removeElement(_selectionRect);
        }
    }
}
