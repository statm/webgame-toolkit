package statm.dev.mapeditor.dom.objects
{
	import spark.components.Image;
	
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.ui.UIResource;


	/**
	 * DOM 对象：出生点。
	 *
	 * @author renjie.zh
	 *
	 */
	public class BornPoint extends Item
	{
		public function BornPoint(root : DomNode)
		{
			super(root);
			_name = "出生点";
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
			var result : XML = <bornPoint x={x} y={y}>
					<allowNations/>
				</bornPoint>;

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

			var nations : Array = [];
			for each (var nation : XML in xml.allowNations.children())
			{
				nations.push(nation.toString());
			}
			this.allowNations = nations;
		}
	}
}
