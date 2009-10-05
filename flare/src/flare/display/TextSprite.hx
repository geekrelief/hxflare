package flare.display;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * A Sprite representing a text label.
	 * TextSprites support multiple forms of text representation: bitmapped
	 * text, embedded font text, and standard (device font) text. This allows
	 * flexibility in how text labels are handled. For example, by default,
	 * text fields using device fonts do not support alpha blending or
	 * rotation. By using a TextSprite in BITMAP mode, the text is rendered
	 * out to a bitmap which can then be alpha blended.
	 */
	class TextSprite extends DirtySprite
	{
		public var bold(getBold, setBold) : Bool;
		public var color(getColor, setColor) : UInt;
		public var font(getFont, setFont) : String;
		public var horizontalAnchor(getHorizontalAnchor, setHorizontalAnchor) : Int;
		public var htmlText(getHtmlText, setHtmlText) : String;
		public var italic(getItalic, setItalic) : Bool;
		public var kerning(getKerning, setKerning) : Bool;
		public var letterSpacing(getLetterSpacing, setLetterSpacing) : Int;
		public var size(getSize, setSize) : Number;
		public var text(getText, setText) : String;
		public var textField(getTextField, null) : TextField ;
		public var textFormat(null, setTextFormat) : TextFormat;
		public var textMode(getTextMode, setTextMode) : Int;
		public var underline(getUnderline, setUnderline) : Bool;
		public var verticalAnchor(getVerticalAnchor, setVerticalAnchor) : Int;
		// vertical anchors
		/**
		 * Constant for vertically aligning the top of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var TOP:Int = 0;
		/**
		 * Constant for vertically aligning the middle of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var MIDDLE:Int = 1;
		/**
		 * Constant for vertically aligning the bottom of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var BOTTOM:Int = 2;

		// horizontal anchors
		/**
		 * Constant for horizontally aligning the left of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var LEFT:Int = 0;
		/**
		 * Constant for horizontally aligning the center of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var CENTER:Int = 1;
		/**
		 * Constant for horizontally aligning the right of the text field
		 * to a TextSprite's y-coordinate.
		 */
		inline public static var RIGHT:Int = 2;
		
		// text handling modes
		/**
		 * Constant indicating that text should be rendered using a TextField
		 * instance using device fonts.
		 */
		inline public static var DEVICE:UInt = 0;
		/**
		 * Constant indicating that text should be rendered using a TextField
		 * instance using embedded fonts. For this mode to work, the fonts
		 * used must be embedded in your application SWF file.
		 */
		inline public static var EMBED:UInt = 1;
		/**
		 * Constant indicating that text should be rendered into a Bitmap
		 * instance.
		 */
		inline public static var BITMAP:UInt = 2;
		
		private var _mode:Int ;
		private var _bmap:Bitmap;
		private var _tf:TextField;
		private var _fmt:TextFormat;
		private var _locked:Bool ;
		private var _maskColor:UInt ;
		
		private var _hAnchor:Int ;
		private var _vAnchor:Int ;
		
		/**
		 * The TextField instance backing this TextSprite.
		 */
		public function getTextField():TextField { return _tf; }
		
		/**
		 * The text rendering mode for this TextSprite, one of BITMAP,
		 * DEVICE, or EMBED.
		 */
		public function getTextMode():Int { return _mode; }
		public function setTextMode(mode:Int):Int {
			setMode(mode);
			return mode;
		}
		
		/** Sets the text format. */
		public function setTextFormat(fmt:TextFormat):TextFormat {
			_tf.defaultTextFormat = (_fmt = fmt);
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return fmt;
		}
		
		/**
		 * The text shown by this TextSprite.
		 */
		public function getText():String { return _tf.text; }
		public function setText(txt:String):String {
			if (_tf.text != txt) {
				_tf.text = (txt==null ? "" : txt);
				if (_fmt!=null) _tf.setTextFormat(_fmt);
				dirty();
			}
			return txt;
		}
		
		/**
		 * The html text shown by this TextSprite.
		 */
		public function getHtmlText():String { return _tf.htmlText; }
		public function setHtmlText(txt:String):String {
			if (_tf.htmlText != txt) {
				_tf.htmlText = (txt==null ? "" : txt);
				dirty();
			}
			return txt;
		}
		
		/**
		 * The font to the text.
		 */
		public function getFont():String { return String(_fmt.font); }
		public function setFont(f:String):String {
			_fmt.font = f;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return f;
		}
		
		/**
		 * The color of the text.
		 */
		public function getColor():UInt { return uint(_fmt.color); }
		public function setColor(c:UInt):UInt {
			_fmt.color = c;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return c;
		}
		
		/**
		 * The size of the text.
		 */
		public function getSize():Number { return Number(_fmt.size); }
		public function setSize(s:Number):Number {
			_fmt.size = s;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return s;
		}
		
		/**
		 * The boldness of the text.
		 */
		public function getBold():Bool { return Boolean(_fmt.bold); }
		public function setBold(b:Bool):Bool {
			_fmt.bold = b;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return b;
		}
		
		/**
		 * The italics of the text.
		 */
		public function getItalic():Bool { return Boolean(_fmt.italic); }
		public function setItalic(b:Bool):Bool {
			_fmt.italic = b;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return b;
		}
		
		/**
		 * The underline of the text.
		 */
		public function getUnderline():Bool { return Boolean(_fmt.underline); }
		public function setUnderline(b:Bool):Bool {
			_fmt.underline = b;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return b;
		}
		
		/**
		 * The kerning of the text.
		 */
		public function getKerning():Bool { return Boolean(_fmt.kerning); }
		public function setKerning(b:Bool):Bool {
			_fmt.kerning = b;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return b;
		}
		
		/**
		 * The letter-spacing of the text.
		 */
		public function getLetterSpacing():Int { return int(_fmt.letterSpacing); }
		public function setLetterSpacing(s:Int):Int {
			_fmt.letterSpacing = s;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
			return s;
		}
		
		/**
		 * The horizontal anchor for the text, one of LEFT, RIGHT, or CENTER.
		 * This setting determines how the text is horizontally aligned with
		 * respect to this TextSprite's (x,y) location.
		 */
		public function getHorizontalAnchor():Int { return _hAnchor; }
		public function setHorizontalAnchor(a:Int):Int { 
			if (_hAnchor != a) { _hAnchor = a; layout(); }
			return a; 
		}
		
		/**
		 * The vertical anchor for the text, one of TOP, BOTTOM, or MIDDLE.
		 * This setting determines how the text is vertically aligned with
		 * respect to this TextSprite's (x,y) location.
		 */
		public function getVerticalAnchor():Int { return _vAnchor; }
		public function setVerticalAnchor(a:Int):Int {
			if (_vAnchor != a) { _vAnchor = a; layout(); }
			return a;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new TextSprite instance.
		 * @param text the text string for this label
		 * @param format the TextFormat determining font family, size, and style
		 * @param mode the text rendering mode to use (BITMAP by default)
		 */
		public function new(?text:String=null, ?format:TextFormat=null, ?mode:Int=BITMAP) {
			
			_mode = -1;
			_locked = false;
			_maskColor = 0xFFFFFF;
			_hAnchor = LEFT;
			_vAnchor = TOP;
			_tf = new TextField();
			_tf.selectable = false; // not selectable by default
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.defaultTextFormat = (_fmt = format ? format : new TextFormat());
			if (text != null) _tf.text = text;
			_bmap = new Bitmap();
			setMode(mode);
			dirty();
		}
		
		public function setMode(mode:Int):Void
		{
			if (mode == _mode) return; // nothing to do
			
			switch (_mode) {
				case BITMAP:
					_bmap.bitmapData = null;
					removeChild(_bmap);
					break;
				case EMBED:
					_tf.embedFonts = false;
				case DEVICE:
					removeChild(_tf);
					break;
			}
			switch (mode) {
				case BITMAP:
					rasterize();
					addChild(_bmap);
					break;
				case EMBED:
					_tf.embedFonts = true;
				case DEVICE:
					addChild(_tf);
					break;
			}
			_mode = mode;
		}
		
		/**
		 * Applies the settings of the input text format to this sprite's
		 * internal text format. This method makes a shallow copy of the
		 * input format, it does not save a reference to it.
		 * @param fmt the text format to apply
		 */
		public function applyFormat(fmt:TextFormat):Void {
			_fmt.align = fmt.align;
			_fmt.blockIndent = fmt.blockIndent;
			_fmt.bold = fmt.bold;
			_fmt.bullet = fmt.bullet;
			_fmt.color = fmt.color;
			_fmt.display = fmt.display;
			_fmt.font = fmt.font;
			_fmt.indent = fmt.indent;
			_fmt.italic = fmt.italic;
			_fmt.kerning = fmt.kerning;
			_fmt.leading = fmt.leading;
			_fmt.leftMargin = fmt.leftMargin;
			_fmt.letterSpacing = fmt.letterSpacing;
			_fmt.rightMargin = fmt.rightMargin;
			_fmt.size = fmt.size;
			_fmt.tabStops = fmt.tabStops;
			_fmt.target = fmt.target;
			_fmt.underline = fmt.underline;
			_fmt.url = fmt.url;
			_tf.setTextFormat(_fmt);
			if (_mode==BITMAP) dirty();
		}
		
		/** @inheritDoc */
		public override function render():Void
		{
			if (_mode == BITMAP) {
				rasterize();
			}
			layout();
		}
		
		/** @private */
		public function layout():Void
		{
			var d:DisplayObject = (_mode==BITMAP ? _bmap : _tf);
			
			// horizontal anchor
			switch (_hAnchor) {
				case LEFT:   d.x = 0; break;
				case CENTER: d.x = -d.width / 2; break;
				case RIGHT:  d.x = -d.width; break;
			}
			// vertical anchor
			switch (_vAnchor) {
				case TOP:    d.y = 0; break;
				case MIDDLE: d.y = -d.height / 2; break;
				case BOTTOM: d.y = -d.height; break;
			}
		}
		
		/** @private */
		public function rasterize():Void
		{
			if (_locked) return;
			var tw:Int = _tf.width + 1;
			var th:Int = _tf.height + 1;
			var bd:BitmapData = _bmap.bitmapData;
			if (bd == null || bd.width != tw || bd.height != th) {
				bd = new BitmapData(tw, th, true, 0x00ffffff);
				_bmap.bitmapData = bd;
			} else {
				bd.fillRect(new Rectangle(0,0,tw,th), 0x00ffffff);
			}
			bd.draw(_tf);
		}
		
		/**
		 * Locks this TextSprite, such that no re-rendering of the text is
		 * performed until the <code>unlock</code> method is called. This
		 * method can be used if a number of sequential updates are to be made.
		 */
		public function lock():Void
		{
			_locked = true;
		}
		
		/**
		 * Unlocks this TextSprite, allowing re-rendering to resume if the
		 * sprite has been locked using the <code>lock</code> method.
		 */
		public function unlock():Void
		{
			if (_locked) {
				_locked = false;
				if (_mode == BITMAP) rasterize();
			}
		}
		
	} // end of class TextSprite
