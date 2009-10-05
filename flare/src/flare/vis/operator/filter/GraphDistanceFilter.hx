package flare.vis.operator.filter;

	import flare.animate.Transitioner;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	import flash.utils.Dictionary;

	/**
	 * Filter operator that sets visible all items within a specified graph
	 * distance from a set of focus nodes.
	 */
	class GraphDistanceFilter extends Operator
	{
		/** An array of focal NodeSprites. */
		public var focusNodes:/*NodeSprite*/Array<Dynamic>;
		/** Graph distance within which which items wll be visible. */
		public var distance:Int;
		/** Flag indicating which graph links to traverse. */
		public var links:Int;
		
		/**
		 * Creates a new GraphDistanceFilter.
		 * @param focusNodes an array of focal NodeSprites. Graph distance is
		 *  measured as the minimum number of edge-hops to one of these nodes.
		 * @param distance graph distance within which items will be visible
		 * @param links flag indicating which graph links to traverse. The
		 *  default value is <code>NodeSprite.GRAPH_LINKS</code>.
		 */		
		public function new(?focusNodes:Array<Dynamic>=null,
			?distance:Int=1, ?links:Int=3/*NodeSprite.GRAPH_LINKS*/)
		{
			this.focusNodes = focusNodes;
			this.distance = distance;
			this.links = links;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			t = (t==null ? Transitioner.DEFAULT : t);
	        
	        // initialize breadth-first traversal
	        var q:Array<Dynamic> = [], depths:Dictionary = new Dictionary();
			for each (var fn:NodeSprite in focusNodes) {				
				depths[fn] = 0;
				fn.visitEdges(function(e:EdgeSprite):Void {
					depths[e] = 1;
					q.push(e);
				}, links);
			}
			
			// perform breadth-first traversal
			var xe:EdgeSprite, xn:NodeSprite, d:Int;
			while (q.length > 0) {
				xe = q.shift(); d = depths[xe];
				// -- fix to bug 1924891 by goosebumps4all
				if (depths[xe.source] == undefined) {
					xn = xe.source;
				} else if (depths[xe.target] == undefined) {
					xn = xe.target;
				} else {
					continue;
				}
				// -- end fix
				depths[xn] = d;
				if (d == distance) continue; // stop traversal at max distance
				
				xn.visitEdges(function(e:EdgeSprite):Void {
					if (depths[e] == undefined) {
						depths[e] = d+1;
						q.push(e);
					}
				}, links);
			}
			
			// now set visibility based on traversal results
	        visualization.data.visit(function(ds:DataSprite):Void {
	        	var visible:Boolean = (depths[ds] != undefined);
	        	var alpha:Int = visible ? 1 : 0;
				var obj:Dynamic = t._S_(ds);
				
				obj.alpha = alpha;
				if (Std.is( ds, NodeSprite)) {
					var ns:NodeSprite = cast( ds, NodeSprite);
					ns.expanded = (visible && depths[ds] < distance);
				}
				if (t.immediate) {
					ds.visible = visible;
				} else {
					obj.visible = visible;
				}
	        });
		}
		
	} // end of class GraphDistanceFilter
