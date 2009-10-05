package flare.vis.controls;

	import flare.vis.Visualization;
	import flare.vis.operator.layout.Layout;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Interactive control for updating a layout's anchor point in response
	 * to mouse movement. This control is often used to dynamically update a
	 * focus+context distortion.
	 */
	class AnchorControl extends Control
	{
		public var layout(getLayout, setLayout) : Layout;
		private var _layout:Layout;
		
		public function getLayout():Layout { return _layout; }
		public function setLayout(l:Layout):Layout { _layout = l; 	return l;}
		
		/** Update function called when the layout anchor changes. */
		public var update:Dynamic public function new(?layout:Layout=null)
		{
			
			update = function():Void {
			Visualization(_object).update();
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new AnchorControl
		 * @param layout the layout on which to update the anchor point
		 */
		;
			_layout = layout;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):Void
		{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(Event.ENTER_FRAME, updateMouse);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(Event.ENTER_FRAME, updateMouse);
			}
			return super.detach();
		}
		
		/**
		 * Causes the layout anchor to be updated according to the current
		 * mouse position.
		 * @param evt an optional mouse event
		 */
		public function updateMouse(?evt:Event=null):Void
		{
			// get current anchor, run update if changed
			var p1:Point = _layout.layoutAnchor;
			_layout.layoutAnchor = new Point(_object.mouseX, _object.mouseY);
			// distortion might snap the anchor to the layout bounds
			// so we need to re-retrieve the point to ensure accuracy
			var p2:Point = _layout.layoutAnchor;
			if (p1.x != p2.x || p1.y != p2.y) update();
		}
		
	} // end of class AnchorControl
