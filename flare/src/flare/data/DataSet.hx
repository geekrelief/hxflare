package flare.data;
	
	/**
	 * A data set is a collection of data tables.
	 */
	class DataSet
	{
		/**
		 * Creates a new DataSet.
		 * @param nodes a data table of node data
		 * @param edges a data table of edge data (optional, for graphs only)
		 */
		public function new(nodes:DataTable, ?edges:DataTable=null) {
			this.nodes = nodes;
			this.edges = edges;
		}

		/** A DataTable of nodes (or table rows). */
		public var nodes:DataTable ;
		
		/** A DataTable of edges. */
		public var edges:DataTable ;

	} // end of class DataSet
