package flare.display;

	/**
	 * A Sprite representing a line. Supports position, color, and width
	 * properties.
	 */
	class LineSprite extends DirtySprite
	{
		public var lineColor(getLineColor, setLineColor) : UInt;
		public var lineWidth(getLineWidth, setLineWidth) : Number;
		public var x1(getX1, setX1) : Number;
		public var x2(getX2, setX2) : Number;
		public var y1(getY1, setY1) : Number;
		public var y2(getY2, setY2) : Number;
		private var _color:UInt ;
		private var _width:Int ;
		private var _x1:Number;
		private var _y1:Number;
		private var _x2:Number;
		private var _y2:Number;
		
		/** The x-coordinate for the first line endpoint. */
		public function getX1():Number  { return _x1; }
		public function setX1(x:Number):Number { _x1 = x; dirty(); 	return x;}
		
		/** The y-coordinate for the first line endpoint. */
		public function getY1():Number  { return _y1; }
		public function setY1(y:Number):Number { _y1 = y; dirty(); 	return y;}
		
		/** The x-coordinate for the second line endpoint. */
		public function getX2():Number  { return _x2; }
		public function setX2(x:Number):Number { _x2 = x; dirty(); 	return x;}

		/** The y-coordinate for the second line endpoint. */		
		public function getY2():Number  { return _y2; }
		public function setY2(y:Number):Number { _y2 = y; dirty(); 	return y;}
		
		/** The color of the line. */
		public function getLineColor():UInt  { return _color; }
		public function setLineColor(c:UInt):UInt { _color = c; dirty(); 	return c;}
		
		/** The width of the line. A value of zero indicates a hairwidth line,
		 *  as determined by <code>Graphics.lineStyle</code> */
		public function getLineWidth():Number  { return _width; }
		public function setLineWidth(w:Number):Number { _width = w; dirty(); 	return w;}
		
		public override function render():Void
		{
			graphics.clear();
			graphics.lineStyle(_width, _color, 1, true, "none");
			graphics.moveTo(_x1, _y1);
			graphics.lineTo(_x2, _y2);
		}
		
	} // end of class LineSprite
