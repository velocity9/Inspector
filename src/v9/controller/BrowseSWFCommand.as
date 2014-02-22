package v9.controller
{
	import v9.model.SWFModel;
	
	import org.robotlegs.mvcs.Command;
	
	public class BrowseSWFCommand extends Command
	{
		[Inject]
		public var model:SWFModel;
		
		override public function execute():void {
			model.browse();
		}
	}
}