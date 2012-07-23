package statm.dev.mapeditor.dom.item
{
	import flash.display.BitmapData;

	import statm.dev.mapeditor.io.IXMLSerializable;

	/**
	 * 物件定义。
	 * ItemFactory 类根据物件定义制造实际的地图元素。
	 * 在地图文件中，要保存此列表。
	 *
	 * @author statm
	 *
	 */
	public class ItemDefinition implements IXMLSerializable
	{
		private var _iconID : int;

		private var _type : String;

		private var _name : String;

		public function ItemDefinition(iconID : int = 0, type : String = null, name : String = null) : void
		{
			_iconID = iconID;
			_type = type;
			_name = name;
		}

		public function get iconID() : int
		{
			return _iconID;
		}

		public function get type() : String
		{
			return _type;
		}

		public function get name() : String
		{
			return _name;
		}

		public function readXML(xml : XML) : void
		{
			_name = xml.@name;
			_type = xml.@type;
			_iconID = xml.@iconID;
		}

		public function toXML() : XML
		{
			return <itemDefinition name={_name} iconID={_iconID} type={_type}/>;
		}
	}
}
