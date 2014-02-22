package v9.controller
{
	import v9.events.SWFEvent;
	import v9.model.SWFModel;
	
	import flash.filesystem.File;
	
	import org.robotlegs.mvcs.Command;
	
	public class LoadSWFCommand extends Command
	{
		[Inject]
		public var event:SWFEvent;
		
		[Inject]
		public var model:SWFModel;
		
		override public function execute():void {
			var file:File = new File(event.url);
			if(file && file.exists && !file.isDirectory) {
				model.load(file);
			}
		}
	}
}