package v9.view.components
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	import org.robotlegs.mvcs.Mediator;
	
	
	
	public class FooterMediator extends Mediator
	{
		[Inject]
		public var footer:Footer;
		
		public function FooterMediator()
		{
			super();
		}
		
		protected override function onCreationComplete(e:Event):void {
		}
		
		public override function onRegister():void {
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		public override function onRemove():void {
		}
		
		protected function timerHandler(event:TimerEvent):void {
			footer.memory = System.totalMemory;
		}
	}
}