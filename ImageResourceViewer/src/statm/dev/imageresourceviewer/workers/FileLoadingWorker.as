package statm.dev.imageresourceviewer.workers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;


	/**
	 * 文件读取 Worker。
	 *
	 * @author statm
	 *
	 */
	public class FileLoadingWorker extends Sprite
	{
		public function FileLoadingWorker()
		{
			init();
		}

		private var inChannel : MessageChannel;
		private var outChannel : MessageChannel;

		private function init() : void
		{
			inChannel = Worker.current.getSharedProperty("statm.dev.imageresourceviewer.msgchannels.fileloadingworker_in");
			outChannel = Worker.current.getSharedProperty("statm.dev.imageresourceviewer.msgchannels.fileloadingworker_out");

			inChannel.addEventListener(Event.CHANNEL_MESSAGE, inChannel_channelMessageHandler);
		}

		private function inChannel_channelMessageHandler(event : Event) : void
		{
			startProcessing(inChannel.receive() as Array);
		}

		private var batches : Array;

		private function startProcessing(filePathArray : Array) : void
		{
			var c : int = filePathArray.length;
			var folderArray:Array = [];
			
			batches = [];

			while (--c > -1)
			{
				var file:File = new File(filePathArray[c]);
				
				if (file && file.isDirectory)
				{
					folderArray.push(file);
				}
			}

			traverseFolders(folderArray);

			outChannel.send(batches);
		}

		private function traverseFolders(folders : Array) : void
		{
			for each (var folder : File in folders)
			{
				// 建立一个 batch
				var batch : ResourceBatch = new ResourceBatch(folder);
				if (batch.length > 0)
				{
					batches.push(batch);
				}

				// 遍历目录内容，递归	
				var folderContent : Array = folder.getDirectoryListing();
				for each (var folderItem : File in folderContent)
				{
					if (folderItem.isDirectory)
					{
						traverseFolders([folderItem]);
					}
				}
			}
		}
	}
}
