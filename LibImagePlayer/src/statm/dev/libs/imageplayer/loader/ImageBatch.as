package statm.dev.libs.imageplayer.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;

	import statm.dev.libs.imageplayer.utils.FileUtils;

	[Event(name="progress", type="statm.dev.libs.imageplayer.loader.ImageBatchEvent")]
	[Event(name="complete", type="statm.dev.libs.imageplayer.loader.ImageBatchEvent")]
	[Event(name="error", type="statm.dev.libs.imageplayer.loader.ImageBatchEvent")]

	/**
	 * 图片组。
	 *
	 * @author statm
	 *
	 */
	public class ImageBatch extends EventDispatcher
	{
		private var files : ArrayCollection;

		protected var count : int = 0;

		private var loadedImages : Vector.<BitmapData>;

		private var loader : Loader;

		private var loadingIndex : int;

		public function get loadedCount() : int
		{
			return loadingIndex + 1;
		}

		private var _state : int = ImageBatchState.READY;

		public function get batchState() : int
		{
			return _state;
		}

		public function ImageBatch(folder : File = null) : void
		{
			files = new ArrayCollection();

			var sort : Sort = new Sort();
			sort.compareFunction = FileUtils.compareFiles;
			files.sort = sort;

			if (folder)
			{
				var imgFiles : Array = folder.getDirectoryListing();
				for each (var img : File in imgFiles)
				{
					addFile(img);
				}
			}
		}

		public function addFile(item : File) : void
		{
			if (!FileUtils.isValidImageFile(item)
				|| _state != ImageBatchState.READY)
			{
				return;
			}

			files.addItem(item);
			files.refresh();
			count++;
		}

		public function getImage(index : int) : BitmapData
		{
			if (!loadedImages
				|| index > loadedImages.length - 1)
			{
				return null;
			}

			return loadedImages[index];
		}

		public function get length() : int
		{
			return count;
		}

		public function load() : void
		{
			if (count == 0 || _state == ImageBatchState.COMPLETE)
			{
				dispatchEvent(new ImageBatchEvent(ImageBatchEvent.COMPLETE));
				return;
			}

			if (_state == ImageBatchState.LOADING
				|| _state == ImageBatchState.ERROR)
			{
				return;
			}

			loadedImages = new Vector.<BitmapData>(count, true);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, next);
			loadingIndex = -1;
			next();
			_state = ImageBatchState.LOADING;
		}

		private function next(event : Event = null) : void
		{
			if (event)
			{
				loadedImages[loadingIndex] = Bitmap(loader.content).bitmapData;
			}

			loadingIndex++;

			if (loadingIndex < count)
			{
				loader.load(new URLRequest(files[loadingIndex].url));
				dispatchEvent(new ImageBatchEvent(ImageBatchEvent.PROGRESS));
			}
			else
			{
				_state = ImageBatchState.COMPLETE;
				dispatchEvent(new ImageBatchEvent(ImageBatchEvent.COMPLETE));
			}
		}
	}
}
