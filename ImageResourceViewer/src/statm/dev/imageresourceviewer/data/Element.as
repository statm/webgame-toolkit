package statm.dev.imageresourceviewer.data
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	/**
	 * 动画元素，如角色、武器、NPC 等。
	 *
	 * @author statm
	 *
	 */
	public class Element
	{
		private var _type : String;

		public function get type() : String
		{
			return _type;
		}

		private var _name : String;

		public function get name() : String
		{
			return _name;
		}

		private var _actions : ArrayCollection;

		private var _actionDic : Dictionary;

		public function Element(name : String, type : String) : void
		{
			_name = name;
			_type = type;
			_actions = new ArrayCollection();
			_actionDic = new Dictionary();
		}

		public function getAction(actionName : String) : Action
		{
			var action : Action = _actionDic[actionName];
			if (!action)
			{
				action = new Action(actionName);
				_actionDic[actionName] = action;
				_actions.addItem(action);
			}
			return action;
		}

		public function toString() : String
		{
			return "[Element(type=" + type + ",name=" + name + ")]";
		}
	}
}
