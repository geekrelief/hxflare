package flare.analytics.cluster;

	/**
	 * Auxiliary class that represents a merge in a clustering.
	 */
	private class MergeEdge
	{
		public var i:Int;
		public var j:Int;
		public var next:MergeEdge ;
		public var prev:MergeEdge ;
		
		public function new(i:Int, j:Int) {
			
			next = null;
			prev = null;
			this.i = i;
			this.j = j;
		}
		
		public function update(i:Int, j:Int):Void
		{
			this.i = i;
			this.j = j;
		}
		
		public function add(e:MergeEdge):MergeEdge {
			if (next) {
				e.next = next;
				next.prev = e;
			}
			next = e;
			e.prev = this;
			return e;
		}
		
		public function remove():Void {
			if (prev) prev.next = next;
			if (next) next.prev = prev;
		}
		
	} // end of class MergeEdge
