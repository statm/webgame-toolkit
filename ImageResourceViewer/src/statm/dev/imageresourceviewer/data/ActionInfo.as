package statm.dev.imageresourceviewer.data
{
	import flash.events.EventDispatcher;

	/**
	 * 动作信息。
	 *
	 * @author statm
	 *
	 */
	public class ActionInfo extends EventDispatcher
	{
		[Bindable]
		public var name : String;

		public var frameCount : int;

		public function equals(info : ActionInfo) : Boolean
		{
			return info.name == name;
		}

		override public function toString() : String
		{
			return "[" + name + ":" + frameCount + "]";
		}
	}
}
