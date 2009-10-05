package flare.util;

	/**
	 * Interface for methods that evaluate an object and return true or false.
	 */
	interface IPredicate
	{
		/**
		 * Boolean test function that returns true or false for an
		 * input object.
		 * @param o the input object
		 * @return true or false
		 */
		function predicate(o:Dynamic):Bool;
		
	} // end of interface IPredicate
