package flare.vis.operator.layout;

	import flare.util.Arrays;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places tree nodes in a radial layout, laying out depths of a tree
	 * along circles of increasing radius. 
	 * This layout can be used for both node-link diagrams, where nodes are
	 * connected by edges, and for radial space-filling ("sunburst") diagrams.
	 * To generate space-filling layouts, nodes should have their shape
	 * property set to <code>Shapes.WEDGE</code> and the layout instance should
	 * have the <code>useNodeSize<code> property set to false.
	 * 
	 * <p>The algorithm used is an adaptation of a technique by Ka-Ping Yee,
	 * Danyel Fisher, Rachna Dhamija, and Marti Hearst, published in the paper
	 * <a href="http://citeseer.ist.psu.edu/448292.html">Animated Exploration of
	 * Dynamic Graphs with Radial Layout</a>, InfoVis 2001. This algorithm computes
	 * a radial layout which factors in possible variation in sizes, and maintains
	 * both orientation and ordering constraints to facilitate smooth and
	 * understandable transitions between layout configurations.
	 * </p>
	 */
	class RadialTreeLayout extends Layout
	{
		public var angleWidth(getAngleWidth, setAngleWidth) : Number;
		public var autoScale(getAutoScale, setAutoScale) : Bool;
		public var radiusIncrement(getRadiusIncrement, setRadiusIncrement) : Number;
		public var sortAngles(getSortAngles, setSortAngles) : Bool;
		public var startAngle(getStartAngle, setStartAngle) : Number;
		public var useNodeSize(getUseNodeSize, setUseNodeSize) : Bool;
		// -- Properties ------------------------------------------------------
		
		/** Property name for storing parameters for this layout. */
		inline public static var PARAMS:String = "radialTreeLayoutParams";
		/** The default radius increment between depth levels. */
		inline public static var DEFAULT_RADIUS:Int = 50;
	
	    private var _maxDepth:Int ;
	    private var _radiusInc:Int ;
	    private var _theta1:Int ;
	    private var _theta2:Int ;
	    private var _sortAngles:Bool ;
	    private var _setTheta:Bool ;
	    private var _autoScale:Bool ;
	    private var _useNodeSize:Bool ;
	    private var _prevRoot:NodeSprite ;

		/** The radius increment between depth levels. */
		public function getRadiusIncrement():Number { return _radiusInc; }
		public function setRadiusIncrement(r:Number):Number { _radiusInc = r; 	return r;}
		
		/** Flag determining if nodes should be sorted by angles to help
		 *  maintain ordering across different spanning-tree configurations.
		 *  This sorting is important for understandable transitions when using
		 *  a radial layout of a general graph. However, it is unnecessary for
		 *  tree structures and increases the running time of layout. */
		public function getSortAngles():Bool { return _sortAngles; }
		public function setSortAngles(b:Bool):Bool { _sortAngles = b; 	return b;}
		
		/** Flag indicating if the layout should automatically be scaled to
		 *  fit within the layout bounds. */
		public function getAutoScale():Bool { return _autoScale; }
		public function setAutoScale(b:Bool):Bool { _autoScale = b; 	return b;}
		
		/** The initial angle for the radial layout (in radians). */
		public function getStartAngle():Number { return _theta1; }
		public function setStartAngle(a:Number):Number {
			_theta2 += (a - _theta1);
			_theta1 = a;
			_setTheta = true;
			return a;
		}
		
		/** The angular width of the layout (in radians, default is 2 pi). */
		public function getAngleWidth():Number { return _theta1 - _theta2; }
		public function setAngleWidth(w:Number):Number {
			_theta2 = _theta1 - w;
			_setTheta = true;
			return w;
		}

		/** Flag indicating if node's <code>size</code> property should be
		 *  used to determine layout spacing. If a space-filling radial
		 *  layout is desired, this value must be false for the layout
		 *  to be accurate. */
		public function getUseNodeSize():Bool { return _useNodeSize; }
		public function setUseNodeSize(b:Bool):Bool {
			_useNodeSize = b;
			return b;
		}

		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new RadialTreeLayout.
		 * @param radius the radius increment between depth levels
		 * @param sortAngles flag indicating if nodes should be sorted by angle
		 *  to maintain node ordering across spanning-tree configurations
		 * @param autoScale flag indicating if the layout should automatically
		 *  be scaled to fit within the layout bounds
		 */		
		public function new(?radius:Int=DEFAULT_RADIUS,
			?sortAngles:Bool=true, ?autoScale:Bool=true)
		{
			
			_maxDepth = 0;
			_radiusInc = DEFAULT_RADIUS;
			_theta1 = Math.PI/2;
			_theta2 = Math.PI/2 - 2*Math.PI;
			_sortAngles = true;
			_setTheta = false;
			_autoScale = true;
			_useNodeSize = true;
			_prevRoot = null;
			layoutType = POLAR;
			_radiusInc = radius;
			_sortAngles = sortAngles;
			_autoScale = autoScale;
		}

		/** @inheritDoc */
		public override function layout():Void
		{
			var n:NodeSprite = cast( layoutRoot, NodeSprite);
			if (n == null) { _t = null; return; }
			var np:Params = params(n);
			
			// calc relative widths and maximum tree depth
        	// performs one pass over the tree
        	_maxDepth = 0;
        	calcAngularWidth(n, 0);
			
			if (_autoScale) setScale(layoutBounds);
			if (!_setTheta) calcAngularBounds(n);
			_anchor = layoutAnchor;
			
			// perform the layout
	        if (_maxDepth > 0) {
	        	doLayout(n, _radiusInc, _theta1, _theta2);
	        } else if (n.childDegree > 0) {
	        	n.visitTreeDepthFirst(function(n:NodeSprite):Void {
	        		n.origin = _anchor;
	        		var o:Dynamic = _t._S_(n);
	        		// collapse to inner radius
					o.radius = o.h = o.v = _radiusInc / 2;
					o.alpha = 0;
					o.mouseEnabled = false;
					if (n.parentEdge != null)
						_t._S_(n.parentEdge).alpha = false;
            	});
	        }
	        
	        // update properties of the root node
	        np.angle = _theta2 - _theta1;
	        n.origin = _anchor;
	        update(n, 0, _theta1+np.angle/2, np.angle, true);
	        if (!_t.immediate) {
	        	delete _t._(n).values.radius;
	        	delete _t._(n).values.angle;
	        }
	        _t._S_(n).x = _anchor.x;
	        _t._S_(n).y = _anchor.y;
			
			updateEdgePoints(_t);
		}
		
		private function setScale(bounds:Rectangle):Void
		{
	        var r:Float = Math.min(bounds.width, bounds.height)/2.0;
	        if (_maxDepth > 0) _radiusInc = r / (_maxDepth+1);
	    }
		
	    /**
	     * Calculates the angular bounds of the layout, attempting to
	     * preserve the angular orientation of the display across transitions.
	     */
	    private function calcAngularBounds(r:NodeSprite):Void
	    {
	        if (_prevRoot == null || r == _prevRoot)
	        {
	            _prevRoot = r; return;
	        }
	        
	        // try to find previous parent of root
	        var p:NodeSprite = _prevRoot, pp:NodeSprite;
	        while (true) {
	        	pp = p.parentNode;
	            if (pp == r) {
	                break;
	            } else if (pp == null) {
	                _prevRoot = r;
	                return;
	            }
	            p = pp;
	        }
	
	        // compute offset due to children's angular width
	        var dt:Int = 0;
	        
	        for each (var n:NodeSprite in sortedChildren(r)) {
	        	if (n == p) break;
	        	dt += params(n).width;
	        }
	        
	        var rw:Int = params(r).width;
	        var pw:Int = params(p).width;
	        dt = -2*Math.PI * (dt+pw/2)/rw;
	
	        // set angular bounds
	        _theta1 = dt + Math.atan2(p.y-r.y, p.x-r.x);
	        _theta2 = _theta1 + 2*Math.PI;
	        _prevRoot = r;     
	    }
		
		/**
	     * Computes relative measures of the angular widths of each
	     * expanded subtree. Node diameters are taken into account
	     * to improve space allocation for variable-sized nodes.
	     * 
	     * This method also updates the base angle value for nodes 
	     * to ensure proper ordering of nodes.
	     */
	    private function calcAngularWidth(n:NodeSprite, d:Int):Number
	    {
	        if (d > _maxDepth) _maxDepth = d;       
	        var aw:Int = 0, diameter:Int = 0;
	        if (_useNodeSize && d > 0) {
	        	//diameter = 1;
	        	diameter = n.expanded && n.childDegree > 0 ? 0 : _t._S_(n).size;
	        } else if (d > 0) {
	        	var w:Int = n.width, h:Int = n.height;
	        	diameter = Math.sqrt(w*w+h*h)/d;
	        	if (isNaN(diameter)) diameter = 0;
	        }

	        if (n.expanded && n.childDegree > 0) {
	        	var c:NodeSprite=n.firstChildNode;
	        	while (c!=null)
	        	{
	        		aw += calcAngularWidth(c, d+1);
	        		c=c.nextNode;
	        	}
	        	aw = Math.max(diameter, aw);
	        } else {
	        	aw = diameter;
	        }
			params(n).width = aw;
	        return aw;
	    }
		
		private static function normalize(angle:Number):Number
		{
	        while (angle > 2*Math.PI)
	            angle -= 2*Math.PI;
	        while (angle < 0)
	            angle += 2*Math.PI;
	        return angle;
	    }

		private function sortedChildren(n:NodeSprite):Array<Dynamic>
		{
			var cc:Int = n.childDegree;
			if (cc == 0) return Arrays.EMPTY;
			var angles:Array<Dynamic> = new Array(cc);
	        
	        if (_sortAngles) {
	        	// update base angle for node ordering			
				var base:Int = -_theta1;
				var p:NodeSprite = n.parentNode;
	        	if (p != null) base = normalize(Math.atan2(p.y-n.y, n.x-p.x));
	        	
	        	// collect the angles
	        	var c:NodeSprite = n.firstChildNode;
		        for (i in 0...cc) {
		        	angles[i] = normalize(-base + Math.atan2(c.y-n.y,n.x-c.x));
		        }
		        // get array of indices, sorted by angle
		        angles = angles.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
		        // switch in the actual nodes and return
		        for (i in 0...cc) {
		        	angles[i] = n.getChildNode(angles[i]);
		        }
		    } else {
		    	for (i in 0...cc) {
		        	angles[i] = n.getChildNode(i);
		        }
		    }
	        
	        return angles;
	    }
		
		/**
	     * Compute the layout.
	     * @param n the root of the current subtree under consideration
	     * @param r the radius, current distance from the center
	     * @param theta1 the start (in radians) of this subtree's angular region
	     * @param theta2 the end (in radians) of this subtree's angular region
	     */
	    private function doLayout(n:NodeSprite, r:Number,
	    	theta1:Number, theta2:Number):Void
	    {
	    	var dtheta:Int = theta2 - theta1;
	    	var dtheta2:Float = dtheta / 2.0;
	    	var width:Int = params(n).width;
	    	var cfrac:Number, nfrac:Int = 0;
	        
	        for each (var c:NodeSprite in sortedChildren(n)) {
	        	var cp:Params = params(c);
	            cfrac = cp.width / width;
	            if (c.expanded && c.childDegree > 0)
	            {
	                doLayout(c, r+_radiusInc, theta1 + nfrac*dtheta, 
	                                          theta1 + (nfrac+cfrac)*dtheta);
	            }
	            else if (c.childDegree > 0)
	            {
	            	var cr:Int = r + _radiusInc;
	            	var ca:Int = theta1 + nfrac*dtheta + cfrac*dtheta2;
	            	
	            	c.visitTreeDepthFirst(function(n:NodeSprite):Void {
	            		n.origin = _anchor;
	            		update(n, cr, minAngle(n.angle, ca), 0, false);
	            	});
	            }
	            
	            c.origin = _anchor;
	            var a:Int = minAngle(c.angle, theta1 + nfrac*dtheta + cfrac*dtheta2);
	            cp.angle = cfrac * dtheta;
	            update(c, r, a, cp.angle, true);
	            nfrac += cfrac;
	        }
	    }
		
		private function update(n:NodeSprite, r:Number, a:Number,
								aw:Number, v:Bool) : Void
		{
			var o:Dynamic = _t._S_(n), alpha:Int = v ? 1 : 0;
			o.radius = r;
			o.angle = a;
			if (aw == 0) {
				o.h = o.v = r - _radiusInc/2;
			} else {
				o.h = r + _radiusInc/2;
				o.v = r - _radiusInc/2;
			}
			o.w = aw;
			o.u = a - aw/2;
			o.alpha = alpha;
			o.mouseEnabled = v;
			if (n.parentEdge != null)
				_t._S_(n.parentEdge).alpha = alpha;
		}
				
		private function params(n:NodeSprite):Params
		{
			var p:Params = n.props[PARAMS];
			if (p == null) {
				p = new Params();
				n.props[PARAMS] = p;
			}
			return p;
		}
		
	} // end of class RadialTreeLayout
