package v9.events
{
	import flash.events.Event;
	
	public class SWFEvent extends Event
	{
		public static const BROWSE:String = "swfBrowse";
		public static const LOAD:String = "swfLoad";
		
		public static const LOADING:String = "swfLoading";
		public static const LOADED:String = "swfLoaded";

		public var url:String;
		
		public function SWFEvent(type:String, url:String = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.url = url;
		}
		
		public override function clone():Event {
			return new SWFEvent(type, url, bubbles, cancelable);
		}
		
		public override function toString():String {
			return "[SWFEvent type=\"" + type + "\"] " + url
		}
	}
}
