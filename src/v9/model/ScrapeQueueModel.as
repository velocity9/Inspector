package v9.model
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.events.SWFErrorEvent;
	import com.codeazur.as3swf.events.SWFProgressEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import v9.model.vo.EmbeddedSWFVO;

	public class ScrapeQueueModel extends AbstractDatabaseModel
	{
		[Inject]
		public var archiveModel:ArchiveModel;
		
		public var queue:ArrayCollection;
		
		protected var activeItem:EmbeddedSWFVO;
		protected var queueMap:Dictionary;
		
		public function ScrapeQueueModel()
		{
			super();
			queue = new ArrayCollection();
			queueMap = new Dictionary();
		}
		
		public function add(vo:EmbeddedSWFVO):void {
			if(queueMap[vo.swfUrl] == null) {
				queueMap[vo.swfUrl] = vo;
				queue.addItemAt(vo, 0);
				loadNext();
			} else {
				var voLoaded:EmbeddedSWFVO = EmbeddedSWFVO(queueMap[vo.swfUrl]);
				if(voLoaded.state == EmbeddedSWFVO.STATE_ERROR) {
					voLoaded.state = EmbeddedSWFVO.STATE_IDLE;
					loadNext();
				}
			}
		}
		
		public function loadNext():void {
			if(activeItem == null) {
				for(var i:int = queue.length - 1; i >= 0; --i) {
					var vo:EmbeddedSWFVO = EmbeddedSWFVO(queue.getItemAt(i));
					if(vo.state == EmbeddedSWFVO.STATE_IDLE) {
						load(vo);
						break;
					}
				}
			}
		}
		
		protected function load(vo:EmbeddedSWFVO):void {
			activeItem = vo;
			activeItem.state = EmbeddedSWFVO.STATE_LOADING;
			activeItem.bytesTotal = 0;
			activeItem.bytesLoaded = 0;
			var req:URLRequest = new URLRequest(vo.swfUrl);
			req.userAgent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.86 Safari/533.4";
			req.requestHeaders = [ new URLRequestHeader("Referer", activeItem.baseUrl) ];
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(req);
		}
		
		protected function loadProgressHandler(event:ProgressEvent):void {
			activeItem.bytesTotal = event.bytesTotal;
			activeItem.bytesLoaded = event.bytesLoaded;
		}
		
		protected function loadCompleteHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			removeLoadEventListeners(loader);
			activeItem.bytes = loader.data as ByteArray;
			var swf:SWF = new SWF();
			swf.addEventListener(SWFProgressEvent.PROGRESS, swfParseCompleteHandler);
			swf.addEventListener(SWFErrorEvent.ERROR, swfParseErrorHandler);
			try {
				swf.loadBytesAsync(activeItem.bytes);
			} catch(e:Error) {
				removeSWFParseEventListeners(swf);
				activeItem.state = EmbeddedSWFVO.STATE_ERROR;
				activeItem = null;
				loadNext();
			}
		}
		
		protected function loadErrorHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			removeLoadEventListeners(loader);
			activeItem.state = EmbeddedSWFVO.STATE_ERROR;
			activeItem = null;
			loadNext();
		}
		
		protected function swfParseCompleteHandler(event:SWFProgressEvent):void {
			event.preventDefault();
			var swf:SWF = SWF(event.target);
			removeSWFParseEventListeners(swf);
			activeItem.state = EmbeddedSWFVO.STATE_COMPLETE;
			activeItem.width = swf.frameSize.rect.width;
			activeItem.height = swf.frameSize.rect.height;
			activeItem.version = swf.version;
			activeItem.frameRate = swf.frameRate;
			activeItem.fileLength = swf.fileLength;
			activeItem.fileLengthCompressed = swf.fileLengthCompressed;
			//trace(activeItem.version, activeItem.width, activeItem.height, activeItem.frameRate, activeItem.fileLength, activeItem.fileLengthCompressed);
			archiveModel.add(activeItem);
			activeItem = null;
			loadNext();
		}
		
		protected function swfParseErrorHandler(event:SWFErrorEvent):void {
			var swf:SWF = SWF(event.target);
			removeSWFParseEventListeners(swf);
			activeItem.state = EmbeddedSWFVO.STATE_WARNING;
			activeItem = null;
			loadNext();
		}
		
		protected function removeSWFParseEventListeners(swf:SWF):void {
			swf.removeEventListener(SWFProgressEvent.PROGRESS, swfParseCompleteHandler);
			swf.removeEventListener(SWFErrorEvent.ERROR, swfParseErrorHandler);
		}
		
		protected function removeLoadEventListeners(loader:URLLoader):void {
			loader.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
			loader.removeEventListener(Event.COMPLETE, loadCompleteHandler);
		}
	}
}
