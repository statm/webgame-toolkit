package statm.dev.imageresourceviewer.data.io
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	
	import statm.dev.imageresourceviewer.data.Action;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
	import statm.dev.imageresourceviewer.data.type.DirectionType;
	import statm.dev.libs.imageplayer.loader.ImageBatchEvent;
	import statm.dev.libs.imageplayer.loader.ImageBatchState;

	/**
	 * Spritesheet 拼合输出工具类。
	 *
	 * @author statm
	 *
	 */
	public class SpritesheetWriter
	{
		public function writeActionSpritesheet(action : Action, path : File) : void
		{
			var originalImages : Vector.<BitmapData>;

			var unloadedBatchCount : int = action.batchCount;
			var unloadedBatches : Array = [];

			for each (var direction : String in DirectionType.directionList)
			{
				var batch : ResourceBatch = action.getBatch(direction);

				if (!batch
					|| batch.batchState == ImageBatchState.COMPLETE
					|| batch.batchState == ImageBatchState.LOADING)
				{
					unloadedBatchCount--;
				}
				else
				{
					batch.addEventListener(ImageBatchEvent.COMPLETE,
						function(event : ImageBatchEvent) : void
						{
							event.currentTarget.removeEventListener(ImageBatchEvent.COMPLETE, arguments.callee);
							--unloadedBatchCount;

							if (unloadedBatchCount == 0)
							{
								originalImages = action.getAllImages();

								$writeActionSpritesheet(originalImages, action, path);
								for each (var batch : ResourceBatch in unloadedBatches)
								{
									batch.unload();
								}
							}
						});

					unloadedBatches.push(batch);
					batch.load();
				}
			}

			if (unloadedBatchCount == 0)
			{
				originalImages = action.getAllImages();

				$writeActionSpritesheet(originalImages, action, path);
			}
		}

		private function $writeActionSpritesheet(originalImages : Vector.<BitmapData>, action:Action, path : File) : void
		{
			var assembledSpritesheet : BitmapData;
			var configXML : XML;

			var l : int = originalImages.length;
			var i : int;
			var frame : BitmapData;
			var totalSize : int = 0;

			var croppedImages : Vector.<BitmapData> = new Vector.<BitmapData>(l, true);
			var cropBounds : Vector.<Rectangle> = new Vector.<Rectangle>(l, true);

			// 图片切割
			for (i = 0; i < l; i++)
			{
				var image : BitmapData = originalImages[i];

				if (image)
				{
					var bound : Rectangle = image.getColorBoundsRect(0xFF000000, 0x000000, false);
					cropBounds[i] = bound;
	
					if (!bound.isEmpty())
					{
						var cropped : BitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
						cropped.copyPixels(image, bound, new Point(0, 0));
						croppedImages[i] = cropped;
					}
					totalSize += bound.width * bound.height;
				}
			}

			// Spritesheet 拼合
			var MAX_WIDTH : int = Math.sqrt(totalSize);
			var nextX : int = 0, nextY : int = 0, lineHeight : int = 0, maxX : int = 0, maxY : int = 0;
			var framePos : Vector.<Point> = new Vector.<Point>(croppedImages.length, true);


			for (i = 0; i < l; i++)
			{
				frame = croppedImages[i];

				if (frame)
				{
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
			}

			assembledSpritesheet = new BitmapData(maxX, maxY, true, 0x00000000);

			for (i = 0; i < l; i++)
			{
				(frame = croppedImages[i]) && assembledSpritesheet.copyPixels(frame, frame.rect, framePos[i]);

					// DBG
				if (!frame) continue;
				
//				var tf : TextField = new TextField();
//				tf.text = i.toString();
//				tf.setTextFormat(new TextFormat("Arial", 20, 0xFF0000, true));
//				var mtx : Matrix = new Matrix();
//				mtx.translate(framePos[i].x + 2, framePos[i].y + 2);
//				assembledSpritesheet.draw(tf, mtx);
			}

			var spritesheetImageByteArray : ByteArray = new PNGEncoder().encode(assembledSpritesheet);
			var fs : FileStream = new FileStream();
			fs.open(path.resolvePath(action.name + ".png"), FileMode.WRITE);
			fs.writeBytes(spritesheetImageByteArray);
			fs.close();

			// 输出配置 XML
			configXML = <anime-desc>
					<size>{assembledSpritesheet.width},{assembledSpritesheet.height}</size>
					<frameRate>{action.frameRate}</frameRate>
					<frames/>
				</anime-desc>;

			for (i = 0; i < l; i++)
			{
				if (originalImages[i])
				{
					var originalSize : Rectangle = originalImages[i].rect;
					var cropBound : Rectangle = cropBounds[i];
	
					if (!cropBound.isEmpty())
					{
						var frameBound : Rectangle = new Rectangle();
						frameBound.topLeft = framePos[i];
						frameBound.size = cropBound.size;
		
						var frameXML : XML = <frame/>;
						frameXML.appendChild(<reg-point>{Math.floor(originalSize.width / 2) - cropBound.x},{Math.floor(originalSize.height / 2) - cropBound.y}</reg-point>)
							.appendChild(<rect>{frameBound.x},{frameBound.y},{frameBound.width},{frameBound.height}</rect>);
		
						configXML.frames.appendChild(frameXML);
					}
					else
					{
						configXML.frames.appendChild(<frame empty="true"/>);
					}
				}
				else
				{
					configXML.frames.appendChild(<frame empty="true"/>);
				}
			}

			fs.open(path.resolvePath(action.name + ".xml"), FileMode.WRITE);
			fs.writeMultiByte('<?xml version="1.0" encoding="utf-8"?>\n'
				+ configXML.toXMLString(), "utf-8");
			fs.close();

			assembledSpritesheet.dispose();
			for each (var bd : BitmapData in croppedImages)
			{
				bd && bd.dispose();
			}
		}

		private static var id : int = 0;
	}
}
