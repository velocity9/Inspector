package v9.view.browser.html
{
	import v9.view.events.HTMLHostEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.html.HTMLHost;
	import flash.html.HTMLLoader;
	import flash.html.HTMLWindowCreateOptions;
	
	import mx.controls.HTML;
	
	public class CustomHTMLHost extends HTMLHost implements IEventDispatcher
	{
		protected var dispatcher:IEventDispatcher;
		
		public function CustomHTMLHost(defaultBehaviors:Boolean = true)
		{
			super(defaultBehaviors);
			dispatcher = new EventDispatcher(this);
		}
		
		override public function createWindow(windowCreateOptions:HTMLWindowCreateOptions):HTMLLoader {
			var loader:HTMLLoader = new HTMLLoader();
			var host:CustomHTMLHost = new CustomHTMLHost();
			host.addEventListener(HTMLHostEvent.UPDATE_LOCATION, function(event:HTMLHostEvent):void {
				loader.cancelLoad();
				loader.htmlHost = null
				dispatchEvent(new HTMLHostEvent(HTMLHostEvent.CREATE_WINDOW, event.payload));
			}, false, 0, true);
			loader.htmlHost = host; 
			return loader;
		}
		
		override public function updateLocation(locationURL:String):void {
			if(locationURL == "app:/") { locationURL = ""; }
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.UPDATE_LOCATION, locationURL));
		}
		
		override public function updateStatus(status:String):void {
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.UPDATE_STATUS, status));
		}
		
		override public function updateTitle(title:String):void {
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.UPDATE_TITLE, title));
		}
		
		override public function windowBlur():void {
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.WINDOW_BLUR));
		}
		
		override public function windowClose():void {
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.WINDOW_CLOSE));
		}
		
		override public function windowFocus():void {
			dispatchEvent(new HTMLHostEvent(HTMLHostEvent.WINDOW_FOCUS));
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
	}
}
