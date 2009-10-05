package flare.vis.controls;

	import flare.vis.data.DataSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Interactive control for dragging items. A DragControl will enable
	 * dragging of all Sprites in a container object by clicking and dragging
	 * them.
	 */
	class DragControl extends Control
	{
		public var activeItem(getActiveItem, null) : Sprite ;
		private var _cur:Sprite;
		private var _mx:Number, _my:Number;
		
		/** Indicates if drag should be followed at frame rate only.
		 *  If false, drag events can be processed faster than the frame
		 *  rate, however, this may pre-empt other processing. */
		public var trackAtFrameRate:Bool ;
		
		/** The active item currently being dragged. */
		public function getActiveItem():Sprite { return _cur; }
		
		/**
		 * Creates a new DragControl.
		 * @param filter a Boolean-valued filter function determining which
		 *  items should be draggable.
		 */		
		public function DragControl(filter:*=null) {
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		