package flare.vis.legend;

	import flare.animate.Transitioner;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.scale.Scale;
	import flare.scale.ScaleType;
	import flare.util.Displays;
	import flare.util.Orientation;
	import flare.util.palette.ColorPalette;
	import flare.util.palette.Palette;
	import flare.util.palette.ShapePalette;
	import flare.util.palette.SizePalette;
	import flare.vis.data.ScaleBinding;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	/**
	 * A legend describing the visual encoding of a data property. Legends
	 * support both discrete legends that list individual items and
	 * range legends the convey a continuous range of values. Discrete
	 * legends consist of a collection of <code>LegendItem</code> instances
	 * stored in the <code>items</code> sprite. Range legends consist of
	 * a single <code>LegendRange</code> instance stored in the
	 * <code>items</code> sprite.
	 * 
	 * <p>There are multiple ways to generate a legend. To build a legend
	 * based on an existing visual encoding, use the static
	 * <code>fromScale</code> constructor. This method takes a data scale
	 * and one more or more palettes (e.g., color, shape, or size palettes)
	 * and uses them to generate an appropriate legend. If the data scale
	 * is a quantitative scale and only a color palette is provided, a
	 * continuous range legend will be generated. Otherwise, a discrete
	 * legend will be created.</p>
	 * 
	 * <p>Legends can also be created from a collection of independent
	 * values using the static <code>fromValues</code> constructor. This
	 * method takes an array of legend item descriptions and uses them to
	 * generate a legend. For example, consider this code:</p>
	 * 
	 * <pre>
	 * var legend:Legend = Legend.fromValues("Legend Title", [
	 *   {color: 0xff0000, shape:Shapes.X, label:"Red X"},
	 *   {color: 0x00ff00, shape:Shapes.SQUARE, label:"Green Square"},
	 *   {color: 0x0000ff, shape:Shapes.CIRCLE, label:"Blue Circle"}
	 * ]);
	 * </pre>
	 * 
	 * <p>This example will create a legend with the described values.
	 * See the documentation for the <code>buildFromValues</code> method
	 * for more details.</p>
	 */
	class Legend extends Sprite
	{
		public var baseIconSize(getBaseIconSize, setBaseIconSize) : Number;
		public var border(getBorder, null) : RectSprite ;
		public var bounds(getBounds, setBounds) : Rectangle;
		public var colorPalette(getColorPalette, setColorPalette) : ColorPalette;
		public var defaultColor(getDefaultColor, setDefaultColor) : UInt;
		public var discrete(getDiscrete, null) : Bool ;
		public var items(getItems, null) : Sprite ;
		public var labelTextFormat(getLabelTextFormat, setLabelTextFormat) : TextFormat;
		public var labelTextMode(getLabelTextMode, setLabelTextMode) : Int;
		public var margin(getMargin, setMargin) : Number;
		public var orientation(getOrientation, setOrientation) : String;
		public var range(getRange, null) : LegendRange ;
		public var scale(getScale, setScale) : Scale;
		public var shapePalette(getShapePalette, setShapePalette) : ShapePalette;
		public var sizePalette(getSizePalette, setSizePalette) : SizePalette;
		public var spacing(getSpacing, setSpacing) : Number;
		public var title(getTitle, null) : TextSprite ;
		/** @private The layout bounds for this legend instance. */
		public var _bounds:Rectangle ;

		/** @private Sprite defining the border of the legend. */
		public var _border:RectSprite;
		/** @private Sprite containing the legend items. */
		public var _items:Sprite;
		/** @private TextSprite containing the legend title.*/
		public var _title:TextSprite;
		
		/** @private Scale instance used to define the legend mapping. */
		public var _scale:Scale;
		/** @private Flag for if this legend is discrete or continuous. */
		public var _discrete:Bool ;
		
		/** @private The default color to use for legend items. */
		public var _defaultColor:UInt ;
		/** @private The color palette used to encode values (may be null). */
		public var _colors:ColorPalette;
		/** @private The shape palette used to encode values (may be null). */
		public var _shapes:ShapePalette;
		/** @private The size palette used to encode values (may be null). */
		public var _sizes:SizePalette;
		
		/** @private Flag indicating the desired orientation of this legend. */
		public var _orient:String ;
		/** @private Margins within legend items. */
		public var _margin:Int ;
		/** @private Spacing between legend items. */
		public var _spacing:Int ;
		/** @private Base icon size */
		public var _baseIconSize:Int ;

		/** @private TextFormat (font, size, style) of legend item labels. */
		public var _labelTextFormat:TextFormat ;	
		/** @private Label text mode. */
		public var _labelTextMode:Int ;
	
		/** @private The calculated internal width of the legend. */
		public var _iw:Number;
		/** @private The calculated internal height of the legend. */
		public var _ih:Number;

		// -- Properties ------------------------------------------------------

		/** The layout bounds for this legend instance. */
		public function getBounds():Rectangle { return _bounds; }
		public function setBounds(b:Rectangle):Rectangle { _bounds = b; 	return b;}
		
		/** Sprite defining the border of the legend. */
		public function getBorder():RectSprite { return _border; }
		/** Sprite containing the legend items. */
		public function getItems():Sprite { return _items; }
		/** TextSprite containing the legend title.*/
		public function getTitle():TextSprite { return _title; }
		
		/** Flag indicating if this legend is discrete or continuous. */
		public function getDiscrete():Bool { return _discrete; }
		
		/** Scale instance used to define the legend mapping. */
		public function getScale():Scale { return _scale; }
		public function setScale(s:Scale):Scale { _scale = s; 	return s;}
		/** The legend range, if this legend is continuous. This
		 *  value is null if the legend is discrete. */
		public function getRange():LegendRange {
			return _discrete ? null : LegendRange(_items.getChildAt(0));
		}

		/** The default color to use for legend items. */		
		public function getDefaultColor():UInt { return _defaultColor; }
		public function setDefaultColor(c:UInt):UInt { _defaultColor = c; 	return c;}

		/** The color palette used to encode values (may be null). */		
		public function getColorPalette():ColorPalette { return _colors; }
		public function setColorPalette(cp:ColorPalette):ColorPalette { _colors = cp; 	return cp;}

		/** The shape palette used to encode values (may be null). */		
		public function getShapePalette():ShapePalette { return _shapes; }
		public function setShapePalette(sp:ShapePalette):ShapePalette { _shapes = sp; 	return sp;}

		/** The size palette used to encode values (may be null). */		
		public function getSizePalette():SizePalette { return _sizes; }
		public function setSizePalette(sp:SizePalette):SizePalette { _sizes = sp; 	return sp;}
		
		/** The desired orientation of this legend. */
		public function getOrientation():String { return _orient; }
		public function setOrientation(o:String):String { _orient = o; 	return o;}

		/** Margins within legend items. */		
		public function getMargin():Number { return _margin; }
		public function setMargin(m:Number):Number { _margin = m; 	return m;}

		/** Spacing between legend items. */		
		public function getSpacing():Number { return _spacing; }
		public function setSpacing(s:Number):Number { _spacing = s; 	return s;}

		/** Base icon size, corresponding to a size factor of 1. */
		public function getBaseIconSize():Number { return _baseIconSize; }
		public function setBaseIconSize(s:Number):Number {
			if (_baseIconSize != s && _discrete) {
				for (i in 0..._items.numChildren) {
					var li:LegendItem = LegendItem(_items.getChildAt(i));
					li.iconSize *= (s / _baseIconSize);
					li.maxIconSize *= (s / _baseIconSize);
				}
			}
			_baseIconSize = s;
			return s;
		}

		/** TextFormat (font, size, style) of legend item labels. */		
		public function getLabelTextFormat():TextFormat { return _labelTextFormat; }
		public function setLabelTextFormat(f:TextFormat):TextFormat {
			_labelTextFormat = f; updateItems();
			return f;
		}
		
		/** Label text mode. */
		public function getLabelTextMode():Int { return _labelTextMode; }
		public function setLabelTextMode(mode:Int):Int {
			_labelTextMode = mode; updateItems();
			return mode;
		}
		
		// -- Initialization --------------------------------------------------
		
		/**
		 * Creates a new Legend for the given data field.
		 * @param dataField the data field to describe with the legend
		 * @param vis the visualization corresponding to this legend
		 * @param scale the scale value used to map the data field to visual
		 *  variables
		 */
		public function new(title:String, ?scale:Scale=null,
			?colors:ColorPalette=null, ?shapes:ShapePalette=null,
			?sizes:SizePalette=null)
		{
			
			_bounds = null;
			_discrete = true;
			_defaultColor = 0xff888888;
			_orient = null;
			_margin = 4;
			_spacing = 0;
			_baseIconSize = 12;
			_labelTextFormat = new TextFormat("Arial",12,0);
			_labelTextMode = TextSprite.BITMAP;
			this.scale = scale;
			addChild(_border = new RectSprite(0,0,0,0,13,13));
			addChild(_title = new TextSprite());
			addChild(_items = new Sprite());
			_border.lineColor = 0;
			_border.fillColor = 0;
			
			_colors = colors;
			_shapes = shapes;
			_sizes = sizes;
			
			_title.textField.defaultTextFormat = 
				new TextFormat("Arial",12,null,true);
			if (title != null)
				_title.text = title;
			else
				_title.visible = false;
			
			if (scale != null) {
				buildFromScale();
				update();
			}
		}
		
		/**
		 * Update the legend, recomputing layout of items.
		 * @param t a transitioner for value updates
		 * @return the input transitioner
		 */
		public function update(?t:Transitioner=null):Transitioner
		{
			if (Std.is( _scale, ScaleBinding) && ScaleBinding(_scale).updateBinding())
				buildFromScale();
			updateItems();
			layout(t);
			return t;
		}
		
		/**
		 * Builds the contents of this legend from the current scale values.
		 * This method will remove all items from the legend and rebuild the
		 * legend using the current scale and palette settings.
		 */
		public function buildFromScale():Void
		{
			// first, remove all items
			while (_items.numChildren > 0) {
				_items.removeChildAt(_items.numChildren-1);
			}
					
			// determine legend type
			var type:String = _scale.scaleType;
			if (ScaleType.isQuantitative(type) && !_sizes && !_shapes) {
				// build continuous legend
				_discrete = false;
				if (!_orient) _orient = Orientation.LEFT_TO_RIGHT;
				_items.addChild(new LegendRange(_title.text,
					_scale,	_colors, _orient));
			} else {
				// build discrete legend
				_discrete = true;
				if (!_orient) _orient = Orientation.TOP_TO_BOTTOM;
				
				var numVals:Int = ScaleType.isQuantitative(type) ? 5 : -1;
				var maxSize:Int = Number.MIN_VALUE;
				var vals:Array<Dynamic> = _scale.values(numVals);
				for (i in 0...vals.length) {
					// determine legend item properties
					var f:Int = _scale.interpolate(vals[i]);
					var color:UInt = _defaultColor;
					if (_colors && ScaleType.isOrdinal(type)) {
						color = _colors.getColorByIndex(i);
					} else if (_colors) {
						color = _colors.getColor(f);
					}
					var shape:String = _shapes ? _shapes.getShape(i) : null;
					var size:Int = _baseIconSize*(_sizes?_sizes.getSize(f):1);
					if (size > maxSize) maxSize = size;
					
					var item:LegendItem = new LegendItem(
						_scale.label(vals[i]), color, shape, size);
					item.value = vals[i];
					_items.addChild(item);
				}
				for (i=0; i<_items.numChildren; ++i)
					LegendItem(_items.getChildAt(i)).maxIconSize = maxSize;
			}
		}
		
		/**
		 * Populates the contents of this legend from a list of value objects.
		 * This method will create a legend with discrete entries determined by
		 * the contents of the input <code>values</code> array. This should be
		 * an array of objects containing the following properties:
		 * <ul>
		 *  <li><code>value</code>: The data value the legend item represents.
		 *    This value is not required.</li>
		 *  <li><code>label</code>: The text label to place in the legend item.
		 *    If this value is not provided, the method will attempt to
		 *    generate a label string from the <code>value</code> property.</li>
		 *  <li><code>color</code>: The color for the legend item. If missing,
		 *    this legend's default color will be used.</li>
		 *  <li><code>shape</code>: The shape for the legend item. If missing,
		 *    a default circle shape will be used.</li>
		 *  <li><code>size</code>: The size for the legend item. If missing,
		 *    a size value of 1 will be used.</li>
		 * </ul>
		 * When this method is called, any previous values in the legend will
		 * be removed.
		 * @param values an array of value to include in the legend.
		 */
		public function buildFromValues(values:Array<Dynamic>):Void
		{
			// first, remove all items
			while (_items.numChildren > 0) {
				_items.removeChildAt(_items.numChildren-1);
			}
			_discrete = true;
			if (!_orient) _orient = Orientation.TOP_TO_BOTTOM;
			
			var maxSize:Int = Number.MIN_VALUE;
			for each (var v:Dynamic in values) {
				var value:Object = v.value != undefined ? v.value : null;
				var label:String = v.label ? v.label.toString() : value ? value.toString() : "???";
				var color:uint = v.color != undefined ? uint(v.color) : _defaultColor;
				var shape:String = v.shape ? cast( v.shape, String) : null;
				var size:Int = _baseIconSize*(Std.is( v.size, Number) ? v.size : 1);
				if (size > maxSize) maxSize = size;
				
				var item:LegendItem = new LegendItem(label, color, shape, size);
				item.value = value;
				item.margin = margin;
				_items.addChild(item);
			}
			for (var i:UInt=0; i<_items.numChildren; ++i)
				LegendItem(_items.getChildAt(i)).maxIconSize = maxSize;
		}
		
		// -- Layout ----------------------------------------------------------
		
		/**
		 * Performs layout, setting the position for all items in the legend.
		 * @param t a transitioner for value updates
		 */
		public function layout(?t:Transitioner=null):Void
		{
			t = (t ? t : Transitioner.DEFAULT);
			
			var vert:Bool = Orientation.isVertical(_orient);
			var o:Dynamic;
			var b:Rectangle = bounds;
			var x:Int = b ? b.left : 0;
			var y:Int = b ? b.top : 0;
			var w:Number, h:Number, th:Int = 0;
			
			// layout the title
			o = t._S_(_title);
			if (_title.text != null && _title.text.length > 0) {
				o.x = x + _margin;
				o.alpha = 1;
				_title.visible = true;
				y += (th = _title.height + (vert?_spacing:0));
			} else {
				o.alpha = 0;
				o.visible = false;
			}
			
			// layout item container
			o = t._S_(_items);
			o.x = x;
			o.y = y;
			
			// layout items
			if (_discrete) {
				layoutDiscrete(t);
			} else {
				layoutContinuous(t);
			}
			
			w = b ? (vert ? b.width : Math.min(_iw, b.width)) : _iw;
			h = b ? (vert ? Math.min(_ih, b.height) : _ih) : _ih;
			
			// size the border
			o = t._S_(_border);
			o.x = x;
			o.y = b ? b.top : 0;
			o.w = w;
			o.h = h + th;
			if (t.immediate) _border.render();
			
			// create clipping panel
			t._S_(items).scrollRect = new Rectangle(0, 0, 1+w, 1+h);
		}
		
		/**
		 * @private
		 * Layout helper for positioning discrete legend items.
		 * @param t a transitioner for value updates
		 */
		public function layoutDiscrete(t:Transitioner):Void
		{
			var vert:Bool = Orientation.isVertical(_orient);
			var rev:Bool = _orient == Orientation.RIGHT_TO_LEFT ||
							  _orient == Orientation.BOTTOM_TO_TOP;
			var x:Int = 0, y:Int = 0, i:UInt, j:UInt;
			var item:LegendItem, o:Dynamic;
			var bw:Int = vert && bounds ? bounds.width : NaN;
			
			// if needed, compute shared width for legend items
			if (vert && isNaN(bw)) {
				bw = Number.MIN_VALUE;
				for (i in 0..._items.numChildren) {
					item = cast( _items.getChildAt(i), LegendItem);
					bw = Math.max(bw, item.innerWidth);
				}
			}
			
			_iw = _ih = 0;
			for (i in 0..._items.numChildren) {
				j = rev ? _items.numChildren-i-1 : i;
				// layout the item
				item = cast( _items.getChildAt(j), LegendItem);
				o = t._S_(item);
				o.x = x;
				o.y = y;
				o.w = isNaN(bw) ? item.innerWidth : bw;
				
				// increment spacing
				if (vert) {
					y += item.innerHeight + _spacing;
					_iw = Math.max(_iw, item.innerWidth);
				}
				else {
					x += item.innerWidth + _spacing;
					_ih = Math.max(_ih, item.innerHeight);
				}
			}
			_iw = vert ? _iw : x-_spacing;
			_ih = vert ? y-_spacing : _ih;
		}
		
		/**
		 * @private
		 * Layout helper for positioning a continous legend range.
		 * @param trans a transitioner for value updates
		 */
		public function layoutContinuous(t:Transitioner):Void
		{
			var lr:LegendRange = cast( _items.getChildAt(0), LegendRange);
			lr.orientation = _orient;
			if (Orientation.isHorizontal(_orient)) {
				_iw = lr.w = bounds ? bounds.width : 200;
				lr.updateLabels();
				_ih = lr.height + lr.margin;
			} else {
				_ih = lr.h = bounds ? bounds.height : 200;
				lr.updateLabels();
				_iw = lr.width;
			}
		}
		
		// -- Legend Items ----------------------------------------------------
		
		/** @private */
		public function updateItems() : Void
		{
			if (_items.numChildren == 0) {
				return;
			} else if (_discrete) {
				for (var i:UInt = 0; i<_items.numChildren; ++i)
					updateItem(cast( _items.getChildAt(i), LegendItem));
			} else {
				updateRange(cast( _items.getChildAt(0), LegendRange));
			}
		}
		
		/** @private */
		public function updateItem(item:LegendItem):Void
		{
			item.label.textMode = _labelTextMode;
			item.label.applyFormat(_labelTextFormat);
			item.margin = _margin;
		}
		
		/** @private */
		public function updateRange(range:LegendRange):Void
		{
			range.labelTextMode = _labelTextMode;
			range.labelTextFormat = _labelTextFormat;
			range.margin = _margin;
		}
		
		/**
		 * Sets property values on all legend items. The values
		 * within the <code>vals</code> argument can take a number of forms:
		 * <ul>
		 *  <li>If a value is a <code>Function</code>, it will be evaluated
		 *      for each element and the result will be used as the property
		 *      value for that element.</li>
		 *  <li>If a value is an <code>IEvaluable</code> instance, such as
		 *      <code>flare.util.Property</code> or
		 *      <code>flare.query.Expression</code>, it will be evaluated for
		 *      each element and the result will be used as the property value
		 *      for that element.</li>
		 *  <li>In all other cases, a property value will be treated as a
		 *      literal and assigned for all elements.</li>
		 * </ul>
		 * @param vals an object containing the properties and values to set.
		 * @param t a transitioner or time span for updating object values. If
		 *  the input is a transitioner, it will be used to store the updated
		 *  values. If the input is a number, a new Transitioner with duration
		 *  set to the input value will be used. The input is null by default,
		 *  in which case object values are updated immediately.
		 * @return the transitioner used to update the values
		 */
		public function setItemProperties(vals:Object, t:*=null):Transitioner
		{
			var trans:Transitioner ;
			Displays.setChildrenProperties(items, vals, trans);
			return trans;
		}
		
		// -- Static Constructors ---------------------------------------------
		
		/**
		 * Generates a legend from a given scale and one or more palettes.  If
		 * multiple palettes of the same type are provided, only the first of
		 * each type will be used for the legend, the others will be ignored.
		 * @param title the title text for the legend
		 * @param scale the scale instance determining the legend values
		 * @param palette a color, shape, or size palette for legend items
		 * @param args one or more additional palettes
		 * @return the generated Legend, or null if a legend could not be built
		 */
		public static function fromScale(title:String, scale:Scale,
			palette:Palette, ...args):Legend
		{
			if (scale == null || palette == null)
				return null;
				
			var colors:ColorPalette;
			var shapes:ShapePalette;
			var sizes:SizePalette;
			
			// construct palette collection
			var palettes:Array = args as Array;
			palettes.unshift(palette);
			for each (var p:Palette in palettes) {
				if (p is ColorPalette && !colors)
					colors = ColorPalette(p);
				else if (p is ShapePalette && !shapes)
					shapes = ShapePalette(p);
				else if (p is SizePalette && !sizes)
					sizes = SizePalette(p);
			