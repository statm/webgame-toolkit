package statm.dev.mapeditor.dom.item
{

    public class DecorationItemDefinition extends ItemDefinitionBase
    {
        private var _decorationID:int;

        private var _decorationName:String = "装饰物";

        private var _decorationAlias:String;

        public function DecorationItemDefinition(id:int = 0, alias:String = "", name:String = "", dressID:int = 0)
        {
            super(8, ItemType.DECORATION, "装饰物");
        }
    }
}
