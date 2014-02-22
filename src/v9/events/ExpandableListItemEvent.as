package v9.events
{
	import flash.events.Event;
	
	public class ExpandableListItemEvent extends Event
	{
		public static const EXPANDABLE_LIST_ITEM_TOGGLE:String = "expandableListItemToggle";
		
		public var item:Object;
		
		public function ExpandableListItemEvent(type:String, item:Object, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
		override public function clone():Event {
			return new ExpandableListItemEvent(type, item, bubbles, cancelable);
		}
	}
}