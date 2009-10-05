package flare.vis.operator.layout;

	import flare.scale.LinearScale;
	import flare.scale.OrdinalScale;
	import flare.scale.QuantitativeScale;
	import flare.scale.Scale;
	import flare.scale.TimeScale;
	import flare.util.Arrays;
	import flare.util.Maths;
	import flare.util.Orientation;
	import flare.util.Stats;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that consecutively places items on top of each other. The layout
	 * currently assumes that each column value is available as separate
	 * properties of individual DataSprites.
	 */
	class StackedAreaLayout extends Layout
	{
		public var columns(getColumns, setColumns) : Array<Dynamic>;
		public var normalize(getNormalize, setNormalize) : Bool;
		public var orientation(getOrientation, setOrientation) : String;
		public var padding(getPadding, setPadding) : Number;
		public var scale(getScale, setScale) : QuantitativeScale;
		public var threshold(getThreshold, setThreshold) : Number;
		// -- Properties ------------------------------------------------------
		
		private var _columns:Array<Dynamic>;
    	private var _peaks:Array<Dynamic>;
    	private var _poly:Array<Dynamic>;
		
		private var _orient:String ;
		private var _horiz:Bool ;
		private var _top:Bool ;
		private var _initAxes:Bool ;
		
		private var _normalize:Bool ;
		private var _padding:Float 5;
		private var _threshold:Float ;
		
		private var _scale:QuantitativeScale ;
		private var _colScale:Scale;
		
		/** Array containing the column names. */
		public function getColumns():Array<Dynamic> { return _columns; }
		public function setColumns(cols:Array<Dynamic>):Array<Dynamic> {
			_columns = Arrays.copy(cols);
			_peaks = new Array(cols.length);
			_poly = new Array(cols.length);
			_colScale = getScale(_columns);
			return cols;
		}
		
		/** Flag indicating if the visualization should be normalized. */		
		public function getNormalize():Bool { return _normalize; }
		public function setNormalize(b:Bool):Bool { _normalize = b; 	return b;}
		
		/** Value indicating the padding (as a percentage of the view)
		 *  that should be reserved within the visualization. */
		public function getPadding():Number { return _padding; }
		public function setPadding(p:Number):Number {
			if (p<0 || isNaN(p) || !isFinite(p)) return;
			_padding = p;
			return p;
		}
		
		/** Threshold size value (in pixels) that at least one column width
		 *  must surpass for a stack to remain visible. */
		public function getThreshold():Number { return _threshold; }
		public function setThreshold(t:Number):Number { _threshold = t; 	return t;}
		
		/** The orientation of the layout. */
		public function getOrientation():String { return _orient; }
		public function setOrientation(o:String):String {
			_orient = o;
			_horiz = Orientation.isHorizontal(_orient);
        	_top   = (_orient == Orientation.TOP_TO_BOTTOM ||
        			  _orient == Orientation.LEFT_TO_RIGHT);
        	initializeAxes();
			return o;
		}
		
		/** The scale used to layout the stacked values. */
		public function getScale():QuantitativeScale { return _scale; }
		public function setScale(s:QuantitativeScale):QuantitativeScale {
			_scale = s; _scale.dataMin = 0;
			return s;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new StackedAreaLayout.
		 * @param cols an ordered array of properties for the column values
		 * @param padding percentage of space to leave as a padding margin
		 *  for the stacked chart
		 */		
		public function StackedAreaLayout(cols:Array=null, padding:Number=0.05)
		{
			layoutType = CARTESIAN;
			if (cols != null) this.columns = cols;
			this.padding = padding;
		}
		
		private static function getScale(cols:Array):Scale
		{
			var stats:Stats = new Stats(cols);
			switch (stats.dataType) {
				case Stats.NUMBER:
					return new LinearScale(stats.minimum, stats.maximum, 10, true);
				case Stats.DATE:
					return new TimeScale(stats.minDate, stats.maxDate, true);
				case Stats.OBJECT:
				default:
					return new OrdinalScale(stats.distinctValues, true, false);
			