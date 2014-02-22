package v9.view.events
{
	import flash.events.Event;

	public class FrameNumberEvent extends Event
	{
		public static const CHANGE:String = "frameNumberChange";
		
		public var frameNumber:uint;
		
		public function FrameNumberEvent(type:String, frameNumber:uint, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.frameNumber = frameNumber;
		}
		
		public override function clone():Event
		{
			return new FrameNumberEvent(type, frameNumber, bubbles, cancelable);
		}
	}
}
