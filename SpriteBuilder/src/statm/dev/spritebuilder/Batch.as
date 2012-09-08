package statm.dev.spritebuilder
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.graphics.codec.PNGEncoder;

	import statm.dev.spritebuilder.utils.FileUtils;

	/**
	 * 批量任务。
	 *
	 * @author statm
	 *
	 */
	public class Batch extends EventDispatcher
	{
		// 文件
		[Bindable]
		public var files : ArrayCollection;

		public var folder : File;

		[Bindable]
		public var fileCount : int;

		// 位图存储，切割流程
		public var originalBitmaps : Vector.<BitmapData>;

		public var cropBounds : Vector.<Rectangle>;

		public var croppedBitmaps : Vector.<BitmapData>;

		public var framePos : Vector.<Point>;

		public var assembledSprite : BitmapData;

		// 静态显示控制
		[Bindable]
		public var currentBitmapData : BitmapData;

		private var _currentFrameIndex : int = -1;

		[Bindable]
		public function get currentFrameIndex() : int
		{
			return _currentFrameIndex;
		}

		public function set currentFrameIndex(value : int) : void
		{
			_currentFrameIndex = value;

			if (_currentFrameIndex >= fileCount)
			{
				_currentFrameIndex -= fileCount;
			}

			if (_currentFrameIndex < 0)
			{
				_currentFrameIndex += fileCount;
			}

			currentBitmapData = originalBitmaps[_currentFrameIndex];
		}

		// 加载流程
		public function load() : void
		{
			files = new ArrayCollection(FileUtils.filterImageFiles(folder));
			if (files.length == 0)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}

			var sort : Sort = new Sort();
			sort.compareFunction = FileUtils.compareFiles;
			files.sort = sort;
			files.refresh();

			var count : int = fileCount = files.length;

			originalBitmaps = new Vector.<BitmapData>(count, true);
			cropBounds = new Vector.<Rectangle>(count, true);
			croppedBitmaps = new Vector.<BitmapData>(count, true);

			loadBitmaps();
		}

		private var bitmapLoader : Loader;

		public var loadingIndex : int;

		private function loadBitmaps() : void
		{
			bitmapLoader = new Loader();
			bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_next);
			loadingIndex = -1;
			totalSize = 0.;
			loader_next();
		}

		private function loader_next(event : Event = null) : void
		{
			if (event)
			{
				var bitmapData : BitmapData = Bitmap(bitmapLoader.content).bitmapData;
				originalBitmaps[loadingIndex] = bitmapData;

				var bound : Rectangle = bitmapData.getColorBoundsRect(0xFF000000, 0x000000, false);
				cropBounds[loadingIndex] = bound;

				var cropped : BitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
				cropped.copyPixels(bitmapData, bound, new Point(0, 0));
				croppedBitmaps[loadingIndex] = cropped;

				totalSize += bound.width * bound.height;
			}
			loadingIndex++;

			dispatchEvent(new Event(Event.CHANGE));

			if (loadingIndex < files.length)
			{
				bitmapLoader.load(new URLRequest(files[loadingIndex].url));
			}
			else
			{
				assembleSprite();
				writeConfigXML();

				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private var totalSize : Number;

		private function assembleSprite() : void
		{
			var MAX_WIDTH : int = Math.sqrt(totalSize);
			var nextX : int = 0, nextY : int = 0, lineHeight : int = 0, maxX : int = 0, maxY : int = 0;
			var framePos : Vector.<Point> = new Vector.<Point>(fileCount, true);

			var i : int;
			var l : int = fileCount;
			var frame : BitmapData;
			for (i = 0; i < l; i++)
			{
				frame = croppedBitmaps[i];

				if (nextX + frame.width <= MAX_WIDTH)
				{
					framePos[i] = new Point(nextX, nextY);
					(frame.height > lineHeight) && (lineHeight = frame.height) && (maxY = nextY + frame.height);
				}
				else // 折行
				{
					nextX = 0;
					nextY += lineHeight;
					lineHeight = frame.height;
					framePos[i] = new Point(nextX, nextY);
					maxY = nextY + lineHeight;
				}

				nextX += frame.width;
				(nextX > maxX) && (maxX = nextX);
			}

			assembledSprite = new BitmapData(maxX, maxY, true, 0x00000000);

			for (i = 0; i < l; i++)
			{
				frame = croppedBitmaps[i];
				assembledSprite.copyPixels(frame, frame.rect, framePos[i]);
				
				var tf : TextField = new TextField();
				tf.text = i.toString();
				tf.setTextFormat(new TextFormat("Arial", 20, 0xFF0000, true));
				var mtx : Matrix = new Matrix();
				mtx.translate(framePos[i].x + 2, framePos[i].y + 2);
				assembledSprite.draw(tf, mtx);
			}

			// 输出
			var outputBytes : ByteArray = new PNGEncoder().encode(assembledSprite);
			var fs : FileStream = new FileStream();
			fs.open(folder.resolvePath("sprite.png"), FileMode.WRITE);
			fs.writeBytes(outputBytes);
			fs.close();
		}

		private function writeConfigXML() : void
		{
			var xml : XML = <anime-desc>
					<size>{assembledSprite.width},{assembledSprite.height}</size>
					<frames/>
				</anime-desc>;

			var c : int = fileCount;
			for (var i : int = 0; i < c; i++)
			{
				var originalSize : Rectangle = originalBitmaps[i].rect;
				var framePos : Point = framePos[i];
				var cropBound : Rectangle = cropBounds[i];

				var frameBound : Rectangle = new Rectangle();
				frameBound.topLeft = framePos;
				frameBound.size = cropBound.size;

				var frameXML : XML = <frame/>;
				frameXML.appendChild(<reg-point>{Math.floor(originalSize.width / 2) - cropBound.x},{Math.floor(originalSize.height / 2) - cropBound.y}</reg-point>)
					.appendChild(<rect>{frameBound.x},{frameBound.y},{frameBound.width},{frameBound.height}</rect>);
				xml.frames.appendChild(frameXML);
			}

			var fs : FileStream = new FileStream();
			fs.open(folder.resolvePath("animeDesc.xml"), FileMode.WRITE);
			fs.writeMultiByte('<?xml version="1.0" encoding="utf-8"?>\n'
				+ xml.toXMLString(), "utf-8");
			fs.close();
		}
	}
}
