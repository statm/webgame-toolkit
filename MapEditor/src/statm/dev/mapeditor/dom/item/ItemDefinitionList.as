package statm.dev.mapeditor.dom.item
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import statm.dev.mapeditor.io.IXMLSerializable;

	/**
	 * 物件定义列表。
	 *
	 * @author statm
	 *
	 */
	public class ItemDefinitionList implements IXMLSerializable
	{
		public function ItemDefinitionList()
		{
			addBuiltinItemDefs();
		}

		private function addBuiltinItemDefs():void
		{
			addItemDefinition(new ItemDefinitionBase(0, ItemType.TELEPORT_POINT, "传送点"));
			addItemDefinition(new ItemDefinitionBase(1, ItemType.LINK_POINT, "连接点"));
			addItemDefinition(new ItemDefinitionBase(2, ItemType.LINK_DEST_POINT, "连接目标点"));
			addItemDefinition(new ItemDefinitionBase(3, ItemType.BORN_POINT, "出生点"));
			addItemDefinition(new ItemDefinitionBase(4, ItemType.WAYPOINT, "路点"));
		}

		private var _itemDefinitions:ArrayCollection = new ArrayCollection();

		public function get itemDefinitions():ArrayCollection
		{
			return _itemDefinitions;
		}

		private function addItemDefinition(itemDef:ItemDefinitionBase):void
		{
			_itemDefinitions.addItem(itemDef);
			if (itemDef is NPCItemDefinition)
			{
				if (npcDefs[NPCItemDefinition(itemDef).npcID])
				{
					_itemDefinitions.removeItemAt(_itemDefinitions.getItemIndex(npcDefs[NPCItemDefinition(itemDef).npcID]));
				}
				npcDefs[NPCItemDefinition(itemDef).npcID] = itemDef;
			}
			if (itemDef is MobItemDefinition)
			{
				if (mobDefs[MobItemDefinition(itemDef).mobID])
				{
					_itemDefinitions.removeItemAt(_itemDefinitions.getItemIndex(mobDefs[MobItemDefinition(itemDef).mobID]));
				}
				mobDefs[MobItemDefinition(itemDef).mobID] = itemDef;
			}
		}

		private var npcDefs:Dictionary = new Dictionary();

		public function getNPCDefinitionByID(npcID:int):NPCItemDefinition
		{
			return npcDefs[npcID];
		}

		private var mobDefs:Dictionary = new Dictionary();

		public function getMobDefinitionByID(mobID:int):MobItemDefinition
		{
			return mobDefs[mobID];
		}

		public function toXML():XML
		{
			var result:XML = <itemDefinitionList/>;

			for each (var itemDef:ItemDefinitionBase in _itemDefinitions)
			{
				if (itemDef.iconID < 5)
				{
					continue;
				}
				result.appendChild(itemDef.toXML());
			}

			return result;
		}

		public function readXML(xml:XML):void
		{
			_itemDefinitions.removeAll();

			addBuiltinItemDefs();

			for each (var itemDefXML:XML in xml.itemDefinition)
			{
				var itemDef:ItemDefinitionBase;

				switch (itemDefXML.@type.toString())
				{
					case ItemType.NPC:
						itemDef = new NPCItemDefinition();
						break;
					case ItemType.MOB:
						itemDef = new MobItemDefinition();
						break;
					default:
						itemDef = new ItemDefinitionBase();
						break;
				}

				itemDef.readXML(itemDefXML);
				addItemDefinition(itemDef);
			}
		}

		public function importNPCXML(file:XML):void
		{
			for each (var xml:XML in file.NPC)
			{
				addItemDefinition(new NPCItemDefinition(int(xml.@id), xml.name.toString(), xml.appearanceID.toString()));
			}
		}

		public function importMobXML(file:XML):void
		{
			for each (var xml:XML in file.item)
			{
				addItemDefinition(new MobItemDefinition(int(xml.id), xml.desc.toString()));
			}
		}
	}
}
