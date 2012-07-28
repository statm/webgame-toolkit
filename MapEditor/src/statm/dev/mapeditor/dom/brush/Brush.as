package statm.dev.mapeditor.dom.brush
{
	import flash.display.BitmapData;

	import statm.dev.mapeditor.io.IXMLSerializable;
	import statm.dev.mapeditor.ui.UIResource;
	import statm.dev.mapeditor.utils.BitmapCODECUtils;

	/**
	 * 画笔数据。
	 *
	 * @author statm
	 *
	 */
	public class Brush implements IXMLSerializable
	{
		public static const BRUSH_WIDTH : int = 31;

		public static const BRUSH_HEIGHT : int = 31;

		public static const ERASE : Brush = new Brush("擦除", null, new UIResource.ERASE_ICON().bitmapData, BrushType.ERASE);

		public function Brush(name : String = null, data : String = null, icon : BitmapData = null, type : String = null) : void
		{
			_name = name;
			_data = data;
			_icon = icon;
			_type = type;
			_id = createID();
		}

		private static var currentID : int = 0;

		private static function createID() : int
		{
			return currentID++;
		}

		private var _id : int;

		public function get id() : int
		{
			return _id;
		}

		private var _name : String;

		public function get name() : String
		{
			return _name;
		}

		private var _data : String;

		public function get data() : String
		{
			return _data;
		}

		private var _icon : BitmapData;

		public function get icon() : BitmapData
		{
			return _icon;
		}

		private var _type : String;

		public function get type() : String
		{
			return _type;
		}

		public function toXML() : XML
		{
			var result : XML = <brush name={this.name} id={this.id}/>;

			result.data = XML("<data><![CDATA[" + (this.data ? this.data : "") + "]]></data>");

			result.type = <type>{this.type}</type>;

			result.icon = XML("<icon><![CDATA[" + BitmapCODECUtils.encode(this.icon) + "]]></icon>");

			return result;
		}

		public function readXML(xml : XML) : void
		{
			this._id = xml.@id;
			this._name = xml.@name;
			this._data = xml.data.toString();
			this._type = xml.type;
			this._icon = BitmapCODECUtils.decode(xml.icon.toString(), BRUSH_WIDTH, BRUSH_HEIGHT);
		}
	}
}
