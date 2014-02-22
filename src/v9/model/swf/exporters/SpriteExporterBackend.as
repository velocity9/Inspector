package v9.model.swf.exporters
{
	import v9.model.swf.V9SWF;
	import v9.model.swf.V9Sprite;
	import v9.model.swf.exporters.sprite.SpriteAnimationExporter;
	import v9.model.swf.exporters.sprite.SpriteShapeExporter;

	public class SpriteExporterBackend implements IExporterBackend
	{
		protected var _swf:V9SWF;
		protected var _sprite:V9Sprite;
		protected var _currentSprite:V9Sprite;

		public function SpriteExporterBackend(swf:V9SWF, frameNumber:int = 0)
		{
			_swf = swf;
			_sprite = _currentSprite = new V9Sprite(frameNumber);
		}

		public function createAnimationExporter():IExporter
		{
			return new SpriteAnimationExporter(this);
		}
		
		public function createShapeExporter():IExporter
		{
			return new SpriteShapeExporter(this);
		}
		
		public function get currentSprite():V9Sprite
		{
			return _currentSprite;
		}
		public function set currentSprite(value:V9Sprite):void
		{
			_currentSprite = value;
		}
		
		public function get sprite():V9Sprite
		{
			return _sprite;
		}
		
		public function get swf():V9SWF
		{
			return _swf;
		}
	}
}
