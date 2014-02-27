package v9.view
{
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.SWFParseEvent;
	import v9.events.SetMainViewEvent;
	import v9.model.swf.V9SWF;
	
	public class V9MainMediator extends Mediator
	{
		[Inject]
		public var main:V9Main;
		
		public function V9MainMediator()
		{
			super();
		}
		
		override public function onRegister():void {
			eventMap.mapListener(eventDispatcher, SWFParseEvent.COMPLETE, swfParseCompleteHandler);
			eventMap.mapListener(eventDispatcher, SetMainViewEvent.SWITCH, switchViewHandler);
		}
		
		override public function onRemove():void {
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.COMPLETE, swfParseCompleteHandler);
			eventMap.unmapListener(eventDispatcher, SetMainViewEvent.SWITCH, switchViewHandler);
		}

		private function swfParseCompleteHandler(event:SWFParseEvent):void {
			main.mainContentStack.selectedIndex = 1;
			main.viewEditor.swf = event.swf as V9SWF;
			main.viewEditor.url = event.url;
			main.viewEditor.mainPanel.visible = false;
		}

		private function switchViewHandler(event:SetMainViewEvent):void {
			main.mainContentStack.selectedIndex = event.index;
		}
	}
}
