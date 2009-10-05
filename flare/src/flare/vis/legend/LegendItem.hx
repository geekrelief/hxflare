package flare.vis.legend;

	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.util.Shapes;
	
	import flash.display.Graphics;
	import flash.display.Shape;

	/**
	 * An item in a discrete legend consisting of a label and
	 * an icon indicating color, shape, and/or size.
	 */
	class LegendItem extends RectSprite
	{
		public var icon(getIcon, null) : Shape ;
		public var iconLineWidth(getIconLineWidth, setIconLineWidth) : Number;
		public var iconSize(getIconSize, setIconSize) : Number;
		public var innerHeight(getInnerHeight, null) : Number ;
		public var innerWidth(getInnerWidth, null) : Number ;
		public var label(getLabel, null) : TextSprite ;
		public var margin(getMargin, setMargin) : Number;
		public var maxIconSize(getMaxIconSize, setMaxIconSize) : Number;
		public var selected(getSelected, setSelected) : Bool;
		public var text(getText, setText) : String;
		public var value(getValue, setValue) : Dynamic;
		private var _value:Dynamic;
		
		private var _icon:Shape;
		private var _iconLineWidth:Int ;
		private var _label:TextSprite;
		
		private var _iconSize:Int ;
		private var _maxIconSize:Int ;
		private var _margin:Int ;
		
		private var _shape:String;
		private var _color:UInt;
		
		private var _selected:Bool ;
		
		// -- Properties ------------------------------------------------------
		
		/** The data value represented by this legend item. */
		public function getValue():Dynamic { return _value; }
		public function setValue(v:Dynamic):Dynamic { _value = v; 	return v;}
		
		/** Shape presenting this legend item's icon. */
		public function getIcon():Shape { return _icon; }
		/** TextSprite presenting this legend item's label. */
		public function getLabel():TextSprite { return _label; }
		
		/** The label text. */
		public function getText():String { return _label.text; }
		public function setText(t:String):String {
			if (t != _label.text) { _label.text = t; dirty(); }
			return t;
		}
		
		/** Line width to use within the icon. */
		public function getIconLineWidth():Number { return _iconLineWidth; }
		public function setIconLineWidth(s:Number):Number {
			if (s != _iconLineWidth) { _iconLineWidth = s; dirty(); }
			return s;
		}
		
		/** Size parameter for icon drawing. */
		public function getIconSize():Number { return _iconSize; }
		public function setIconSize(s:Number):Number {
			if (s != _iconSize) { _iconSize = s; dirty(); }
			return s;
		}
		
		/** Maximum size parameter for icon drawing. */
		public function getMaxIconSize():Number { return _maxIconSize; }
		public function setMaxIconSize(s:Number):Number {
			if (s != _maxIconSize) { _maxIconSize = s; dirty(); }
			return s;
		}
		
		/** Margin value for padding within the legend item. */
		public function getMargin():Number { return _margin; }
		public function setMargin(m:Number):Number {
			if (m != _margin) { _margin = m; dirty(); }
			return m;
		}
		
		/** The inner width of this legend item. */
		public function getInnerWidth():Number {
			return 2*_margin + _maxIconSize + 
				(_label.text.length>0 ? _margin + _label.width : 0);
		}
		/** The inner height of this legend item. */
		public function getInnerHeight():Number {
			return Math.max(2*_margin + _maxIconSize, _label.height);
		}
		
		/** Flag indicating if this legend item has been selected. */
		public function getSelected():Bool { return _selected; }
		public function setSelected(b:Bool):Bool { _selected = b; 	return b;}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new LegendItem.
		 * @param text the label text
		 * @param color the color of the label icon
		 * @param shape a shape drawing function for the label icon
		 * @param iconSize a size parameter for drawing the label icon
		 */
		public function new(?text:String=null, ?color:UInt=0xff888888,
								   ?shape:String=null, ?iconSize:Int=NaN)
		{
			
			_iconLineWidth = 2;
			_iconSize = 12;
			_maxIconSize = 12;
			_margin = 5;
			_selected = false;
			addChild(_icon = new Shape());
			addChild(_label = new TextSprite(text));
			
			// init background
			super(0,0,0, 2*_margin + _iconSize, 13, 13);
			lineColor = 0;
			fillColor = 0;
			
			// init label
			_label.horizontalAnchor = TextSprite.LEFT;
			_label.verticalAnchor = TextSprite.MIDDLE;
			_label.mouseEnabled = false;
			
			// init icon
			_color = color;
			_shape = shape;
			if (!isNaN(iconSize)) _iconSize = iconSize;
		}
		
		/** @inheritDoc */
		public override function render():Void
		{			
			// layout label
			_label.x = 2*_margin + _maxIconSize;
			_label.y = innerHeight / 2;
			// TODO compute text abbrev as needed?
			
			// layout icon
			_icon.x = _margin + _maxIconSize/2;
			_icon.y = innerHeight / 2;
			if (_label.textMode != TextSprite.EMBED) _icon.y -= 1;
			
			// render icon
			var draw:Dynamic = _shape ? Shapes.getShape(_shape) : null;
			var g:Graphics = _icon.graphics;
			g.clear();
			if (draw != null) {
				g.lineStyle(_iconLineWidth, _color, 1);
				draw(g, _iconSize/2);
			} else {
				g.beginFill(_color);
				Shapes.drawCircle(g, _iconSize/2);
				g.endFill();
			}
			
			_h = innerHeight;
			super.render();
		}
		
	} // end of class LegendItem
