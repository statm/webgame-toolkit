package statm.dev.npceditor.dom.layers
{
	import flash.filesystem.File;
	
	import statm.dev.npceditor.app.AppFacade;
	import statm.dev.npceditor.app.AppNotificationCode;
	import statm.dev.npceditor.app.AppState;
	import statm.dev.npceditor.app.MapEditingActions;
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.Map;

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
//			var result : XML = <bgLayer path={this.bgPath}/>;
//
//			return result;
			return <bgLayer/>;
		}

		override public function readXML(xml : XML) : void
		{
//			this.bgPath = xml.@path;
			var mapFile:File = new File(Map(root).filePath);
			this.bgPath = mapFile.resolvePath(".." + File.separator + mapFile.name.split(".")[0] + ".jpg").nativePath;
		}
	}
}
