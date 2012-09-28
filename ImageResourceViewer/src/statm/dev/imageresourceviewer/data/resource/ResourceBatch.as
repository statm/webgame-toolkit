package statm.dev.imageresourceviewer.data.resource
{
	import flash.filesystem.File;
	
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
		private var _folder : File;

		public function ResourceBatch(folder : File) : void
		{
			super(folder);

			_folder = folder;
			_path = folder.nativePath;

			if (count > 0)
			{
				_batchInfo = getResourceBatchInfo(_path);
			}
		}

		private var _path : String;

		public function get path() : String
		{
			return _path;
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
		// NOTE：“特效”的目录结构与其他不同，需要特殊处理。
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
			result.type = ResourceType.UNKNOWN;
			for (var i : int = l - 1; i >= 0; i--)
			{
				var part : String = pathParts[i];
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
				result.direction = pathParts[0];
				result.name = pathParts[1];
			}
			
			return result;
		}
	}
}
