package flare.vis.controls;

	import flare.util.Arrays;
	import flare.vis.Visualization;
	
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	
	import mx.core.IMXMLObject;
	
	/**
	 * A ControlList maintains a sequential chain of controls for interacting
	 * with a visualization. Controls may perform operations such as selection,
	 * panning, zooming, and expand/contract. Controls can be added to a
	 * ControlList using the <code>add</code> method. Once added, controls can be
	 * retrieved and set using their index in the lists, either with array
	 * notation (<code>[]</code>) or with the <code>getControlAt</code> and
	 * <code>setControlAt</code> methods.
	 */
	class ControlList extends Proxy implements IMXMLObject
	{
		public var length(getLength, null) : UInt ;
		public var list(null, setList) : Array<Dynamic>;
		public var visualization(getVisualization, setVisualization) : Visualization;
		public var _vis:Visualization;
		public var _list:/*IControl*/Array<Dynamic> ;
		
		/** The visualization manipulated by these controls. */
		public function getVisualization():Visualization { return _vis; }
		public function setVisualization(v:Visualization):Visualization { 
			_vis = v;
			for each (var ic:IControl in _list) { ic.attach(v);	}
			return v; 
		}
		
		/** An array of the controls contained in the control list. */
		public function setList(ctrls:Array<Dynamic>):Array<Dynamic> {
			// first remove all current operators
			while (_list.length > 0) {
				removeControlAt(_list.length-1);
			}
			// then add the new operators
			for each (var ic:IControl in ctrls) {
				add(ic);
			}
			return ctrls;
			// first remove all current operators
		}
		
		/** The number of controls in the list. */
		public function getLength():UInt { return _list.length; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ControlList.
		 * @param ops an ordered set of controls to include in the list.
		 */
		public function new(controls:Array<Dynamic>) {
			
			_list = [];
			for each (var ic:IControl in controls) {
				add(ic);
			}
		}
		
		/**
		 * Proxy method for retrieving controls from the internal array.
		 */
		flash_proxy override function getProperty(name:Dynamic):Dynamic
		{
    		return _list[name];
    	}

		/**
		 * Proxy method for setting controls in the internal array.
		 */
    	flash_proxy override function setProperty(name:Dynamic, value:Dynamic):Void
    	{
        	if (Std.is( value, IControl)) {
        		var ic:IControl = IControl(value);
        		_list[name].detach();
        		_list[name] = ic;
        		ic.attach(_vis);
        	} else {
        		throw new ArgumentError("Input value must be an IControl.");
        	}
    	}
		
		/**
		 * Returns the control at the specified position in the list
		 * @param i the index into the control list
		 * @return the requested control
		 */
		public function getControlAt(i:UInt):IControl
		{
			return _list[i];
		}
		
		/**
		 * Removes the control at the specified position in the list
		 * @param i the index into the control list
		 * @return the removed control
		 */
		public function removeControlAt(i:UInt):IControl
		{
			var ic:IControl = cast( Arrays.removeAt(_list, i), IControl);
			if (ic) ic.detach();
			return ic;
		}
		
		/**
		 * Set the control at the specified position in the list
		 * @param i the index into the control list
		 * @param ic the control to place in the list
		 * @return the control previously at the index
		 */
		public function setControlAt(i:UInt, ic:IControl):IControl
		{
			var old:IControl = _list[i];
			_list[i] = ic;
			old.detach();
			ic.attach(_vis);
			return old;
		}
		
		/**
		 * Adds a control to the end of this list.
		 * @param ic the control to add
		 */
		public function add(ic:IControl):Void
		{
			ic.attach(_vis);
			_list.push(ic);
		}
		
		/**
		 * Adds a control at the specified index in the list.
		 * @param ic the control to add
		 * @param idx the index into the list
		 */
		public function addAt(ic:IControl, idx:Int):Void
		{
			ic.attach(_vis);
			_list.splice(idx, 0, ic);
		}
		
		/**
		 * Removes an control from this list.
		 * @param ic the control to remove
		 * @return true if the control was found and removed, false otherwise
		 */
		public function remove(ic:IControl):IControl
		{
			var idx:Int = Arrays.remove(_list, ic);
			if (idx >= 0) ic.detach();
			return ic;
		}
		
		/**
		 * Removes all controls from this list.
		 */
		public function clear():Void
		{
			for each (var ic:IControl in _list) { ic.detach(); }
			Arrays.clear(_list);
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}

	} // end of class ControlList
