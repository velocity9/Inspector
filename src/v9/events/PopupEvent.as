package v9.events
{
	import flash.events.Event;
	
	import mx.core.IFlexDisplayObject;
	
	public class PopupEvent extends Event
	{
		public static const OPEN:String = "popupOpen";
		public static const CLOSE:String = "popupClose";

		public var popup:IFlexDisplayObject;
		public var data:Object;
		
		public function PopupEvent(type:String, popup:IFlexDisplayObject, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.popup = popup;
			this.data = data;
		}
		
		public override function clone():Event {
			return new PopupEvent(type, popup, data, bubbles, cancelable);
		}
		
		public override function toString():String {
			return "[PopupEvent type=\"" + type + "\"] " + popup;
		}
	}
}
