package flare.vis.controls;

	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.data.NodeSprite;
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	/**
	 * Interactive control for expaning and collapsing graph or tree nodes
	 * by clicking them. This control will only work when applied to a
	 * Visualization instance.
	 */
	class ExpandControl extends Control
	{
		private var _cur:NodeSprite;
		
		/** Update function invoked after expanding or collapsing an item.
		 *  By default, invokes the <code>update</code> method on the
		 *  visualization with a 1-second transitioner. */
		public var update:Dynamic public function ExpandControl(filter:*=null, update:Function=null)
		{
			this.filter = filter;
			if (update != null) this.update = update;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj==null) { detach(); return; 