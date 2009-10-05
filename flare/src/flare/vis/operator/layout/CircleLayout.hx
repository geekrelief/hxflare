package flare.vis.operator.layout;

	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.ScaleBinding;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places items in a circular layout. This operator is quite
	 * flexible and offers a number of layout options:
	 * <ul>
	 *  <li>By default, all items are arranged along the circumference of the
	 *      circle using the sort order of the underlying data list.</li>
	 *  <li>If a data field for either the radius or angle is provided, this
	 *      layout will act as a radial scatter plot, using the data fields
	 *      to determine the radius or angle values of the layout.</li>
	 *  <li>If no data field is provided but the <code>treeLayout</code>
	 *      property is set to <code>true</code>, the layout will use an
	 *      underlying tree structure to layout the data. Leaf nodes will be
	 *      placed along the circumference of the circle, but parent nodes will
	 *      be placed in the interior. Also, the layout will add spacing to
	 *      differentiate sibling groups along the circumference.</li>
	 * </ul>
	 * 
	 * <p>The layout also supports mixes of the above modes. For example, if
	 * <code>treeLayout</code> is set to <code>true</code> and a data field for
	 * the radius is set, the angles in the layout will be determined as in
	 * a normal ciruclar tree layout, but the radius values will be derived
	 * using the data field.</p>
	 */
	class CircleLayout extends Layout
	{	
		public var angleField(getAngleField, setAngleField) : String;	
		public var angleScale(getAngleScale, setAngleScale) : ScaleBinding;	
		public var radiusField(getRadiusField, setRadiusField) : String;	
		public var radiusScale(getRadiusScale, setRadiusScale) : ScaleBinding;	
		public var startRadius(getStartRadius, setStartRadius) : Number;	
		public var startRadiusFraction(getStartRadiusFraction, setStartRadiusFraction) : Number;	
		/** The padding around the circumference of the circle, in pixels. */
		public var padding:Int ;
		/** The starting angle for the layout, in radians. */
		public var startAngle:Int ;
		/** The angular width of the layout, in radians (default is 2 pi). */
		public var angleWidth:Int ;
		/** Flag indicating if tree structure should inform the layout. */
		public var treeLayout:Bool ;
		
		public var _inner:Int , _innerFrac:Int ;
		public var _outer:Number;
		public var _group:String;
		public var _rField:Property;
		public var _aField:Property;
		public var _rBinding:ScaleBinding;
		public var _aBinding:ScaleBinding;
		
		/** The starting (inner) radius at which to place items. 
		 *  Setting this value also overrides the
		 *  <code>startRadiusFraction</code> property. */
		public function getStartRadius():Number { return _inner; }
		public function setStartRadius(r:Number):Number {
			_inner = r; _innerFrac = NaN;
			return r;
		}
		
		/** The starting (inner) radius as a fraction of the outer radius. 
		 *  Setting this value also overrides the 
		 *  <code>startRadius</code> property. When this property is set to
		 *  <code>NaN</code>, the current value of <code>startRadius</code>
		 *  will be used directly. */
		public function getStartRadiusFraction():Number { return _innerFrac; }
		public function setStartRadiusFraction(f:Number):Number {
			_innerFrac = f;
			return f;
		}
		
		/** The radius source property. */
		public function getRadiusField():String { return _rBinding.property; }
		public function setRadiusField(f:String):String { _rBinding.property = f; 	return f;}
		
		/** The angle source property. */
		public function getAngleField():String { return _aBinding.property; }
		public function setAngleField(f:String):String { _aBinding.property = f; 	return f;}
		
		/** The scale binding for the radius. */
		public function getRadiusScale():ScaleBinding { return _rBinding; }
		public function setRadiusScale(b:ScaleBinding):ScaleBinding {
			if (_rBinding) {
				if (!b.property) b.property = _rBinding.property;
				if (!b.group) b.group = _rBinding.group;
				if (!b.data) b.data = _rBinding.data;
			}
			_rBinding = b;
			return b;
		}
		
		/** The scale binding for the angle. */
		public function getAngleScale():ScaleBinding { return _aBinding; }
		public function setAngleScale(b:ScaleBinding):ScaleBinding {
			if (_aBinding) {
				if (!b.property) b.property = _aBinding.property;
				if (!b.group) b.group = _aBinding.group;
				if (!b.data) b.data = _aBinding.data;
			}
			_aBinding = b;
			return b;
		}
		
		// --------------------------------------------------------------------
				
		/**
		 * Creates a new CircleLayout.
		 * @param radiusField optional data field to encode as radius length
		 * @param angleField optional data field to encode as angle
		 * @param treeLayout boolean flag indicating if any tree-structure in
		 *  the data should be used to inform the layout
		 * @param group the data group to process. If tree layout is set to
		 *  true, this value may get ignored.
		 */
		public function new(
			?radiusField:String=null, ?angleField:String=null,
			?treeLayout:Bool=false, ?group:String=Data.NODES)
		{
			
			padding = 50;
			startAngle = Math.PI / 2;
			angleWidth = 2 * Math.PI;
			treeLayout = false;
			_inner = 0;
			_innerFrac = NaN;
			layoutType = POLAR;
			_group = group;
			this.treeLayout = treeLayout;
			
			_rBinding = new ScaleBinding();
			_rBinding.group = _group;
			_rBinding.property = radiusField;
			
			_aBinding = new ScaleBinding();
			_aBinding.group = _group;
			_aBinding.property = angleField;
		}
		
		/** @inheritDoc */
		public override function setup():Void
		{
			if (visualization==null) return;
			_rBinding.data = visualization.data;
			_aBinding.data = visualization.data;
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{			
			var list:DataList = visualization.data.group(_group);
			var i:Int = 0, N:Int = list.length, dr:Number;
			var visitor:Dynamic = null;
			
			// determine radius
			var b:Rectangle = layoutBounds;
			_outer = Math.min(b.width, b.height)/2 - padding;
			_inner = isNaN(_innerFrac) ? _inner : _outer * _innerFrac;
			
			// set the anchor point
			var anchor:Point = layoutAnchor;
			list.visit(function(n:NodeSprite):Void { n.origin = anchor; });
			
			// compute angles
			if (_aBinding.property) {
				// if angle property, get scale binding and do layout
				_aBinding.updateBinding();
				_aField = Property._S_(_aBinding.property);
				visitor = function(n:NodeSprite):Void {
					var f:Int = _aBinding.interpolate(_aField.getValue(n));
					_t._S_(n).angle = minAngle(n.angle, 
					                         startAngle - f*angleWidth);
				};
			} else if (treeLayout) {
				// if tree mode, use tree order
				setTreeAngles();
			} else {
				// if nothing use total sort order
				i = 0;
				visitor = function(n:NodeSprite):Void {
					_t._S_(n).angle = minAngle(n.angle,
						                     startAngle - (i/N)*angleWidth);
					i++;
				};
			}
			if (visitor != null) list.visit(visitor);
			
			// compute radii
			visitor = null;
			if (_rBinding.property) {
				// if radius property, get scale binding and do layout
				_rBinding.updateBinding();
				_rField = Property._S_(_rBinding.property);
				dr = _outer - _inner;
				visitor = function(n:NodeSprite):Void {
					var f:Int = _rBinding.interpolate(_rField.getValue(n));
					_t._S_(n).radius = _inner + f * dr;
				};
			} else if (treeLayout) {
				// if tree-mode, use tree depth
				setTreeRadii();
			} else {
				// if nothing, use outer radius
				visitor = function(n:NodeSprite):Void {
					_t._S_(n).radius = _outer;
				};
			}
			if (visitor != null) list.visit(visitor);
			if (treeLayout) _t._S_(visualization.data.tree.root).radius = 0;
			
			// finish up
			updateEdgePoints(_t);
		}
		
		private function setTreeAngles():Void
		{
			// first pass, determine the angular spacing
			var root:NodeSprite = visualization.tree.root, p:NodeSprite = null;
			var leafCount:Int = 0, parentCount:Int = 0;
			root.visitTreeDepthFirst(function(n:NodeSprite):Void {
				if (n.childDegree == 0) {
					if (p != n.parentNode) {
						p = n.parentNode;
						++parentCount;
					}
					++leafCount;
				}
			});
			var inc:Int = (-angleWidth) / (leafCount + parentCount);
			var angle:Int = startAngle;
			
			// second pass, set the angles
			root.visitTreeDepthFirst(function(n:NodeSprite):Void {
				var a:Int = 0, b:Number;
				if (n.childDegree == 0) {
					if (p != n.parentNode) {
						p = n.parentNode;
						angle += inc;
					}
					a = angle;
					angle += inc;
				} else if (n.parent != null) {
					a = _t._S_(n.firstChildNode).angle;
					b = _t._S_(n.lastChildNode).angle - a;
					while (b >  Math.PI) b -= 2*Math.PI;
					while (b < -Math.PI) b += 2*Math.PI;
					a += b / 2;
				}
				_t._S_(n).angle = minAngle(n.angle, a);
			});
		}
		
		private function setTreeRadii():Void
		{
			var n:NodeSprite;
			var depth:Int = 0, dr:Int = _outer - _inner;
			
			for each (n in visualization.tree.nodes) {
				if (n.childDegree == 0) {
					depth = Math.max(n.depth, depth);
					_t._S_(n).radius = _outer;
				}
			}
			for each (n in visualization.tree.nodes) {
				if (n.childDegree != 0) {
					_t._S_(n).radius = _inner + (n.depth/depth) * dr;
				}
			}
			
			n = visualization.tree.root;
			if (!_t.immediate) {
	        	delete _t._(n).values.radius;
	        	delete _t._(n).values.angle;
	        }
	        _t._S_(n).x = n.origin.x;
	        _t._S_(n).y = n.origin.y;
		}
		
	} // end of class CircleLayout
