package statm.dev.mapeditor.io
{
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.objects.Mark;

	public class ClientMarkWriter
	{
		private var map:Map
		
		private var xmlResult:XML;
		
		private var log:String = "";
		
		public function read(map:Map):void
		{
			reset();
			this.map = map;
			parseMap();
		}
		
		public function flush():XML
		{
			return xmlResult;
		}
		
		private function reset():void
		{
			
		}
		
		private function parseMap():void
		{
			xmlResult = <siteList/>;
			
			for each (var mark:Mark in map.items.markLayer.children)
			{
				xmlResult.appendChild(<site name={mark.markName} mapID={map.mapID} col={mark.x} row={mark.y}/>);
			}
		}
	}
}