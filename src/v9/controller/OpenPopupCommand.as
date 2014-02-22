package v9.controller
{
	import v9.events.PopupEvent;
	import v9.view.popups.IPopupMediator;

	import org.robotlegs.mvcs.Command;

	import mx.managers.PopUpManager;
	
	public class OpenPopupCommand extends Command
	{
		[Inject]
		public var event:PopupEvent;
		
		override public function execute():void
		{
			PopUpManager.addPopUp(event.popup, contextView, true);
			PopUpManager.centerPopUp(event.popup);
			var mediator:IPopupMediator = mediatorMap.createMediator(event.popup) as IPopupMediator;
			if(mediator) {
				mediator.data = event.data;
			}
		}
	}
}