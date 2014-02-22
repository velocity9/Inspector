package v9.view.editor.mainpanel.timeline
{
	import spark.components.supportClasses.GroupBase;
	import spark.core.NavigationUnit;
	import spark.layouts.supportClasses.DropLocation;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.layouts.supportClasses.LinearLayoutVector;

	import v9.view.editor.mainpanel.timeline.renderers.TimelineRenderer;
	import v9.view.editor.mainpanel.timeline.renderers.TimelineRulerRenderer;

	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	use namespace mx_internal;
	
	/**
	 *  The VerticalLayout class arranges the layout elements in a vertical sequence,
	 *  top to bottom, with optional gaps between the elements and optional padding
	 *  around the sequence of elements.
	 *
	 *  <p>The vertical position of the elements is determined by arranging them
	 *  in a vertical sequence, top to bottom, taking into account the padding
	 *  before the first element and the gaps between the elements.</p>
	 *
	 *  <p>The horizontal position of the elements is determined by the layout's
	 *  <code>horizontalAlign</code> property.</p>
	 *
	 *  <p>During the execution of the <code>measure()</code> method, 
	 *  the default size of the container is calculated by
	 *  accumulating the preferred sizes of the elements, including gaps and padding.
	 *  When <code>requestedRowCount</code> is set, only the space for that many elements
	 *  is measured, starting from the first element.</p>
	 *
	 *  <p>During the execution of the <code>updateDisplayList()</code> method, 
	 *  the height of each element is calculated
	 *  according to the following rules, listed in their respective order of
	 *  precedence (element's minimum height and maximum height are always respected):</p>
	 *  <ul>
	 *    <li>If <code>variableRowHeight</code> is <code>false</code>, 
	 *    then set the element's height to the
	 *    value of the <code>rowHeight</code> property.</li>
	 *
	 *    <li>If the element's <code>percentHeight</code> is set, then calculate the element's
	 *    height by distributing the available container height between all
	 *    elements with a <code>percentHeight</code> setting. 
	 *    The available container height
	 *    is equal to the container height minus the gaps, the padding and the
	 *    space occupied by the rest of the elements. The element's <code>precentHeight</code>
	 *    property is ignored when the layout is virtualized.</li>
	 *
	 *    <li>Set the element's height to its preferred height.</li>
	 *  </ul>
	 *
	 *  <p>The width of each element is calculated according to the following rules,
	 *  listed in their respective order of precedence (element's minimum width and
	 *  maximum width are always respected):</p>
	 *  <ul>
	 *    <li>If <code>horizontalAlign</code> is <code>"justify"</code>, 
	 *    then set the element's width to the container width.</li>
	 *
	 *    <li>If <code>horizontalAlign</code> is <code>"contentJustify"</code>,
	 *    then set the element's width to the maximum between the container's width 
	 *    and all elements' preferred width.</li>
	 *
	 *    <li>If the element's <code>percentWidth</code> is set, then calculate the element's
	 *    width as a percentage of the container's width.</li>
	 *
	 *    <li>Set the element's width to its preferred width.</li>
	 *  </ul>
	 *
	 *  @mxml 
	 *  <p>The <code>&lt;s:VerticalLayout&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;s:VerticalLayout 
	 *    <strong>Properties</strong>
	 *    gap="6"
	 *    horizontalAlign="left"
	 *    paddingBottom="0"
	 *    paddingLeft="0"
	 *    paddingRight="0"
	 *    paddingTop="0"
	 *    requestedMinRowCount="-1"
	 *    requestedRowCount="-1"
	 *    rowHeight="<i>calculated</i>"
	 *    variableRowHeight="true"
	 *    verticalAlign="top"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class TimelineLayout extends LayoutBase
	{
		/**
		 *  @private
		 *  Cached row heights, max column width for virtual layout.   Not used unless
		 *  useVirtualLayout=true.   See updateLLV(), resetCachedVirtualLayoutState(),
		 *  etc.
		 */
		protected var llv:LinearLayoutVector = new LinearLayoutVector();
		
		protected var adjustedHorizontalScrollPosition:Number = 0;
		protected var adjustedContentWidth:Number = 0;

		public var totalFrames:Number = 0;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */    
		public function TimelineLayout():void
		{
			super();
			
			// Don't drag-scroll in the horizontal direction
			dragScrollRegionSizeHorizontal = 0;
			
			// Virtualization defaults for cases
			// where there are no items and no typical item.
			// The llv defaults are the width/height of a Spark Button skin.
			llv.defaultMinorSize = 71;
			llv.defaultMajorSize = 22;
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _rowCount:int = -1;
		protected var _paddingLeft:Number = 0;
		protected var _paddingRight:Number = 0;
		protected var _paddingTop:Number = 0;
		protected var _paddingBottom:Number = 0;
		protected var _requestedMinRowCount:int = -1;
		protected var _requestedRowCount:int = -1;
		protected var _rowHeight:Number;
		protected var _firstIndexInView:int = -1;
		protected var _lastIndexInView:int = -1;
		
		[Bindable("propertyChange")]
		[Inspectable(category="General")]
		public function get rowCount():int { return _rowCount; }

		protected function setRowCount(value:int):void {
			if (_rowCount == value)
				return;
			var oldValue:int = _rowCount;
			_rowCount = value;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowCount", oldValue, value));
		}
		
		[Inspectable(category="General")]
		public function get paddingLeft():Number { return _paddingLeft; }
		public function set paddingLeft(value:Number):void {
			if (_paddingLeft == value)
				return;
			
			_paddingLeft = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		[Inspectable(category="General")]
		public function get paddingRight():Number { return _paddingRight; }
		public function set paddingRight(value:Number):void {
			if (_paddingRight == value)
				return;
			_paddingRight = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		[Inspectable(category="General")]
		public function get paddingTop():Number { return _paddingTop; }
		public function set paddingTop(value:Number):void {
			if (_paddingTop == value)
				return;
			_paddingTop = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		[Inspectable(category="General")]
		public function get paddingBottom():Number { return _paddingBottom; }
		public function set paddingBottom(value:Number):void {
			if (_paddingBottom == value)
				return;
			_paddingBottom = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		[Inspectable(category="General", minValue="-1")]
		public function get requestedMinRowCount():int { return _requestedMinRowCount; }
		public function set requestedMinRowCount(value:int):void {
			if (_requestedMinRowCount == value)
				return;
			_requestedMinRowCount = value;
			if (target)
				target.invalidateSize();
		}    
		
		[Inspectable(category="General", minValue="-1")]
		public function get requestedRowCount():int { return _requestedRowCount; }
		public function set requestedRowCount(value:int):void {
			if (_requestedRowCount == value)
				return;
			_requestedRowCount = value;
			if (target)
				target.invalidateSize();
		}    
		
		[Inspectable(category="General", minValue="0.0")]
		public function get rowHeight():Number {
			if (!isNaN(_rowHeight)) {
				return _rowHeight;
			} else {
				var elt:ILayoutElement = typicalLayoutElement;
				return (elt) ? elt.getPreferredBoundsHeight() : 0;
			}
		}
		public function set rowHeight(value:Number):void {
			if (_rowHeight == value)
				return;
			_rowHeight = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		[Inspectable(category="General")]
		[Bindable("indexInViewChanged")]    
		public function get firstIndexInView():int { return _firstIndexInView; }
		
		[Inspectable(category="General")]
		[Bindable("indexInViewChanged")]    
		public function get lastIndexInView():int { return _lastIndexInView; }
		
		protected function setIndexInView(firstIndex:int, lastIndex:int):void {
			if ((_firstIndexInView == firstIndex) && (_lastIndexInView == lastIndex))
				return;
			_firstIndexInView = firstIndex;
			_lastIndexInView = lastIndex;
			dispatchEvent(new Event("indexInViewChanged"));
		}

		public override function get useVirtualLayout():Boolean { return true; }
		public override function set useVirtualLayout(value:Boolean):void {}

		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function clearVirtualLayoutCache():void {
			llv.clear();
		}     
		
		/**
		 *  @private
		 */
		override public function getElementBounds(index:int):Rectangle {
			var g:GroupBase = GroupBase(target);
			if (!g || (index < 0) || (index >= g.numElements)) 
				return null;
			
			return llv.getBounds(index);
		}
		
		/**
		 *  Returns 1.0 if the specified index is completely in view, 0.0 if
		 *  it's not, or a value between 0.0 and 1.0 that represents the percentage 
		 *  of the if the index that is partially in view.
		 * 
		 *  <p>An index is "in view" if the corresponding non-null layout element is 
		 *  within the vertical limits of the container's <code>scrollRect</code>
		 *  and included in the layout.</p>
		 *  
		 *  <p>If the specified index is partially within the view, the 
		 *  returned value is the percentage of the corresponding
		 *  layout element that's visible.</p>
		 *
		 *  @param index The index of the row.
		 * 
		 *  @return The percentage of the specified element that's in view.
		 *  Returns 0.0 if the specified index is invalid or if it corresponds to
		 *  null element, or a ILayoutElement for which 
		 *  the <code>includeInLayout</code> property is <code>false</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function fractionOfElementInView(index:int):Number 
		{
			var g:GroupBase = GroupBase(target);
			if (!g)
				return 0.0;
			
			if ((index < 0) || (index >= g.numElements))
				return 0.0;
			
			if (!clipAndEnableScrolling)
				return 1.0;
			
			var r0:int = firstIndexInView;  
			var r1:int = lastIndexInView;
			
			// outside the visible index range
			if ((r0 == -1) || (r1 == -1) || (index < r0) || (index > r1))
				return 0.0;
			
			// within the visible index range, but not first or last            
			if ((index > r0) && (index < r1))
				return 1.0;
			
			// get the layout element's Y and Height
			var eltY:Number = llv.start(index);
			var eltHeight:Number = llv.getMajorSize(index);
			
			// So, index is either the first or last row in the scrollRect
			// and potentially partially visible.
			//   y0,y1 - scrollRect top,bottom edges
			//   iy0, iy1 - layout element top,bottom edges
			var y0:Number = g.verticalScrollPosition;
			var y1:Number = y0 + g.height;
			var iy0:Number = eltY;
			var iy1:Number = iy0 + eltHeight;
			if (iy0 >= iy1)  // element has 0 or negative height
				return 1.0;
			if ((iy0 >= y0) && (iy1 <= y1))
				return 1.0;
			return (Math.min(y1, iy1) - Math.max(y0, iy0)) / (iy1 - iy0);
		}
		
		/**
		 *  @private
		 * 
		 *  Binary search for the first layout element that contains y.  
		 * 
		 *  This function considers both the element's actual bounds and 
		 *  the gap that follows it to be part of the element.  The search 
		 *  covers index i0 through i1 (inclusive).
		 *  
		 *  This function is intended for variable height elements.
		 * 
		 *  Returns the index of the element that contains y, or -1.
		 */
		protected static function findIndexAt(y:Number, g:GroupBase, i0:int, i1:int):int
		{
			var index:int = (i0 + i1) / 2;
			var element:ILayoutElement = g.getElementAt(index);     
			var elementY:Number = element.getLayoutBoundsY();
			var elementHeight:Number = element.getLayoutBoundsHeight();
			// TBD: deal with null element, includeInLayout false.
			if ((y >= elementY) && (y < elementY + elementHeight))
				return index;
			else if (i0 == i1)
				return -1;
			else if (y < elementY)
				return findIndexAt(y, g, i0, Math.max(i0, index-1));
			else 
				return findIndexAt(y, g, Math.min(index+1, i1), i1);
		} 
		
		/**
		 *  @private
		 * 
		 *  Returns the index of the first non-null includeInLayout element, 
		 *  beginning with the element at index i.  
		 * 
		 *  Returns -1 if no such element can be found.
		 */
		private static function findLayoutElementIndex(g:GroupBase, i:int, dir:int):int
		{
			var n:int = g.numElements;
			while((i >= 0) && (i < n))
			{
				var element:ILayoutElement = g.getElementAt(i);
				if (element && element.includeInLayout)
				{
					return i;      
				}
				i += dir;
			}
			return -1;
		}
		
		/**
		 *  @private
		 * 
		 *  Updates the first,lastIndexInView properties per the new
		 *  scroll position.
		 *  
		 *  @see setIndexInView
		 */
		override protected function scrollPositionChanged():void
		{
			super.scrollPositionChanged();
			
			var g:GroupBase = target;
			if (!g)
				return;     
			
			var n:int = g.numElements - 1;
			if (n < 0) 
			{
				setIndexInView(-1, -1);
				return;
			}
			
			var scrollR:Rectangle = getScrollRect();
			if (!scrollR)
			{
				setIndexInView(0, n);
				return;    
			}
			
			// We're going to use findIndexAt to find the index of 
			// the elements that overlap the top and bottom edges of the scrollRect.
			// Values that are exactly equal to scrollRect.bottom aren't actually
			// rendered, since the top,bottom interval is only half open.
			// To account for that we back away from the bottom edge by a
			// hopefully infinitesimal amount.
			
			var y0:Number = scrollR.top;
			var y1:Number = scrollR.bottom - .0001;
			if (y1 <= y0)
			{
				setIndexInView(-1, -1);
				return;
			}
			
			var i0:int = llv.indexOf(y0);
			var i1:int = llv.indexOf(y1);
			
			// Special case: no element overlaps y0, is index 0 visible?
			if (i0 == -1)
			{   
				var index0:int = findLayoutElementIndex(g, 0, +1);
				if (index0 != -1)
				{
					var element0:ILayoutElement = g.getElementAt(index0); 
					var element0Y:Number = element0.getLayoutBoundsY();
					var elementHeight:Number = element0.getLayoutBoundsHeight();                 
					if ((element0Y < y1) && ((element0Y + elementHeight) > y0))
						i0 = index0;
				}
			}
			
			// Special case: no element overlaps y1, is index n visible?
			if (i1 == -1)
			{
				var index1:int = findLayoutElementIndex(g, n, -1);
				if (index1 != -1)
				{
					var element1:ILayoutElement = g.getElementAt(index1); 
					var element1Y:Number = element1.getLayoutBoundsY();
					var element1Height:Number = element1.getLayoutBoundsHeight();                 
					if ((element1Y < y1) && ((element1Y + element1Height) > y0))
						i1 = index1;
				}
			}
			
			g.invalidateDisplayList();
			
			setIndexInView(i0, i1);
		}
		
		/**
		 *  @private
		 * 
		 *  Returns the actual position/size Rectangle of the first partially 
		 *  visible or not-visible, non-null includeInLayout element, beginning
		 *  with the element at index i, searching in direction dir (dir must
		 *  be +1 or -1).   The last argument is the GroupBase scrollRect, it's
		 *  guaranteed to be non-null.
		 * 
		 *  Returns null if no such element can be found.
		 */
		private function findLayoutElementBounds(g:GroupBase, i:int, dir:int, r:Rectangle):Rectangle
		{
			var n:int = g.numElements;
			
			if (fractionOfElementInView(i) >= 1)
			{
				// Special case: if we hit the first/last element, 
				// then return the area of the padding so that we
				// can scroll all the way to the start/end.
				i += dir;
				if (i < 0)
					return new Rectangle(0, 0, 0, paddingTop);
				if (i >= n)
					return new Rectangle(0, getElementBounds(n-1).bottom, 0, paddingBottom);
			}
			
			while((i >= 0) && (i < n))
			{
				var elementR:Rectangle = getElementBounds(i);
				// Special case: if the scrollRect r _only_ contains
				// elementR, then if we're searching up (dir == -1),
				// and elementR's top edge is visible, then try again
				// with i-1.   Likewise for dir == +1.
				if (elementR)
				{
					var overlapsTop:Boolean = (dir == -1) && (elementR.top == r.top) && (elementR.bottom >= r.bottom);
					var overlapsBottom:Boolean = (dir == +1) && (elementR.bottom == r.bottom) && (elementR.top <= r.top);
					if (!(overlapsTop || overlapsBottom))             
						return elementR;
				}
				i += dir;
			}
			return null;
		}
		
		/**
		 *  @private 
		 */
		override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
		{
			return findLayoutElementBounds(target, firstIndexInView, -1, scrollRect);
		} 
		
		/**
		 *  @private 
		 */
		override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
		{
			return findLayoutElementBounds(target, lastIndexInView, +1, scrollRect);
		} 
		
		/**
		 *  @private
		 *  Syncs the LinearLayoutVector llv with typicalLayoutElement and
		 *  the target's numElements.  Calling this function accounts
		 *  for the possibility that the typicalLayoutElement has changed, or
		 *  something that its preferred size depends on has changed.
		 */
		private function updateLLV(layoutTarget:GroupBase):void
		{
			var typicalElt:ILayoutElement = typicalLayoutElement;
			if (typicalElt)
			{
				var typicalWidth:Number = typicalElt.getPreferredBoundsWidth();
				var typicalHeight:Number = typicalElt.getPreferredBoundsHeight();
				llv.defaultMinorSize = typicalWidth;
				llv.defaultMajorSize = typicalHeight; 
			}
			if (layoutTarget)
				llv.length = layoutTarget.numElements;
			llv.gap = 0;
			llv.majorAxisOffset = paddingTop;
		}
		
		/**
		 *  @private
		 */
		override public function elementAdded(index:int):void
		{
			if (index >= 0)
				llv.insert(index);  // insert index parameter is uint
		}
		
		/**
		 *  @private
		 */
		override public function elementRemoved(index:int):void
		{
			if (index >= 0)
				llv.remove(index);  // remove index parameter is uint
		}     
		
		/**
		 *  @private
		 * 
		 *  Compute potentially approximate values for measuredWidth,Height and 
		 *  measuredMinWidth,Height.
		 * 
		 *  This method does not get layout elements from the target except
		 *  as a side effect of calling typicalLayoutElement.
		 * 
		 *  If variableRowHeight="false" then all dimensions are based on 
		 *  typicalLayoutElement and the sizes already cached in llv.  The 
		 *  llv's defaultMajorSize, minorSize, and minMinorSize 
		 *  are based on typicalLayoutElement.
		 */
		private function measureVirtual(layoutTarget:GroupBase):void
		{
			var eltCount:uint = layoutTarget.numElements;
			var measuredEltCount:int = (requestedRowCount != -1) ? requestedRowCount : 
				Math.max(requestedMinRowCount, eltCount);
			
			var hPadding:Number = paddingLeft + paddingRight;
			var vPadding:Number = paddingTop + paddingBottom;
			
			if (measuredEltCount <= 0)
			{
				layoutTarget.measuredWidth = layoutTarget.measuredMinWidth = hPadding;
				layoutTarget.measuredHeight = layoutTarget.measuredMinHeight = vPadding;
				return;
			}        
			
			updateLLV(layoutTarget);     

			layoutTarget.measuredHeight = (measuredEltCount * rowHeight) + vPadding;
			layoutTarget.measuredWidth = llv.minorSize + hPadding;
			
			layoutTarget.measuredMinWidth = layoutTarget.measuredWidth;
			layoutTarget.measuredMinHeight = layoutTarget.measuredHeight;
		}
		
		/**
		 *  @private
		 * 
		 *  If requestedRowCount is specified then as many layout elements
		 *  or "rows" are measured, starting with element 0, otherwise all of the 
		 *  layout elements are measured.
		 *  
		 *  If requestedRowCount is specified and is greater than the
		 *  number of layout elements, then the typicalLayoutElement is used
		 *  in place of the missing layout elements.
		 * 
		 *  If variableRowHeight="true", then the layoutTarget's measuredHeight 
		 *  is the sum of preferred heights of the layout elements, plus the sum of the
		 *  gaps between elements, and its measuredWidth is the max of the elements' 
		 *  preferred widths.
		 * 
		 *  If variableRowHeight="false", then the layoutTarget's measuredHeight 
		 *  is rowHeight multiplied by the number or layout elements, plus the 
		 *  sum of the gaps between elements.
		 * 
		 *  The layoutTarget's measuredMinHeight is the sum of the minHeights of 
		 *  layout elements that have specified a value for the percentHeight
		 *  property, and the preferredHeight of the elements that have not, 
		 *  plus the sum of the gaps between elements.
		 * 
		 *  The difference reflects the fact that elements which specify 
		 *  percentHeight are considered to be "flexible" and updateDisplayList 
		 *  will give flexible components at least their minHeight.  
		 * 
		 *  Layout elements that aren't flexible always get their preferred height.
		 * 
		 *  The layoutTarget's measuredMinWidth is the max of the minWidths for 
		 *  elements that have specified percentWidth (that are "flexible") and the 
		 *  preferredWidth of the elements that have not.
		 * 
		 *  As before the difference is due to the fact that flexible items are only
		 *  guaranteed their minWidth.
		 */
		override public function measure():void
		{
			var layoutTarget:GroupBase = target;
			if (!layoutTarget)
				return;
			
			measureVirtual(layoutTarget);
			
			// Use Math.ceil() to make sure that if the content partially occupies
			// the last pixel, we'll count it as if the whole pixel is occupied.
			layoutTarget.measuredWidth = Math.ceil(layoutTarget.measuredWidth);    
			layoutTarget.measuredHeight = Math.ceil(layoutTarget.measuredHeight);    
			layoutTarget.measuredMinWidth = Math.ceil(layoutTarget.measuredMinWidth);    
			layoutTarget.measuredMinHeight = Math.ceil(layoutTarget.measuredMinHeight);
		}
		
		/**
		 *  @private 
		 */  
		override public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint, arrowKeysWrapFocus:Boolean):int
		{
			if (!target || target.numElements < 1)
				return -1; 
			
			var maxIndex:int = target.numElements - 1;
			
			// Special case when nothing was previously selected
			if (currentIndex == -1)
			{
				if (navigationUnit == NavigationUnit.UP)
					return arrowKeysWrapFocus ? maxIndex : -1;
				if (navigationUnit == NavigationUnit.DOWN)
					return 0;    
			}    
			
			// Make sure currentIndex is within range
			currentIndex = Math.max(0, Math.min(maxIndex, currentIndex));
			
			var newIndex:int; 
			var bounds:Rectangle;
			var y:Number;
			
			switch (navigationUnit)
			{
				case NavigationUnit.UP:
				{
					if (arrowKeysWrapFocus && currentIndex == 0)
						newIndex = maxIndex;
					else
						newIndex = currentIndex - 1;  
					break;
				} 
					
				case NavigationUnit.DOWN: 
				{
					if (arrowKeysWrapFocus && currentIndex == maxIndex)
						newIndex = 0;
					else
						newIndex = currentIndex + 1;  
					break;
				}
					
				case NavigationUnit.PAGE_UP:
				{
					// Find the first fully visible element
					var firstVisible:int = firstIndexInView;
					var firstFullyVisible:int = firstVisible;
					if (fractionOfElementInView(firstFullyVisible) < 1)
						firstFullyVisible += 1;
					
					// Is the current element in the middle of the viewport?
					if (firstFullyVisible < currentIndex && currentIndex <= lastIndexInView)
						newIndex = firstFullyVisible;
					else
					{
						// Find an element that's one page up
						if (currentIndex == firstFullyVisible || currentIndex == firstVisible)
						{
							// currentIndex is visible, we can calculate where the scrollRect top
							// would end up if we scroll by a page                    
							y = getVerticalScrollPositionDelta(NavigationUnit.PAGE_UP) + getScrollRect().top;
						}
						else
						{
							// currentIndex is not visible, just find an element a page up from currentIndex
							y = getElementBounds(currentIndex).bottom - getScrollRect().height;
						}
						
						// Find the element after the last element that spans above the y position
						newIndex = currentIndex - 1;
						while (0 <= newIndex)
						{
							bounds = getElementBounds(newIndex);
							if (bounds && bounds.top < y)
							{
								// This element spans the y position, so return the next one
								newIndex = Math.min(currentIndex - 1, newIndex + 1);
								break;
							}
							newIndex--;    
						}
					}
					break;
				}
					
				case NavigationUnit.PAGE_DOWN:
				{
					// Find the last fully visible element:
					var lastVisible:int = lastIndexInView;
					var lastFullyVisible:int = lastVisible;
					if (fractionOfElementInView(lastFullyVisible) < 1)
						lastFullyVisible -= 1;
					
					// Is the current element in the middle of the viewport?
					if (firstIndexInView <= currentIndex && currentIndex < lastFullyVisible)
						newIndex = lastFullyVisible;
					else
					{
						// Find an element that's one page down
						if (currentIndex == lastFullyVisible || currentIndex == lastVisible)
						{
							// currentIndex is visible, we can calculate where the scrollRect bottom
							// would end up if we scroll by a page                    
							y = getVerticalScrollPositionDelta(NavigationUnit.PAGE_DOWN) + getScrollRect().bottom;
						}
						else
						{
							// currentIndex is not visible, just find an element a page down from currentIndex
							y = getElementBounds(currentIndex).top + getScrollRect().height;
						}
						
						// Find the element before the first element that spans below the y position
						newIndex = currentIndex + 1;
						while (newIndex <= maxIndex)
						{
							bounds = getElementBounds(newIndex);
							if (bounds && bounds.bottom > y)
							{
								// This element spans the y position, so return the previous one
								newIndex = Math.max(currentIndex + 1, newIndex - 1);
								break;
							}
							newIndex++;    
						}
					}
					break;
				}
					
				default: return super.getNavigationDestinationIndex(currentIndex, navigationUnit, arrowKeysWrapFocus);
			}
			return Math.max(0, Math.min(maxIndex, newIndex));  
		}
		
		/**
		 *  @private
		 * 
		 *  Update the layout of the virtualized elements that overlap
		 *  the scrollRect's vertical extent.
		 *
		 *  The height of each layout element will be its preferred height, and its
		 *  y will be the bottom of the previous item, plus the gap.
		 * 
		 *  No support for percentHeight, includeInLayout=false, or null layoutElements,
		 * 
		 *  The width of each layout element will be set to its preferred width, unless
		 *  one of the following is true:
		 * 
		 *  - If percentWidth is specified for this element, then its width will be the
		 *  specified percentage of the target's actual (unscaled) width, clipped 
		 *  the layout element's minimum and maximum width.
		 * 
		 *  - If horizontalAlign is "justify", then the element's width will
		 *  be set to the target's actual (unscaled) width.
		 * 
		 *  - If horizontalAlign is "contentJustify", then the element's width
		 *  will be set to the larger of the target's width and its content width.
		 * 
		 *  The X coordinate of each layout element will be set to 0 unless one of the
		 *  following is true:
		 * 
		 *  - If horizontalAlign is "center" then x is set so that the element's preferred
		 *  width is centered within the larger of the contentWidth, target width:
		 *      x = (Math.max(contentWidth, target.width) - layoutElementWidth) * 0.5
		 * 
		 *  - If horizontalAlign is "right" the x is set so that the element's right
		 *  edge is aligned with the the right edge of the content:
		 *      x = (Math.max(contentWidth, target.width) - layoutElementWidth)
		 * 
		 *  Implementation note: unless horizontalAlign is either "justify" or 
		 *  "left", the layout elements' x or width depends on the contentWidth.
		 *  The contentWidth is a maximum and although it may be updated to 
		 *  different value after all (viewable) elements have been laid out, it
		 *  often does not change.  For that reason we use the current contentWidth
		 *  for the initial layout and then, if it has changed, we loop through 
		 *  the layout items again and fix up the x/width values.
		 */
		private function updateDisplayListVirtual():void
		{
			var layoutTarget:GroupBase = target; 
			var eltCount:int = layoutTarget.numElements;
			var minVisibleY:Number = layoutTarget.verticalScrollPosition;
			var maxVisibleY:Number = minVisibleY + layoutTarget.height;
			
			updateLLV(layoutTarget);
			
			// Find the index of the first visible item.
			var startIndex:int = llv.indexOf(Math.max(0, minVisibleY));
			if (startIndex == -1)
				return;
			
			var totalFrameGroups:Number = Math.ceil(totalFrames / 5);
			
			var contentWidth:Number = totalFrames * 8;
			var targetWidth:Number = Math.max(0, layoutTarget.width - paddingLeft - paddingRight);
			
			var ignoredGroupsLeft:Number = Math.floor(horizontalScrollPosition / (8 * 5));
			var ignoredGroupsRight:Number = Math.floor(Math.max(0, totalFrameGroups * (8 * 5) - targetWidth - horizontalScrollPosition) / (8 * 5));
			var firstRenderedFrame:Number = ignoredGroupsLeft * 5;
			var totalRenderedFrames:Number = totalFrames - Math.max(0, ignoredGroupsLeft + ignoredGroupsRight - 1) * 5;
			var totalVisibleFrames:Number = Math.max(Math.ceil(targetWidth / 8), totalRenderedFrames);

			adjustedHorizontalScrollPosition = horizontalScrollPosition - ignoredGroupsLeft * (8 * 5);
			adjustedContentWidth = Math.max(totalRenderedFrames * 8, targetWidth);

			/*trace(
				"  totalFrames", totalFrames,
				"\n  totalFrameGroups", totalFrameGroups,
				"\n  ignoredGroups", ignoredGroupsLeft, ignoredGroupsRight,
				"\n  firstRenderedFrame", firstRenderedFrame,
				"\n  totalRenderedFrames", totalRenderedFrames,
				"\n  adjustedHorizontalScrollPosition", adjustedHorizontalScrollPosition,
				"\n  adjustedContentWidth", adjustedContentWidth,
				"\n  contentWidth", contentWidth,
				"\n  targetWidth", targetWidth
			);*/

			var y:Number = llv.start(startIndex);
			var index:int = startIndex;
			var fixedRowHeight:Number = rowHeight;
			for (; (y < maxVisibleY) && (index < eltCount); index++)
			{
				var elt:TimelineRenderer = layoutTarget.getVirtualElementAt(index, NaN, NaN) as TimelineRenderer;
				elt.setLayoutBoundsSize(adjustedContentWidth, fixedRowHeight);
				elt.setLayoutBoundsPosition(paddingLeft, y);
				elt.setVisibleFrames(firstRenderedFrame, (elt is TimelineRulerRenderer) ? totalVisibleFrames : totalRenderedFrames);
				llv.cacheDimensions(index, elt);
				y += fixedRowHeight;
			}
			var endIndex:int = index - 1;
			
			var contentHeight:Number = llv.end(llv.length - 1) - paddingTop;
			
			setRowCount(index - startIndex);
			setIndexInView(startIndex, endIndex);
			
			// Make sure that if the content spans partially over a pixel to the right/bottom,
			// the content size includes the whole pixel.
			var paddedContentWidth:Number = Math.ceil(contentWidth + paddingLeft + paddingRight);
			var paddedContentHeight:Number = Math.ceil(contentHeight + paddingTop + paddingBottom);
			layoutTarget.setContentSize(paddedContentWidth, paddedContentHeight);
		}
		
		/**
		 *  @private
		 */
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var layoutTarget:GroupBase = target; 
			if (!layoutTarget)
				return;
			
			if ((layoutTarget.numElements == 0) || (unscaledWidth == 0) || (unscaledHeight == 0)) {
				setRowCount(0);
				setIndexInView(-1, -1);
				if (layoutTarget.numElements == 0) {
					layoutTarget.setContentSize(
						Math.ceil(paddingLeft + paddingRight),
						Math.ceil(paddingTop + paddingBottom));
				}
				return;         
			}
			
			//trace("layout updateDisplayList", unscaledWidth, unscaledHeight)

			updateDisplayListVirtual();
		}
		
		/**
		 *  @private 
		 *  Convenience function for subclasses that invalidates the
		 *  target's size and displayList so that both layout's <code>measure()</code>
		 *  and <code>updateDisplayList</code> methods get called.
		 * 
		 *  <p>Typically a layout invalidates the target's size and display list so that
		 *  it gets a chance to recalculate the target's default size and also size and
		 *  position the target's elements. For example changing the <code>gap</code>
		 *  property on a <code>VerticalLayout</code> will internally call this method
		 *  to ensure that the elements are re-arranged with the new setting and the
		 *  target's default size is recomputed.</p> 
		 */
		private function invalidateTargetSizeAndDisplayList():void
		{
			var g:GroupBase = target;
			if (!g)
				return;
			
			g.invalidateSize();
			g.invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Drop methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private 
		 */
		override protected function calculateDropIndex(x:Number, y:Number):int
		{
			// Iterate over the visible elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			
			// If there are no items, insert at index 0
			if (count == 0)
				return 0;
			
			// Go through the visible elements
			var minDistance:Number = Number.MAX_VALUE;
			var bestIndex:int = -1;
			var start:int = this.firstIndexInView;
			var end:int = this.lastIndexInView;
			
			for (var i:int = start; i <= end; i++)
			{
				var elementBounds:Rectangle = this.getElementBounds(i);
				if (!elementBounds)
					continue;
				
				if (elementBounds.top <= y && y <= elementBounds.bottom)
				{
					var centerY:Number = elementBounds.y + elementBounds.height / 2;
					return (y < centerY) ? i : i + 1;
				}
				
				var curDistance:Number = Math.min(Math.abs(y - elementBounds.top),
					Math.abs(y - elementBounds.bottom));
				if (curDistance < minDistance)
				{
					minDistance = curDistance;
					bestIndex = (y < elementBounds.top) ? i : i + 1;
				}
			}
			
			// If there are no visible elements, either pick to drop at the beginning or at the end
			if (bestIndex == -1)
				bestIndex = getElementBounds(0).y < y ? count : 0;
			
			return bestIndex;
		}
		
		/**
		 *  @private
		 */
		override protected function calculateDropIndicatorBounds(dropLocation:DropLocation):Rectangle
		{
			var dropIndex:int = dropLocation.dropIndex;
			var count:int = target.numElements;
			
			var emptySpaceTop:Number = 0;
			if (target.numElements > 0)
			{
				emptySpaceTop = (dropIndex < count) ? getElementBounds(dropIndex).top : 
					getElementBounds(dropIndex - 1).bottom;
			}
			
			// Calculate the size of the bounds, take minium and maximum into account
			var width:Number = Math.max(target.width, target.contentWidth) - paddingLeft - paddingRight;
			var height:Number = 0;
			if (dropIndicator is IVisualElement)
			{
				var element:IVisualElement = IVisualElement(dropIndicator);
				height = Math.max(Math.min(height, element.getMaxBoundsHeight(false)), element.getMinBoundsHeight(false));
			}
			
			var x:Number = paddingLeft;
			var y:Number = emptySpaceTop - Math.round(height / 2);
			// Allow 1 pixel overlap with container border
			y = Math.max(-1, Math.min(target.contentHeight - height + 1, y));
			return new Rectangle(x, y, width, height);
		}
		
		/**
		 *  @private
		 */
		override protected function calculateDragScrollDelta(dropLocation:DropLocation,
															 elapsedTime:Number):Point
		{
			var delta:Point = super.calculateDragScrollDelta(dropLocation, elapsedTime);
			// Don't scroll in the horizontal direction
			if (delta)
				delta.x = 0;
			return delta;
		}
		
		
		override public function updateScrollRect(w:Number, h:Number):void
		{
			var g:GroupBase = target;
			if (!g)
				return;
			
			if (clipAndEnableScrolling) {
				//var hsp:Number = horizontalScrollPosition;
				var vsp:Number = verticalScrollPosition;
				g.scrollRect = new Rectangle(adjustedHorizontalScrollPosition, vsp, w, h);
			} else {
				g.scrollRect = null;
			}
		}
	}
}
import mx.containers.utilityClasses.FlexChildInfo;
import mx.core.ILayoutElement;

class LayoutElementFlexChildInfo extends FlexChildInfo
{
	public var layoutElement:ILayoutElement;    
}

class SizesAndLimit
{
	public var preferredSize:Number;
	public var minSize:Number;
}
