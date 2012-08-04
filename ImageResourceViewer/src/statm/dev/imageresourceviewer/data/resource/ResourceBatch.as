package statm.dev.imageresourceviewer.data.resource
{
	import flash.filesystem.File;

	import statm.dev.imageresourceviewer.data.type.ResourceType;
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

			if (_length > 0)
			{
				_batchInfo = getResourceBatchInfo(_path);
			}
		}

		private var _path : String;

		public function get path() : String
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

		private var _batchInfo : ResourceBatchInfo;

		public function get batchInfo() : ResourceBatchInfo
		{
			return _batchInfo;
		}

		// 静态方法：通过路径猜测 ResourceBatch 的信息
		public static function getResourceBatchInfo(path : String) : ResourceBatchInfo
		{
			var result : ResourceBatchInfo = new ResourceBatchInfo();
			var pathParts : Array = path.split(File.separator).reverse();
			var searchStr : String;

			// 删掉“动作”
			var pos : int = pathParts.indexOf("动作");
			if (pos != -1)
			{
				pathParts.splice(pos, 1);
			}

			// 提取类型(type)
			var l : int = pathParts.length;
			for (var i : int = l - 1; i >= 0; i--)
			{
				var part : String = pathParts[i]
				var found : Boolean = false;

				for each (searchStr in ResourceType.typeList)
				{
					if (part.indexOf(searchStr) != -1)
					{
						result.type = searchStr;
						found = true;
						break;
					}
				}

				if (found)
				{
					pathParts.splice(i, 1);
				}
			}

			// 提取动作(action)
			result.action = pathParts[0];

			// 提取方向(direction)
			result.direction = pathParts[1];

			// 提取名称(name)
			result.name = pathParts[2];

			return result;
		}
	}
}
