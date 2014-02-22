package v9.exporters
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.as3swf.utils.NumberUtils;
	import com.codeazur.utils.StringUtils;
	import com.probertson.utils.GZIPBytesEncoder;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.robotlegs.mvcs.Actor;
	
	import v9.model.vo.ExportParamsVO;
	
	public class SVGExporter extends Actor
	{
		protected static var LF:String = File.lineEnding;
		
		protected var swf:SWF;
		protected var folder:File;
		protected var params:ExportParamsVO;
		
		protected var mcs:Dictionary = new Dictionary();
		protected var defs:Dictionary = new Dictionary();
		
		protected static var renderer_js:String = loadFile("assets/export/svg/renderer.js");
		
		public function SVGExporter()
		{
			super();
		}
		
		public function export(swf:SWF, folder:File, params:ExportParamsVO):void
		{
			this.swf = swf;
			this.folder = folder;
			this.params = params;
			
			mcs = new Dictionary();
			defs = new Dictionary();

			processTimeline(swf, "root");
			
			var svg:String = createSVG();
			save(svg, "index.svg", "index.svgz");
			save(renderer_js, "renderer.js");
		}

		protected function save(value:String, filename:String, filenameCompressed:String = null):void
		{
			var file:File = folder.resolvePath(filename);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(value);
			stream.close();
			
			if(params.compress && filenameCompressed != null) {
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(value);
				ba.position = 0;
				var enc:GZIPBytesEncoder = new GZIPBytesEncoder();
				ba = enc.compressToByteArray(ba, new Date());
				ba.position = 0;
				file = folder.resolvePath(filenameCompressed);
				stream.open(file, FileMode.WRITE);
				stream.writeBytes(ba);
				stream.close();
			}
		}
		
		protected function createSVG():String
		{
			var i:uint;
			var id:String;
			var si1:String = params.indent;
			var si2:String = StringUtils.repeat(2, params.indent);
			var si3:String = StringUtils.repeat(3, params.indent);
			var si4:String = StringUtils.repeat(4, params.indent);
			var si5:String = StringUtils.repeat(5, params.indent);
			var bgColor:uint = ColorUtils.rgb(swf.backgroundColor);
			var frameRate:Number = (params.fps > 0) ? params.fps : swf.frameRate;
			
			var svg:String = '<?xml version="1.0" standalone="yes"?>' + LF;
			
			svg += StringUtils.printf(
				'<svg ' +
				'onload="init(%d)" ' +
				'xmlns="http://www.w3.org/2000/svg" ' +
				'xmlns:xlink="http://www.w3.org/1999/xlink" ' +
				'version="1.1" ' +
				'width="%.0f" ' +
				'height="%.0f">',
				frameRate,
				Math.round(swf.frameSize.rect.width * params.scaleX),
				Math.round(swf.frameSize.rect.height * params.scaleY)
			) + LF;
			
			if(params.comments) {
				for(i = 0; i < params.comments.length; i++) {
					svg += si1 + '<!-- ' + params.comments[i] + ' -->' + LF;
				}
			}
			
			svg += si1 + '<script type="text/javascript" xlink:href="renderer.js"></script>' + LF;
			svg += si1 + '<script type="text/javascript">' + LF;
			svg += si1 + "<![CDATA[" + LF;

			svg += si2 + "var mcs = {";
			var mcsArr:Array = [];
			for(id in mcs) {
				var frames:Array = mcs[id] as Array;
				var framesArr:Array = [];
				for(i = 0; i < frames.length; i++) {
					var objects:Array = frames[i] as Array;
					var objectArr:Array = [];
					for(var j:uint = 0; j < objects.length; j++) {
						objectArr.push(formatFrameObject(objects[j]));
					}
					framesArr.push("[" + objectArr.join(",") + "]");
				}
				var mc:String = 
					LF + si3 + id + ": {" +
					LF + si4 + "frames: [" +
					LF + si5 + framesArr.join("," + LF + si5) +
					LF + si4 + "]" +
					LF + si3 + "}";
				mcsArr.push(mc);
			}
			svg += mcsArr.join(",");
			svg += LF + si2 + "};";

			svg += LF + si1 + "]]" + ">";
			svg += LF + si1 + '</script>' + LF;

			svg += si1 + '<defs>';
			for(id in defs) {
				var def:XML = defs[id] as XML;
				var defStr:String = def.toXMLString();
				defStr = defStr.split('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">').join("");
				defStr = defStr.split('</svg>').join("");
				defStr = StringUtils.trim(defStr);
				defStr = defStr.split("\n").join(LF + si1);
				svg += LF + si2 + defStr;
			}
			svg += LF + si1 + '</defs>' + LF;

			svg += si1 + StringUtils.printf(
				'<rect width="%.0f" height="%.0f" fill="#%06x"/>',
				Math.round(swf.frameSize.rect.width * params.scaleX),
				Math.round(swf.frameSize.rect.height * params.scaleY),
				bgColor
			) + LF;
			
			svg += si1 + StringUtils.printf(
				'<g id="timeline" transform="scale(%f,%f)"/>',
				params.scaleX,
				params.scaleY
			) + LF;

			if(params.debug) {
				svg += si1 + '<text id="debug" x="10" y="25" font-family="Verdana" font-size="12" fill="black" >' + frameRate + ' fps</text>' + LF;
			}

			svg += '</svg>' + LF;
			
			return svg;
		}
		
		protected function processTimeline(timeline:SWFTimelineContainer, id:String):void
		{
			if(mcs[id] != undefined) return;
			var frames:Array = [];
			var depthMap:Dictionary = createDepthMap(timeline);
			for(var i:uint = 0; i < timeline.frames.length; i++) {
				var objects:Array = [];
				var frame:Frame = timeline.frames[i];
				for each(var frameObject:FrameObject in frame.objects) {
					var object:Object = {};
					var prevFrameObject:FrameObject = getFrameObjectByDepth(timeline, i - 1, frameObject.depth);
					var tag:IDefinitionTag = swf.getCharacter(frameObject.characterId) as IDefinitionTag;
					var cid:String = "s" + tag.characterId;
					var prevCID:String;
					var prevX:String;
					var prevY:String;
					var prevR:String;
					var prevSX:String;
					var prevSY:String;
					if(prevFrameObject != null) {
						var prevTag:IDefinitionTag = swf.getCharacter(prevFrameObject.characterId) as IDefinitionTag;
						prevCID = "s" + prevTag.characterId;
						if(prevCID == cid) {
							var prevPlaceIndex:uint = (prevFrameObject.lastModifiedAtIndex != 0) ? prevFrameObject.lastModifiedAtIndex : prevFrameObject.placedAtIndex;
							var prevPlaceTag:TagPlaceObject = TagPlaceObject(timeline.tags[prevPlaceIndex]);
							if(prevPlaceTag.hasMatrix && !prevPlaceTag.matrix.isIdentity()) {
								prevX = String(NumberUtils.roundPixels20(prevPlaceTag.matrix.translateX / 20));
								prevY = String(NumberUtils.roundPixels20(prevPlaceTag.matrix.translateY / 20));
								prevR = String(NumberUtils.roundPixels400(prevPlaceTag.matrix.rotation));
								prevSX = String(NumberUtils.roundPixels400(prevPlaceTag.matrix.xscale));
								prevSY = String(NumberUtils.roundPixels400(prevPlaceTag.matrix.yscale));
							}
						} else {
							prevX = "0";
							prevY = "0";
							prevR = "0";
							prevSX = "1";
							prevSY = "1";
						}
					}
					if(tag is TagDefineSprite) {
						processTimeline(TagDefineSprite(tag), cid);
					} else if(tag is TagDefineShape && defs[cid] == undefined) {
						var exporter:SVGCustomShapeExporter = new SVGCustomShapeExporter(swf, cid);
						TagDefineShape(tag).export(exporter);
						defs[cid] = exporter.svg;
					}
					
					if(prevCID != cid) {
						object.id = cid;
					}
					var placeIndex:uint = (frameObject.lastModifiedAtIndex != 0) ? frameObject.lastModifiedAtIndex : frameObject.placedAtIndex;
					var placeTag:TagPlaceObject = TagPlaceObject(timeline.tags[placeIndex]);
					if(placeTag.hasMatrix && !placeTag.matrix.isIdentity()) {
						var x:String = String(NumberUtils.roundPixels20(placeTag.matrix.translateX / 20));
						var y:String = String(NumberUtils.roundPixels20(placeTag.matrix.translateY / 20));
						var r:String = String(NumberUtils.roundPixels400(placeTag.matrix.rotation));
						var sx:String = String(NumberUtils.roundPixels400(placeTag.matrix.xscale));
						var sy:String = String(NumberUtils.roundPixels400(placeTag.matrix.yscale));
						if((placeTag.matrix.translateX != 0 && prevX != x) || (placeTag.matrix.translateX == 0 && prevX != "0" && prevX != null)) {
							object.x = x;
						}
						if((placeTag.matrix.translateY != 0 && prevY != y) || (placeTag.matrix.translateY == 0 && prevY != "0" && prevY != null)) {
							object.y = y;
						}
						if((placeTag.matrix.rotation != 0 && prevR != r) || (placeTag.matrix.rotation == 0 && prevR != "0" && prevR != null)) {
							object.r = r;
						}
						if((placeTag.matrix.xscale != 1 && prevSX != sx) || (placeTag.matrix.xscale == 1 && prevSX != "1" && prevSX != null)) {
							object.sx = sx;
						}
						if((placeTag.matrix.yscale != 1 && prevSY != sy) || (placeTag.matrix.yscale == 1 && prevSY != "1" && prevSY != null)) {
							object.sy = sy;
						}
					}
					objects[depthMap[frameObject.depth]] = object;
				}
				frames.push(objects);
			}
			mcs[id] = frames;
		}
		
		protected function getFrameObjectByDepth(timeline:SWFTimelineContainer, frameIdx:int, depth:uint):FrameObject
		{
			if(frameIdx >= 0 && frameIdx < timeline.frames.length) {
				return timeline.frames[frameIdx].objects[depth];
			}
			return null;
		}
		
		protected function createDepthMap(timeline:SWFTimelineContainer):Dictionary
		{
			var i:uint;
			var depths:Array = [];
			for(i = 0; i < timeline.frames.length; i++) {
				var frame:Frame = timeline.frames[i];
				var frameObjects:Array = frame.getObjectsSortedByDepth();
				for(var j:uint = 0; j < frameObjects.length; j++) {
					var frameObject:FrameObject = frameObjects[j] as FrameObject;
					if(depths.indexOf(frameObject.depth) == -1) {
						depths.push(frameObject.depth);
					}
				}
			}
			depths.sort(Array.NUMERIC);
			var map:Dictionary = new Dictionary();
			for(i = 0; i < depths.length; i++) {
				map[depths[i]] = i;
			}
			return map;
		}
		
		protected function formatFrameObject(o:Object):String
		{
			if(o == null) {
				return "";
			} else {
				var elements:Array = [];
				if(o.id != undefined) { elements.push('id:"' + o.id + '"'); }
				if(o.x != undefined) { elements.push('x:' + o.x); }
				if(o.y != undefined) { elements.push('y:' + o.y); }
				if(o.r != undefined) { elements.push('r:' + o.r); }
				if(o.sx != undefined) { elements.push('sx:' + o.sx); }
				if(o.sy != undefined) { elements.push('sy:' + o.sy); }
				return "{" + elements.join(",") + "}";
			}
		}
		
		protected static function loadFile(path:String):String {
			var result:String = "";
			var file:File = File.applicationDirectory.resolvePath(path);
			if(file.exists && !file.isDirectory) {
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				result = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
			}
			return result;
		}
	}
}