package statm.dev.npceditor.dom.objects
{
	import mx.collections.ArrayCollection;

	import spark.components.Group;
	import spark.components.Image;

	import statm.dev.npceditor.app.MapEditingActions;
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.DomObject;
	import statm.dev.npceditor.dom.Map;
	import statm.dev.npceditor.ui.UIResource;


	/**
	 * DOM 对象：连接点目标。
	 *
	 * @author statm
	 *
	 */
	public class LinkDestPoint extends Item
	{
		public function LinkDestPoint(root : DomNode)
		{
			super(root);
			_name = "连接点目标";
			_mapID = Map(root).mapID;
		}

		override public function get x() : int
		{
			if (_parent)
			{
				return _x + LinkPoint(parent).x;
			}
			else
			{
				return _x;
			}
		}

		override public function set x(value : int) : void
		{
			if (_parent)
			{
				super.x = value - LinkPoint(parent).x;
				LinkPoint(parent).redrawArrow(this);
			}
			else
			{
				_x = value;
			}
		}

		override public function get y() : int
		{
			if (_parent)
			{
				return _y + LinkPoint(parent).y;
			}
			else
			{
				return _y;
			}
		}

		override public function set y(value : int) : void
		{
			if (_parent)
			{
				super.y = value - LinkPoint(parent).y;
				LinkPoint(parent).redrawArrow(this);
			}
			else
			{
				_y = value;
			}
		}

		private var _mapID : int;

		public function get mapID() : int
		{
			return _mapID;
		}

		public function set mapID(value : int) : void
		{
			if (value != _mapID)
			{
				_mapID = value;
				if (_parent)
				{
					LinkPoint(parent).redrawArrow(this);
					this.notifyChange(MapEditingActions.OBJECT_PROPS);
				}
			}
		}

		override public function set parent(value : DomNode) : void
		{
			super.parent = value;

			super.x = _x - LinkPoint(parent).x;
			super.y = _y - LinkPoint(parent).y;
			LinkPoint(parent).redrawArrow(this);
			this.notifyChange(MapEditingActions.OBJECT_PROPS);
		}

		private var _allowNations : Array = ["WU", "SHU", "WEI"];

		public function get allowNations() : Array
		{
			return _allowNations;
		}

		public function set allowNations(value : Array) : void
		{
			if (value.join(",") != _allowNations.join(","))
			{
				_allowNations = value;
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		override public function toXML() : XML
		{
			var result : XML = <linkDestPoint x={x} y={y} mapID={mapID}>
					<allowNations/>
				</linkDestPoint>;

			for each (var nation : String in allowNations)
			{
				result.allowNations.appendChild(<nation>{nation}</nation>);
			}

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			this.x = xml.@x;
			this.y = xml.@y;
			this.mapID = xml.@mapID;

			var nations : Array = [];
			for each (var nation : XML in xml.allowNations.children())
			{
				nations.push(nation.toString());
			}
			this.allowNations = nations;
		}
	}
}
