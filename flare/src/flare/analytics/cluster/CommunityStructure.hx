package flare.analytics.cluster;

	import flare.animate.Transitioner;
	import flare.util.math.IMatrix;
	import flare.vis.data.DataList;
	
	/**
	 * Hierarchically clusters a network based on inferred community structure.
	 * The result is a cluster tree in which each merge is chosen so as to
	 * maximize within-cluster linkage while minimizing between-cluster linkage.
	 * This class uses <a href="http://arxiv.org/abs/cond-mat/0309508">Newman's
	 * fast algorithm for detecting community structure</a>. Optionally allows
	 * clients to provide an edge weight function indicating the strength of
	 * ties within the network.
	 */
	class CommunityStructure extends HierarchicalCluster
	{
		/** A function defining edge weights in the graph. */
		public var edgeWeights:Dynamic ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new community structure instance
		 */
		public function new()
		{
		
		edgeWeights = null;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			calculate(visualization.data.group(group), edgeWeights);
		}
		
		/**
		 * Calculates the community structure clustering. As a result of this
		 * method, a cluster tree will be computed and graph nodes will be
		 * annotated with both community and sequence indices.
		 * @param list the data list to cluster
		 * @param w an edge weighting function. If null, each edge will be
		 *  given weight one.
		 */
		public function calculate(list:DataList, ?w:Dynamic=null):Void
		{
			compute(list.adjacencyMatrix(w));
			_tree = buildTree(list);
			labelNodes();
		}
		
		/** Computes the clustering */
		private function compute(G:IMatrix):Void
		{
			_merges = new MergeEdge(-1, -1); _qvals = [];
			_size = G.rows;
			var i:Int, j:Int, k:Int, s:Int, t:Int, v:Number;
			var Q:Int=0, Qmax:Int=0, dQ:Number, dQmax:Int=0, imax:Int;
			
			// initialize normalized matrix
			var N:Int = G.rows, Z:IMatrix = G.clone();
			for (i=0; i<N; ++i) Z.set(i,i,0); // clear diagonal
			Z.scale(1 / Z.sum); // normalize matrix
			
			// initialize column sums and edge list
			var E:MergeEdge = new MergeEdge(-1,-1);
			var e:MergeEdge = E, m:MergeEdge = _merges;
			var eMax:MergeEdge = new MergeEdge(0,0);
			var A:Array<Dynamic> = new Array(N);
			
			for (i in 0...N) {
				A[i] = 0;
				for (j in 0...N) {
					if ((v=Z.get(i,j)) != 0) {
						A[i] += v;
						e = e.add(new MergeEdge(i,j));
					}
				}
			}
			
			// run the clustering algorithm
			for (ii in 0...E.next) {
				dQmax = Number.NEGATIVE_INFINITY;
				eMax.update(0,0);
				
				// find the edge to merge
				e=E.next;
				while (e!=null) {
					i = e.i; j = e.j;
					if (i==j) continue;
					dQ = Z.get(i,j) + Z.get(j,i) - 2*A[i]*A[j];
					if (dQ > dQmax) {
						dQmax = dQ; eMax.update(i,j);
					}
					e=e.next;
				}
				
				// perform merge on graph
				i = eMax.i; j = eMax.j; if (j<i) { i=eMax.j; j=eMax.i; }
				var na:Int = 0;
				for (k in 0...N) {
					v = Z.get(i,k) + Z.get(j,k);
					if (v != 0) {
						na += v; Z.set(i,k,v); Z.set(j,k,0);
					}
				}
				for (k in 0...N) {
					v = Z.get(k,i) + Z.get(k,j);
					if (v != 0) {
						Z.set(k,i,v); Z.set(k,j,0);
					}
				}
				A[i] = na;
				A[j] = 0;
				e=E.next;
				while (e!=null) {
					s = e.i; t = e.j;
					if ((i==s && j==t) || (i==t && j==s)) {
						e.remove();
					} else if (s==j) {
						e.i = i;
					} else if (t==j) {
						e.j = i;
					}
					e=e.next;
				}
				
				Q += dQmax;
				if (Q > Qmax) {
					Qmax = Q;
					imax = ii;
				}
				_qvals.push(Q);
				m = m.add(new MergeEdge(i,j));
			}
		}
		
	} // end of class CommunityStructure
