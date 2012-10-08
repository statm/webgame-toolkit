package statm.dev.imageresourceviewer.data.resource
{
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 资源组信息。
	 *
	 * @author statm
	 *
	 */
	public class ResourceBatchInfo
	{
		public var type : String;

		public var name : String;

		public var action : String;

		public var direction : String;

		public function get isComplete() : Boolean
		{
			return ((type != null)
				&& (name != null)
				&& (action != null)
				&& (direction != null))
				|| ((type == ResourceType.FX)
					&& (name != null));
		}

		public function toString() : String
		{
			return "类型:" + type + ", 名称:" + name + ", 动作:" + action + ", 方向:" + direction;
		}
	}
}
