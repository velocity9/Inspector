package v9.view
{
	import org.robotlegs.mvcs.Mediator;
	
	public class V9MainMediator extends Mediator
	{
		[Inject]
		public var main:V9Main;
		
		public function V9MainMediator()
		{
			super();
		}
		
		override public function onRegister():void {
		}
		
		override public function onRemove():void {
		}
	}
}
