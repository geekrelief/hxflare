package flare.vis.operator.layout;

	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places node in a TreeMap layout that optimizes for low
	 * aspect ratios of visualized tree nodes. TreeMaps are a form of
	 * space-filling layout that represents nodes as boxes on the display, with
	 * children nodes represented as boxes placed within their parent's box.
	 * This layout determines the area of nodes in the tree map by looking up
	 * the <code>sizeField</code> property on leaf nodes. By default, this
	 * property is "size", such that the layout will look for size
	 * values in the <code>DataSprite.size</code> property.
	 * 
	 * <p>
	 * This particular algorithm is taken from Bruls, D.M., C. Huizing, and 
	 * J.J. van Wijk, "Squarified Treemaps" In <i>Data Visualization 2000, 
	 * Proceedings of the Joint Eurographics and IEEE TCVG Sumposium on 
	 * Visualization</i>, 2000, pp. 33-42. Available online at:
	 * <a href="http://www.win.tue.nl/~vanwijk/stm.pdf">
	 * http://www.win.tue.nl/~vanwijk/stm.pdf</a>.
	 * </p>
	 * <p>
	 * For more information on TreeMaps in general, see 
	 * <a href="http://www.cs.umd.edu/hcil/treemap-history/">
	 * http://www.cs.umd.edu/hcil/treemap-history/</a>.
	 * </p>
	 */
	class TreeMapLayout extends Layout
	{
		public var sizeField(getSizeField, setSizeField) : String;
		inline private static var AREA:String = "treeMapArea";
		
		private var _kids:Array<Dynamic> ;
		private var _row:Array<Dynamic>  ;
		private var _r:Rectangle ;
		
		private var _size:Property ;
		
		/** The property from which to access size values for leaf nodes. */
		public function getSizeField():String { return _size.name; }
		public function setSizeField(s:String):String { _size = Property._S_(s); 	return s;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new TreeMapLayout 
		 * @param sizeField the data property from which to access the size
		 *  value for leaf nodes. The default is the "size" property.
		 */
		public function new(?sizeField:String="size") {
			
			_kids = new Array();
			_row = new Array();
			_r = new Rectangle();
			_size = Property._S_("size");
			this.sizeField = sizeField;
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{
	        // setup
	        var root:NodeSprite = cast( layoutRoot, NodeSprite);
	        var b:Rectangle = layoutBounds;
	        _r.x=b.x; _r.y=b.y; _r.width=b.width-1; _r.height=b.height-1;
	        
	        // process size values
	        computeAreas(root);
	        
	        // layout root node
	        var o:Dynamic = _t._S_(root);
	        o.x = 0;//_r.x + _r.width/2;
	        o.y = 0;//_r.y + _r.height/2;
	        o.u = _r.x;
	        o.v = _r.y;
	        o.w = _r.width;
	        o.h = _r.height;
	
	        // layout the tree
	        updateArea(root, _r);
	        doLayout(root, _r);
		}
		
	    /**
    	 * Compute the pixel areas of nodes based on their size values.
	     */
	    private function computeAreas(root:NodeSprite):Void
	    {
	    	var leafCount:Int = 0;
        
	        // reset all sizes to zero
	        root.visitTreeDepthFirst(function(n:NodeSprite):Void {
	        	n.props[AREA] = 0;
	        });
        
	        // set raw sizes, compute leaf count
	        root.visitTreeDepthFirst(function(n:NodeSprite):Void {
	        	if (n.childDegree == 0) {
	        		var sz:Int = _size.getValue(_t._S_(n));
	        		n.props[AREA] = sz;
	        		var p:NodeSprite = n.parentNode;
	        		for (; p != null; p=p.parentNode)
	        			p.props[AREA] += sz;
	        		++leafCount;
	        	}
	        });
        
	        // scale sizes by display area factor
	        var b:Rectangle = layoutBounds;
	        var area:Int = (b.width-1)*(b.height-1);
	        var scale:Int = area / root.props[AREA];
	        root.visitTreeDepthFirst(function(n:NodeSprite):Void {
	        	n.props[AREA] *= scale;
	        });
	    }
	    
	    /**
	     * Compute the tree map layout.
	     */
	    private function doLayout(p:NodeSprite, r:Rectangle):Void
	    {
	        // create sorted list of children's properties
	        for (i in 0...p.childDegree) {
	        	_kids.push(p.getChildNode(i).props);
	        }
	        _kids.sortOn(AREA, Array.NUMERIC);
	        // update array to point to sprites, not props
	        for (i in 0..._kids.length) {
	        	_kids[i] = _kids[i].self;
	        }
	        
	        // do squarified layout of siblings
	        var w:Int = Math.min(r.width, r.height);
	        squarify(_kids, _row, w, r); 
	        _kids.splice(0, _kids.length); // clear _kids
	        
	        // recurse
	        for (i in 0...p.childDegree) {
	        	var c:NodeSprite = p.getChildNode(i);
	        	if (c.childDegree > 0) {
	        		updateArea(c, r);
	        		doLayout(c, r);
	        	}
	        }
	    }
	    
	    private function updateArea(n:NodeSprite, r:Rectangle):Void
	    {
	    	var o:Dynamic = _t._S_(n);
			r.x = o.u;
			r.y = o.v;
			r.width = o.w;
			r.height = o.h;
			return;
			
			/*
	        Rectangle2D b = n.getBounds();
	        if ( m_frame == 0.0 ) {
	            // if no framing, simply update bounding rectangle
	            r.setRect(b);
	            return;
	        }
	        
	        // compute area loss due to frame
	        double dA = 2*m_frame*(b.getWidth()+b.getHeight()-2*m_frame);
	        double A = n.getDouble(AREA) - dA;
	        
	        // compute renormalization factor
	        double s = 0;
	        Iterator childIter = n.children();
	        while ( childIter.hasNext() )
	            s += ((NodeItem)childIter.next()).getDouble(AREA);
	        double t = A/s;
	        
	        // re-normalize children areas
	        childIter = n.children();
	        while ( childIter.hasNext() ) {
	            NodeItem c = (NodeItem)childIter.next();
	            c.setDouble(AREA, c.getDouble(AREA)*t);
	        }
	        
	        // set bounding rectangle and return
	        r.setRect(b.getX()+m_frame,       b.getY()+m_frame, 
	                  b.getWidth()-2*m_frame, b.getHeight()-2*m_frame);
	        return;
	        */
	    }
	    
	    private function squarify(c:Array<Dynamic>, row:Array<Dynamic>, w:Number, r:Rectangle):Void
	    {
	    	var worst:Int = Number.MAX_VALUE, nworst:Number;
	    	var len:Int;
	        
	        while ((len=c.length) > 0) {
	            // add item to the row list, ignore if negative area
	            var item:NodeSprite = c[len-1];
				var a:Int = item.props[AREA];
	            if (a <= 0.0) {
	            	c.pop();
	                continue;
	            }
	            row.push(item);
	            
	            nworst = getWorst(row, w);
	            if (nworst <= worst) {
	            	c.pop();
	                worst = nworst;
	            } else {
	            	row.pop(); // remove the latest addition
	                r = layoutRow(row, w, r); // layout the current row
	                w = Math.min(r.width, r.height); // recompute w
	                row.splice(0, row.length); // clear the row
	                worst = Number.MAX_VALUE;
	            }
	        }
	        if (row.length > 0) {
	            r = layoutRow(row, w, r); // layout the current row
	            row.splice(0, row.length); // clear the row
	        }
	    }
	
	    private function getWorst(rlist:Array<Dynamic>, w:Number):Number
	    {
	    	var rmax:Int = Number.MIN_VALUE;
	    	var rmin:Int = Number.MAX_VALUE;
	    	var s:Int = 0;

			for each (var n:NodeSprite in rlist) {
				var r:Int = n.props[AREA];
				rmin = Math.min(rmin, r);
				rmax = Math.max(rmax, r);
				s += r;
			}
	        s = s*s; w = w*w;
	        return Math.max(w*rmax/s, s/(w*rmin));
	    }
	    
	    private function layoutRow(row:Array<Dynamic>, ww:Number, r:Rectangle):Rectangle
	    {
	    	var s:Int = 0; // sum of row areas
	        for each (var n:NodeSprite in row) {
	        	s += n.props[AREA];
	        }
			
			var xx:Int = r.x, yy:Int = r.y, d:Int = 0;
			var hh:Int = ww==0 ? 0 : s/ww;
			var horiz:Bool = (ww == r.width);
	        
	        // set node positions and dimensions
	        for each (n in row) {
	        	var p:NodeSprite = n.parentNode;
	        	var nw:Int = n.props[AREA]/hh;
	        	
	        	var o:Dynamic = _t._S_(n);
				if (horiz) {
	        		o.u = xx + d;
	        		o.v = yy;
	        		o.w = nw;
	        		o.h = hh;
	        		//o.x = xx + d + nw/2;
	        		//o.y = yy + hh/2;
	        	} else {
	        		o.u = xx;
	        		o.v = yy + d;
	        		o.w = hh;
	        		o.h = nw;
	        		//o.x = xx + hh/2;
	        		//o.y = yy + d + nw/2;
	        	}
	        	o.x = 0;
	        	o.y = 0;
	        	d += nw;
	        }
	        
	        // update space available in rectangle r
	        if (horiz) {
	        	r.x = xx; r.y = yy+hh; r.height -= hh;
	        } else {
	        	r.x = xx+hh; r.y = yy; r.width -= hh;
	        }
	        return r;
	    }
	}
