package v9.view.browser.html
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import mx.core.FlexHTMLLoader;
	
	public class FlexHTMLLoaderExt extends FlexHTMLLoader
	{
		protected var tmpLoader:URLLoader;
		protected var tmpRequest:URLRequest;
		protected var tmpRequestMethod:String;
		protected var tmpFollowRedirects:Boolean;
		
		public function FlexHTMLLoaderExt()
		{
			super();
		}
		
		override public function load(urlRequestToLoad:URLRequest):void {
			createLoader();
			tmpRequest = urlRequestToLoad;
			tmpRequestMethod = urlRequestToLoad.method;
			tmpFollowRedirects = urlRequestToLoad.followRedirects;
			urlRequestToLoad.followRedirects = false;
			urlRequestToLoad.method = URLRequestMethod.HEAD;
			urlRequestToLoad.requestHeaders = [ new URLRequestHeader("Referer", urlRequestToLoad.url) ];
			urlRequestToLoad.userAgent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.86 Safari/533.4";
			tmpLoader.load(urlRequestToLoad);
		}
		
		protected function httpResponseHandler(event:HTTPStatusEvent):void {
			killLoader();
			dispatchEvent(event.clone());
			if(event.status >= 400) {
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			} else {
				tmpRequest.method = tmpRequestMethod;
				tmpRequest.followRedirects = tmpFollowRedirects;
				super.load(tmpRequest);
			}
		}
		
		protected function errorHandler(event:Event):void {
			killLoader();
			dispatchEvent(event.clone());
		}
		
		protected function createLoader():void {
			killLoader();
			tmpLoader = new URLLoader();
			tmpLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			tmpLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			tmpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
		
		protected function killLoader():void {
			if(tmpLoader != null) {
				tmpLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
				tmpLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				tmpLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				try { tmpLoader.close(); } catch(e:Error) {}
				tmpLoader = null;
			}
		}
	}
}
