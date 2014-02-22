package v9.view.browser
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.TabBar;

	[Event(name="addTab", type="flash.events.Event")]
	
	public class BrowserTabBar extends TabBar
	{
		[SkinPart(required="true")]
		public var addTabButton:Button;
		
		public function BrowserTabBar()
		{
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch(partName) {
				case "addTabButton":
					addTabButton.addEventListener(MouseEvent.CLICK, addTabButtonClickHandler);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			switch(partName) {
				case "addTabButton":
					addTabButton.removeEventListener(MouseEvent.CLICK, addTabButtonClickHandler);
					break;
			}
		}
		
		protected function addTabButtonClickHandler(event:MouseEvent):void {
			dispatchEvent(new Event("addTab"));
		}
	}
}
