package v9.events
{
	import com.codeazur.as3swf.SWF;

	import flash.events.Event;
	
	public class SWFParseEvent extends Event
	{
		public static const PARSE:String = "swfParse";
		
		public static const HEADER:String = "swfParseHeader";
		public static const PROGRESS:String = "swfParseProgress";
		public static const COMPLETE:String = "swfParseComplete";

		public static const ASSETS_START:String = "swfParseAssetsStart";
		public static const ASSETS_PROGRESS:String = "swfParseAssetsProgress";
		public static const ASSETS_COMPLETE:String = "swfParseAssetsComplete";

		public var swf:SWF;
		public var url:String;
		public var progressPercent:Number;
		
		public function SWFParseEvent(type:String, swf:SWF, url:String, progressPercent:Number, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.swf = swf;
			this.url = url;
			this.progressPercent = progressPercent;
		}
		
		public override function clone():Event {
			return new SWFParseEvent(type, swf, url, progressPercent, bubbles, cancelable);
		}
		
		public override function toString():String {
			return "[SWFParseEvent type=\"" + type + "\"]";
		}
	}
}
