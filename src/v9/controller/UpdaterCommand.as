package v9.controller
{
	import v9.events.UpdaterEvent;
	import v9.model.UpdaterModel;

	import org.robotlegs.mvcs.Command;

	public class UpdaterCommand extends Command
	{
		[Inject]
		public var event:UpdaterEvent;
		
		[Inject]
		public var model:UpdaterModel;
		
		public override function execute():void
		{
			switch(event.type)
			{
				case UpdaterEvent.UPDATE_CHECK:
					model.check();
					break;
				case UpdaterEvent.UPDATE_DOWNLOAD:
					model.download();
					trace("download");
					break;
				case UpdaterEvent.UPDATE_INSTALL:
					model.install();
					break;
			}
		}
	}
}
