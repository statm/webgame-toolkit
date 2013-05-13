package statm.dev.mapeditor.dom.brush
{
    import mx.collections.ArrayCollection;

    import statm.dev.mapeditor.io.IXMLSerializable;
    import statm.dev.mapeditor.ui.UIResource;

    /**
     * 画笔列表。
     *
     * @author statm
     *
     */
    public class BrushList implements IXMLSerializable
    {
        public function BrushList(enforcer:SingletonEnforcer):void
        {
            addBrush(new Brush("可行走", "", new UIResource.WALKING_ICON().bitmapData, BrushType.WALKING));
            addBrush(new Brush("行走半透明", "true", new UIResource.WALKING_SHADOW_ICON().bitmapData, BrushType.WALKING_SHADOW));
            addBrush(new Brush("安全区", "<battleType>PVP</battleType>", new UIResource.PVE_ICON().bitmapData, BrushType.COMBAT));
            addBrush(new Brush("备战阻挡", "<walkState>READY</walkState>", new UIResource.READY_ICON().bitmapData, BrushType.WALKING));
        }

        public var regionBrushes:ArrayCollection = new ArrayCollection();

        public var walkingBrushes:ArrayCollection = new ArrayCollection();

        public var walkingShadowBrushes:ArrayCollection = new ArrayCollection();

        public var combatBrushes:ArrayCollection = new ArrayCollection();

        public function toXML():XML
        {
            var result:XML = <brushList/>;
            var brush:Brush;

            for each (brush in regionBrushes)
            {
                result.appendChild(brush.toXML());
            }

            for each (brush in walkingBrushes)
            {
                result.appendChild(brush.toXML());
            }

            for each (brush in walkingShadowBrushes)
            {
                result.appendChild(brush.toXML());
            }

            for each (brush in combatBrushes)
            {
                result.appendChild(brush.toXML());
            }

            return result;
        }

        public function readXML(xml:XML):void
        {
            regionBrushes.removeAll();
            walkingBrushes.removeAll();
            walkingShadowBrushes.removeAll();
            combatBrushes.removeAll();
            brushArray.length = 0;

            var brushList:XMLList = xml.brush;

            for each (var brushXML:XML in brushList)
            {
                var brush:Brush = new Brush();
                brush.readXML(brushXML);
                addBrush(brush);
            }
        }

        private function addBrush(brush:Brush):void
        {
            switch (brush.type)
            {
                case BrushType.REGION:
                    regionBrushes.addItem(brush);
                    break;

                case BrushType.WALKING:
                    walkingBrushes.addItem(brush);
                    break;

                case BrushType.WALKING_SHADOW:
                    walkingShadowBrushes.addItem(brush);
                    break;

                case BrushType.COMBAT:
                    combatBrushes.addItem(brush);
                    break;
            }

            brushArray[brush.id] = brush;
        }

        private var brushArray:Array = [];

        public function getBrushById(id:int):Brush
        {
            return brushArray[id];
        }

        private static var currentInstance:BrushList;

        public static function getInstance():BrushList
        {
            return currentInstance;
        }

        public static function createInstance():BrushList
        {
            currentInstance = new BrushList(new SingletonEnforcer());
            return currentInstance;
        }
    }
}

class SingletonEnforcer
{
}
