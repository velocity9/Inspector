package v9.view.popups
{
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.PopupEvent;
	import v9.events.SWFParseEvent;
	import v9.events.UpdaterEvent;
	
	
	public class AppUpdateLoaderProgressPopupMediator extends Mediator implements IPopupMediator
	{
		private var _data:Object;
		
		[Inject]
		public var popup:AppUpdateLoaderProgressPopup;
		
		public function AppUpdateLoaderProgressPopupMediator()
		{
			super();
		}
		
		public override function onRegister():void {
			eventMap.mapListener(eventDispatcher, UpdaterEvent.UPDATE_DOWNLOAD_PROGRESS, progressHandler);
			eventMap.mapListener(eventDispatcher, UpdaterEvent.UPDATE_DOWNLOAD_COMPLETE, completeHandler);
		}
		
		public override function onRemove():void {
			eventMap.unmapListener(eventDispatcher, UpdaterEvent.UPDATE_DOWNLOAD_PROGRESS, progressHandler);
			eventMap.unmapListener(eventDispatcher, UpdaterEvent.UPDATE_DOWNLOAD_COMPLETE, completeHandler);
		}

		protected function progressHandler(event:UpdaterEvent):void {
			popup.progress = event.progressPercent;
		}
		
		protected function completeHandler(event:UpdaterEvent):void {
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
