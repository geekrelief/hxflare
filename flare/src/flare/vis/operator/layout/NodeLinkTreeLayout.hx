package flare.vis.operator.layout;

	import flare.util.Arrays;
	import flare.util.Orientation;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places nodes using a tidy layout of a node-link tree
	 * diagram. This algorithm lays out a rooted tree such that each
	 * depth level of the tree is on a shared line. The orientation of the
	 * tree can be set such that the tree goes left-to-right (default),
	 * right-to-left, top-to-bottom, or bottom-to-top.
	 * 
	 * <p>The algorithm used is that of Christoph Buchheim, Michael Jünger,
	 * and Sebastian Leipert from their research paper
	 * <a href="http://citeseer.ist.psu.edu/buchheim02improving.html">
	 * Improving Walker's Algorithm to Run in Linear Time</a>, Graph Drawing 2002.
	 * This algorithm corrects performance issues in Walker's algorithm, which
	 * generalizes Reingold and Tilford's method for tidy drawings of trees to
	 * support trees with an arbitrary number of children at any given node.</p>
	 */
	class NodeLinkTreeLayout extends Layout
	{
		public var breadthSpacing(getBreadthSpacing, setBreadthSpacing) : Number;
		public var depthSpacing(getDepthSpacing, setDepthSpacing) : Number;
		public var orientation(getOrientation, setOrientation) : String;
		public var subtreeSpacing(getSubtreeSpacing, setSubtreeSpacing) : Number;
		// -- Properties ------------------------------------------------------
		
		/** Property name for storing parameters for this layout. */
		inline public static var PARAMS:String = "nodeLinkTreeLayoutParams";
		
		private var _orient:String ; // orientation
		private var _bspace:Int ;  // the spacing between sibling nodes
    	private var _tspace:Int ; // the spacing between subtrees
    	private var _dspace:Int ; // the spacing between depth levels
    	private var _depths:Array<Dynamic> ; // stores depth co-ords
    	private var _maxDepth:Int ;
    	private var _ax:Number, _ay:Number; // for holding anchor co-ordinates
		
		/** The orientation of the layout. */
		public function getOrientation():String { return _orient; }
		public function setOrientation(o:String):String { _orient = o; 	return o;}
		
		/** The space between successive depth levels of the tree. */
		public function getDepthSpacing():Number { return _dspace; }
		public function setDepthSpacing(s:Number):Number { _dspace = s; 	return s;}
		
		/** The space between siblings in the tree. */
		public function getBreadthSpacing():Number { return _bspace; }
		public function setBreadthSpacing(s:Number):Number { _bspace = s; 	return s;}
		
		/** The space between different sub-trees. */
		public function getSubtreeSpacing():Number { return _tspace; }
		public function setSubtreeSpacing(s:Number):Number { _tspace = s; 	return s;}
		
		
		// -- Methods ---------------------------------------------------------
	
		/**
		 * Creates a new NodeLinkTreeLayout.
		 * @param orientation the orientation of the layout
		 * @param depthSpace the space between depth levels in the tree
		 * @param breadthSpace the space between siblings in the tree
		 * @param subtreeSpace the space between different sub-trees
		 */		
		public function new(
			?orientation:String=Orientation.LEFT_TO_RIGHT, ?depthSpace:Int=50,
			?breadthSpace:Int=5, ?subtreeSpace:Int=25)
		{
			
			_orient = Orientation.LEFT_TO_RIGHT;
			_bspace = 5;
			_tspace = 25;
			_dspace = 50;
			_depths = new Array(20);
			_maxDepth = 0;
			_orient = orientation;
			_dspace = depthSpace;
			_bspace = breadthSpace;
			_tspace = subtreeSpace;
		}
	
		/** @inheritDoc */
		public override function layout():Void
		{
        	Arrays.fill(_depths, 0);
        	_maxDepth = 0;
        	
        	var root:NodeSprite = cast( layoutRoot, NodeSprite);
        	if (root == null) { _t = null; return; }
        	var rp:Params = params(root);

        	firstWalk(root, 0, 1);                       // breadth/depth stats
        	var a:Point = layoutAnchor;
        	_ax = a.x; _ay = a.y;                        // determine anchor
        	determineDepths();                           // sum depth info
        	secondWalk(root, null, -rp.prelim, 0, true); // assign positions
        	updateEdgePoints(_t);                        // update edges
    	}

		public override function autoAnchor():Void
		{
			// otherwise generate anchor based on the bounds
			var b:Rectangle = layoutBounds;
			var r:NodeSprite = cast( layoutRoot, NodeSprite);
			switch (_orient) {
			case Orientation.LEFT_TO_RIGHT:
				_ax = b.x + _dspace + r.w;
				_ay = b.y + b.height / 2;
				break;
			case Orientation.RIGHT_TO_LEFT:
				_ax = b.width - (_dspace + r.w);
				_ay = b.y + b.height / 2;
				break;
			case Orientation.TOP_TO_BOTTOM:
				_ax = b.x + b.width / 2;
				_ay = b.y + _dspace + r.h;
				break;
			case Orientation.BOTTOM_TO_TOP:
				_ax = b.x + b.width / 2;
				_ay = b.height - (_dspace + r.h);
				break;
			default:
				throw new Error("Unrecognized orientation value");
			}
			_anchor.x = _ax;
			_anchor.y = _ay;
		}

    	private function firstWalk(n:NodeSprite, num:Int, depth:UInt):Void
    	{
    		setSizes(n);
    		updateDepths(depth, n);
    		var np:Params = params(n);
    		np.number = num;
    		
    		var expanded:Bool = n.expanded;
    		if (n.childDegree == 0 || !expanded) // is leaf
    		{
    			var l:NodeSprite = n.prevNode;
    			np.prelim = l==null ? 0 : params(l).prelim + spacing(l,n,true);
    		}
    		else if (expanded) // has children, is expanded
    		{
    			var midpoint:Number, i:UInt;
    			var lefty:NodeSprite = n.firstChildNode;
    			var right:NodeSprite = n.lastChildNode;
    			var ancestor:NodeSprite = lefty;
    			var c:NodeSprite = lefty;
    			
    			i=0;
    			while (c != null) {
    				firstWalk(c, i, depth+1);
    				ancestor = apportion(c, ancestor);
    				++i, c = c.nextNode;
    			}
    			executeShifts(n);
    			midpoint = 0.5 * (params(lefty).prelim + params(right).prelim);
    			
    			l = n.prevNode;
    			if (l != null) {
    				np.prelim = params(l).prelim + spacing(l,n,true);
    				np.mod = np.prelim - midpoint;
    			} else {
    				np.prelim = midpoint;
    			}
    		}
    	}
    
    	private function apportion(v:NodeSprite, a:NodeSprite):NodeSprite
    	{
    		var w:NodeSprite = v.prevNode;
    		if (w != null) {
    			var vip:NodeSprite, vim:NodeSprite, vop:NodeSprite, vom:NodeSprite;
    			var sip:Number, sim:Number, sop:Number, som:Number;
    			
    			vip = vop = v;
    			vim = w;
    			vom = vip.parentNode.firstChildNode;
    			
    			sip = params(vip).mod;
    			sop = params(vop).mod;
    			sim = params(vim).mod;
    			som = params(vom).mod;
    			
    			var shift:Number;
    			var nr:NodeSprite = nextRight(vim);
    			var nl:NodeSprite = nextLeft(vip);
    			while (nr != null && nl != null) {
    				vim = nr;
    				vip = nl;
    				vom = nextLeft(vom);
    				vop = nextRight(vop);
    				params(vop).ancestor = v;
    				shift = (params(vim).prelim + sim) - 
    					(params(vip).prelim + sip) + spacing(vim,vip,false);
    				
    				if (shift > 0) {
    					moveSubtree(ancestor(vim,v,a), v, shift);
    					sip += shift;
    					sop += shift;
    				}
    				
    				sim += params(vim).mod;
                	sip += params(vip).mod;
                	som += params(vom).mod;
                	sop += params(vop).mod;
                
                	nr = nextRight(vim);
                	nl = nextLeft(vip);
            	}
            	if (nr != null && nextRight(vop) == null) {
                	var vopp:Params = params(vop);
                	vopp.thread = nr;
                	vopp.mod += sim - sop;
            	}
            	if (nl != null && nextLeft(vom) == null) {
                	var vomp:Params = params(vom);
                	vomp.thread = nl;
                	vomp.mod += sip - som;
                	a = v;
            	}
        	}
        	return a;
    	}
    
    	private function nextLeft(n:NodeSprite):NodeSprite
    	{
    		var c:NodeSprite = null;
        	if (n.expanded) c = n.firstChildNode;
        	return (c != null ? c : params(n).thread);
    	}

    	private function nextRight(n:NodeSprite):NodeSprite
    	{
    		var c:NodeSprite = null;
    		if (n.expanded) c = n.lastChildNode;
        	return (c != null ? c : params(n).thread);
    	}

		private function moveSubtree(wm:NodeSprite, wp:NodeSprite, shift:Number):Void
		{
			var wmp:Params = params(wm);
			var wpp:Params = params(wp);
			var subtrees:Int = wpp.number - wmp.number;
			wpp.change -= shift/subtrees;
			wpp.shift += shift;
			wmp.change += shift/subtrees;
			wpp.prelim += shift;
			wpp.mod += shift;
		}   

		private function executeShifts(n:NodeSprite):Void
		{
			var shift:Int = 0, change:Int = 0;
			var c:NodeSprite = n.lastChildNode;
			while (c != null)
			{
				var cp:Params = params(c);
				cp.prelim += shift;
				cp.mod += shift;
				change += cp.change;
				shift += cp.shift + change;
				c = c.prevNode;
			}
		}
		
		private function ancestor(vim:NodeSprite, v:NodeSprite, a:NodeSprite):NodeSprite
		{
			var vimp:Params = params(vim);
			var p:NodeSprite = v.parentNode;
			return (vimp.ancestor.parentNode == p ? vimp.ancestor : a);
		}
    
    	private function secondWalk(n:NodeSprite, p:NodeSprite, m:Number, depth:UInt, visible:Bool):Void
    	{
    		// set position
    		var np:Params = params(n);
    		var o:Dynamic = _t._S_(n);
    		setBreadth(o, p, (visible ? np.prelim : 0) + m);
    		setDepth(o, p, _depths[depth]);
    		setVisibility(n, o, visible);
    		
    		// recurse
    		var v:Bool = n.expanded ? visible : false;
    		var b:Int = m + (n.expanded ? np.mod : np.prelim)
    		if (v) depth += 1;
    		var c:NodeSprite = n.firstChildNode;
    		while (c!=null)
    		{
    			secondWalk(c, n, b, depth, v);
    			c=c.nextNode;
    		}
    		np.clear();
    	}

		private function setBreadth(n:Dynamic, p:NodeSprite, b:Number):Void
		{
			switch (_orient) {
				case Orientation.LEFT_TO_RIGHT:
				case Orientation.RIGHT_TO_LEFT:
					n.y = _ay + b;
					break;
				case Orientation.TOP_TO_BOTTOM:
				case Orientation.BOTTOM_TO_TOP:
					n.x = _ax + b;
					break;
				default:
					throw new Error("Unrecognized orientation value");
			}
		}

		private function setDepth(n:Dynamic, p:NodeSprite, d:Number):Void
		{
			switch (_orient) {
				case Orientation.LEFT_TO_RIGHT:
					n.x = _ax + d;
					break;
				case Orientation.RIGHT_TO_LEFT:
					n.x = _ax - d;
					break;
				case Orientation.TOP_TO_BOTTOM:
					n.y = _ay + d;
					break;
				case Orientation.BOTTOM_TO_TOP:
					n.y = _ax - d;
					break;
				default:
					throw new Error("Unrecognized orientation value");
			}
		}
		
		private function setVisibility(n:NodeSprite, o:Dynamic, visible:Bool):Void
		{
    		o.alpha = visible ? 1.0 : 0.0;
    		o.mouseEnabled = visible;
    		if (n.parentEdge != null) {
    			o = _t._S_(n.parentEdge);
    			o.alpha = visible ? 1.0 : 0.0;
    			o.mouseEnabled = visible;
    		}

		}
		
		private function setSizes(n:NodeSprite):Void
		{
			_t.endSize(n, _rect);
			n.w = _rect.width;
			n.h = _rect.height;
		}
		
		private function spacing(l:NodeSprite, r:NodeSprite, siblings:Bool):Number
		{
			var w:Bool = Orientation.isVertical(_orient);
			return (siblings ? _bspace : _tspace) + 0.5 *
					(w ? l.w + r.w : l.h + r.h)
    	}
    
    	private function updateDepths(depth:UInt, item:NodeSprite):Void
    	{
    		var v:Bool = Orientation.isVertical(_orient);
    		var d:Int = v ? item.h : item.w;

			// resize if needed
			if (depth >= _depths.length) {
    			_depths = Arrays.copy(_depths, new Array(int(1.5*depth)));
    			for (var i:Int=depth; i<_depths.length; ++i) _depths[i] = 0;
			} 

        	_depths[depth] = Math.max(_depths[depth], d);
        	_maxDepth = Math.max(_maxDepth, depth);
    	}
    
    	private function determineDepths():Void
    	{
        	for (var i:UInt=1; i<_maxDepth; ++i)
            	_depths[i] += _depths[i-1] + _dspace;
    	}
		
		// -- Parameter Access ------------------------------------------------
		
		private function params(n:NodeSprite):Params
		{
			var p:Params = cast( n.props[PARAMS], Params);
			if (p == null) {
				p = new Params();
				n.props[PARAMS] = p;
			}
			if (p.number == -2) { p.init(n); }
			return p;
    	}
		
	} // end of class NodeLinkTreeLayout

