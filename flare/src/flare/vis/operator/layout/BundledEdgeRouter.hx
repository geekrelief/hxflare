package flare.vis.operator.layout;

	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;

	/**
	 * Layout that routes edges in a graph so that they form groups, reducing
	 * clutter. This operator requires that a tree structure (for example, a
	 * computed spanning tree) be defined over the graph. The class also sets
	 * all edges' <code>shape</code> property to <code>Shapes.BSPLINE</code>
	 * and can optionally compute <code>alpha</code> values to improve edge
	 * visibility.
	 * 
	 * <p>The algorithm uses the tree path between two nodes to define control
	 * points for routing a b-spline curve. The technique is adapted from
	 * Danny Holten's work on
	 * <a href="http://www.win.tue.nl/~dholten/papers/bundles_infovis.pdf">
	 * Hierarchical Edge Bundles</a>, InfoVis 2006.</p>
	 */
	class BundledEdgeRouter extends Operator
	{
		/** Determines how "tight" the edges are bundled. At 0, all edges are
		 *  unbundled straight lines. At 1, the edges bundle together tightly.
		 *  The default is 0.85. */
		public var bundling:Float ;
		/** Removes the shared ancestor along a node path. */
		public var removeSharedAncestor:Bool ;
		
		/**
		 * Creates a new BundledEdgeRouter 
		 * @param bundling the tightness of edge bundles
		 */
		public function new(?bundling:Float=0.85,
			?removeSharedAncestor:Bool=false)
		{
			
			bundling = 0.85;
			removeSharedAncestor = false;
			this.bundling = bundling;
			this.removeSharedAncestor = removeSharedAncestor;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			t = (t==null ? Transitioner.DEFAULT : t);
			
			var u:NodeSprite, v:NodeSprite, pu:NodeSprite, pv:NodeSprite;
			var p1:Array<Dynamic> = [], p2:Array<Dynamic> = [];
			var d1:Int, d2:Int, o:Dynamic;
			var ux:Number, uy:Number, dx:Number, dy:Number;
			
			// compute edge bundles
			for each (var e:EdgeSprite in visualization.data.edges) {
				u = e.source; p1.push(pu=u); d1 = u.depth;
				v = e.target; p2.push(pv=v); d2 = v.depth;
				
				// trace paths to the least common ancestor of u,v
				while (d1 > d2) { p1.push(pu=pu.parentNode); --d1; }
				while (d2 > d1) { p2.push(pv=pv.parentNode); --d2; }
				while (pu != pv) {
					p1.push(pu=pu.parentNode);
					p2.push(pv=pv.parentNode);
				}
				
				// collect b-spline control points
				var p:Array<Dynamic> = t._S_(e).points;
				if (p==null) { p = []; } else { Arrays.clear(p); }
				
				d1 = p1.length;
				d2 = p2.length;
				if ((d1+d2)==4 && d1>1 && d2>1) { // shared parent
					addPoint(p, p1[1], t);
				} else {
					var off:Int = removeSharedAncestor ? 1 : 0;
					for (var i:Int=1; i<p1.length-off; ++i)
						addPoint(p, p1[i], t);
					for (i=p2.length-1; --i>=1;)
						addPoint(p, p2[i], t);
				}
				
				// set the bundling strength by adjusting control points
				var b:Int = bundling, ib:Int = 1-b, N:Int = p.length;
				if (b < 1) {
					o = t._S_(u); ux = o.x; uy = o.y;
					o = t._S_(v);	dx = o.x; dy = o.y;
					dx = (dx-ux)/(N+2);
					dy = (dy-uy)/(N+2);

					i=0;
					while (i<N) {
						p[i]   = b*p[i]   + ib*(ux + (i+2)*dx);
						p[i+1] = b*p[i+1] + ib*(uy + (i+2)*dy);
						i+=2;
					}
				}
				
				o = t._S_(e);
				o.points = p;
				e.shape = Shapes.BSPLINE;
				
				// clean-up
				Arrays.clear(p1);
				Arrays.clear(p2);
			}
		}
		
		private static function addPoint(p:Array<Dynamic>, d:DataSprite, t:Transitioner):Void
		{
			var o:Dynamic = t._S_(d);
			p.push(o.x);
			p.push(o.y);
		}
		
	} // end of class BundledEdgeRouter
