package statm.dev.mapeditor.dom.objects
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import spark.components.Image;
	import spark.primitives.BitmapImage;

	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.DomObject;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.ui.UIResource;

	/**
	 * DOM 对象：传送点。
	 *
	 * @author statm
	 *
	 */
	public class TeleportPoint extends Item
	{
		public function TeleportPoint(root : DomNode)
		{
			super(root);
			_name = "传送点";
			_mapID = Map(root).mapID;
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
				_display.visible = (value == Map(root).mapID);
				this.notifyChange(MapEditingActions.OBJECT_PROPS);
			}
		}

		override public function toXML() : XML
		{
			var result : XML = <teleportPoint x={x} y={y} mapID={mapID}>
					<allowNations/>
				</teleportPoint>;

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

			_display.visible = (this.mapID == Map(root).mapID);

			var nations : Array = [];
			for each (var nation : XML in xml.allowNations.children())
			{
				nations.push(nation.toString());
			}
			this.allowNations = nations;
		}
	}
}
