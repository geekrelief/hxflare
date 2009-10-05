package flare.vis.data;

	import flare.scale.LinearScale;
	import flare.scale.LogScale;
	import flare.scale.OrdinalScale;
	import flare.scale.QuantileScale;
	import flare.scale.QuantitativeScale;
	import flare.scale.RootScale;
	import flare.scale.Scale;
	import flare.scale.ScaleType;
	import flare.scale.TimeScale;
	import flare.util.Stats;
	import flare.vis.events.DataEvent;
	
	/**
	 * Utility class that binds a data property to a descriptive scale.
	 * A ScaleBinding provides a layer of indirection between a data field and
	 * a data scale describing that field. The created scale can be used for
	 * layout and encoding of data values. When scale parameters such as the
	 * scale type or value range are updated, an underlying scale instance will
	 * be updated accordingly or a new instance will be created as needed.
	 */
	class ScaleBinding extends Scale
	{
		public var base(getBase, setBase) : Number;
		public var bins(getBins, setBins) : Int;
		public var data(getData, setData) : Data;
		public var flush(getFlush, setFlush) : Bool;
		public var group(getGroup, setGroup) : String;
		public var labelFormat(getLabelFormat, setLabelFormat) : String;
		public var length(getLength, null) : Int
		;
		public var max(getMax, setMax) : Dynamic;
		public var min(getMin, setMin) : Dynamic;
		public var ordinals(getOrdinals, setOrdinals) : Array<Dynamic>;
		public var power(getPower, setPower) : Number;
		public var preferredMax(getPreferredMax, setPreferredMax) : Dynamic;
		public var preferredMin(getPreferredMin, setPreferredMin) : Dynamic;
		public var property(getProperty, setProperty) : String;
		public var scale(getScale, null) : Scale ;
		public var scaleType(getScaleType, setScaleType) : String;
		public var zeroBased(getZeroBased, setZeroBased) : Bool;
		/** @private */
		public var _scale:Scale ;
		/** @private */
		public var _scaleType:String ;
		/** @private */
		public var _pmin:Dynamic ;
		/** @private */
		public var _pmax:Dynamic ;
		/** @private */
		public var _base:Int ;
		/** @private */
		public var _bins:Int ;
		/** @private */
		public var _power:Int ;
		/** @private */
		public var _zeroBased:Bool ;
		/** @private */
		public var _ordinals:Array<Dynamic> ;
		
		/** @private */
		public var _property:String;
		/** @private */
		public var _group:String;
		/** @private */
		public var _data:Data;
		/** @private */
		public var _stats:Stats;
		
		/** If true, updates to the underlying data will be ignored, as will
		 *  any calls to <code>updateBinding</code>. Set this flag if you want
		 *  to prevent the scale values from changing automatically. */
		public var ignoreUpdates:Bool ;
		
		/** The type of scale to create. */
		public override function getScaleType():String {
			return _scaleType ? _scaleType : scale.scaleType;
		}
		public function setScaleType(type:String):String {
			_scaleType = type;
			_scale = null;
			return type;
		}
		
		/** The preferred minimum data value for the scale. If null, the scale
		 *  minimum will be determined from the data directly. */
		public function getPreferredMin():Dynamic { return _pmin; }
		public function setPreferredMin(val:Dynamic):Dynamic {
			_pmin = val;
			if (_scale && _pmin) {
				_scale.min = _pmin;
				if (_zeroBased) zeroAlignScale(_scale);
			}
			return val;
		}
		
		/** The preferred maximum data value for the scale. If null, the scale
		 *  maximum will be determined from the data directly. */
		public function getPreferredMax():Dynamic { return _pmax; }
		public function setPreferredMax(val:Dynamic):Dynamic {
			_pmax = val;
			if (_scale && _pmax) {
				_scale.max = _pmax;
				if (_zeroBased) zeroAlignScale(_scale);
			}
			return val;
		}
		
		/** @inheritDoc */
		public override function getMax():Dynamic { return scale.max; }
		public override function setMax(v:Dynamic):Dynamic { scale.max = v; 	return v;}
		
		/** @inheritDoc */
		public override function getMin():Dynamic { return scale.min; }
		public override function setMin(v:Dynamic):Dynamic { scale.min = v; 	return v;}
		
		/** The number base to use for a quantitative scale (10 by default). */
		public function getBase():Number { return _base; }
		public function setBase(val:Number):Number {
			_base = val;
			if (Std.is( _scale, QuantitativeScale)) {
				QuantitativeScale(_scale).base = _base;
			}
			return val;
		}
		
		/** A free parameter that indicates the exponent for a RootScale. */
		public function getPower():Number { return _power; }
		public function setPower(val:Number):Number {
			_power = val;
			if (Std.is( _scale, RootScale)) {
				RootScale(_scale).power = _power;
			}
			return val;
		}
		
		/** The number of bins for quantile scales. */
		public function getBins():Int { return _bins; }
		public function setBins(count:Int):Int {
			_bins = count;
			if (Std.is( _scale, QuantileScale)) {
				_scale = null;
			}
			return count;
		}
		
		/** Flag indicating if the scale bounds should be flush with the data.
		 *  @see flare.scale.Scale#flush */
		public override function getFlush():Bool { return _flush; }
		public override function setFlush(val:Bool):Bool {
			_flush = val;
			if (_scale) _scale.flush = _flush;
			return val;
		}
		
		/** Formatting pattern for formatting labels for scale values.
		 *  @see flare.vis.scale.Scale#labelFormat. */
		public override function getLabelFormat():String { return _format; }
		public override function setLabelFormat(fmt:String):String {
			_format = fmt;
			if (_scale) _scale.labelFormat = fmt;
			return fmt;
		}
		
		/** Flag indicating if a zero-based scale should be used. If set to
		 *  true, and the scale type is numerical, the minimum or maximum
		 *  scale value will automatically be adjusted to include the zero
		 *  point as necessary. */
		public function getZeroBased():Bool { return _zeroBased; }
		public function setZeroBased(val:Bool):Bool {
			_zeroBased = val;
			if (_scale) zeroAlignScale(_scale);
			return val;
		}
		
		/** An ordered array of values for defining an ordinal scale. */
		public function getOrdinals():Array<Dynamic> { return _ordinals; }
		public function setOrdinals(ord:Array<Dynamic>):Array<Dynamic> {
			_ordinals = ord;
			if (ScaleType.isOrdinal(_scaleType)) {
				_stats = null;
				_scale = null;
			}
			return ord;
		}
		
		// -----------------------------------------------------
		
		/** The data instance to bind to. */
		public function getData():Data { return _data; }
		public function setData(data:Data):Data {
			if (_data != null) { // remove existing listeners
				_data.removeEventListener(DataEvent.ADD,   onDataEvent);
				_data.removeEventListener(DataEvent.REMOVE, onDataEvent);
				_data.removeEventListener(DataEvent.UPDATE, onDataEvent);
			}
			_data = data;
			if (_data != null) { // add new listeners
				_data.addEventListener(DataEvent.ADD,
					onDataEvent, false, 0, true);
				_data.addEventListener(DataEvent.REMOVE,
					onDataEvent, false, 0, true);
				_data.addEventListener(DataEvent.UPDATE,
					onDataEvent, false, 0, true);
			}
			return data;
		}
		
		/** The data group to bind to. */
		public function getGroup():String { return _group; }
		public function setGroup(name:String):String {
			if (name != _group) {
				_group = name;
				_stats = null;
				_scale = null;
			}
			return name;
		}
		
		/** The data property to bind to. */
		public function getProperty():String { return _property; }
		public function setProperty(name:String):String {
			if (name != _property) {
				_property = name;
				_stats = null;
				_scale = null;
			}
			return name;
		}
		
		/** The underlying scale created by this binding. */
		public function getScale():Scale {
			if (!_data || !_group || !_property) {
				throw new Error("Can't create scale with data to bind to.");
			}
			if (!_scale) {
				_stats = _data.group(_group).stats(_property);
				_scale = buildScale(_stats);
			}
			return _scale;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ScaleBinding.
		 */
		public function new()
		{
		
		_scale = null;
		_scaleType = null;
		_pmin = null;
		_pmax = null;
		_base = 10;
		_bins = 5;
		_power = NaN;
		_zeroBased = false;
		_ordinals = null;
		ignoreUpdates = false;
		}
		
		/**
		 * Checks to see if the binding is current. If not, the internal stats
		 * and scale for this binding will be cleared and lazily recomputed.
		 * @return true if the binding was updated, false otherwise
		 */
		public function updateBinding():Bool
		{
			if (ignoreUpdates) return false;
			var stats:Stats = _data.group(_group).stats(_property);
			if (stats !== _stats) { // object identity test
				_stats = null;
				_scale = null;
				return true;
			}
			return false;
		}
		
		/**
		 * Internal listener for data events that clears the current scale
		 * instance as needed.
		 * @param evt a DataEvent
		 */
		private function onDataEvent(evt:DataEvent):Void
		{
			if (ignoreUpdates) return;
			if (evt.list.name == _group) {
				if (evt.type == DataEvent.UPDATE) {
					updateBinding();
				} else {
					_stats = null;
					_scale = null;
				}
			}
		}
		
		/** @inheritDoc */
		public override function clone() : Scale
		{
			return scale.clone();
		}
		
		/**
		 * Returns the index of the input value in the ordinal array if the
		 * scale is ordinal or categorical, otherwise returns -1.
		 * @param value the value to lookup
		 * @return the index of the input value. If the value is not contained
		 *  in the ordinal array, this method returns -1.
		 */
		public function index(value:Dynamic):Int
		{
			var s:OrdinalScale = cast( scale, OrdinalScale);
			return (s ? s.index(value) : -1);
		}
		
		/** The number of distinct values in this scale, if ordinal. */
		public function getLength():Int
		{
			var s:OrdinalScale = cast( scale, OrdinalScale);
			return (s ? s.length : -1);
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Dynamic) : Number
		{
			return scale.interpolate(value);
		}

		/** @inheritDoc */
		public override function lookup(f:Number) : Dynamic
		{
			return scale.lookup(f);
		}

		/** @inheritDoc */
		public override function values(?num:Int=-1) : Array<Dynamic>
		{
			return scale.values(num);
		}
		
		/** @inheritDoc */
		public override function label(value:Dynamic) : String
		{
			return scale.label(value);
		}
		
		/** @private */
		public function buildScale(stats:Stats):Scale
		{
			var type:String = _scaleType ? _scaleType : ScaleType.UNKNOWN;
			var vals:Array<Dynamic> = _ordinals ? _ordinals : stats.distinctValues;
			var scale:Scale;
			
			switch (stats.dataType) {
				case Stats.NUMBER:
					switch (type) {
						case ScaleType.LINEAR:
						case ScaleType.UNKNOWN:
							scale = new LinearScale(stats.minimum, stats.maximum, _base, _flush, _format);
							break;
						case ScaleType.ROOT:
							var pow:Int = isNaN(_power) ? 2 : _power;
							scale = new RootScale(stats.minimum, stats.maximum, _base, _flush, pow, _format);
							break;
						case ScaleType.LOG:
							scale = new LogScale(stats.minimum, stats.maximum, _base, _flush, _format);
							break;
						case ScaleType.QUANTILE:
							scale = new QuantileScale(_bins, stats.values, true, _format);
							break;
						default:
							scale = new OrdinalScale(vals, _flush, false, _format);
							break;
					}
					break;
				case Stats.DATE:
					switch (type) {
						case ScaleType.UNKNOWN:
						case ScaleType.LINEAR:
						case ScaleType.TIME:
							scale = new TimeScale(stats.minDate, stats.maxDate, _flush, _format);
							break;
						default:
							scale = new OrdinalScale(vals, _flush, false, _format);
							break;
					}
					break;
				default:
					scale = new OrdinalScale(vals, _flush, false, _format);
					break;
			}
			
			if (_pmin) scale.min = _pmin;
			if (_pmax) scale.max = _pmax;
			if (_zeroBased) zeroAlignScale(scale);
			
			return scale;
		}
		
		private static function zeroAlignScale(scale:Scale):Void
		{
			if (Std.is( scale, QuantitativeScale)) {
				var qs:QuantitativeScale = QuantitativeScale(scale);
				if (qs.scaleMin > 0) qs.dataMin = 0;
				if (qs.scaleMax < 0) qs.dataMax = 0;
			}
		}

	} // end of class ScaleBinding
