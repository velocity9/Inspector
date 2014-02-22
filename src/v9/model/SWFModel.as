package v9.model
{
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.events.SWFErrorEvent;
	import com.codeazur.as3swf.events.SWFProgressEvent;
	import com.codeazur.fzip.FZip;
	import com.codeazur.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import org.robotlegs.mvcs.Actor;
	
	import v9.events.PopupEvent;
	import v9.events.SWFParseEvent;
	import v9.model.swf.V9SWF;
	import v9.model.swf.events.SWFAssetCreationEvent;
	import v9.view.popups.ParseSWFProgressPopup;
	
	public class SWFModel extends Actor
	{
		public var swf:V9SWF;
		public var url:String;
		
		public function SWFModel()
		{
			super();
		}
		
		public function browse():void {
			var file:File;
			var so:SharedObject = SharedObject.getLocal("Velocity9");
			if (so && so.data && so.data.swfDirectory) {
				file = new File(so.data.swfDirectory);
			} else {
				file = File.documentsDirectory;
			}
			file.addEventListener(Event.SELECT, function(event:Event):void { load(file); });
			file.browseForOpen("Load SWF or SWC", [new FileFilter("SWF", "*.swf"), new FileFilter("SWC", "*.swc")]);
		}
		
		public function load(file:File):void {
			var folder:File = file.parent;
			var so:SharedObject = SharedObject.getLocal("Velocity9");
			so.data.swfDirectory = folder.nativePath;
			so.flush();
			var ba:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			url = file.nativePath;
			stream.open(file, FileMode.READ);
			stream.readBytes(ba);
			stream.close();
			if(checkSWFSignature(ba)) {
				parse(ba);
			} else {
				try {
					var zip:FZip = new FZip();
					zip.loadBytes(ba);
					var zipFile:FZipFile = zip.getFileByName("library.swf");
					if(zipFile != null && zipFile.sizeUncompressed > 0) {
						parse(zipFile.content);
					} else {
						trace("###ERROR### library.swf not found or empty");
					}
				} catch(e:Error) {
					trace("###ERROR###", e);
				}
			}
		}
		
		public function parse(ba:ByteArray):void {
			createSWFObject();
			swf.loadBytesAsync(ba);
			dispatch(new PopupEvent(PopupEvent.OPEN, new ParseSWFProgressPopup()));
		}
		
		protected function swfParseProgressHandler(event:SWFProgressEvent):void {
			dispatch(new SWFParseEvent(SWFParseEvent.PROGRESS, swf, url, event.progressPercent));
		}
		
		protected function swfParseCompleteHandler(event:SWFProgressEvent):void {
		}
		
		protected function swfAssetCreationStartHandler(event:SWFAssetCreationEvent):void {
			dispatch(new SWFParseEvent(SWFParseEvent.ASSETS_START, swf, url, event.progressPercent));
		}
		
		protected function swfAssetCreationProgressHandler(event:SWFAssetCreationEvent):void {
			dispatch(new SWFParseEvent(SWFParseEvent.ASSETS_PROGRESS, swf, url, event.progressPercent));
		}
		
		protected function swfAssetCreationCompleteHandler(event:SWFAssetCreationEvent):void {
			dispatch(new SWFParseEvent(SWFParseEvent.ASSETS_COMPLETE, swf, url, event.progressPercent));
			dispatch(new SWFParseEvent(SWFParseEvent.COMPLETE, swf, url, 100));
		}
		
		protected function swfParseErrorHandler(event:SWFErrorEvent):void {
			trace("###ERROR###", event);
		}
		
		protected function createSWFObject():void {
			if(swf) {
				swf.removeEventListener(SWFProgressEvent.PROGRESS, swfParseProgressHandler);
				swf.removeEventListener(SWFProgressEvent.COMPLETE, swfParseCompleteHandler);
				swf.removeEventListener(SWFAssetCreationEvent.START, swfAssetCreationStartHandler);
				swf.removeEventListener(SWFAssetCreationEvent.PROGRESS, swfAssetCreationProgressHandler);
				swf.removeEventListener(SWFAssetCreationEvent.COMPLETE, swfAssetCreationCompleteHandler);
				swf.removeEventListener(SWFErrorEvent.ERROR, swfParseErrorHandler);
				swf.unloadAssets();
			}
			swf = new V9SWF();
			swf.addEventListener(SWFProgressEvent.PROGRESS, swfParseProgressHandler);
			swf.addEventListener(SWFProgressEvent.COMPLETE, swfParseCompleteHandler);
			swf.addEventListener(SWFAssetCreationEvent.START, swfAssetCreationStartHandler);
			swf.addEventListener(SWFAssetCreationEvent.PROGRESS, swfAssetCreationProgressHandler);
			swf.addEventListener(SWFAssetCreationEvent.COMPLETE, swfAssetCreationCompleteHandler);
			swf.addEventListener(SWFErrorEvent.ERROR, swfParseErrorHandler);
			SWFTimelineContainer.EXTRACT_SOUND_STREAM = true;
			SWFTimelineContainer.AUTOBUILD_LAYERS = true;
			SWFTimelineContainer.TIMEOUT = 20;
		}
		
		protected function checkSWFSignature(ba:ByteArray):Boolean
		{
			if (ba[0] != 0x43 && ba[0] != 0x46 && ba[0] != 0x5a) {
				return false;
			}
			if (ba[1] != 0x57) {
				return false;
			}
			if (ba[2] != 0x53) {
				return false;
			}
			return true;
		}
	}
}
