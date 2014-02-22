package v9.view.popups
{
	import v9.exporters.V9GraphicsDataShapeExporter;
	import v9.model.swf.V9SWF;

	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;

	import org.robotlegs.mvcs.Mediator;
	
	public class ExportAnimationPopupMediator extends Mediator implements IPopupMediator
	{
		private var _data:Object;
		
		[Inject]
		public var popup:ExportAnimationPopup;
		
		public function ExportAnimationPopupMediator()
		{
			super();
		}
		
		public override function onRegister():void {
		}
		
		public override function onRemove():void {
		}

		public function get data():Object {
			return _data;
		}
		public function set data(data:Object):void {
			_data = data;
			
			var swfTimeline:SWFTimelineContainer = data["swfTimeline"] as SWFTimelineContainer;
			var swf:V9SWF = data["swf"] as V9SWF;
			var source:String = export(swfTimeline, 0, swf);
			popup.text = HEADER + source + FOOTER;
		}
		
		protected function export(timeline:SWFTimelineContainer, frameNr:uint, swf:V9SWF):String {
			if(timeline && timeline.frames.length > 0) {
				var frame1:Frame = timeline.frames[frameNr];
				var frameObjects:Array = frame1.getObjectsSortedByDepth();
				for (var i:int = 0; i < frameObjects.length; i++) {
					var frameObject:FrameObject = frameObjects[i] as FrameObject;
					//var placeTag:TagPlaceObject = timeline.tags[frameObject.placedAtIndex] as TagPlaceObject;
					var definitionTag:IDefinitionTag = swf.getCharacter(frameObject.characterId);
					if(definitionTag is TagDefineSprite) {
						export(definitionTag as SWFTimelineContainer, 0, swf);
					} else if(definitionTag is TagDefineShape) {
						var defineShape:TagDefineShape = definitionTag as TagDefineShape;
						var exporter:V9GraphicsDataShapeExporter = new V9GraphicsDataShapeExporter(swf);
						defineShape.export(exporter);
						//shape.graphics.drawGraphicsData(exporter.graphicsData);
					}
					//if(displayObject && placeTag && placeTag.matrix && placeTag.matrix.matrix) {
					//	var matrix:Matrix = placeTag.matrix.matrix.clone();
					//	matrix.tx /=  20;
					//	matrix.ty /=  20;
					//	displayObject.transform.matrix = matrix;
					//}
				}
			}
			return "Hello";
		}
		
		//protected function completeHandler(event:SWFParseEvent):void {
		//	dispatch(new PopupEvent(PopupEvent.CLOSE, popup));
		//}
		
		private static const HEADER:String = "<!DOCTYPE html>\r" + 
			"<html>\r" +
			"	<head>\r" +
			"		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\r" +
			"		<title>Example</title>\r" +
			"		<style>\r" +
			"			html, body { margin: 0; overflow: hidden; background-color: #f2f2f2; }\r" +
			"		</style>\r" +
			"		<script type=\"text/javascript\" src=\"paper.js\"></script>\r" +
			"		<script type=\"text/paperscript\" canvas=\"canvas\">\r" +
			"\r" +
			"			var layer = project.activeLayer;\r" +
			"\r";

		private static const FOOTER:String = "\r		</script>\r" +
			"	</head>\r" +
			"	<body>\r" +
			"		<canvas id=\"canvas\" resize keepalive=\"true\"></canvas>\r" +
			"	</body>\r" +
			"</html>\r";
	}
}
