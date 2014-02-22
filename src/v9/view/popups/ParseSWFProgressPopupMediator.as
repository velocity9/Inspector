package v9.view.popups
{
	import org.robotlegs.mvcs.Mediator;
	import v9.events.PopupEvent;
	import v9.events.SWFParseEvent;
	
	
	public class ParseSWFProgressPopupMediator extends Mediator implements IPopupMediator
	{
		private var _data:Object;
		
		[Inject]
		public var popup:ParseSWFProgressPopup;
		
		public function ParseSWFProgressPopupMediator()
		{
			super();
		}
		
		public override function onRegister():void {
			eventMap.mapListener(eventDispatcher, SWFParseEvent.PROGRESS, progressHandler);
			eventMap.mapListener(eventDispatcher, SWFParseEvent.COMPLETE, completeHandler);
			eventMap.mapListener(eventDispatcher, SWFParseEvent.ASSETS_START, assetsStartHandler);
			eventMap.mapListener(eventDispatcher, SWFParseEvent.ASSETS_PROGRESS, progressHandler);
			eventMap.mapListener(eventDispatcher, SWFParseEvent.ASSETS_COMPLETE, progressHandler);
		}
		
		public override function onRemove():void {
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.PROGRESS, progressHandler);
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.COMPLETE, completeHandler);
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.ASSETS_START, assetsStartHandler);
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.ASSETS_PROGRESS, progressHandler);
			eventMap.unmapListener(eventDispatcher, SWFParseEvent.ASSETS_COMPLETE, progressHandler);
		}

		protected function progressHandler(event:SWFParseEvent):void {
			popup.progress = event.progressPercent;
		}
		
		private function assetsStartHandler(event:SWFParseEvent):void {
			popup.title = "Processing SWF ...";
		}
		
		protected function completeHandler(event:SWFParseEvent):void {
			popup.progress = 100;
			dispatch(new PopupEvent(PopupEvent.CLOSE, popup));
		}

		public function get data():Object {
			return _data;
		}
		public function set data(data:Object):void {
			_data = data;
		}
	}
}
