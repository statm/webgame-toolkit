package statm.dev.mapeditor.dom
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.collections.ArrayCollection;

	import statm.dev.mapeditor.app.AppFacade;
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.io.IXMLSerializable;
	import statm.dev.mapeditor.utils.assert;

	/**
	 * DOM 节点。
	 *
	 * @author statm
	 *
	 */
	public class DomNode extends EventDispatcher implements IXMLSerializable
	{
		public function DomNode(root : DomNode) : void
		{
			_root = root;
		}

		protected var _root : DomNode;

		public function get root() : DomNode
		{
			return _root;
		}

		protected var _parent : DomNode;

		public function get parent() : DomNode
		{
			return _parent;
		}

		public function set parent(value : DomNode) : void
		{
			// 不能重复设置 parent
			assert(!_parent);

			_parent = value;
		}

		protected var _selected : Boolean;

		public function select() : void
		{
			_selected = true;
		}

		public function deselect() : void
		{
			_selected = false;
		}

		protected var _display : Object;

		[Bindable]
		public function get display() : Object
		{
			return _display;
		}

		public function set display(d : Object) : void
		{
			_display = d;
		}

		protected var _name : String = "DOM 节点";

		public function get name() : String
		{
			return _name;
		}

		protected var _children : ArrayCollection;

		public function get children() : ArrayCollection
		{
			return _children;
		}

		public function toXML() : XML
		{
			return null;
		}

		public function readXML(xml : XML) : void
		{
		}

		protected function notifyChange(action : String = null) : void
		{
			AppFacade.getInstance().sendNotification(AppNotificationCode.MAP_DATA_CHANGED, action);
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
