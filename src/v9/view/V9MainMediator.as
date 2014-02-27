package v9.view
{
	import flash.events.InvokeEvent;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.WindowedApplication;
	
	import v9.events.SWFEvent;
	import v9.events.SWFParseEvent;
	import v9.events.SetMainViewEvent;
	import v9.model.swf.V9SWF;
	
	public class V9MainMediator extends Mediator
	{
		[Inject]
		public var main:V9Main;
		
		private var firstArgument:String;
		
		public function V9MainMediator()
		{
			super();
			firstArgument = null;
		}
		
		override public function onRegister():void {
			eventMap.mapListener(WindowedApplication(FlexGlobals.topLevelApplication), InvokeEvent.INVOKE, invokeHandler);
			eventMap.mapListener(eventDispatcher, SWFParseEvent.COMPLETE, swfParseCompleteHandler);
			eventMap.mapListener(eventDispatcher, SetMainViewEvent.SWITCH, switchViewHandler);
		}
		
		override public function onRemove():void {
			eventMap.unmapListener(WindowedApplication(FlexGlobals.topLevelApplication), InvokeEvent.INVOKE, invokeHandler);
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.COMPLETE, swfParseCompleteHandler);
			eventMap.unmapListener(eventDispatcher, SetMainViewEvent.SWITCH, switchViewHandler);
		}
		
		private function invokeHandler(event:InvokeEvent):void {
			if (event.arguments.length > 0) {
				if (firstArgument == null) {
					firstArgument = event.arguments[0];
					if (firstArgument && firstArgument.length > 0) {
						dispatch(new SWFEvent(SWFEvent.LOAD, firstArgument));
						setTimeout(function():void {
							firstArgument = null;
						}, 200);
					}
				}
			}
		}
		
		private function swfParseCompleteHandler(event:SWFParseEvent):void {
			main.showFooter = true;
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
