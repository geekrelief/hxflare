package flare.vis.operator;

	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Interface for operators that perform processing tasks on the contents
	 * of a Visualization. These tasks include layout, and color, shape, and
	 * size encoding. Custom operators can be defined by implementing this
	 * interface;
	 */
	interface IOperator extends IMXMLObject
	{
		/** The visualization processed by this operator. */
		function visualization():Visualization;
		function visualization(v:Visualization):Void;
		
		/** Indicates if the operator is enabled or disabled. */
		function enabled():Bool;
		function enabled(b:Bool):Void;
		
		/**
		 * Sets parameter values for this operator.
		 * @params an object containing parameter names and values.
		 */
		function parameters(params:Dynamic):Void;
		
		/**
		 * Performs an operation over the contents of a visualization.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		function operate(?t:Transitioner=null):Void;
		
		/**
		 * Setup method invoked whenever this operator's visualization
		 * property is set.
		 */
		function setup():Void;
		
	} // end of interface IOperator
