package statm.dev.mapeditor.dom
{
	import mx.collections.ArrayCollection;

	import statm.dev.mapeditor.app.AppFacade;
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.brush.Brush;
	import statm.dev.mapeditor.dom.brush.BrushList;
	import statm.dev.mapeditor.dom.item.ItemDefinitionList;
	import statm.dev.mapeditor.dom.layers.BgLayer;
	import statm.dev.mapeditor.dom.layers.Grids;
	import statm.dev.mapeditor.dom.layers.Items;
	import statm.dev.mapeditor.dom.layers.TransportPoints;
	import statm.dev.mapeditor.dom.layers.WaypointLayer;
	import statm.dev.mapeditor.dom.objects.IconList;

	/**
	 * DOM 对象：地图。
	 *
	 * @author statm
	 *
	 */
	public class Map extends DomNode
	{
		public function Map()
		{
			super(null);

			_name = "地图";
			_children = new ArrayCollection([
				_bgLayer = new BgLayer(this),
				_grids = new Grids(this),
				_items = new Items(this)]);
			_brushList = BrushList.createInstance();
			_iconList = new IconList();
			_itemDefinitionList = new ItemDefinitionList();
		}

		private var _version : String = MapEditor.VERSION;

		public function get version() : String
		{
			return _version;
		}

		private var _bgLayer : BgLayer;

		public function get bgLayer() : BgLayer
		{
			return _bgLayer;
		}

		private var _grids : Grids;

		public function get grids() : Grids
		{
			return _grids;
		}

		private var _items : Items;

		public function get items() : Items
		{
			return _items;
		}

		private var _mapID : int = 1234;

		public function get mapID() : int
		{
			return _mapID;
		}

		public function set mapID(id : int) : void
		{
			if (id != _mapID)
			{
				_mapID = id;
				notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _mapName : String = "新地图";

		public function get mapName() : String
		{
			return _mapName;
		}

		public function set mapName(name : String) : void
		{
			if (name != _mapName)
			{
				_mapName = name;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _levelLimit : int;

		public function get levelLimit() : int
		{
			return _levelLimit;
		}

		public function set levelLimit(limit : int) : void
		{
			if (limit != _levelLimit)
			{
				_levelLimit = limit;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		private var _brushList : BrushList;

		public function get brushList() : BrushList
		{
			return _brushList;
		}

		private var _iconList : IconList;

		public function get iconList() : IconList
		{
			return _iconList;
		}

		private var _itemDefinitionList : ItemDefinitionList;

		public function get itemDefinitionList() : ItemDefinitionList
		{
			return _itemDefinitionList;
		}

		private var dirty : Boolean = false;

		public function get isDirty() : Boolean
		{
			return dirty;
		}

		public function setDirty(dirty : Boolean) : void
		{
			if (dirty != this.dirty)
			{
				this.dirty = dirty;
			}
		}

		private var _filePath : String;

		public function get filePath() : String
		{
			return _filePath;
		}

		public function set filePath(path : String) : void
		{
			_filePath = path;
		}

		public function testWalk(x : int, y : int) : Boolean
		{
			var brush : Brush = grids.walkingLayer.getMask(x, y) as Brush;
			return (brush && (brush.name == "可行走"));
		}

		override public function toXML() : XML
		{
			var result : XML = <map id={this.mapID} name={this.mapName} levelLimit={this.levelLimit} version={MapEditor.VERSION}/>;

			var layers : XML = <layers/>;
			layers.appendChild(_bgLayer.toXML())
				.appendChild(_grids.toXML())
				.appendChild(_items.toXML());

			result.appendChild(layers)
				.appendChild(_brushList.toXML())
				.appendChild(_iconList.toXML())
				.appendChild(_itemDefinitionList.toXML());

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			this._version = xml.@version;
			this._mapID = parseInt(xml.@id);
			this._mapName = xml.@name;
			this._levelLimit = xml.@levelLimit;

			this.brushList.readXML(xml.brushList[0]);
			this.bgLayer.readXML(xml.layers.bgLayer[0]);
			this.grids.readXML(xml.layers.grids[0]);
			this.iconList.readXML(xml.iconList[0]);
			this.itemDefinitionList.readXML(xml.itemDefinitionList[0]);
			this.items.readXML(xml.layers.items[0]);
		}
	}
}
