package v9.model.swf.events
{
	import flash.events.Event;

	public class SWFAssetCreationEvent extends Event
	{
		public static const START:String = "assetCreationStart";
		public static const PROGRESS:String = "assetCreationProgress";
		public static const COMPLETE:String = "assetCreationComplete";
		
		protected var processed:uint;
		protected var total:uint;
		
		public function SWFAssetCreationEvent(type:String, processed:uint = 0, total:uint = 0, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.processed = processed;
			this.total = total;
		}
		
		public function get progress():Number {
			return (processed > 0 && total > 0) ? processed / total : 0;
		}
		
		public function get progressPercent():Number {
			return Math.round(progress * 100);
		}
		
		override public function clone():Event {
			return new SWFAssetCreationEvent(type, processed, total, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[SWFAssetCreationEvent] processed: " + processed + ", total: " + total + " (" + progressPercent + "%)";
		}
	}
}
