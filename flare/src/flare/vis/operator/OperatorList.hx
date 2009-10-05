package flare.vis.operator;

	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.vis.Visualization;
	
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	
	/**
	 * An OperatorList maintains a sequential chain of operators that are
	 * invoked one after the other. Operators can be added to an OperatorList
	 * using the <code>add</code> method. Once added, operators can be
	 * retrieved and set using their index in the lists, either with array
	 * notation (<code>[]</code>) or with the <code>getOperatorAt</code> and
	 * <code>setOperatorAt</code> methods.
	 */
	class OperatorList extends Proxy implements IOperator
	{
		public var enabled(getEnabled, setEnabled) : Bool;
		public var first(getFirst, null) : Dynamic ;
		public var last(getLast, null) : Dynamic ;
		public var length(getLength, null) : UInt ;
		public var list(null, setList) : Array<Dynamic>;
		public var parameters(null, setParameters) : Dynamic;
		public var visualization(getVisualization, setVisualization) : Visualization;
		// -- Properties ------------------------------------------------------
		
		public var _vis:Visualization;
		public var _enabled:Bool ;
		public var _list:Array<Dynamic> ;
		
		/** The visualization processed by this operator. */
		public function getVisualization():Visualization { return _vis; }
		public function setVisualization(v:Visualization):Visualization
		{
			_vis = v; setup();
			for each (var op:IOperator in _list) {
				op.visualization = v;
			}
			return v;
		}
		
		/** Indicates if the operator is enabled or disabled. */
		public function getEnabled():Bool { return _enabled; }
		public function setEnabled(b:Bool):Bool { _enabled = b; 	return b;}
		
		/** @inheritDoc */
		public function setParameters(params:Dynamic):Dynamic
		{
			Operator.applyParameters(this, params);
			return params;
		}
		
		/** An array of the operators contained in the operator list. */
		public function setList(ops:Array<Dynamic>):Array<Dynamic> {
			// first remove all current operators
			while (_list.length > 0) {
				removeOperatorAt(_list.length-1);
			}
			// then add the new operators
			for each (var op:IOperator in ops) {
				add(op);
			}
			return ops;
			// first remove all current operators
		}
		
		/** The number of operators in the list. */
		public function getLength():UInt { return _list.length; }
		/** Returns the first operator in the list. */
		public function getFirst():Dynamic { return _list[0]; }
		/** Returns the last operator in the list. */
		public function getLast():Dynamic { return _list[_list.length-1]; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new OperatorList.
		 * @param ops an ordered set of operators to include in the list.
		 */
		public function new(ops:Array<Dynamic>) {
			
			_enabled = true;
			_list = new Array();
			for each (var op:IOperator in ops) {
				add(op);
			}
		}

		/** @inheritDoc */
		public function setup():Void
		{
			for each (var op:IOperator in _list) {
				op.setup();
			}
		}
		
		/**
		 * Proxy method for retrieving operators from the internal array.
		 */
		flash_proxy override function getProperty(name:Dynamic):Dynamic
		{
    		return _list[name];
    	}

		/**
		 * Proxy method for setting operators in the internal array.
		 */
    	flash_proxy override function setProperty(name:Dynamic, value:Dynamic):Void
    	{
        	if (Std.is( value, IOperator)) {
        		var op:IOperator = IOperator(value);
        		_list[name] = op;
        		op.visualization = this.visualization;
        	} else {
        		throw new ArgumentError("Input value must be an IOperator.");
        	}
    	}
		
		/**
		 * Returns the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @return the requested operator
		 */
		public function getOperatorAt(i:UInt):IOperator
		{
			return _list[i];
		}
		
		/**
		 * Removes the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @return the removed operator
		 */
		public function removeOperatorAt(i:UInt):IOperator
		{
			return cast( Arrays.removeAt(_list, i), IOperator);
		}
		
		/**
		 * Set the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @param op the operator to place in the list
		 * @return the operator previously at the index
		 */
		public function setOperatorAt(i:UInt, op:IOperator):IOperator
		{
			var old:IOperator = _list[i];
			op.visualization = visualization;
			_list[i] = op;
			return old;
		}
		
		/**
		 * Adds an operator to the end of this list.
		 * @param op the operator to add
		 */
		public function add(op:IOperator):Void
		{
			op.visualization = visualization;
			_list.push(op);
		}
		
		/**
		 * Removes an operator from this list.
		 * @param op the operator to remove
		 * @return true if the operator was found and removed, false otherwise
		 */
		public function remove(op:IOperator):Bool
		{
			return Arrays.remove(_list, op) >= 0;
		}
		
		/**
		 * Removes all operators from this list.
		 */
		public function clear():Void
		{
			Arrays.clear(_list);
		}
		
		/** @inheritDoc */
		public function operate(?t:Transitioner=null):Void
		{
			t = (t!=null ? t : Transitioner.DEFAULT);
			for each (var op:IOperator in _list) {
				if (op.enabled) op.operate(t);
			}
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}
		
	} // end of class OperatorList
