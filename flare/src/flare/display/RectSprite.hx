package flare.display;

	import flare.util.Colors;
	
	/**
	 * A Sprite representing a rectangle shape. Supports line and fill colors
	 * and rounded corners.
	 */
	class RectSprite extends DirtySprite
	{
		public var cornerHeight(getCornerHeight, setCornerHeight) : Number;
		public var cornerSize(null, setCornerSize) : Number;
		public var cornerWidth(getCornerWidth, setCornerWidth) : Number;
		public var fillColor(getFillColor, setFillColor) : UInt;
		public var h(getH, setH) : Number;
		public var lineColor(getLineColor, setLineColor) : UInt;
		public var linePixelHinting(getLinePixelHinting, setLinePixelHinting) : Bool;
		public var lineWidth(getLineWidth, setLineWidth) : Number;
		public var w(getW, setW) : Number;
		/** @private */
		public var _w:Number;
		/** @private */
		public var _h:Number;
		/** @private */
		public var _cw:Int ;
		/** @private */
		public var _ch:Int ;
		/** @private */
		public var _fillColor:UInt ;
		/** @private */
		public var _lineColor:UInt ;
		/** @private */
		public var _lineWidth:Int ;
		/** @private */
		public var _pixelHinting:Bool ;
		
		/** The width of the rectangle. */
		public function getW():Number { return _w; }
		public function setW(v:Number):Number { _w = v; dirty(); 	return v;}
		
		/** The height of the rectangle. */
		public function getH():Number { return _h; }
		public function setH(v:Number):Number { _h = v; dirty(); 	return v;}
		
		/** The width of rounded corners. Zero indicates no rounding. */
		public function getCornerWidth():Number { return _cw; }
		public function setCornerWidth(v:Number):Number { _cw = v; dirty(); 	return v;}
		
		/** The height of rounded corners. Zero indicates no rounding. */
		public function getCornerHeight():Number { return _ch; }
		public function setCornerHeight(v:Number):Number { _ch = v; dirty(); 	return v;}
		
		/** Sets corner width and height simultaneously. */
		public function setCornerSize(v:Number):Number { _cw = _ch = v; dirty(); 	return v;}
		
		/** The fill color of the rectangle. */
		public function getFillColor():UInt { return _fillColor; }
		public function setFillColor(c:UInt):UInt { _fillColor = c; dirty(); 	return c;}
		
		/** The line color of the rectangle outline. */
		public function getLineColor():UInt { return _lineColor; }
		public function setLineColor(c:UInt):UInt { _lineColor = c; dirty(); 	return c;}
		
		/** The line width of the rectangle outline. */
		public function getLineWidth():Number { return _lineWidth; }
		public function setLineWidth(v:Number):Number { _lineWidth = v; dirty(); 	return v;}
		
		/** Flag indicating if pixel hinting should be used for the outline. */
		public function getLinePixelHinting():Bool { return _pixelHinting; }
		public function setLinePixelHinting(b:Bool):Bool {
			_pixelHinting = b; dirty();
			return b;
		}
				
		/**
		 * Creates a new RectSprite.
		 * @param x the x-coordinate of the top-left corner of the rectangle
		 * @param y the y-coordinate of the top-left corder of the rectangle
		 * @param w the width of the rectangle
		 * @param h the height of the rectangle
		 * @param cw the width of rounded corners (zero for no rounding)
		 * @param ch the height of rounded corners (zero for no rounding)
		 */
		public function new(?x:Int=0, ?y:Int=0, ?w:Int=0,
			?h:Int=0, ?cw:Int=0, ?ch:Int=0)
		{
			
			_cw = 0;
			_ch = 0;
			_fillColor = 0x00ffffff;
			_lineColor = 0xffaaaaaa;
			_lineWidth = 0;
			_pixelHinting = true;
			this.x = x;
			this.y = y;
			this._w = w;
			this._h = h;
			this._cw = cw;
			this._ch = ch;
		}
		
		/** @inheritDoc */
		public override function render():Void
		{
			graphics.clear();
			if (isNaN(_w) || isNaN(_h)) return;
			
			var la:Int = Colors.a(_lineColor) / 255;
			var fa:Int = Colors.a(_fillColor) / 255;
			var lc:UInt = _lineColor & 0x00ffffff;
			var fc:UInt = _fillColor & 0x00ffffff;

			if (la>0) graphics.lineStyle(_lineWidth, lc, la, _pixelHinting);
			graphics.beginFill(fc, fa);
			if (_cw > 0 || _ch > 0) {
				graphics.drawRoundRect(0, 0, _w, _h, _cw, _ch);
			} else {
				graphics.drawRect(0, 0, _w, _h);
			}
			graphics.endFill();
		}
		
	} // end of class RectSprite
