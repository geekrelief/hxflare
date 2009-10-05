package flare.analytics.cluster;

	import flare.util.Arrays;
	import flare.util.Property;
	import flare.util.Sort;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.operator.Operator;

	/**
	 * Base class for clustering operators that construct a hierarchical
	 * clustering tree. Provides methods for taking a sequence of
	 * merge operations by a clustering algorithm and constructing a
	 * resulting cluster tree.
	 * 
	 * <p>Once a clustering has been computed, each node included in the
	 * analysis will be annotated with both its cluster membership
	 * using the name indicated by the <code>clusterField</code> property.
	 * By default, this class will attempt to pick an optimal level of the
	 * cluster tree at which to break up items into discrete clusters.
	 * However, clients can invoke the <code>labelNodes</code> method with
	 * a specific merge number which indicates the point at which to "cut"
	 * the cluster tree into discrete sub-clusters. This class also annotates
	 * nodes with a sequence number using the name indicated by the
	 * <code>sequenceField</code> property. The sequence number allows items
	 * to be sorted in a way that attempts to preserve the clustered structure.
	 * Additionally, the <code>clusterTree</code> property will return a
	 * <code>flare.vis.data.Tree</code> instance that can be used to
	 * visualize the structure of the cluster tree.</p>
	 */
	class HierarchicalCluster extends Operator
	{
		public var clusterField(getClusterField, setClusterField) : String;
		public var clusterTree(getClusterTree, null) : Tree ;
		public var criteria(getCriteria, null) : Array<Dynamic> ;
		public var group(getGroup, setGroup) : String;
		public var sequenceField(getSequenceField, setSequenceField) : String;
		/** @private */
		public var _idx:Property ;
		/** @private */
		public var _com:Property ;
		
		/** @private */
		public var _qvals:Array<Dynamic>;
		/** @private */
		public var _merges:MergeEdge;
		/** @private */
		public var _size:Int;
		/** @private */
		public var _tree:Tree;
		/** @private */
		public var _group:String ;
		
		/** The data group to cluster. */
		public function getGroup():String { return _group; }
		public function setGroup(g:String):String { _group = g; 	return g;}
		
		/** The property in which to store cluster indices. This property
		 *  is used to annotate nodes with the community they belong to
		 *  (indicated as an integer index). The default value
		 *  is "props.cluster". */
		public function getClusterField():String { return _com.name; }
		public function setClusterField(f:String):String { _com = Property._S_(f); 	return f;}
		
		/** The property in which to store sequence indices. This property
		 *  is used to annotate nodes with their sequence index along the
		 *  computed cluster tree. This value can be used to sort the nodes
		 *  in a way that best preserves community structure. The default value
		 *  is "props.sequence". */
		public function getSequenceField():String { return _idx.name; }
		public function setSequenceField(f:String):String { _idx = Property._S_(f); 	return f;}
		
		/** Computed criterion values for each merge in the cluster tree. */
		public function getCriteria():Array<Dynamic> { return _qvals; }
		
		/** The cluster tree of detected community structures. The leaf nodes
		 *  correspond to each of the nodes in the input graph, and include the
		 *  same <code>data</code> property. Non-leaf nodes indicate merges
		 *  made by the clustering algorithm, and have <code>data</code>
		 *  properties that include the <code>merge</code> number (1 for the
		 *  first merger, 2 for the second, etc), the <code>criterion</code>
		 *  value computed for that merge, and the <code>size</code> of the
		 *  cluster rooted at that node (the number of descendants in the
		 *  cluster tree).
		 */
		public function getClusterTree():Tree { return _tree; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new HierarchicalCluster instance. 
		 */
		public function new()
		{
			
			_idx = Property._S_("props.sequence");
			_com = Property._S_("props.cluster");
			_group = Data.NODES;
			super();
		}
		
		/**
		 * Labels nodes with their cluster membership, determined by
		 * the given merge number. If the merge number is less than
		 * zero or unprovided, the merge number that maximizes the
		 * clustering criteria will be assumed.
		 * @param merge the merge number at which to compute the clusters
		 */
		public function labelNodes(?merge:Int=-1):Void
		{
			if (merge < 0) merge = Arrays.maxIndex(_qvals);
			var com:Int, idx:Int;
			var helper:Dynamic = function(n:NodeSprite):Void
			{
				var nn:NodeSprite;
				if (n.childDegree && n.data.merge > merge)
				{
					for (var i:Int=0; i<n.childDegree; ++i)
						helper(n.getChildNode(i));
				}
				else if (n.childDegree)
				{
					n.visitTreeDepthFirst(function(c:NodeSprite):Void {
						if (c.childDegree==0) {
							nn = c.props.node;
							_com.setValue(nn, com);
							_idx.setValue(nn, idx++);
						}
					});
					com++;
				}
				else
				{
					nn = n.props.node;
					_com.setValue(nn, com++);
					_idx.setValue(nn, idx++);
				}
			}
			helper(_tree.root);
		}
		
		/**
		 * @private
		 * Constructs the cluster tree from the cluster results
		 */
		public function buildTree(list:DataList):Tree
		{
			var tree:Tree = new Tree();
			
			var e:MergeEdge, i:Int, j:Int, ii:Int, map:Dynamic = {};
			var l:NodeSprite, r:NodeSprite, p:NodeSprite;
			
			// populate the leaf notes
			for (i in 0..._size) {
				map[i] = (p = new NodeSprite());
				p.data = list[i].data;
				p.props.node = list[i];
				p.props.size = 0;
			}
			
			// build up the tree
			ii=0, e=_merges.next;
			while (e!=null) {
				i = e.i;
				j = e.j;
				l = map[i];
				r = map[j];
				map[i] = (p = new NodeSprite());
				if (l.props.size >= r.props.size) {
					p.addChildEdge(new EdgeSprite(p, l));
					p.addChildEdge(new EdgeSprite(p, r));
				} else {
					p.addChildEdge(new EdgeSprite(p, r));
					p.addChildEdge(new EdgeSprite(p, l));
				}
				p.data.merge = ii + 1;
				p.data.criterion = _qvals[ii];
				p.props.size = 2 + l.props.size + r.props.size;
				delete map[j];
				++ii, e=e.next;
			}
			
			// build and sort array of cluster roots
			var roots:Array<Dynamic> = [];
			for each (var n:NodeSprite in map) roots.push(n);
			roots.sort(Sort._S_("-props.size"));
			
			// merge cluster roots into final tree, if needed
			if (roots.length == 1) {
				p = NodeSprite(roots[0]);
			} else {
				p = new NodeSprite();
				p.data.merge = ii;
				for each (n in roots) {
					p.addChildEdge(new EdgeSprite(p, n));
				}
			}
			tree.root = p;
			return tree;
		}
		
	} // end of class HierarchicalCluster
