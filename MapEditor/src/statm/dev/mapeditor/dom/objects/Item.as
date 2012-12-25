package statm.dev.mapeditor.dom.objects
{
    import spark.components.Image;
    
    import statm.dev.mapeditor.dom.DomNode;
    import statm.dev.mapeditor.dom.DomObject;


    /**
     * 物件基类。
     *
     * @author statm
     *
     */
    public class Item extends DomObject
    {
        public function Item(root:DomNode)
        {
            super(root);
            _name = "物件";
            display = _iconImage;
        }

        protected var _iconImage:Image = new Image();

        public function get iconImage():Image
        {
            return _iconImage;
        }
    }
}
