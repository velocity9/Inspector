package v9.view.popups
{
	import org.robotlegs.core.IMediator;

	public interface IPopupMediator extends IMediator
	{
		function get data():Object;
		function set data(data:Object):void;
	}
}
