package flare.analytics.cluster;

	import flare.animate.Transitioner;
	import flare.util.math.IMatrix;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	
	/**
	 * Hierarchically clusters a set of items using agglomerative clustering.
	 * This approach continually merges the most similar items (those with the
	 * minimum distance between them) into clusters, until all items have been
	 * merged into a final resulting cluster tree. Clients must provide a
	 * distance function that takes as input two <code>DataSprite</code>
	 * instances and returns a <code>Number</code>.
	 * <p>This class supports both <i>minimum-link</i> clustering, in which the
	 * distance between clusters is measured as the distance between the two
	 * nearest items in each cluster, and <i>maximum-link</i> clustering, in
	 * which distance is measured using the two furthest items in each cluster.
	 * </p>
	 * <p>For a richer description, see
	 * <a href="http://en.wikipedia.org/wiki/Cluster_analysis#Agglomerative_hierarchical_clustering">
	 * the Wikipedia article on Cluster Analysis</a>.
	 * </p>
	 */
	class AgglomerativeCluster extends HierarchicalCluster
	{		
		/** A function defining distances between items. */
		public var distance:Dynamic ;
		
		/** If true, minimum-link distances are computed between clusters.
		 *  If false, maximum-link distances are computed between clusters. */
		public var minLink:Bool ;

		// --------------------------------------------------------------------
		
		/**
		 * Creates a new agglomerative cluster instance
		 */
		public function new(?group:String=Data.NODES)
		{
			
			distance = null;
			minLink = true;
			this.group = group;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			calculate(visualization.data.group(group), distance);
		}
		
		/**
		 * Calculates the community structure clustering. As a result of this
		 * method, a cluster tree will be computed and graph nodes will be
		 * annotated with both community and sequence indices.
		 * @param list a data list to cluster
		 * @param d a distance function
		 */
		public function calculate(list:DataList, d:Dynamic):Void
		{
			compute(list.distanceMatrix(d));
			_tree = buildTree(list);
			labelNodes();
		}
		
		/** Computes the clustering */
		private function compute(Z:IMatrix):Void
		{
			_merges = new MergeEdge(-1, -1);
			_qvals = [];
			_size = Z.rows;
			
			var m:MergeEdge = _merges;
			var i:UInt, j:UInt, k:Int, s:Int, t:Int, ii:UInt, jj:UInt;
			var min:Number, a:UInt, b:UInt, bb:UInt, imax:Int;
			var v:Number, sum:Int=0, Q:Int=0, Qmax:Int=0, dQ:Number;
			
			// initialize matrix
			var N:Int = Z.rows;
			var idx:/*int*/Array<Dynamic> = new Array(N);
			for (i in 0...N) {
				idx[i] = i;
				Z.set(i,i,Number.POSITIVE_INFINITY);
			}
			
			// run the clustering algorithm
			for (iter in 0...N-1) {
				// find the nodes to merge
				min = Number.MAX_VALUE;
				for (ii in 0...idx.length) {
					i = idx[ii];
					for (jj in 1...idx.length) {
						j = idx[jj];
						v = Z.get(i,j);
						if (v < min) {
							min = v;
							a = i;
							b = j; bb = jj;
						}
					}
				}
				i = a; j = b; jj = bb;
				
				// perform merge on graph
				for (k in 0...N) {
					if (minLink) {
						v = Math.min(Z.get(i,k), Z.get(j,k)); // min link
					} else {
						v = Math.max(Z.get(i,k), Z.get(j,k)); // max link
					}
					Z.set(i, k, v);
					Z.set(k, i, v);
				}
				for (k in 0...N) {
					Z.set(j, k, Number.POSITIVE_INFINITY);
					Z.set(k, j, Number.POSITIVE_INFINITY);
				}
				idx.splice(jj, 1);
				
				Q += min;
				if (Q > Qmax) {
					Qmax = Q;
					imax = iter;
				}
				_qvals.push(Q);
				m = m.add(new MergeEdge(i,j));
			}
		}
		
	} // end of class AgglomerativeCluster
