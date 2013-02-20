package statm.dev.mapeditor.dom.item
{
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    
    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.dom.layers.MobLayer;
    import statm.dev.mapeditor.dom.objects.Mineral;
    import statm.dev.mapeditor.dom.objects.Mob;
    import statm.dev.mapeditor.dom.objects.NPC;
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
			addItemDefinition(new ItemDefinitionBase(4, ItemType.MARK, "标记点"));
			addItemDefinition(new ItemDefinitionBase(4, ItemType.ROUTE_POINT, "路径节点"));
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
            if (itemDef is MineralItemDefinition)
            {
                if (mineralDefs[MineralItemDefinition(itemDef).mineralID])
                {
                    _itemDefinitions.removeItemAt(_itemDefinitions.getItemIndex(mineralDefs[MineralItemDefinition(itemDef).mineralID]));
                }
                mineralDefs[MineralItemDefinition(itemDef).mineralID] = itemDef;
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

        private var mineralDefs:Dictionary = new Dictionary();

        public function getMineralDefinitionByID(mineralID:int):MineralItemDefinition
        {
            return mineralDefs[mineralID];
        }

        public function toXML():XML
        {
            var result:XML = <itemDefinitionList/>;

            for each (var itemDef:ItemDefinitionBase in _itemDefinitions.source)
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
                    case ItemType.MINERAL:
                        itemDef = new MineralItemDefinition();
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
            var map:Map = AppState.getCurrentMap();
			var oldFilterFunc:Function = _itemDefinitions.filterFunction;

            _itemDefinitions.filterFunction = function(o:Object):Boolean
            {
                return (o is NPCItemDefinition);
            };
            _itemDefinitions.refresh();
            _itemDefinitions.removeAll();
			
			_itemDefinitions.filterFunction = oldFilterFunc;
			_itemDefinitions.refresh();

            npcDefs = new Dictionary();

            for each (var xml:XML in file.NPC)
            {
                var npcID:int = int(xml.@id);
                var nationSet:Array = [];
                for each (var nationXML:XML in xml.talkLimit.nation)
                {
                    nationSet.push(nationXML.toString());
                }
                var npcDef:NPCItemDefinition = new NPCItemDefinition(npcID, xml.name.toString(), xml.siteName.toString(), xml.appearanceID.toString(), nationSet);
                addItemDefinition(npcDef);
            }

			var l:int = map.items.npcLayer.children.length;
			
			for (var i:int = l - 1; i >= 0; i--)
			{
				var npc:NPC = NPC(map.items.npcLayer.children.getItemAt(i));
				if (npcDefs[npc.npcID])
				{
					npc.npcDef = npcDefs[npc.npcID];
				}
				else
				{
					map.items.npcLayer.removeItem(npc);
				} 
			}
        }

        public function importMobXML(file:XML):void
        {
			var map:Map = AppState.getCurrentMap();
			var oldFilterFunc:Function = _itemDefinitions.filterFunction;
			
			_itemDefinitions.filterFunction = function(o:Object):Boolean
			{
				return (o is MobItemDefinition);
			};
			_itemDefinitions.refresh();
			_itemDefinitions.removeAll();
			
			_itemDefinitions.filterFunction = oldFilterFunc;
			_itemDefinitions.refresh();
			
			mobDefs = new Dictionary();
			
            for each (var xml:XML in file.item)
            {
                var mobID:int = int(xml.@id);
                var mobDef:MobItemDefinition = new MobItemDefinition(int(xml.id), xml.desc.toString(), xml.alias.toString());
                addItemDefinition(mobDef);
            }
			
			var mobs:ArrayCollection = map.items.mobLayerContainer.getAllMobs();
			var l:int = mobs.length;
			
			for (var i:int = l - 1; i >= 0; i--)
			{
				var mob:Mob = Mob(mobs.getItemAt(i));
				if (mobDefs[mob.mobID])
				{
					mob.mobDef = mobDefs[mob.mobID];
				}
				else
				{
					MobLayer(mob.parent).removeItem(mob);
				} 
			}
        }

        public function importMineralXML(file:XML):void
        {
			var map:Map = AppState.getCurrentMap();
			var oldFilterFunc:Function = _itemDefinitions.filterFunction;
			
			_itemDefinitions.filterFunction = function(o:Object):Boolean
			{
				return (o is MineralItemDefinition);
			};
			_itemDefinitions.refresh();
			_itemDefinitions.removeAll();
			
			_itemDefinitions.filterFunction = oldFilterFunc;
			_itemDefinitions.refresh();
			
            mineralDefs = new Dictionary();

            for each (var xml:XML in file.item)
            {
                var mineralID:int = int(xml.id);
                var mineralDef:MineralItemDefinition = new MineralItemDefinition(int(xml.id), xml.desc.toString(), xml.alias.toString());
                addItemDefinition(mineralDef);
            }

			var l:int = map.items.mineralLayer.children.length;
			
			for (var i:int = l - 1; i >= 0; i--)
			{
				var mineral:Mineral = Mineral(map.items.mineralLayer.children.getItemAt(i));
				if (mobDefs[mineral.mineralID])
				{
					mineral.mineralDef = mineralDefs[mineral.mineralID];
				}
				else
				{
					map.items.mineralLayer.removeItem(mineral);
				} 
			}
        }
    }
}
