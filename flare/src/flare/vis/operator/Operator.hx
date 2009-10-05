package flare.vis.operator;

	import flare.animate.Transitioner;
	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.vis.Visualization;
	
	/**
	 * Operators performs processing tasks on the contents of a Visualization.
	 * These tasks include layout, and color, shape, and size encoding.
	 * Custom operators can be defined by subclassing this class.
	 */
	class Operator implements IOperator
	{
		public var enabled(getEnabled, setEnabled) : Bool;
		public var parameters(null, setParameters) : Dynamic;
		public var visualization(getVisualization, setVisualization) : Visualization;
		// -- Properties ------------------------------------------------------
		
		private var _vis:Visualization;
		private var _enabled:Bool ;
		
		/** The visualization processed by this operator. */
		public function getVisualization():Visualization { return _vis; }
		public function setVisualization(v:Visualization):Visualization {
			_vis = v; setup();
			return v;
		}
		
		/** Indicates if the operator is enabled or disabled. */
		public function getEnabled():Bool { return _enabled; }
		public function setEnabled(b:Bool):Bool { _enabled = b; 	return b;}
		
		/** @inheritDoc */
		public function setParameters(params:Dynamic):Dynamic
		{
			applyParameters(this, params);
			return params;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Performs an operation over the contents of a visualization.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		public function operate(?t:Transitioner=null) : Void {
			// for sub-classes to implement	
		}
		
		/**
		 * Setup method invoked whenever this operator's visualization
		 * property is set.
		 */
		public function setup():Void
		{
			// for subclasses
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}
		
		// -- Parameterization ------------------------------------------------
		
		/**
		 * Static method that applies parameter settings to an operator.
		 * @param op the operator
		 * @param p the parameter object
		 */
		public static function applyParameters(op:IOperator,params:Dynamic):Void
		{
			if (op==null || params==null) return;
			var o:Dynamic = cast( op, Object);
			for (var name:String in params) {
				var p:Property = Property._S_(name);
				var v:Dynamic = params[name];
				var f:Dynamic = cast( v, Function);
				if (Std.is( v, IEvaluable)) f = IEvaluable(v).eval;
				p.setValue(op, f==null ? v : f(op));
			}
		}
		
	} // end of class Operator
