package v9.view.components
{
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.PopupEvent;
	import v9.events.SWFEvent;
	import v9.events.UpdaterEvent;
	import v9.view.popups.AppUpdateLoaderProgressPopup;


	
	public class HeaderMediator extends Mediator
	{
		[Inject]
		public var header:Header;
		
		public function HeaderMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, UpdaterEvent.UPDATE_AVAILABLE, updateAvailableHandler);
			eventMap.mapListener(header.loadButton, MouseEvent.CLICK, loadButtonClickHandler);
			eventMap.mapListener(header.updateButton, MouseEvent.CLICK, updateButtonClickHandler);
		}
		
		public override function onRemove():void
		{
			eventMap.unmapListener(eventDispatcher, UpdaterEvent.UPDATE_AVAILABLE, updateAvailableHandler);
			eventMap.unmapListener(header.loadButton, MouseEvent.CLICK, loadButtonClickHandler);
			eventMap.unmapListener(header.updateButton, MouseEvent.CLICK, updateButtonClickHandler);
		}
		
		protected function loadButtonClickHandler(event:MouseEvent):void
		{
			dispatch(new SWFEvent(SWFEvent.BROWSE));
		}

		private function updateButtonClickHandler(event:MouseEvent):void
		{
			dispatch(new PopupEvent(PopupEvent.OPEN, new AppUpdateLoaderProgressPopup()));
			dispatch(new UpdaterEvent(UpdaterEvent.UPDATE_DOWNLOAD));
		}

		private function updateAvailableHandler(event:UpdaterEvent):void
		{
			header.updateButton.visible = header.updateButton.includeInLayout = true;
		}
	}
}
