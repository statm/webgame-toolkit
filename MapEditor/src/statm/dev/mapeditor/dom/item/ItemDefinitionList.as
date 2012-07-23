package statm.dev.mapeditor.dom.item
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.mapeditor.io.IXMLSerializable;

	/**
	 * 物件定义列表。
	 *
	 * @author renjie.zh
	 *
	 */
	public class ItemDefinitionList implements IXMLSerializable
	{
		public function ItemDefinitionList()
		{
			addBuiltinItemDefs();
		}

		private function addBuiltinItemDefs() : void
		{
			addItemDefinition(new ItemDefinition(0, ItemType.TELEPORT_POINT, "传送点"));
			addItemDefinition(new ItemDefinition(1, ItemType.LINK_POINT, "连接点"));
			addItemDefinition(new ItemDefinition(2, ItemType.LINK_DEST_POINT, "连接目标点"));
			addItemDefinition(new ItemDefinition(3, ItemType.BORN_POINT, "出生点"));
			addItemDefinition(new ItemDefinition(4, ItemType.WAYPOINT, "路点"));
		}

		private var _itemDefinitions : ArrayCollection = new ArrayCollection();

		public function get itemDefinitions() : ArrayCollection
		{
			return _itemDefinitions;
		}

		private function addItemDefinition(itemDef : ItemDefinition) : void
		{
			_itemDefinitions.addItem(itemDef);
		}

		public function toXML() : XML
		{
			var result : XML = <itemDefinitionList/>;

			for each (var itemDef : ItemDefinition in _itemDefinitions)
			{
				if (itemDef.iconID < 5)
				{
					continue;
				}
				result.appendChild(itemDef.toXML());
			}

			return result;
		}

		public function readXML(xml : XML) : void
		{
			_itemDefinitions.removeAll();
			
			addBuiltinItemDefs();

			for each (var itemDefXML : XML in xml.itemDefinitionList)
			{
				var itemDef : ItemDefinition = new ItemDefinition();
				itemDef.readXML(itemDefXML);
				addItemDefinition(itemDef);
			}
		}
	}
}
