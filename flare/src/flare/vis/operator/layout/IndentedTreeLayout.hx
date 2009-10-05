package flare.vis.operator.layout;

	import flare.vis.data.NodeSprite;
	import flare.animate.Transitioner;
	import flash.geom.Point;
	import flare.util.Arrays;
	import flare.vis.data.EdgeSprite;
	
	/**
	 * Layout that places tree nodes in an indented outline layout.
	 */
	class IndentedTreeLayout extends Layout
	{		
		public var breadthSpacing(getBreadthSpacing, setBreadthSpacing) : Number;		
		public var depthSpacing(getDepthSpacing, setDepthSpacing) : Number;		
		private var _bspace:Int ;  // the spacing between sibling nodes
    	private var _dspace:Int ; // the spacing between depth levels
    	private var _depths:Array<Dynamic> ; // TODO make sure array regrows as needed
    	private var _maxDepth:Int ;
    	private var _ax:Number, _ay:Number; // for holding anchor co-ordinates
		
		/** The spacing to use between depth levels (the amount of indent). */
		public function getDepthSpacing():Number { return _dspace; }
		public function setDepthSpacing(s:Number):Number { _dspace = s; 	return s;}
		
		/** The spacing to use between rows in the layout. */
		public function getBreadthSpacing():Number { return _bspace; }
		public function setBreadthSpacing(s:Number):Number { _bspace = s; 	return s;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new IndentedTreeLayout.
		 * @param depthSpace the amount of indent between depth levels
		 * @param breadthSpace the amount of spacing between rows
		 */		
		public function new(?depthSpace:Int=50,
										   ?breadthSpace:Int=5)
		{
			
			_bspace = 5;
			_dspace = 50;
			_depths = new Array(20);
			_maxDepth = 0;
			_bspace = breadthSpace;
			_dspace = depthSpace;
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{
        	Arrays.fill(_depths, 0);
        	_maxDepth = 0;
        
        	var a:Point = layoutAnchor;
        	_ax = a.x + layoutBounds.x;
        	_ay = a.y + layoutBounds.y;
        
        	var root:NodeSprite = cast( layoutRoot, NodeSprite);
        	if (root == null) return; // TODO: throw exception?
        	
        	layoutNode(root,0,0,true);
    	}
    	
    	
    	private function layoutNode(node:NodeSprite, height:Number, indent:UInt, visible:Bool):Number
    	{
    		var x:Int = _ax + indent * _dspace;
    		var y:Int = _ay + height;
    		var o:Dynamic = _t._S_(node);
    		node.h = _t.endSize(node, _rect).height;
    		
    		// update node
    		o.x = x;
    		o.y = y;
    		o.alpha = visible ? 1.0 : 0.0;
    		
    		// update edge
    		if (node.parentEdge != null) 
    		{
    			var e:EdgeSprite = node.parentEdge;
    			var p:NodeSprite = node.parentNode;
    			o = _t._S_(e); 
    			o.alpha = visible ? 1.0 : 0.0;
    			if (e.points == null) {
					e.points = [(p.x+node.x)/2, (p.y+node.y)/2];
    			}
    			o.points = [_t.getValue(p,"x"), y];
    		}
    		
    		if (visible) { height += node.h + _bspace; }
    		if (!node.expanded) { visible = false; }
    		
    		if (node.childDegree > 0) // is not a leaf node
    		{    			
    			var c:NodeSprite = node.firstChildNode;   			
    			;
    			while (c != null) {
    				height = layoutNode(c, height, indent+1, visible);
    				c = c.nextNode;
    			}
    		}
    		return height;
    	}
    	
	} // end of class IndentedTreeLayout
