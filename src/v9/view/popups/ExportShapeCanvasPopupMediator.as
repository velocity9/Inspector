package v9.view.popups
{
	import com.codeazur.as3swf.exporters.JSCanvasShapeExporter;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.utils.NumberUtils;
	import com.codeazur.utils.StringUtils;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.InterpolationMethod;
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.PopupEvent;
	import v9.exporters.V9GraphicsDataShapeExporter;
	import v9.exporters.V9PaperJSShapeExporter;
	import v9.model.swf.V9SWF;
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.model.swf.vo.SWFShapeVO;
	
	public class ExportShapeCanvasPopupMediator extends Mediator implements IPopupMediator
	{
		private var _data:Object;
		
		[Inject]
		public var popup:ExportShapeCanvasPopup;
		
		public function ExportShapeCanvasPopupMediator()
		{
			super();
		}
		
		public override function onRegister():void {
			eventMap.mapListener(popup.clipBoardButton, MouseEvent.CLICK, clipBoardClickHandler);
		}
		
		public override function onRemove():void {
			eventMap.unmapListener(popup.clipBoardButton, MouseEvent.CLICK, clipBoardClickHandler);
		}

		private function clipBoardClickHandler(event:MouseEvent):void {
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, popup.text, false);
			dispatch(new PopupEvent(PopupEvent.CLOSE, popup));
		}

		public function get data():Object {
			return _data;
		}
		public function set data(data:Object):void {
			_data = data;
			var swf:V9SWF = data["swf"] as V9SWF;
			var shapeVO:SWFShapeVO = data["characterVO"] as SWFShapeVO;

			var exporter:JSCanvasShapeExporter = new JSCanvasShapeExporter(swf, false);
			var defineShape:TagDefineShape = shapeVO.tag as TagDefineShape;
			defineShape.export(exporter);
			popup.text = exporter.js;

		}
	}
}
