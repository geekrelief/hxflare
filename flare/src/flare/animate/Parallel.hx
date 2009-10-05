package flare.animate;

	import flare.util.Arrays;
	import flare.util.Maths;
	
	/**
	 * Transition that runs multiple transitions simultaneously (in parallel).
	 * The duration of this parallel transition is computed as the maximum
	 * total duration (duration + delay) among the sub-transitions. If the
	 * duration is explicitly set, the sub-transition lengths will be
	 * uniformly scaled to fit within the new time span.
	 */
	class Parallel extends Transition
	{
		public var autoDuration(getAutoDuration, setAutoDuration) : Bool;
		public var duration(getDuration, setDuration) : Number;
		// -- Properties ------------------------------------------------------
		
		/** Array of parallel transitions */
		public var _trans:/*Transition*/Array<Dynamic> ;
		/** @private */
		public var _equidur:Bool;
		/** @private */
		public var _dirty:Bool ;
		/** @private */
		public var _autodur:Bool ;

		/**
		 * If true, the duration of this sequence is automatically determined
		 * by the longest sub-transition. This is the default behavior.
		 */
		public function getAutoDuration():Bool { return _autodur; }
		public function setAutoDuration(b:Bool):Bool {
			_autodur = b;
			computeDuration();
			return b;
		}
		
		/** @inheritDoc */
		public override function getDuration():Number {
			if (_dirty) computeDuration();
			return super.duration;
		}
		public override function setDuration(dur:Number):Number {
			_autodur = false;
			super.duration = dur;
			_dirty = true;
			return dur;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new Parallel transition.
		 * @param transitions a list of sub-transitions
		 */
		public function new(transitions:Array<Dynamic>) {
			
			_trans = [];
			_dirty = false;
			_autodur = true;
			easing = Easing.none;
			for each (var t:Transition in transitions) {
				_trans.push(t);
			}
			_dirty = true;
		}
		
		/**
		 * Adds a new sub-transition to this parallel transition.
		 * @param t the transition to add
		 */
		public function add(t:Transition):Void {
			if (running) throw new Error("Transition is running!");
			_trans.push(t);
			_dirty = true;
		}
		
		/**
		 * Removes a sub-transition from this parallel transition.
		 * @param t the transition to remove
		 * @return true if the transition was found and removed, false
		 *  otherwise
		 */
		public function remove(t:Transition):Bool {
			if (running) throw new Error("Transition is running!");
			var rem:Bool = Arrays.remove(_trans, t) >= 0;
			if (rem) _dirty = true;
			return rem;
		}
		
		/**
		 * Computes the duration of this parallel transition.
		 */
		public function computeDuration():Void {
			var d:Int=0, td:Number;
			if (_trans.length > 0) d = _trans[0].totalDuration;
			_equidur = true;	
			for each (var t:Transition in _trans) {
				td = t.totalDuration;
				if (_equidur && td != d) _equidur = false;
				d = Math.max(d, t.totalDuration);
			}
			if (_autodur) super.duration = d;
			_dirty = false;
		}
		
		/** @inheritDoc */
		public override function dispose():Void {
			while (_trans.length > 0) { _trans.pop().dispose(); }
		}
		
		// -- Transition Handlers ---------------------------------------------

		/** @inheritDoc */
		public override function play(?reverse:Bool=false):Void
		{
			if (_dirty) computeDuration();
			super.play(reverse);
		}

		/**
		 * Sets up each sub-transition.
		 */
		public override function setup():Void
		{
			for each (var t:Transition in _trans) { t.doSetup(); }
		}
		
		/**
		 * Starts each sub-transition.
		 */
		public override function start():Void
		{
			for each (var t:Transition in _trans) { t.doStart(_reverse); }
		}
		
		/**
		 * Steps each sub-transition.
		 * @param ef the current progress fraction.
		 */
		private override function step(ef:Number):Void
		{
			var t:Transition;
			if (_equidur) {
				// if all durations are the same, we can skip some calculations
				for each (t in _trans) { t.doStep(ef); }
			} else {
				// otherwise, make sure we respect the different lengths
				var d:Int = duration;
				for each (t in _trans) {
					var td:Int = t.totalDuration;
					var f:Int = d==0 || td==d ? 1 : td/d;
					t.doStep(ef>f ? 1 : f==1 ? ef : ef/f);
				}
			}
		}
		
		/**
		 * Ends each sub-transition.
		 */
		public override function end():Void
		{
			for each (var t:Transition in _trans) { t.doEnd(); }
		}
		
	} // end of class Parallel
