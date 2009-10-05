package flare.query;

	import flare.util.Filter;
	import flare.util.Property;
	import flare.util.Sort;
	
	/**
	 * Performs query processing over a collection of ActionScript objects.
	 * Queries can perform filtering, sorting, grouping, and aggregation
	 * operations over a data collection. Arbitrary data collections can
	 * be queried by providing a visitor function similar to the
	 * <code>Array.forEach<code> method to the query <code>eval</code> method.
	 * 
	 * <p>The <code>select</code> and <code>where</code> methods in the
	 * <code>flare.query.methods</code> package are useful shorthands
	 * for helping to construct queries in code.</p>
	 * 
	 * <p>Here is an example of a query. It uses helper methods defined in the
	 * <code>flare.query.methods</code> package. For example, the
	 * <code>sum</code> method creates a <code>Sum</code> query operator and
	 * the <code>_</code> method creates as a <code>Literal</code> expression
	 * for its input value.</p>
	 * 
	 * <pre>
	 * import flare.query.methods.*;
	 * 
	 * var data:Array = [
	 *  {cat:"a", val:1}, {cat:"a", val:2}, {cat:"b", val:3}, {cat:"b", val:4},
	 *  {cat:"c", val:5}, {cat:"c", val:6}, {cat:"d", val:7}, {cat:"d", val:8}
	 * ];
	 * 
	 * var r:Array = select("cat", {sum:sum("val")}) // sum of values
	 *               .where(neq("cat", _("d"))       // exclude category "d"
	 *               .groupby("cat")                 // group by category
	 *               .eval(data);                    // evaluate with data array
	 * 
	 * // r == [{cat:"a", sum:3}, {cat:"b", sum:7}, {cat:"c", sum:11}]
	 * </pre>
	 */
	class Query
	{
		private var _select:Array<Dynamic>;
		private var _orderby:Array<Dynamic>;
		private var _groupby:Array<Dynamic>;
		private var _where:Dynamic;
		private var _sort:Sort;
		private var _aggrs:Array<Dynamic>;
		private var _map:Bool ;
		private var _update:Bool ;
		
		/**
		 * Creates a new Query.
		 * @param select an array of select clauses. A select clause consists
		 *  of either a string representing the name of a variable to query or
		 *  an object of the form <code>{name:expr}</code>, where
		 *  <code>name</code> is the name of the query variable to include in
		 *  query result objects and <code>expr</code> is an Expression for
		 *  the actual query value. Expressions can be any legal expression, 
		 *  including aggregate operators.
		 * @param where a where expression for filtering an object collection
		 * @param orderby directives for sorting query results, using the
		 *  format of the <code>flare.util.Sort</code> class methods.
		 * @param groupby directives for grouping query results, using the
		 *  format of the <code>flare.util.Sort</code> class methods.
		 * @see flare.util.Sort
		 */
		public function Query(select:Array=null, where:*=null,
							  orderby:Array=null, groupby:Array=null)
		{
			if (select != null) setSelect(select);
			this.where(where);
			_orderby = orderby;
			_groupby = groupby;
		}
		
		// -- public methods --------------------------------------------------
		
		/**
		 * Sets the select clauses used by this query. A select clause consists
		 * of either a string representing the name of a variable to query or
		 * an object of the form <code>{name:expr}</code>, where
		 * <code>name</code> is the name of the query variable to include in
		 * query result objects and <code>expr</code> is an
		 * <code>Expression</code> for the actual query value.
		 * <p>Calling the <code>select</code> method will overwrite the effect
		 * of any previous calls to the <code>select</code> or
		 * <code>update</code> methods.</p>
		 * @param terms a list of query terms (select clauses). If the first
		 *  element is an array, it will be used as the term list.
		 * @return this query object
		 */
		public function select(...terms):Query
		{
			if (terms.length > 0 && terms[0] is Array) {
				terms = terms[0];
			