package statm.dev.imageresourceviewer.data
{
	import flash.filesystem.File;
	
	import statm.dev.libs.imageplayer.loader.ImageBatch;
	import statm.dev.libs.imageplayer.loader.ImageBatchEvent;

	/**
	 * 资源组。
	 *
	 * @author statm
	 *
	 */
	public class ResourceBatch
	{
		private var folder : File;

		private var loadingBatch : ImageBatch;

		public function ResourceBatch(folder : File) : void
		{
			this.folder = folder;
			this.loadingBatch = new ImageBatch(folder);
			_path = folder.nativePath;
			_length = loadingBatch.length;
			this.loadingBatch.addEventListener(ImageBatchEvent.COMPLETE, function(event:ImageBatchEvent):void
			{
				trace("done: " + path);
			});
			loadingBatch.load();
		}
		
		private var _path : String;
		
		public function get path():String
		{
			return _path;
		}

		private var _length : int;

		public function get length() : int
		{
			return _length;
		}

		private var _type : String;

		public function get type() : String
		{
			return _type;
		}

		public function set type(value : String) : void
		{
			_type = value;
		}
	}
}
