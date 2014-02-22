package v9.controller
{
	import v9.events.PopupEvent;
	
	import mx.managers.PopUpManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class ClosePopupCommand extends Command
	{
		[Inject]
		public var event:PopupEvent;
		
		override public function execute():void
		{
			PopUpManager.removePopUp(event.popup);
			mediatorMap.removeMediatorByView(event.popup);
		}
	}
}