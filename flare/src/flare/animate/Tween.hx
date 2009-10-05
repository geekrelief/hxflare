package flare.animate;

	import flare.animate.interpolate.Interpolator;
	import flare.util.Property;
	
	import flash.display.DisplayObject;
	
	/**
	 * Transition that interpolates (in-be<em>tweens</em>) properties
	 * of a target object over a time interval. The <tt>values</tt> property
	 * represents the set of properties to tween and their final values. Any
	 * arbitrary property (not just visual properties) can be tweened. The
	 * Tween class handles tweening of Numbers, colors, Dates, Points,
	 * Rectangles, and numeric Arrays. Properties of other types are simply
	 * swapped when then Transition half-completes. Tweening for custom types
	 * is possible, see the <tt>flare.animate.interpolate.Interpolator</tt>
	 * class for more.
	 * 
	 * <p>Starting values are automatically determined from the tweened object.
	 * Once determined, these starting values are stored to allow both forward
	 * and backward playback. Use the <tt>reset</tt> method to force a tween to
	 * redetermine the starting values the next time it is played. Tweens also
	 * provide a <code>remove</code> flag for DisplayObjects. When set to true,
	 * a display object will be removed from the display list at the end of the
	 * tween. Note that playing the tween is reverse will not revert this
	 * removal.</p>
	 * 
	 * <p>Internally, a Tween creates a set of Interpolator objects to compute
	 * intermediate values for each property included in <tt>values</tt>. Note
	 * that property names can involve nested properties. For example,
	 * <tt>{"filters[0].blurX":5}</tt> is a valid tweening property, as both
	 * array access (<tt>[]</tt>) and property access (<tt>.</tt>) syntax are
	 * supported.</p>
	 * 
	 * <p>To manage a collection of objects being tweened simultaneously, use a
	 * <tt>Transitioner</tt> object.</p>
	 */
	class Tween extends Transition
	{
		public var from(getFrom, setFrom) : Dynamic;
		public var remove(getRemove, setRemove) : Bool;
		public var target(getTarget, setTarget) : Dynamic;
		public var values(getValues, setValues) : Dynamic;
		// -- Properties ------------------------------------------------------
		
		private var _interps:Array<Dynamic> ;
		private var _target:Dynamic;
		private var _from:Dynamic;
		private var _remove:Bool ;
		private var _visible:Dynamic ;
		private var _values:Dynamic;
		
		/** The target object whose properties are tweened. */
		public function getTarget():Dynamic { return _target; }
		public function setTarget(t:Dynamic):Dynamic { _target = t; 	return t;}
		
		/** Flag indicating if the target object should be removed from the
		 *  display list at the end of the tween. Only applies when the target
		 *  is a <code>DisplayObject</code>. */
		public function getRemove():Bool { return _remove; }
		public function setRemove(b:Bool):Bool { _remove = b; 	return b;}
		
		/** The properties to tween and their target values. */
		public function getValues():Dynamic { return _values; }
		public function setValues(o:Dynamic):Dynamic { _values = o; 	return o;}
		
		/** Optional starting values for tweened properties. */
		public function getFrom():Dynamic { return _from; }
		public function setFrom(s:Dynamic):Dynamic { _from = s; 	return s;}
		
		
		// - Methods ----------------------------------------------------------
		
		/**
		 * Creates a new Tween with the specified parameters.
		 * @param target the target object
		 * @param duration the duration of the tween, in seconds
		 * @param values the properties to tween and their target values
		 * @param remove a display list removal flag (for
		 *  <code>DisplayObject</code> target objects
		 * @param easing the easing function to use
		 */
		public function new(target:Dynamic, ?duration:Int=1,
			?values:Dynamic=null, ?remove:Bool=false, ?easing:Dynamic=null)
		{
			
			_interps = new Array();
			_remove = false;
			_visible = null;
			super(duration, 0, easing);
			
			_target = target;
			_remove = remove;
			_values = values==null ? {} : values;
			_from = {};
		}
		
		/** @inheritDoc */
		public override function dispose():Void
		{
			// reclaim any old interpolators
			while (_interps.length > 0) {
				Interpolator.reclaim(_interps.pop());
			}
			// remove all target values
			for (var name:String in _values) {
				delete _values[name];
			}
			_visible = null;
			_remove = false;
			_target = null;
		}
		
		/**
		 * Sets up this tween by creating interpolators for each tweened
		 * property.
		 */
		public override function setup():Void
		{
			// reclaim any old interpolators
			while (_interps.length > 0) {
				Interpolator.reclaim(_interps.pop());
			}
			
			// build interpolators
			var vc:Dynamic, v0:Dynamic, v1:Dynamic;
			for (var name:String in _values) {
				// create interpolator only if start/cur/end values don't match
				vc = Property._S_(name).getValue(_target);
				v0 = _from.hasOwnProperty(name) ? _from[name] : vc;
				v1 = _values[name];
				
				if (vc != v1 || vc != v0) {
					if (name == "visible") {
						// special handling for visibility
						_visible = Boolean(v1);
					} else {
						_interps.push(Interpolator.create(_target, name, v0, v1));
					}
				}
			}
		}
		
		/**
		 * Updates target object visibility, if appropriate.
		 */
		public override function start():Void
		{
			// set visibility
			var item:DisplayObject = cast( _target, DisplayObject);
			if (item != null && Boolean(_visible))
				item.visible = true;
		}
		
		/**
		 * Steps the tween, updating the tweened properties.
		 */
		private override function step(ef:Number):Void
		{
			// run the interpolators
			for each (var i:Interpolator in _interps) {
				i.interpolate(ef);
			}
		}
		
		/**
		 * Ends the tween, updating target object visibility and display
		 * list membership, if appropriate.
		 */
		public override function end():Void
		{
			// set visibility, remove from display list if requested
			var item:DisplayObject = cast( _target, DisplayObject);
			if (item != null) {
				if (_remove && item.parent != null)
					item.parent.removeChild(item);
				if (_visible != null)
					item.visible = Boolean(_visible);
			}
		}
		
	} // end of class Tween
