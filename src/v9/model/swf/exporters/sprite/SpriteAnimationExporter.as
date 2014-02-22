package v9.model.swf.exporters.sprite
{
	import v9.model.swf.V9Sprite;
	import v9.model.swf.exporters.IExporter;
	import v9.model.swf.exporters.SpriteExporterBackend;
	import v9.model.swf.vo.SWFCharacterVO;

	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.data.consts.BlendMode;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.timeline.Frame;
	import com.codeazur.as3swf.timeline.FrameObject;

	import flash.geom.Matrix;
	
	public class SpriteAnimationExporter implements IExporter
	{
		protected var backend:SpriteExporterBackend;
		
		public function SpriteAnimationExporter(backend:SpriteExporterBackend)
		{
			this.backend = backend;
		}
		
		public function export(character:SWFCharacterVO):void
		{
			var timeline:SWFTimelineContainer = (character.tag || backend.swf) as SWFTimelineContainer;
			if(timeline && timeline.frames.length > 0)
			{
				var frame:Frame = timeline.frames[clampFrameNr(backend.currentSprite.frameNumber, timeline.frames.length)];
				var frameObjects:Array = frame.getObjectsSortedByDepth();
				for (var i:int = 0; i < frameObjects.length; i++)
				{
					exportChild(frameObjects[i] as FrameObject, timeline);
				}
			}
		}
		
		protected function exportChild(frameObject:FrameObject, timeline:SWFTimelineContainer):void
		{
			var characterVO:SWFCharacterVO = backend.swf.getCharacterVO(frameObject.characterId);
			var placeTag:TagPlaceObject = getPlaceTag(frameObject, timeline);
			 // TODO figure out frameNumber
			var child:V9Sprite = new V9Sprite(0);
			transformObject(child, placeTag);
			backend.currentSprite.addChild(child);
			backend.currentSprite = child;
			if(characterVO) {
				characterVO.export(backend);
			}
			backend.currentSprite = backend.currentSprite.parent as V9Sprite;
		}
		
		protected function transformObject(sprite:V9Sprite, placeTag:TagPlaceObject):void
		{
			if(placeTag)
			{
				if(placeTag.hasMatrix)
				{
					var matrix:Matrix = placeTag.matrix.matrix;
					matrix.tx /= 20;
					matrix.ty /= 20;
					sprite.transform.matrix = matrix;
				}
				if(placeTag.hasColorTransform)
				{
					sprite.transform.colorTransform = placeTag.colorTransform.colorTransform;
				}
				if(placeTag.hasFilterList)
				{
					var filters:Array = [];
					for (var i:int = 0; i < placeTag.surfaceFilterList.length; i++) {
						filters.push(placeTag.surfaceFilterList[i].filter);
					}
					sprite.filters = filters;
				}
				if(placeTag.hasBlendMode)
				{
					sprite.blendMode = BlendMode.toString(placeTag.blendMode);
				}
			}
		}
		
		protected function getPlaceTag(frameObject:FrameObject, timeline:SWFTimelineContainer):TagPlaceObject
		{
			return timeline.tags[(frameObject.lastModifiedAtIndex > 0) ? frameObject.lastModifiedAtIndex : frameObject.placedAtIndex] as TagPlaceObject;
		}
		
		protected function clampFrameNr(frameNr:int, frameCount:uint):uint
		{
			frameNr %= frameCount;
			return (frameNr >= 0) ? frameNr : frameNr + frameCount;
		}
	}
}
