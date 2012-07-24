import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.NativeDragEvent;
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
import mx.graphics.codec.PNGEncoder;
import mx.managers.DragManager;

import spark.collections.Sort;

import statm.dev.spritebuilder.AppState;

private function init() : void
{
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;

	var folder : File = new File("C:\\Users\\Administrator\\Desktop\\input");
	this.currentState = "loading";
	AppState.reset();
	startLoading(folder);
}

protected function app_nativeDragEnterHandler(event : NativeDragEvent) : void
{
	if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
	{
		var fileArray : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
		if (fileArray.length == 1
			&& fileArray[0] is File
			&& fileArray[0].isDirectory)
		{
			DragManager.acceptDragDrop(this);
		}
	}
}

protected function app_nativeDragDropHandler(event : NativeDragEvent) : void
{
	this.currentState = "loading";
	var folder : File = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT)[0];
	AppState.reset();
	startLoading(folder);
}

private function startLoading(folder : File) : void
{
	AppState.folder = folder;

	var fileArray : Array = filterFiles(folder);
	AppState.files = new ArrayCollection(fileArray);

	var sort : Sort = new Sort();
	sort.compareFunction = compareFiles;
	AppState.files.sort = sort;
	AppState.files.refresh();

	var count : int = AppState.fileCount = fileArray.length;

	AppState.originalBitmaps = new Vector.<BitmapData>(count, true);
	AppState.cropBounds = new Vector.<Rectangle>(count, true);
	AppState.croppedBitmaps = new Vector.<BitmapData>(count, true);

	loadBitmaps();
}

private function filterFiles(folder : File) : Array
{
	var files : Array = folder.getDirectoryListing();
	var i : int = files.length;
	while (--i > -1)
	{
		isValidImageFile(files[i]) || files.splice(i, 1);
	}

	return files;
}

private function isValidImageFile(file : File) : Boolean
{
	var acceptedExt : Array = ["jpg", "jpeg", "bmp", "png"];

	var fileName : String = file.name.split(".")[0];
	var l : int = fileName.length;
	for (var i : int = 0; i < l; i++)
	{
		if (fileName.charCodeAt(i) < "0".charCodeAt()
			|| fileName.charCodeAt(i) > "9".charCodeAt())
		{
			return false;
		}
	}

	return acceptedExt.indexOf(file.extension) > -1;
}

private function compareFiles(a : Object, b : Object, fields : Array) : int
{
	var id1 : int = parseInt(a.name.split(".")[0]);
	var id2 : int = parseInt(b.name.split(".")[0]);

	if (id1 > id2)
	{
		return 1;
	}
	else if (id1 == id2)
	{
		return 0;
	}
	else
	{
		return -1;
	}
}

private var bitmapLoader : Loader;

private var loadingIndex : int = -1;

private function loadBitmaps() : void
{
	bitmapLoader = new Loader();
	bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_next);
	loader_next();
}

private function loader_next(event : Event = null) : void
{
	if (event)
	{
		var bitmapData : BitmapData = Bitmap(bitmapLoader.content).bitmapData;
		AppState.originalBitmaps[loadingIndex] = bitmapData;

		var bound : Rectangle = bitmapData.getColorBoundsRect(0xFF000000, 0x000000, false);
		AppState.cropBounds[loadingIndex] = bound;

		var cropped : BitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
		cropped.copyPixels(bitmapData, bound, new Point(0, 0));
		AppState.croppedBitmaps[loadingIndex] = cropped;
	}
	loadingIndex++;
	loadingProgBar.setProgress(loadingIndex + 1, AppState.fileCount);
	if (loadingIndex < AppState.files.length)
	{
		bitmapLoader.load(new URLRequest(AppState.files[loadingIndex].url));
	}
	else
	{
		assembleSprite();
		writeConfigXML();

		this.currentState = "config";
		AppState.currentFrameIndex = 0;
		AppState.currentBitmapData = AppState.originalBitmaps[0];
	}
}

private function assembleSprite() : void
{
	var MAX_WIDTH : int = 3000;
	var nextX : int = 0, nextY : int = 0, lineHeight : int = 0, maxX : int = 0, maxY : int = 0;
	var framePos : Vector.<Point> = AppState.framePos = new Vector.<Point>(AppState.fileCount, true);

	var i : int;
	var l : int = AppState.fileCount;
	var frame : BitmapData;
	for (i = 0; i < l; i++)
	{
		frame = AppState.croppedBitmaps[i];

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

	var result : BitmapData = new BitmapData(maxX, maxY, true, 0x00000000);

	for (i = 0; i < l; i++)
	{
		frame = AppState.croppedBitmaps[i];
		result.copyPixels(frame, frame.rect, framePos[i]);
		var tf : TextField = new TextField();
		tf.text = i.toString();
		tf.setTextFormat(new TextFormat("Arial", 20, 0xFF0000, true));
		var mtx : Matrix = new Matrix();
		mtx.translate(framePos[i].x + 2, framePos[i].y + 2);
		result.draw(tf, mtx);
	}

	// 输出
	var outputBytes : ByteArray = new PNGEncoder().encode(result);
	var fs : FileStream = new FileStream();
	fs.open(AppState.folder.resolvePath("sprite.png"), FileMode.WRITE);
	fs.writeBytes(outputBytes);
	fs.close();

	AppState.assembledSprite = result;
}

private function writeConfigXML() : void
{
	var xml : XML = <anime-desc>
			<size>{AppState.assembledSprite.width},{AppState.assembledSprite.height}</size>
			<frames/>
		</anime-desc>;

	var c : int = AppState.fileCount;
	for (var i : int = 0; i < c; i++)
	{
		var originalSize : Rectangle = AppState.originalBitmaps[i].rect;
		var framePos : Point = AppState.framePos[i];
		var cropBound : Rectangle = AppState.cropBounds[i];

		var frameBound : Rectangle = new Rectangle();
		frameBound.topLeft = framePos;
		frameBound.size = cropBound.size;

		var frameXML : XML = <frame/>;
		frameXML.appendChild(<reg-point>{Math.floor(originalSize.width / 2) - cropBound.x},{Math.floor(originalSize.height / 2) - cropBound.y}</reg-point>)
			.appendChild(<rect>{frameBound.x},{frameBound.y},{frameBound.width},{frameBound.height}</rect>);
		xml.frames.appendChild(frameXML);
	}

	var fs : FileStream = new FileStream();
	fs.open(AppState.folder.resolvePath("animeDesc.xml"), FileMode.WRITE);
	fs.writeMultiByte('<?xml version="1.0" encoding="utf-8"?>\n'
		+ xml.toXMLString(), "utf-8");
	fs.close();
}

private function enterFrameHandler(event : Event) : void
{
	if (AppState.playStatus != 0)
	{
		AppState.currentFrameIndex += AppState.playStatus;
	}
}
