package flare.animate;

	import flare.util.Maths;
	
	import flash.events.EventDispatcher;

	/*[Event(name="start",  type="flare.animate.TransitionEvent")]*/
	/*[Event(name="step",   type="flare.animate.TransitionEvent")]*/
	/*[Event(name="end",    type="flare.animate.TransitionEvent")]*/
	/*[Event(name="cancel", type="flare.animate.TransitionEvent")]*/

	/**
	 * Base class representing an animated transition. Provides support for
	 * tracking animation progress over a time duration. The Transition class
	 * also issues events whenever the transition is started, stepped, or
	 * ended. Register event listeners for <code>TransitionEvents</code> to
	 * track and respond to a transition's progress.
	 * 
	 * <p>Useful subclasses of <code>Transition</code> include the
	 * <code>Tween</code>, <code>Parallel</code>, <code>Sequence</code>,
	 * <code>Pause</code>, and <code>Transitioner</code> classes.</p>
	 */
	class Transition extends EventDispatcher implements ISchedulable
	{
		public var delay(getDelay, setDelay) : Number;
		public var duration(getDuration, setDuration) : Number;
		public var easing(getEasing, setEasing) : Dynamic;
		public var id(getId, setId) : String;
		public var progress(getProgress, setProgress) : Number;
		public var reverse(getReverse, null) : Bool ;
		public var running(getRunning, null) : Bool ;
		public var totalDuration(getTotalDuration, null) : Number ;
		/** Default easing function: a cubic slow-in slow-out. */
		inline public static var DEFAULT_EASING:Dynamic = Easing.easeInOutPoly(3);
		
		/** Constant indicating this Transition needs initialization. */
		inline public static var SETUP:Int = 0;
		/** Constant indicating this Transition has been initialized. */
		inline public static var INIT:Int = 1;
		/** Constant indicating this Transition is currently running. */
		inline public static var RUN:Int = 2;
		
		// -- Properties ------------------------------------------------------

		private var _easing:Dynamic ; // easing function
		
		private var _id:String ;        // transition id, default null
		private var _duration:Number;         // duration, in seconds
		private var _delay:Number;            // delay, in seconds
		private var _frac:Number;             // animation fraction
		private var _state:Int ;       // initialization flag
		/** @private */
		public var _start:Number;          // start time	
		/** Flag indicating this Transition is currently running. */
		public var _running:Bool ;
		/** Flag indicating this Transition is running in reverse. */
		public var _reverse:Bool ;
		
		/** @inheritDoc */
		public function getId():String { return _id; }
		public function setId(s:String):String
		{
			if (_running) {
				throw new Error(
					"The id can't be changed while a transition is running.");
			} else {
				_id = s;
			}
			return s;
		}
		
		/** The total duration, including both delay and active duration. */
		public function getTotalDuration():Number { return duration + delay; }
		
		/** The duration (length) of this Transition, in seconds. */
		public function getDuration():Number { return _duration; }
		public function setDuration(d:Number):Number {
			if (d<0) throw new ArgumentError("Negative duration not allowed.");
			_duration = d;
			return d;
		}

		/** The delay between a call to play and the actual start
		 *  of the transition, in seconds. */
		public function getDelay():Number { return _delay; }
		public function setDelay(d:Number):Number {
			if (d<0) throw new ArgumentError("Negative delay not allowed.");
			_delay = d;
			return d;
		}
		
		/** Fraction between 0 and 1 indicating the current progress
		 *  of this transition. */
		public function getProgress():Number { return _frac; }
		private function setProgress(f:Number):Number { _frac = f; 	return f;}
		
		/** Easing function used to pace this Transition. */
		public function getEasing():Dynamic { return _easing; }
		public function setEasing(f:Dynamic):Dynamic { _easing = f; 	return f;}
		
		/** Indicates if this Transition is currently running. */
		public function getRunning():Bool { return _running; }
		
		/** Indicates if this Transition is running in reverse. */
		public function getReverse():Bool { return _reverse; }
		
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new Transition.
		 * @param duration the duration, in seconds
		 * @param delay the delay, in seconds
		 * @param easing the easing function
		 */
		public function new(?duration:Int=1, ?delay:Int=0,
								   ?easing:Dynamic=null)
		{
			
			_easing = DEFAULT_EASING;
			_id = null;
			_state = SETUP;
			_running = false;
			_reverse = false;
			_duration = duration;
			_delay = delay;
			_easing = (easing==null ? DEFAULT_EASING : easing);
		}
		
		/**
		 * Starts running the transition.
		 * @param reverse if true, the transition is played in reverse,
		 *  if false (the default), it is played normally.
		 */
		public function play(?reverse:Bool = false):Void
		{
			_reverse = reverse;
			init();
			Scheduler.instance.add(this);
			_running = true;
		}
		
		/**
		 * Stops the transition and completes it.
		 * Any end-of-transition actions will still be taken.
		 * Calling play() after stop() will result in the transition
		 * starting over from the beginning.
		 */
		public function stop():Void
		{
			Scheduler.instance.remove(this);
			doEnd();
		}
		
		/**
		 * Informs this transition that it was cancelled by the scheduler.
		 * Assumes that the scheduler has already removed the transition.
		 * Clients should not call this method, but should use the
		 * <code>stop()</code> method to end a transition early.
		 */
		public function cancelled():Void
		{
			doEnd(TransitionEvent.CANCEL);
		}
		
		/**
		 * Resets the transition, so that any cached starting values are
		 * cleared and reset the next time this transition is played.
		 */
		public function reset():Void
		{
			_state = SETUP;
		}
		
		/**
		 * Pauses the transition at its current position.
		 * Calling play() after pause() will resume the transition.
		 */
		public function pause():Void
		{
			Scheduler.instance.remove(this);
			_running = false;
		}
		
		private function init():Void
		{
			if (_state == SETUP) doSetup();
			if (_state == RUN) {
				var f:Int = _reverse ? (1-_frac) : _frac;
				_start = new Date().time - f * 1000 * (duration + delay);
			} else {
				_start = new Date().time;
				doStart(_reverse);
			}
			_state = RUN;
		}

		private function doSetup():Void
		{
			setup();
			_state = INIT;
		}

		private function doStart(reverse:Bool):Void
		{
			_reverse = reverse;
			_running = true;
			_frac = _reverse ? 1 : 0;
			start();
			if (hasEventListener(TransitionEvent.START)) {
				dispatchEvent(new TransitionEvent(TransitionEvent.START, this));
			}
		}
		
		private function doStep(frac:Number):Void
		{
			_frac = frac;
			var f:Int = delay==0 ? frac
				 : Maths.invLinearInterp(frac, delay/totalDuration, 1);
			if (f >= 0) { step(_easing(f)); }
			if (hasEventListener(TransitionEvent.STEP)) {
				dispatchEvent(new TransitionEvent(TransitionEvent.STEP, this));
			}
		}
		
		private function doEnd(?evtType:String="end"):Void
		{
			_frac = _reverse ? 0 : 1;
			end();
			_state = INIT;
			_running = false;
			if (hasEventListener(evtType)) {
				dispatchEvent(new TransitionEvent(evtType, this));
			}
		}
		
		/**
		 * Evaluates the Transition, stepping the transition forward.
		 * @param time the current time in milliseconds
		 * @return true if this item should be removed from the scheduler,
		 * false if it should continue to be run.
		 */
		public function evaluate(time:Number):Bool
		{
			var t:Int = time - _start;
			if (t < 0) return false;
			
			// step the transition forward
			var d:Int = 1000 * (duration + delay);
			t = (d==0 ? 1.0 : t/d);
			if (t > 1) t = 1; // clamp
			doStep(_reverse ? 1-t : t);
			
			// check if we're done
			var _done:Bool = (t >= 1.0);
			if (_done) { doEnd(); }
			return _done;
		}
		
		/**
		 * Disposes of this transition, freeing up any resources held. This
		 * method is optional, but calling it when a transition is no longer
		 * needed can help improve overall performance.
		 */
		public function dispose():Void
		{
			// for sub-classes to implement
		}
		
		// -- abstract methods ------------------------------------------------
		
		/**
		 * Transition setup routine. Subclasses should override this function
		 * to perform custom setup actions.
		 */
		public function setup():Void
		{
			// for sub-classes to implement
		}
		
		/**
		 * Transition start routine. Subclasses should override this function
		 * to perform custom start actions.
		 */
		public function start():Void
		{
			// for sub-classes to implement
		}
		
		/**
		 * Transition step routine. Subclasses should override this function
		 * to perform custom step actions.
		 */
		private function step(ef:Number):Void
		{
			// for sub-classes to implement
		}
		
		/**
		 * Transition end routine. Subclasses should override this function
		 * to perform custom ending actions.
		 */
		public function end():Void
		{
			// for sub-classes to implement
		}
		
	} // end of class Transition
