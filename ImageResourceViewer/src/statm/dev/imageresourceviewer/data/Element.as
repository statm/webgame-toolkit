package statm.dev.imageresourceviewer.data
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;
	import spark.collections.SortField;

	import statm.dev.imageresourceviewer.AppState;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatchInfo;

	/**
	 * 动画元素，如角色、武器、NPC 等。
	 *
	 * @author statm
	 *
	 */
	public class Element extends EventDispatcher
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

			var sort : Sort = new Sort();
			var sortField : SortField = new SortField("name");
			sort.fields = [sortField];
			_actions.sort = sort;
			_actions.refresh();

			_actionDic = new Dictionary();
		}

		public function createAction(actionName : String, frame : int) : Action
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

		public function getAction(actionName : String) : Action
		{
			return _actionDic[actionName];
		}

		public function hasAction(actionName : String) : Boolean
		{
			return _actionDic[actionName] != null;
		}

		public function get actionList() : ArrayCollection
		{
			return _actions;
		}

		public function getCurrentBatch() : ResourceBatch
		{
			var action : Action = getAction(AppState.currentAction);
			if (!action)
			{
				return null;
			}

			return action.getBatch(AppState.currentDirection);
		}

		public function addBatch(batch : ResourceBatch) : void
		{
			var info : ResourceBatchInfo = batch.batchInfo;
			var action : Action = createAction(info.action, batch.length);
			action.addBatch(info.direction, batch);
		}

		override public function toString() : String
		{
			return "[Element(type=" + type + ",name=" + name + ")]";
		}
	}
}
