package flare.vis.controls;

	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/*[Event(name="select",   type="flare.vis.events.SelectionEvent")]*/
	/*[Event(name="deselect", type="flare.vis.events.SelectionEvent")]*/
	
	/**
	 * Interactive control for selecting a group of objects by "rubber-banding"
	 * them with a rectangular section region.
	 */
	class SelectionControl extends Control
	{
		public var hitArea(getHitArea, setHitArea) : InteractiveObject;
		private var _r:Rectangle ;
		private var _drag:Bool ;
		private var _shape:Shape ;
		private var _hit:InteractiveObject;
		private var _stage:Stage;
		private var _sel:Dictionary ;
		
		private var _add0:DisplayObject ;
		private var _rem0:DisplayObject ;
		private var _add:Array<Dynamic> ;
		private var _rem:Array<Dynamic> ;
		
		/** The active hit area over which selection
		 *  interactions can be performed. */
		public function getHitArea():InteractiveObject { return _hit; }
		public function setHitArea(hitArea:InteractiveObject):InteractiveObject {
			if (_hit != null) onRemove();
			_hit = hitArea;
			if (_object && _object.stage != null) onAdd();
			return hitArea;
		}
		
		/** Indicates if a selection events should be fired immediately upon a
		 *  chane of selection status (true) or after the mouse is released
		 * (false). The default is true. Set this to false if immediate
		 * selections are causing any performance issues. */
		public var fireImmediately:Bool ;
		
		/** Line color of the selection region border. */
		public var lineColor:UInt ;
		/** Line alpha of the selection region border. */
		public var lineAlpha:Float ;
		/** Line width of the selection region border. */
		public var lineWidth:Int ;
		/** Fill color of the selection region. */
		public var fillColor:UInt ;
		/** Fill alpha of the selection region. */
		public var fillAlpha:Float ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SelectionControl.
		 * @param filter an optional Boolean-valued filter determining which
		 *  items are eligible for selection.
		 * @param hitArea a display object to use as the hit area for mouse
		 *  events. For example, this could be a background region over which
		 *  the selection can done. If this argument is null,
		 *  the stage will be used.
		 * @param select an optional SelectionEvent listener for selections
		 * @param deselect an optional SelectionEvent listener for deselections
		 */
		public function SelectionControl(filter:*=null,
			select:Function=null, deselect:Function=null,
			hitArea:InteractiveObject=null)
		{
			_hit = hitArea;
			this.filter = filter;
			if (select != null)
				addEventListener(SelectionEvent.SELECT, select);
			if (deselect != null)
				addEventListener(SelectionEvent.DESELECT, deselect);
		}
		
		/**
		 * Indicates is a display object has been selected. 
		 * @param d the display object
		 * @return true if selected, false if not
		 */
		public function isSelected(d:DisplayObject):Boolean
		{
			return _sel[d] != undefined;
		