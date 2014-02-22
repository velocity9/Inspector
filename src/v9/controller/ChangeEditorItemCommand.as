package v9.controller
{
	import v9.events.V9EditorViewEvent;
	import v9.model.V9EditorViewModel;

	import org.robotlegs.mvcs.Command;

	public class ChangeEditorItemCommand extends Command
	{
		[Inject]
		public var event:V9EditorViewEvent;
		
		[Inject]
		public var model:V9EditorViewModel;
		
		override public function execute():void
		{
			model.activeItem = event.item;
		}
	}
}
