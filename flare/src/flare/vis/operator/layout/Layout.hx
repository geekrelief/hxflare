package flare.vis.operator.layout;

	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Base class for all operators that perform spatial layout. Provides
	 * methods for retrieving the desired layout bounds, providing a layout
	 * anchor point, and returning the layout root (for tree layouts in
	 * particular). This class also provides convenience methods for
	 * manipulating the visibility of axes and performing common updates
	 * to edge control points in graph/tree visualizations.
	 */
	class Layout extends Operator
	{
		public var layoutAnchor(getLayoutAnchor, setLayoutAnchor) : Point;
		public var layoutBounds(getLayoutBounds, setLayoutBounds) : Rectangle;
		public var layoutRoot(getLayoutRoot, setLayoutRoot) : DataSprite;
		public var xyAxes(getXyAxes, null) : CartesianAxes
		;
		/** Constant indicating Cartesian (x, y) coordinates. */
		inline public static var CARTESIAN:String = "cartesian";
		/** Constant indicating polar (radius, angle) coordinates. */
		inline public static var POLAR:String = "polar";
		
		/** @private */
		public static var _dummy:Shape = new Shape();
		/** @private */
		public static var _rect:Rectangle = new Rectangle();
		
		// -- Properties ------------------------------------------------------
				
		/** The type of layout and axes. This value should be
		 *  <code>CARTESIAN</code> for x,y axes, <code>POLAR</code> for polar
		 *  coordinates (radius, angle), or null for no axes. */
		public var layoutType:String ;
		
		/** A transitioner for storing value updates. */
		public var _t:Transitioner ;
		
		public var _anchor:Point ;
		public var _setAnchor:Bool ;
		
		private var _bounds:Rectangle ;
		private var _root:DataSprite ;
		
		/** The layout bounds for the layout. If this value is not explicitly
		 *  set, the bounds for the visualization is returned. */
		public function getLayoutBounds():Rectangle {
			if (_bounds != null) return _bounds;
			if (visualization != null) return visualization.bounds;
			return null;
		}
		public function setLayoutBounds(b:Rectangle):Rectangle { _bounds = b; 	return b;}
		
		/** The layout anchor, used by some layout instances to place an
		 *  initial item or determine a focal point. */
		public function getLayoutAnchor():Point {
			if (!_setAnchor)
				autoAnchor();
			return _anchor;
		}
		public function setLayoutAnchor(p:Point):Point {
			_anchor = p;
			_setAnchor = true;
			return p;
		}
		
		/** Automatically-generate an anchor point. */
		public function autoAnchor():Void
		{
			if (layoutType == POLAR) {
				var b:Rectangle = layoutBounds;
				_anchor.x = (b.left + b.right) / 2;
				_anchor.y = (b.top + b.bottom) / 2;
			} else {
				_anchor.x = 0;
				_anchor.y = 0;
			}
		}
		
		/** The layout root, the root node for tree layouts. */
		public function getLayoutRoot():DataSprite {
			if (_root != null) return _root;
			if (visualization != null) {
				return visualization.data.tree.root;
			}
			return null;
		}
		public function setLayoutRoot(r:DataSprite):DataSprite { _root = r; 	return r;}
		
				
		// -- Placement and Axis Helpers --------------------------------------
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			_t = (t ? t : Transitioner.DEFAULT);
			adjustAxes();
			layout();
			_t = null;
		}
		
		/**
		 * Calculates the spatial layout of visualized items. Layout operators
		 * override this method with their layout implementations.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		public function layout():Void
		{
			// sub-classes should override
		}
		
		/** @private */
		public function adjustAxes():Void
		{
			if (layoutType == CARTESIAN) {
				showAxes(_t);
			} else {
				hideAxes(_t);
			}
		}
		
		/**
		 * Reveals the axes.
		 * @param t a transitioner to collect value updates
		 * @return the input transitioner
		 */
		public function showAxes(?t:Transitioner=null):Transitioner
		{
			var axes:Axes = visualization.axes;
			if (axes == null || axes.visible) return t;
			
			if (t==null || t.immediate) {
				axes.alpha = 1;
				axes.visible = true;
			} else {
				t._S_(axes).alpha = 1;
				t._S_(axes).visible = true;
			}
			return t;
		}
		
		/**
		 * Hides the axes.
		 * @param t a transitioner to collect value updates
		 * @return the input transitioner
		 */
		public function hideAxes(?t:Transitioner=null):Transitioner
		{
			var axes:Axes = visualization.axes;
			if (axes == null || !axes.visible) return t;
			
			if (t==null || t.immediate) {
				axes.alpha = 0;
				axes.visible = false;
			} else {
				t._S_(axes).alpha = 0;
				t._S_(axes).visible = false;
			}
			return t;
		}
		
		/**
		 * Returns the visualization's axes as a CartesianAxes instance.
		 * Creates/modifies existing axes as needed to ensure the
		 * presence of CartesianAxes.
		 */
		public function getXyAxes():CartesianAxes
		{
			var vis:Visualization = visualization;
			if (vis == null) return null;
			
			if (vis.xyAxes == null) {
				vis.axes = new CartesianAxes();
			}
			return vis.xyAxes;
		}
		
		/**
		 * Returns an angle value that minimizes the angular distance
		 * between a reference angle and a target angle. This
		 * method may shift the angle value by multiples of 2 pi.
		 * @param a1 the reference angle to stay close to
		 * @param a2 the target angle value
		 * @return an angle that minimizes the distance
		 */
		public static function minAngle(a1:Number, a2:Number):Number
	    {
	    	var d1:Int = a2 - a1;
	    	var d2:Int = Math.abs(d1 - 2*Math.PI);
	    	var d3:Int = Math.abs(d1 + 2*Math.PI);
	    	d1 = Math.abs(d1);
	    	
	    	if (d1 < d2 && d1 < d3) {
	    		return a2;
	    	} else if (d1 < d3) {
	    		return a2 - 2*Math.PI;
	    	} else {
	    		return a2 + 2*Math.PI;
	    	}
	    }
		
		// -- Edge Helpers ----------------------------------------------------
		
		private static var _clear:Bool;
		
		/**
		 * Updates all edges to be straight lines. Useful for undoing the
		 * results of layouts that route edges using edge control points.
		 * @param list a data list of edges to straighten
		 * @param t a transitioner to collect value updates
		 */
		public static function straightenEdges(list:DataList,
			t:Transitioner):Transitioner
		{
			// set end points to mid-points
			list.visit(function(e:EdgeSprite):Void {
				if (e.points == null) return;
				_clear = true;
				
				var src:NodeSprite = e.source;
				var trg:NodeSprite = e.target;
				
				// create new control points
				var i:UInt, len:UInt = e.points.length, f:Number;
				var cp:Array<Dynamic> = new Array(len);
				var x1:Number, y1:Number, x2:Number, y2:Number;
				
				// get target end points
				x1 = t._S_(src).x; y1 = t._S_(src).y;
				x2 = t._S_(trg).x; y2 = t._S_(trg).y;
				
				i=0;
				while (i<len) {
					f = (i+2)/(len+2);
					cp[i]   = x1 + f * (x2 - x1);
					cp[i+1] = y1 + f * (y2 - y1);
					i+=2;
				}
				t._S_(e).points = cp;
			});
			return t;
		}
		
		/** @private */
		public function updateEdgePoints(?t:Transitioner=null):Void
		{
			if (t==null || t.immediate || layoutType==POLAR) {
				clearEdgePoints();
			} else {
				_clear = false;
				straightenEdges(visualization.data.edges, t);
				// after transition, clear out control points
				if (_clear) {
					var f:Dynamic = function(evt:Event):Void {
						clearEdgePoints();
						t.removeEventListener(TransitionEvent.END, f);
					};
					t.addEventListener(TransitionEvent.END, f);
				}
			}
		}
		
		/**
		 * Strips all EdgeSprites in a visualization of any control points.
		 */
		public function clearEdgePoints():Void
		{
			visualization.data.edges["points"] = null;
		}
		
	} // end of class Layout
