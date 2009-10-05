package flare.vis.controls;

	import flare.util.Filter;
	
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;

	/**
	 * Base class for interactive controls.
	 */
	class Control extends EventDispatcher implements IControl
	{
		public var filter(getFilter, setFilter) : Dynamic;
		public var object(getObject, null) : InteractiveObject
		;
		/** @private */
		public var _object:InteractiveObject;
		/** @private */
		public var _filter:Dynamic;
		
		/** Boolean function indicating the items considered by the control.
		 *  @see flare.util.Filter */
		public function getFilter():Dynamic { return _filter; }
		public function setFilter(f:Dynamic):Dynamic { _filter = Filter._S_(f); 	return f;}
		
		/**
		 * Creates a new Control
		 */
		public function new() {
			// do nothing
		}
		
		/** @inheritDoc */
		public function getObject():InteractiveObject
		{
			return _object;
		}
		
		/** @inheritDoc */
		public function attach(obj:InteractiveObject):Void
		{
			if (_object) detach();
			_object = obj;
		}
		
		/** @inheritDoc */
		public function detach():InteractiveObject
		{
			var obj:InteractiveObject = _object;
			_object = null;	
			return obj;
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}
		
	} // end of class Control
