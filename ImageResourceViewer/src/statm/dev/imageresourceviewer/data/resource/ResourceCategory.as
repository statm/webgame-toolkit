package statm.dev.imageresourceviewer.data.resource
{
	import mx.collections.ArrayCollection;
	
	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 资源组。
	 *
	 * @author statm
	 *
	 */
	public class ResourceCategory
	{
		private var _type : String;

		public function get type() : String
		{
			return _type;
		}

		public function ResourceCategory(type : String)
		{
			_type = type;
			elements = new ArrayCollection();
		}

		[Bindable]
		public var elements : ArrayCollection;
	}
}
