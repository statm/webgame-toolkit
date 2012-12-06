package statm.dev.imageresourceviewer.data.resource
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import statm.dev.imageresourceviewer.AppState;
	import statm.dev.imageresourceviewer.data.type.ResourceType;
	import statm.dev.libs.imageplayer.loader.ImageBatch;

	/**
	 * 资源组。
	 *
	 * @author statm
	 *
	 */
	public class ResourceBatch extends ImageBatch
	{
		private var _folder:File;

		public function ResourceBatch(folder:File):void
		{
			super(folder);

			_folder = folder;
			_path = folder.nativePath;

			if (count > 0)
			{
				_batchInfo = getResourceBatchInfo(_path);
				readConfigFile();
			}
		}

		private var _path:String;

		public function get path():String
		{
			return _path;
		}

		private var _type:String;

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		private var _batchInfo:ResourceBatchInfo;

		public function get batchInfo():ResourceBatchInfo
		{
			return _batchInfo;
		}

		private var _frameRate:int = ImageResourceViewer.DEFAULT_FRAME_RATE;

		[Bindable]
		public function get frameRate():int
		{
			return _frameRate;
		}

		public function set frameRate(value:int):void
		{
			if (value != _frameRate)
			{
				_frameRate = value;
				writeConfigFile();
			}
		}

		private var _anchor:int = ImageResourceViewer.DEFAULT_ANCHOR;

		public function get anchor():int
		{
			return _anchor;
		}

		public function set anchor(value:int):void
		{
			if (value != _anchor)
			{
				_anchor = value;
				writeConfigFile();
			}
		}

		override public function load():void
		{
			super.load();
		}

		private function readConfigFile():void
		{
			var configFile:File;
			if (_batchInfo.type == ResourceType.FX)
			{
				configFile = _folder.resolvePath(".config");
			}
			else
			{
				configFile = _folder.resolvePath("..\\.config");
			}
			if (configFile.exists)
			{
				var configFileStream:FileStream = new FileStream();
				configFileStream.open(configFile, FileMode.READ);
				_frameRate = configFileStream.readShort();
				if (configFileStream.bytesAvailable > 0)
				{
					_anchor = configFileStream.readShort();
				}
				configFileStream.close();
			}
		}

		private function writeConfigFile():void
		{
			var configFile:File;
			if (_batchInfo.type == ResourceType.FX)
			{
				configFile = _folder.resolvePath(".config");
			}
			else
			{
				configFile = _folder.resolvePath("..\\.config");
			}
			var configFileStream:FileStream = new FileStream();
			configFileStream.open(configFile, FileMode.WRITE);
			configFileStream.writeShort(_frameRate);
			configFileStream.writeShort(_anchor);
			configFileStream.close();
		}

		// 静态方法：通过路径猜测 ResourceBatch 的信息
		// NOTE：“特效”的目录结构与其他不同，需要特殊处理。
		public static function getResourceBatchInfo(path:String):ResourceBatchInfo
		{
			var result:ResourceBatchInfo = new ResourceBatchInfo();
			var pathParts:Array = path.split(File.separator).reverse();
			var searchStr:String;

			// 删掉“动作”
			var pos:int = pathParts.indexOf("动作");
			if (pos != -1)
			{
				pathParts.splice(pos, 1);
			}

			// 提取类型(type)
			var l:int = pathParts.length;
			result.type = ResourceType.UNKNOWN;
			for (var i:int = l - 1; i >= 0; i--)
			{
				var part:String = pathParts[i];
				var found:Boolean = false;

				for each (searchStr in ResourceType.typeList)
				{
					if (part.indexOf(searchStr) != -1)
					{
						result.type = searchStr;
						found = true;
						break;
					}
				}

				if (found && result.type != ResourceType.FX)
				{
					pathParts.splice(i, 1);
				}
			}

			if (result.type != ResourceType.FX)
			{
				// 提取方向(direction)
				result.direction = pathParts[0];

				// 提取动作(action)
				result.action = pathParts[1];

				// 提取名称(name)
				result.name = pathParts[2];
			}
			else
			{
				result.action = "特效";
				result.name = pathParts[0];
			}

			return result;
		}
	}
}
