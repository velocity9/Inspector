package v9.view.events
{
	import flash.events.Event;

	public class BrowserTabEvent extends Event
	{
		public static const SCRAPE:String = "scrape";
		public static const ADD_TAB:String = "addTab";

		public var url:String;
		public var payload:Object;
		
		public function BrowserTabEvent(type:String, url:String = null, payload:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.url = url;
			this.payload = payload;
		}
		
		public override function clone():Event {
			return new BrowserTabEvent(type, url, payload, bubbles, cancelable);
		}
		
		public override function toString():String {
			return "[BrowserTabEvent] type: " + type + ", url: " + url;
		}
	}
}