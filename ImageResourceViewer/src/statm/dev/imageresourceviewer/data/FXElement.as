package statm.dev.imageresourceviewer.data
{
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
		private var batch : ResourceBatch;
		private var rawName : String;
		private var pseudoAction : Action;

		public function FXElement(name : String)
		{
			super(name, ResourceType.FX);
			rawName = name;
		}

		override public function getCurrentBatch() : ResourceBatch
		{
			return batch;
		}

		override public function addBatch(batch : ResourceBatch) : void
		{
			if (!batch)
			{
				AppState.actionCount++;
			}
			
			this.batch = batch;
			
			_name = rawName + "(" + batch.length + ")";
			
			pseudoAction = new Action("特效");
			pseudoAction.addBatch(DirectionType.N, batch);
			pseudoAction.addBatch(DirectionType.NE, batch);
			pseudoAction.addBatch(DirectionType.E, batch);
			pseudoAction.addBatch(DirectionType.SE, batch);
			pseudoAction.addBatch(DirectionType.S, batch);
		}

		public function getFXAction() : Action
		{
			return pseudoAction;
		}
	}
}
