package v9.view.events
{
	import flash.events.Event;

	public class HTMLHostEvent extends Event
	{
		public static const CREATE_WINDOW:String = "createWindow";
		public static const UPDATE_LOCATION:String = "updateLocation";
		public static const UPDATE_STATUS:String = "updateStatus";
		public static const UPDATE_TITLE:String = "updateTitle";
		public static const WINDOW_BLUR:String = "windowBlur";
		public static const WINDOW_CLOSE:String = "windowClose";
		public static const WINDOW_FOCUS:String = "windowFocus";

		public var payload:Object;
		
		public function HTMLHostEvent(type:String, payload:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.payload = payload;
		}
		
		public override function clone():Event {
			return new HTMLHostEvent(type, payload, bubbles, cancelable);
		}
		
		public override function toString():String {
			return "[HTMLHostEvent] type: " + type + ", payload: " + payload;
		}
	}
}