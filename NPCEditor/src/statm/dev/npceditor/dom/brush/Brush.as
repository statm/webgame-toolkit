package statm.dev.npceditor.dom.brush
{
	import flash.display.BitmapData;

	import statm.dev.npceditor.io.IXMLSerializable;
	import statm.dev.npceditor.ui.UIResource;
	import statm.dev.npceditor.utils.BitmapCODECUtils;

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

			var iconString : String = xml.icon.toString();

			// TODO：一些图标变化。为了照顾现有文件只能写在这里。
			// 要写一个 Patch 类，或者做文件版本控制。

			// 可行走：v1.2 将绿色变浅了一些
			if (iconString == "eNrtzTENAEAMw8Cwef4IiqzSs2iWs+T5km6Tfdez2Ww2m81ms9lsNrtrt/oQOTMW")
			{
				iconString = "eNrtzTERADAMAzGTKZvwp5OyiBf93c9Kuk32Xc9ms9lsNpvNZrPZ7K7d6gMWt7kt";
			}
			// 行走半透明：v1.2 将灰色换成了浅蓝色
			else if (iconString == "eNrtzbENAAAIwzB+Zu/tfEEXR8rsmW6b5Hs2m81ms9lsNpvNZnftVgdQD1Pw"
				|| iconString == "eNrtzTERADAIBEHEYgoDURJhuOCbvZmrtyrb9PvXs9lsNpvNZrPZbDY7a6dayz7kyQ==")
			{
				iconString = "eNpjYBhY8OafCIPbfyGsciDxUXnayr/+Jzrs5XEBetiPD4Dkf/4XoZk8Me4A6ael/Gj+G83fo/l7NH+Pyo/m79H8PZq/qZ2+R7r9tJYnlH5pmb/pBQAwgdjb";
			}

			this._icon = BitmapCODECUtils.decode(iconString, BRUSH_WIDTH, BRUSH_HEIGHT);
		}
	}
}
