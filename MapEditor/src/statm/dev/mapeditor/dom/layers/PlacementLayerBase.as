package statm.dev.mapeditor.dom.layers
{
    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;
    import mx.core.IVisualElement;

    import spark.components.Group;

    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.app.MapEditingActions;
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.DomObject;


    /**
     * DOM 对象：物体放置层（抽象）。
     *
     * @author statm
     *
     */
    public class PlacementLayerBase extends DomNode
    {
        public function PlacementLayerBase(root:DomNode)
        {
            super(root);
            _children = new ArrayCollection();
        }

        protected var itemDic:Dictionary = new Dictionary();

        public function getItems(gridX:int, gridY:int):Array
        {
            return itemDic[gridX + "," + gridY];
        }

        public function addItem(item:DomObject):void
        {
            var key:String = item.x + "," + item.y;

            if (itemDic[key])
            {
                (itemDic[key] as Array).push(item);
            }
            else
            {
                itemDic[key] = [ item ];
            }

            if (this.display)
            {
                Group(this.display).addElement(IVisualElement(item.display));
            }

            this.children.addItem(item);
            if (!item.parent)
            {
                item.parent = this;
            }

            notifyChange(MapEditingActions.ADD_OBJECT);
        }

        public function removeItem(item:DomObject):void
        {
            if (item.parent != this)
            {
                throw new Error("要移除的物件不在此图层中");
            }

            var key:String = item.x + "," + item.y;

            if (itemDic[key])
            {
                var items:Array = itemDic[key] as Array;
                var pos:int = items.indexOf(item);
                items.splice(pos, 1);
                if (items.length == 0)
                {
                    delete itemDic[key];
                }
            }

            if (this.display)
            {
                Group(this.display).removeElement(IVisualElement(item.display));
            }

            this.children.removeItemAt(this.children.getItemIndex(item));

            notifyChange(MapEditingActions.REMOVE_OBJECT);
        }

        override public function set display(d:Object):void
        {
            super.display = d;

            for each (var child:DomNode in _children)
            {
                Group(this.display).addElement(IVisualElement(child.display));
            }
        }

        override public function deselect():void
        {
            AppState.stopDrawingItem();
        }

        override public function toXML():XML
        {
            var result:XML = <placementLayer/>;

            for (var i:int = 0; i < this.children.length; i++)
            {
                var item:DomObject = DomObject(this.children.getItemAt(i));
                result.appendChild(item.toXML());
            }

            return result;
        }
    }
}
