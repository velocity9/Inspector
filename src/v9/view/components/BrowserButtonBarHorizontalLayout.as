package v9.view.components
{
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class BrowserButtonBarHorizontalLayout extends LayoutBase
	{
		public function BrowserButtonBarHorizontalLayout():void
		{
			super();
		}
		
		private var _gap:int = 0;
		
		[Inspectable(category="General")]
		
		public function get gap():int { return _gap; }
		public function set gap(value:int):void {
			if (_gap == value) { return; }
			_gap = value;
			var g:GroupBase = target;
			if (g) {
				g.invalidateSize();
				g.invalidateDisplayList();
			}
		}
		
		override public function measure():void {
			super.measure();
			var layoutTarget:GroupBase = target;
			if (!layoutTarget) { return; }
			var elementCount:int = 0;
			var gap:Number = this.gap;
			var width:Number = 0;
			var height:Number = 0;
			var count:int = layoutTarget.numElements;
			for (var i:int = 0; i < count; i++) {
				var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
				if (!layoutElement || !layoutElement.includeInLayout) {
					continue;
				}
				width += layoutElement.getPreferredBoundsWidth();
				elementCount++;
				height = Math.max(height, layoutElement.getPreferredBoundsHeight());
			}
			if (elementCount > 1) {
				width += gap * (elementCount - 1);
			}
			layoutTarget.measuredWidth = width;
			layoutTarget.measuredHeight = height;
		}
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			var gap:Number = this.gap;
			super.updateDisplayList(width, height);
			
			var layoutTarget:GroupBase = target;
			if (!layoutTarget)
				return;
			
			// Pass one: calculate the excess space
			var totalPreferredWidth:Number = 0;            
			var count:int = layoutTarget.numElements;
			var elementCount:int = count;
			var layoutElement:ILayoutElement;
			for (var i:int = 0; i < count; i++)
			{
				layoutElement = layoutTarget.getElementAt(i);
				if (!layoutElement || !layoutElement.includeInLayout)
				{
					elementCount--;
					continue;
				}
				//trace("preferredBoundsWidth", i, layoutElement.getPreferredBoundsWidth());
				totalPreferredWidth += layoutElement.getPreferredBoundsWidth();
			}
			//trace("totalPreferredWidth", totalPreferredWidth);
			
			// Special case for no elements
			if (elementCount == 0) {
				layoutTarget.setContentSize(0, 0);
				return;
			}
			
			// The content size is always the parent size
			layoutTarget.setContentSize(width, height);
			
			// Special case: if width is zero, make the gap zero as well
			if (width == 0) {
				gap = 0;
			}
			
			// excessSpace can be negative
			var excessSpace:Number = width - totalPreferredWidth - gap * (elementCount - 1);
			var widthToDistribute:Number = width - gap * (elementCount - 1);
			//trace("excessSpace", excessSpace);
			//trace("widthToDistribute", widthToDistribute);
			
			// Special case: when we don't have enough space we need to count
			// the number of children smaller than the averager size.
			var averageWidth:Number;
			var largeChildrenCount:int = elementCount;
			if (excessSpace < 0)
			{
				averageWidth = width / elementCount;
				for (i = 0; i < count; i++)
				{
					layoutElement = layoutTarget.getElementAt(i);
					if (!layoutElement || !layoutElement.includeInLayout)
						continue;
					
					var preferredWidth:Number = layoutElement.getPreferredBoundsWidth();
					if (preferredWidth <= averageWidth)
					{
						widthToDistribute -= preferredWidth;
						largeChildrenCount--;
						continue;
					}
				}
				widthToDistribute = Math.max(0, widthToDistribute);
				//trace("widthToDistribute", widthToDistribute);
			}
			//trace("---------");
			
			// Resize and position children
			var x:Number = 0;
			var childWidth:Number = NaN;
			var childWidthRounded:Number = NaN;
			var roundOff:Number = 0;
			for (i = 0; i < count; i++)
			{
				layoutElement = layoutTarget.getElementAt(i);
				if (!layoutElement || !layoutElement.includeInLayout) {
					continue;
				}
				
				if (excessSpace > 0) {
					childWidth = layoutElement.getPreferredBoundsWidth();
				} else if (excessSpace < 0) {
					childWidth = (averageWidth < layoutElement.getPreferredBoundsWidth()) ? widthToDistribute / largeChildrenCount : NaN;  
				}
				
				if (!isNaN(childWidth)) {
					// Round, we want integer values
					childWidthRounded = Math.round(childWidth + roundOff);
					roundOff += childWidth - childWidthRounded;
				}
				
				layoutElement.setLayoutBoundsSize(childWidthRounded, height);
				layoutElement.setLayoutBoundsPosition(x, 0);
				
				// No need to round, width should be an integer number
				x += gap + layoutElement.getLayoutBoundsWidth(); 
				
				// Reset childWidthRounded
				childWidthRounded = NaN;
			}
		}
	}
	
}
