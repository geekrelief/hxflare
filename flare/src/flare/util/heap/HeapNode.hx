package flare.util.heap;

	/**
	 * A node in a heap data structure.
	 * For use with the <code>FibonacciHeap</code> class.
	 * @see flare.analytics.util.FibonacciHeap
	 */
	class HeapNode
	{
		/** Arbitrary client data property to store with the node. */
		public var data:Dynamic;
		/** The parent node of this node. */
		public var parent:HeapNode;
		/** A child node of this node. */
		public var child:HeapNode;
		/** The right child node of this node. */
		public var right:HeapNode;
		/** The left child node of this node. */
		public var left:HeapNode;
		/** Boolean flag useful for marking this node. */
		public var mark:Bool;
		/** Flag indicating if this node is currently in a heap. */
		public var inHeap:Bool ;
		/** Key value used for sorting the heap nodes. */
		public var key:Number;
		/** The degree of this heap node (number of child nodes). */
		public var degree:Int;
	
		/**
		 * Creates a new HeapNode
		 * @param data arbitrary data to store with this node
		 * @param key the key value to sort on
		 */
		function new(data:Dynamic, key:Number)
		{
			
			inHeap = true;
			this.data = data;
			this.key = key;
			right = this;
			left = this;
		}
	} // end of class HeapNode
