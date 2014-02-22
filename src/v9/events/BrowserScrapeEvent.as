package v9.events
{
	import flash.events.Event;
	
	public class BrowserScrapeEvent extends Event
	{
		public static const SCRAPE:String = "browserScrape";
		
		public var domWindow:Object;
		
		public function BrowserScrapeEvent(type:String, domWindow:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.domWindow = domWindow;
		}
	}
}