package v9.controller
{
	import v9.model.UpdaterModel;

	import org.robotlegs.mvcs.Command;

	public class StartupCommand extends Command
	{
		[Inject]
		public var updaterModel:UpdaterModel;
		
		public override function execute():void
		{
			updaterModel.check();
		}
	}
}
