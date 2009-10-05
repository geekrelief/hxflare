package flare.analytics.graph;

	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	import flash.utils.Dictionary;
	
	/**
	 * Calculates the maximum flow along edges of a graph using the
	 * Edmonds-Karp method. Each edge in the graph will be annotated with its
	 * final flow value, as well as a boolean value indicating if the edge
	 * is part of the minimum cut of the flow graph. Nodes are annotated with
	 * their partition according to the minimum cut: a partition value of 0
	 * indicates the source-side of the cut, a value of 1 indicates the
	 * sink-side of the cut.
	 */
	class MaxFlowMinCut extends Operator
	{
		public var edgeCapacity(getEdgeCapacity, setEdgeCapacity) : Dynamic;
		public var flowField(getFlowField, setFlowField) : String;
		public var maxFlow(getMaxFlow, null) : Number ;
		public var mincutField(getMincutField, setMincutField) : String;
		private var _c:Property ;
		private var _f:Property ;
		private var _p:Property ;
		private var _k:Property ;
		private var _cap:Dynamic ;
		
		/** The property in which to store computed flow values. This property
		 *  is used to annotate edges with the computed flow. The default
		 *  value is "props.flow". */
		public function getFlowField():String { return _f.name; }
		public function setFlowField(f:String):String { _f = Property._S_(f); 	return f;}
		
		/** The property in which to store minimum-cut data. The default value
		 *  is "props.mincut". This property is used to annotate nodes with
		 *  their partition (0 for source-side, 1 for sink-side) and to
		 *  annotate edges with min-cut membership (true if part of the
		 *  minimum cut, false otherwise). */
		public function getMincutField():String { return _k.name; }
		public function setMincutField(f:String):String { _k = Property._S_(f); 	return f;}
		
		/** The source node for which to compute the max flow. */
		public var source:NodeSprite;
		/** The sink node for which to compute the max flow. */
		public var sink:NodeSprite;
		/** A function defining the edge capacities for flow. When setting
		 *  this value, one can pass in either a Function, which should take an
		 *  EdgeSprite as input and return a Number as output, or a String, in
		 *  which case the string will be used as a property name from which to
		 *  retrieve the edge capacity value from an EdgeSprite instance.
		 *  If the value is null (the default) all edges will be assumed to have
		 *  capacity 1.
		 *  
		 *  <p><b>NOTE:</b> Capacities must be greater than or equal to zero!
		 *  </p> */
		public function getEdgeCapacity():Dynamic { return _cap; }
		public function setEdgeCapacity(c:Dynamic):Dynamic {
			if (c==null) {
				_cap = null;
			} else if (Std.is( c, String)) {
				_cap = Property._S_(String(c)).getValue;
			} else if (Std.is( c, Function)) {
				_cap = c;
			} else {
				throw new Error("Unrecognized edgeCapacity value. " +
					"The value should be a Function or String.");
			}
			return c;
		}
		
		/** The computed maximum flow value. This value is zero by default
		 *  and is populated once the max flow calculation is run. */
		public function getMaxFlow():Number { return _maxFlow; }
		
		private var _data:Data, _s:NodeSprite, _t:NodeSprite;
		private var _maxFlow:Int ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new MaxFlowMinCut operator.
		 * @param source the source node in the flow graph
		 * @param sink the sink node in the flow graph
		 * @param edgeCapacity the edge capacity values. This can either be a
		 *  <code>Function</code> that returns capacity values or a
		 *  <code>String</code> providing the name of a property to look up on
		 *  <code>EdgeSprite</code> instances.
		 */
		public function MaxFlowMinCut(source:NodeSprite=null,
			sink:NodeSprite=null, edgeCapacity:*=null)
		{
			this.source = source;
			this.sink = sink;
			this.edgeCapacity = edgeCapacity;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			calculate(visualization.data, source, sink, _cap);
		