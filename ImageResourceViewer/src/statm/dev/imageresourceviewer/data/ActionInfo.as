package statm.dev.imageresourceviewer.data
{

	/**
	 * 动作信息。
	 *
	 * @author statm
	 *
	 */
	public class ActionInfo
	{
		public var name : String;

		public var frameCount : int;

		public function equals(info : ActionInfo) : Boolean
		{
			return info.name == name;
		}

		public function toString() : String
		{
			return "[" + name + ":" + frameCount + "]";
		}
	}
}
