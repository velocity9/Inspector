package v9.view.popups
{
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.as3swf.exporters.JSCanvasShapeExporter;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineShape2;
	import com.codeazur.as3swf.tags.TagDefineShape3;
	import com.codeazur.as3swf.tags.TagDefineShape4;
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
	
	public class ExportShapePopupMediator extends Mediator implements IPopupMediator
	{
		private var _data:Object;
		
		[Inject]
		public var popup:ExportShapePopup;
		
		public function ExportShapePopupMediator()
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

			var exporter:V9GraphicsDataShapeExporter = new V9GraphicsDataShapeExporter(swf);
			if (shapeVO.isMorphShape) {
				var defineMorphShape:TagDefineMorphShape = shapeVO.tag as TagDefineMorphShape;
				defineMorphShape.export(exporter, 0);
				var state1:String = getShapeSource(exporter.graphicsData);
				defineMorphShape.export(exporter, 1);
				var state2:String = getShapeSource(exporter.graphicsData);
				popup.text = state1 + "\n" + state2;
			} else {
				var defineShape:TagDefineShape = shapeVO.tag as TagDefineShape;
				defineShape.export(exporter);
				popup.text = getShapeSource(exporter.graphicsData, defineShape);
			}

		}
		
		protected function getShapeSource(graphicsData:Vector.<IGraphicsData>, defineShape:TagDefineShape = null):String {
			var shape:Array = [];
			var j:uint;
			var k:uint;
			var output:String = "";
			var solidFill:GraphicsSolidFill;
			var gradientFill:GraphicsGradientFill;
			var gradientType:Object = { linear:1, radial:2 };
			var gradientSpread:Object = { pad:0, reflect:1, repeat:2 };
			var gradientInterpolation:Object = { rgb:0, linearRGB:1 };
			var gradientColors:Array;
			for (var i:uint = 0; i < graphicsData.length; i++) {
				if (graphicsData[i] is GraphicsStroke) {
					if (output != "") {
						output += "    }";
						shape.push(output);
						output = "";
					}
					var stroke:GraphicsStroke = GraphicsStroke(graphicsData[i]);
					if (stroke.fill is GraphicsSolidFill) {
						solidFill = GraphicsSolidFill(stroke.fill);
						output += StringUtils.printf(
							"    {\n" +
							"      \"stroke\": {\n" +
							"        \"type\": 0,\n" +
							"        \"color\": %d,\n" +
							"        \"alpha\": %s,\n" +
							"        \"width\": %.0f,\n" +
							"        \"caps\": \"%s\",\n" +
							"        \"joints\": \"%s\",\n" +
							"        \"miterLimit\": %.0f,\n" +
							"        \"scaleMode\": \"%s\",\n" +
							"        \"pixelHinting\": %s\n" +
							"      },\n",
							solidFill.color,
							solidFill.alpha,
							stroke.thickness,
							stroke.caps,
							stroke.joints,
							stroke.miterLimit,
							stroke.scaleMode,
							(stroke.pixelHinting ? "true" : "false")
						);
					} else if (stroke.fill is GraphicsGradientFill) {
						gradientFill = GraphicsGradientFill(stroke.fill);
						output += "    {\n      \"stroke\": {\n";
						output += StringUtils.printf("        \"type\": %d,\n", gradientType[gradientFill.type]);
						output += StringUtils.printf("        \"spreadMethod\": %d,\n", gradientSpread[gradientFill.spreadMethod]);
						output += StringUtils.printf("        \"interpolationMethod\": %d,\n", gradientInterpolation[gradientFill.interpolationMethod]);
						if (gradientFill.type == GradientType.RADIAL) {
							output += StringUtils.printf("        \"focalPoint\": %.0f,\n", gradientFill.focalPointRatio);
						}
						output += "        \"matrix\": { " +
							"\"a\": " + gradientFill.matrix.a / 20 + ", " +
							"\"b\": " + gradientFill.matrix.b / 20 + ", " +
							"\"c\": " + gradientFill.matrix.c / 20 + ", " +
							"\"d\": " + gradientFill.matrix.d / 20 + ", " +
							"\"tx\": " + gradientFill.matrix.tx + ", " +
							"\"ty\": " + gradientFill.matrix.ty +
							" },\n";
						gradientColors = [];
						for (j = 0; j < gradientFill.colors.length; j++) {
							gradientColors.push(StringUtils.printf("%d", gradientFill.colors[j]));
						}
						output += "        \"colors\": [" + gradientColors.join(", ") + "],\n";
						output += "        \"alphas\": [" + gradientFill.alphas.join(", ") + "],\n";
						output += "        \"ratios\": [" + gradientFill.ratios.join(", ") + "],\n";
						output += StringUtils.printf("        \"width\": %.0f,\n", stroke.thickness);
						output += StringUtils.printf("        \"caps\": \"%s\",\n", stroke.caps);
						output += StringUtils.printf("        \"joints\": \"%s\",\n", stroke.joints);
						output += StringUtils.printf("        \"miterLimit\": %.0f,\n", stroke.miterLimit);
						output += StringUtils.printf("        \"scaleMode\": \"%s\",\n", stroke.scaleMode);
						output += StringUtils.printf("        \"pixelHinting\": %s\n", (stroke.pixelHinting ? "true" : "false"));
						output += "      },\n";
					}
				} else if (graphicsData[i] is GraphicsSolidFill) {
					solidFill = GraphicsSolidFill(graphicsData[i]);
					output += StringUtils.printf(
						"    {\n" +
						"      \"fill\": {\n" +
						"        \"type\": 0,\n" +
						"        \"color\": %d,\n" +
						"        \"alpha\": %s\n" +
						"      },\n",
						solidFill.color,
						solidFill.alpha
					);
				} else if (graphicsData[i] is GraphicsGradientFill) {
					gradientFill = GraphicsGradientFill(graphicsData[i]);
					output += "    {\n      \"fill\": {\n";
					output += StringUtils.printf("        \"type\": %d,\n", gradientType[gradientFill.type]);
					output += StringUtils.printf("        \"spreadMethod\": %d,\n", gradientSpread[gradientFill.spreadMethod]);
					output += StringUtils.printf("        \"interpolationMethod\": %d,\n", gradientInterpolation[gradientFill.interpolationMethod]);
					if (gradientFill.type == GradientType.RADIAL) {
						output += StringUtils.printf("        \"focalPoint\": %.0f,\n", gradientFill.focalPointRatio);
					}
					output += "        \"matrix\": { " +
						"\"a\": " + gradientFill.matrix.a / 20 + ", " +
						"\"b\": " + gradientFill.matrix.b / 20 + ", " +
						"\"c\": " + gradientFill.matrix.c / 20 + ", " +
						"\"d\": " + gradientFill.matrix.d / 20 + ", " +
						"\"tx\": " + gradientFill.matrix.tx + ", " +
						"\"ty\": " + gradientFill.matrix.ty +
						" },\n";
					gradientColors = [];
					for (j = 0; j < gradientFill.colors.length; j++) {
						gradientColors.push(StringUtils.printf("%d", gradientFill.colors[j]));
					}
					output += "        \"colors\": [" + gradientColors.join(", ") + "],\n";
					output += "        \"alphas\": [" + gradientFill.alphas.join(", ") + "],\n";
					output += "        \"ratios\": [" + gradientFill.ratios.join(", ") + "]\n";
					output += "      },\n";
				} else if (graphicsData[i] is GraphicsEndFill) {
					output += "    }";
					shape.push(output);
					output = "";
				} else if (graphicsData[i] is GraphicsPath) {
					var path:GraphicsPath = GraphicsPath(graphicsData[i]);
					var c:Vector.<int> = path.commands;
					var d:Vector.<Number> = path.data;
					var subpaths:Array = [];
					var coords:Array = [];
					for (j = 0, k = 0; j < c.length; j++) {
						switch (c[j]) {
							case GraphicsPathCommand.MOVE_TO:
								coords = [];
								subpaths.push(coords);
								coords.push(StringUtils.printf("[%s, %s]", NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++])));
								break;
							case GraphicsPathCommand.LINE_TO:
								coords.push(StringUtils.printf("[%s, %s]", NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++])));
								break;
							case GraphicsPathCommand.CURVE_TO:
								coords.push(StringUtils.printf("[%s, %s, %s, %s]", NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++])));
								break;
							case GraphicsPathCommand.CUBIC_CURVE_TO:
								coords.push(StringUtils.printf("[%s, %s, %s, %s, %s, %s]", NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++])));
								break;
							case GraphicsPathCommand.WIDE_MOVE_TO:
								coords = [];
								subpaths.push(coords);
							case GraphicsPathCommand.WIDE_LINE_TO:
								k += 4;
								coords.push(StringUtils.printf("[%s, %s]", NumberUtils.roundPixels20(d[k++]), NumberUtils.roundPixels20(d[k++])));
								break;
						}
					}
					output += "      \"geometry\": {\n";
					output += "        " + StringUtils.printf("\"fillrule\": %d,\n", (path.winding == "evenOdd") ? 0 : 1);
					if (subpaths.length > 0) {
						output += "        \"paths\": [\n";
						for (k = 0; k < subpaths.length; k++) {
							output += StringUtils.printf("          [%s]", subpaths[k].join(", "));
							if (k < subpaths.length - 1) {
								output += ",\n";
							} else {
								output += "\n";
							}
						}
						output += "        ]\n";
					}
					output += "      }\n";
				} else {
				}
			}
			if (output != "") {
				output += "    }";
				shape.push(output);
				output = "";
			}
			
			var boundsStr:String = "";
			var bounds:SWFRectangle;
			if (defineShape != null) {
				bounds = defineShape.shapeBounds;
				boundsStr = "  \"shapeBounds\": " + 
					"{ \"xmin\": " + NumberUtils.roundPixels20(bounds.xmin / 20) +
					", \"ymin\": " + NumberUtils.roundPixels20(bounds.ymin / 20) +
					", \"xmax\": " + NumberUtils.roundPixels20(bounds.xmax / 20) +
					", \"ymax\": " + NumberUtils.roundPixels20(bounds.ymax / 20) +
					" },\n";
				if (defineShape is TagDefineShape4) {
					var ds4:TagDefineShape4 = defineShape as TagDefineShape4;
					bounds = ds4.edgeBounds;
					boundsStr += "  \"edgeBounds\": " + 
						"{ \"xmin\": " + NumberUtils.roundPixels20(bounds.xmin / 20) +
						", \"ymin\": " + NumberUtils.roundPixels20(bounds.ymin / 20) +
						", \"xmax\": " + NumberUtils.roundPixels20(bounds.xmax / 20) +
						", \"ymax\": " + NumberUtils.roundPixels20(bounds.ymax / 20) +
						" },\n";
				}
			}
			return "{\n" + boundsStr + "  \"subshapes\": [\n" + shape.join(",\n") + "\n  ]\n}\n";
		}
	}
}
