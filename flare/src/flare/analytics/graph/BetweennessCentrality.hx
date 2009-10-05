package flare.analytics.graph;

	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	/**
	 * Calculates betweenness centrality measures for nodes in a graph.
	 * The algorithm used is due to Ulrik Brandes, as published in the
	 * <a href="http://www.inf.uni-konstanz.de/algo/publications/b-fabc-01.pdf">
	 * Journal of Mathematical Sociology, 25(2):163-177, 2001</a>.
	 */
	class BetweennessCentrality extends Operator
	{
		public var centralityField(getCentralityField, setCentralityField) : String;
		private var _bc:Property ;
		
		/** The property in which to store the centrality score. This property
		 *  is used to annotate nodes with their betweenness centrality score.
		 *  The default value is "props.centrality". */
		public function getCentralityField():String { return _bc.name; }
		public function setCentralityField(f:String):String { _bc = Property._S_(f); 	return f;}
		
		/** Flag indicating the type of links to follow in the graph. The
		 *  default is <code>NodeSprite.GRAPH_LINKS</code>. */
		public var links:Int ;

		/**
		 * Creates a new BetweennessCentrality operator.
		 */
		public function new()
		{
		
		_bc = Property._S_("props.centrality");
		links = NodeSprite.GRAPH_LINKS;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			calculate(visualization.data);
		}
		
		/**
		 * Calculates the betweenness centrality values for the given data set. 
		 * @param data the data set for which to compute centrality measures
		 */
		public function calculate(data:Data):Void
		{
			var nodes:DataList = data.nodes; var N:Int = nodes.length, i:Int;
			var n:NodeSprite, v:NodeSprite, w:NodeSprite;
			var si:Score, sv:Score, sw:Score;
			
			nodes.visit(function(n:NodeSprite):Void {
				_bc.setValue(n, 0);
				n.props._score = new Score();
			});
			
			for (i in 0...N) {
				nodes.visit(function(n:NodeSprite):Void {
					n.props._score.reset();
				});
				n  = nodes[i];
				si = n.props._score;
				si.paths = 1;
				si.distance = 0;
				
				var stack:Array<Dynamic> = [];
				var queue:Array<Dynamic> = [n];
				
				while (queue.length > 0) {
					stack.push(v = queue.shift()); si = v.props._score;
					
					v.visitNodes(function(w:NodeSprite):Void {
						var sv:Score = si, sw:Score = w.props._score;
						if (sw.distance < 0) {
							queue.push(w);
							sw.distance = sv.distance + 1;
						}
						if (sw.distance == sv.distance + 1) {
							sw.paths += sv.paths;
							sw.predecessors.push(v);
						}
					}, links);
				}
				while (stack.length > 0) {
					w = stack.pop(); sw = w.props._score;
					for each (v in sw.predecessors) {
						sv = v.props._score;
						sv.dependency += (sv.paths/sw.paths) * (1+sw.dependency);
					}
					if (w !== n) sw.centrality += sw.dependency;
				}
			}
			
			nodes.visit(function(n:NodeSprite):Void {
				_bc.setValue(n, n.props._score.centrality);
				delete n.props._score;
			});
		}
		
	} // end of class BetweennessCentrality
