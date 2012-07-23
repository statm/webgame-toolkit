package statm.dev.mapeditor.dom.layers
{
	import statm.dev.mapeditor.app.AppFacade;
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.Map;

	/**
	 * DOM 对象：背景。
	 *
	 * @author statm
	 *
	 */
	public class BgLayer extends DomNode
	{
		public function BgLayer(root : DomNode)
		{
			super(root);

			_parent = root;
			_name = "背景";
		}

		private var _bgPath : String = "";

		public function get bgPath() : String
		{
			return _bgPath;
		}

		public function set bgPath(path : String) : void
		{
			if (path != _bgPath)
			{
				_bgPath = path;
				notifyChange(MapEditingActions.MAP_BG);
			}
		}

		override public function toXML() : XML
		{
			var result : XML = <bgLayer path={this.bgPath}/>;

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			this.bgPath = xml.@path;
		}
	}
}
