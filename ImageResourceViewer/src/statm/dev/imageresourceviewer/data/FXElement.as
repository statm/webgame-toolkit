package statm.dev.imageresourceviewer.data
{
	import mx.collections.ArrayCollection;

	import statm.dev.imageresourceviewer.AppState;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
	import statm.dev.imageresourceviewer.data.type.DirectionType;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 特效元素。
	 *
	 * @author statm
	 *
	 */
	public class FXElement extends Element
	{
		private var _rawName : String;
		private var _fxAction : FXAction;

		public function FXElement(name : String)
		{
			super(name, ResourceType.FX);
			_rawName = name;
		}

		override public function getCurrentBatch() : ResourceBatch
		{
			if (_fxAction)
			{
				return _fxAction.batch;
			}
			else
			{
				return null;
			}
		}

		override public function get actionList() : ArrayCollection
		{
			return new ArrayCollection([_fxAction]);
		}

		override public function addBatch(batch : ResourceBatch) : void
		{
			_name = _rawName + "(" + batch.length + ")";

			_fxAction = new FXAction(_rawName);
			_fxAction.batch = batch;
		}

		public function get fxAction() : FXAction
		{
			return _fxAction;
		}
	}
}
