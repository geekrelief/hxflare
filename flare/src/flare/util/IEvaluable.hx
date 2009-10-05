package flare.util;

	/**
	 * Interface for methods that evaluate an object and return a result.
	 */
	interface IEvaluable
	{
		/**
		 * Evaluates the input object
		 * @o the object to evaluate
		 * @return the computed result value
		 */
		function eval(?o:Dynamic=null):Dynamic;
		
	} // end of interface IEvaluable
