package flare.util;
	
	import flash.display.Graphics;
	
	/**
	 * Utility class defining shape types and shape drawing routines. All shape
	 * drawing functions take two arguments: a <code>Graphics</code> context
	 * to draw with and a size parameter determining the radius of the shape
	 * (i.e., the height and width of the shape are twice the size parameter).
	 * 
	 * <p>All shapes are indicated by a name. This class registers these names
	 * with drawing functions, allowing the lookup of shape rendering routines
	 * by the shapes name. For example, these shape names may be assigned using
	 * a <code>flare.vis.operator.encoder.ShapeEncoder</code> and then later
	 * rendered by looking up the shape with this class, as done by the
	 * <code>flare.vis.data.render.ShapeRenderer</code> class. The set of 
	 * available shapes can be extended by using the static
	 * <code>setShape</code> method to register a new shape name and
	 * drawing function.</p>
	 */
	class Shapes
	{
		/** Constant indicating a straight line shape. */
		inline public static var LINE:String = "line";
		/** Constant indicating a Bezier curve. */
		inline public static var BEZIER:String = "bezier";
		/** Constant indicating a cardinal spline. */
		inline public static var CARDINAL:String = "cardinal";
		/** Constant indicating a B-spline. */
		inline public static var BSPLINE:String = "bspline";
		
		/** Constant indicating a rectangular block shape. */
		inline public static var BLOCK:String = "block";
		/** Constant indicating a polygon shape. */
		inline public static var POLYGON:String = "polygon";
		/** Constant indicating a "polyblob" shape, a polygon whose
		 *  edges are interpolated with a cardinal spline. */
		inline public static var POLYBLOB:String = "polyblob";
		/** Constant indicating a vertical bar shape. */
		inline public static var VERTICAL_BAR:String = "verticalBar";
		/** Constant indicating a horizontal bar shape. */
		inline public static var HORIZONTAL_BAR:String = "horizontalBar";
		/** Constant indicating a wedge shape. */
		inline public static var WEDGE:String = "wedge";
		
		/** Constant indicating a circle shape. */
		inline public static var CIRCLE:String = "circle";
		/** Constant indicating a square shape. */
		inline public static var SQUARE:String = "square";
		/** Constant indicating a cross shape. */
		inline public static var CROSS:String = "cross";
		/** Constant indicating an 'X' shape. */
		inline public static var X:String = "x";
		/** Constant indicating a diamond shape. */
		inline public static var DIAMOND:String = "diamond";
		/** Constant indicating a upward-pointing triangle shape. */
		inline public static var TRIANGLE_UP:String = "triangleUp";
		/** Constant indicating a downward-pointing triangle shape. */
		inline public static var TRIANGLE_DOWN:String = "triangleDown";
		/** Constant indicating a rightward-pointing triangle shape. */
		inline public static var TRIANGLE_RIGHT:String = "triangleRight";
		/** Constant indicating a leftward-pointing triangle shape. */
		inline public static var TRIANGLE_LEFT:String = "triangleLeft";
		
		private static var _shapes:Dynamic = {
			circle: drawCircle,
			square: drawSquare,
			cross: drawCross,
			x: drawX,
			diamond: drawDiamond,
			triangleUp: drawTriangleUp,
			triangleDown: drawTriangleDown,
			triangleRight: drawTriangleRight,
			triangleLeft: drawTriangleLeft
		};
		
		/**
		 * Gets the shape drawing function with the given name. 
		 * @param name the name of the shape to draw
		 * @return a function for drawing the shape or null if the shape name
		 *  is not found. The returned function takes two parameters:
		 *  a graphics object and a numerical size value. The size value
		 *  indicates the radius of the shape.
		 */
		public static function getShape(name:String):Dynamic
		{
			return _shapes[name];
		}
		
		/**
		 * Sets the shape drawing function for a given shape name. 
		 * @param name the name of the shape to draw
		 * @param draw a function for drawing the shape. This function must
		 *  take two parameters: a graphics object and a numerical size value.
		 *  The size value indicates the radius of the shape.
		 */
		public static function setShape(name:String, draw:Dynamic):Void
		{
			_shapes[name] = draw;
		}
		
		/**
		 * Resets all shape drawing functions to the default settings. 
		 */
		public static function resetShapes():Void
		{
			_shapes = {
				circle: drawCircle,
				square: drawSquare,
				cross: drawCross,
				x: drawX,
				diamond: drawDiamond,
				triangleUp: drawTriangleUp,
				triangleDown: drawTriangleDown,
				triangleRight: drawTriangleRight,
				triangleLeft: drawTriangleLeft
			};
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Draws a circle shape.
		 * @param g the graphics context to draw with
		 * @param size the radius of the circle
		 */
		public static function drawCircle(g:Graphics, size:Number):Void
		{
			g.drawCircle(0, 0, size);
		}
		
		/**
		 * Draws a square shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the square. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawSquare(g:Graphics, size:Number):Void
		{
			g.drawRect(-size, -size, 2*size, 2*size);
		}
		
		/**
		 * Draws a cross shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the cross. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawCross(g:Graphics, size:Number):Void
		{
			g.moveTo(0, -size);
			g.lineTo(0, size);
			g.moveTo(-size, 0);
			g.lineTo(size, 0);
		}
		
		/**
		 * Draws an "x" shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the "x". The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawX(g:Graphics, size:Number):Void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, size);
			g.moveTo(size, -size);
			g.lineTo(-size, size);
		}
		
		/**
		 * Draws a diamond shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the diamond. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawDiamond(g:Graphics, size:Number):Void
		{
			g.moveTo(0, size);
			g.lineTo(-size, 0);
			g.lineTo(0, -size);
			g.lineTo(size, 0);
			g.lineTo(0, size);	
		}
		
		/**
		 * Draws an upward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleUp(g:Graphics, size:Number):Void
		{
			g.moveTo(-size, size);
			g.lineTo(size, size);
			g.lineTo(0, -size);
			g.lineTo(-size, size);
		}
		
		/**
		 * Draws a downward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleDown(g:Graphics, size:Number):Void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, -size);
			g.lineTo(0, size);
			g.lineTo(-size, -size);
		}
		
		/**
		 * Draws a right-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleRight(g:Graphics, size:Number):Void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, 0);
			g.lineTo(-size, size);
			g.lineTo(-size, -size);
		}
		
		/**
		 * Draws a left-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleLeft(g:Graphics, size:Number):Void
		{
			g.moveTo(size, -size);
			g.lineTo(-size, 0);
			g.lineTo(size, size);
			g.lineTo(size, -size);
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Draws an arc (a segment of a circle's circumference)
		 * @param g the graphics context to draw with
		 * @param x the center x-coordinate of the arc
		 * @param y the center y-coorindate of the arc
		 * @param radius the radius of the arc
		 * @param a0 the starting angle of the arc (in radians)
		 * @param a1 the ending angle of the arc (in radians)
		 */
		public static function drawArc(g:Graphics, x:Number, y:Number, 
									radius:Number, a0:Number, a1:Number) : Void
		{
			var slices:Int = (Math.abs(a1-a0) * radius) / 4;
			var a:Number, cx:Int = x, cy:Int = y;
			
			var i:UInt = 0;
			while (i <= slices) {
				a = a0 + i*(a1-a0)/slices;
				x = cx + radius * Math.cos(a);
				y = cy + -radius * Math.sin(a);
				if (i==0) {
					g.moveTo(x, y);
				} else {
					g.lineTo(x,y);
				}
				++i;
			}
		}
		
		/**
		 * Draws a wedge defined by an angular range and inner and outer radii.
		 * An inner radius of zero results in a pie-slice shape.
		 * @param g the graphics context to draw with
		 * @param x the center x-coordinate of the wedge
		 * @param y the center y-coorindate of the wedge
		 * @param outer the outer radius of the wedge
		 * @param inner the inner radius of the wedge
		 * @param a0 the starting angle of the wedge (in radians)
		 * @param a1 the ending angle of the wedge (in radians)
		 */
		public static function drawWedge(g:Graphics, x:Number, y:Number, 
			outer:Number, inner:Number, a0:Number, a1:Number) : Void
		{
			var a:Int = Math.abs(a1-a0);
			var slices:Int = Math.max(4, int(a * outer / 6));
			var cx:Int = x, cy:Int = y, x0:Number, y0:Number;
			var circle:Bool = (a >= 2*Math.PI - 0.001);

			if (slices <= 0) return;
		
			// pick starting point
			if (inner <= 0 && !circle) {
				g.moveTo(cx, cy);
			} else {
				x0 = cx + outer * Math.cos(a0);
				y0 = cy + -outer * Math.sin(a0);
				g.moveTo(x0, y0);
			}
			
			// draw outer arc
			var i:UInt = 0;
			while (i <= slices) {
				a = a0 + i*(a1-a0)/slices;
				x = cx + outer * Math.cos(a);
				y = cy + -outer * Math.sin(a);
				g.lineTo(x,y);
				++i;
			}

			if (circle) {
				// return to starting point
				g.lineTo(x0, y0);
			} else if (inner > 0) {
				// draw inner arc
				i = slices+1;
				while (--i >= 0) {
					a = a0 + i*(a1-a0)/slices;
					x = cx + inner * Math.cos(a);
					y = cy + -inner * Math.sin(a);
					g.lineTo(x,y);
					;
				}
				g.lineTo(x0, y0);
			} else {
				// return to center
				g.lineTo(cx, cy);
			}
		}
		
		/**
		 * Draws a polygon shape.
		 * @param g the graphics context to draw with
		 * @param a a flat array of x, y values defining the polygon
		 */
		public static function drawPolygon(g:Graphics, a:Array<Dynamic>) : Void
		{
			g.moveTo(a[0], a[1]);
			var i:UInt=2;
			while (i<a.length) {
				g.lineTo(a[i], a[i+1]);
				i+=2;
			}
			g.lineTo(a[0], a[1]);
		}
		
		/**
		 * Draws a cubic Bezier curve.
		 * @param g the graphics context to draw with
		 * @param ax x-coordinate of the starting point
		 * @param ay y-coordinate of the starting point
		 * @param bx x-coordinate of the first control point
		 * @param by y-coordinate of the first control point
		 * @param cx x-coordinate of the second control point
		 * @param cy y-coordinate of the second control point
		 * @param dx x-coordinate of the ending point
		 * @param dy y-coordinate of the ending point
		 * @param move if true (the default), the graphics context will be
		 *  moved to the starting point before drawing starts. If false,
		 *  no move command will be issued; this is useful when connecting
		 *  multiple curves to define a filled region.
		 */
		public static function drawCubic(g:Graphics, ax:Number, ay:Number,
			bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number,
			?move:Bool=true) : Void
		{			
			var subdiv:Int, u:Number, xx:Number, yy:Number;			
			
			// determine number of line segments
			subdiv = int((Math.sqrt((xx=(bx-ax))*xx + (yy=(by-ay))*yy) +
					      Math.sqrt((xx=(cx-bx))*xx + (yy=(cy-by))*yy) +
					      Math.sqrt((xx=(dx-cx))*xx + (yy=(dy-cy))*yy)) / 4);
			if (subdiv < 1) subdiv = 1;

			// compute Bezier co-efficients
			var c3x:Int = 3 * (bx - ax);
            var c2x:Int = 3 * (cx - bx) - c3x;
            var c1x:Int = dx - ax - c3x - c2x;
            var c3y:Int = 3 * (by - ay);
            var c2y:Int = 3 * (cy - by) - c3y;
            var c1y:Int = dy - ay - c3y - c2y;
			
			if (move) g.moveTo(ax, ay);
			var i:UInt=0;
			while (i<=subdiv) {
				u = i/subdiv;
				xx = u*(c3x + u*(c2x + u*c1x)) + ax;
				yy = u*(c3y + u*(c2y + u*c1y)) + ay;
				g.lineTo(xx, yy);
				++i;
			}
		}
		
		// -- BSpline rendering state variables --
		inline private static var _knot:Array<Dynamic>  = new Array(20);
		inline private static var _basis:Array<Dynamic> = new Array(36);

		/**
		 * Draws a cubic open uniform B-spline. The spline passes through the
		 * first and last control points, but not necessarily any others.
		 * @param g the graphics context to draw with
		 * @param p an array of points defining the spline control points
		 * @param slack a slack parameter determining the "tightness" of the
		 *  spline. At value 1 (the default) a normal b-spline will be drawn,
		 *  at value 0 a straight line between the first and last points will
		 *  be drawn. Intermediate values interpolate smoothly between these
		 *  two extremes.
		 * @param move if true (the default), the graphics context will be
		 *  moved to the starting point before drawing starts. If false,
		 *  no move command will be issued; this is useful when connecting
		 *  multiple curves to define a filled region.
		 */
		public static function drawBSpline(g:Graphics, p:Array<Dynamic>, ?npts:Int=-1,
			?move:Bool=true):Void
		{
			var N:Int = (npts < 0 ? p.length/2 : npts);
			var k:Int = N<4 ? 3 : 4, nplusk:Int = N+k;
			var i:Int, j:Int, s:Int, subdiv:Int = 40;
			var x:Number, y:Number, step:Number, u:Number;
			
			// if only two points, draw a line between them
			if (N==2) {
				if (move) g.moveTo(p[0],p[1]);
				g.lineTo(p[2],p[3]);
				return;
			}
			
			// initialize knot vector
			for (i in 1...nplusk) {
				_knot[i] = _knot[i-1] + (i>=k && i<=N ? 1 : 0);
			}
			
			// calculate the points on the bspline curve
			step = _knot[nplusk-1] / subdiv;
			s=0;
			while (s <= subdiv) {
				u = step * s;
				
				// calculate basis function -----
				for (i in 0...nplusk-1) { // first-order
					_basis[i] = (u >= _knot[i] && u < _knot[i+1] ? 1 : 0);
				}
				j=2; // higher-order
				while (j <= k) { // higher-order
					for (i in 0...nplusk-j) {
						x = (_basis[i  ]==0 ? 0 : ((u-_knot[i])*_basis[i]) / (_knot[i+j-1]-_knot[i]));
						y = (_basis[i+1]==0 ? 0 : ((_knot[i+j]-u)*_basis[i+1]) / (_knot[i+j]-_knot[i+1]));
						_basis[i] = x + y;
					}
					++j; // higher-order
				}
				if (u == _knot[nplusk-1]) _basis[N-1] = 1; // last point
				
				// interpolate b-spline point -----
				for (i in 0...N) {
					x += _basis[i] * p[j];
					y += _basis[i] * p[j+1];
				}
				if (s==0) {
					if (move) g.moveTo(x, y);
				} else {
					g.lineTo(x, y);
				}
				++s;
			}
		}
		
		/**
		 * Draws a cardinal spline composed of piecewise connected cubic
		 * Bezier curves. Curve control points are inferred so as to ensure
		 * C1 continuity (continuous derivative).
		 * @param g the graphics context to draw with
		 * @param p an array defining a polygon or polyline to render with a
		 *  cardinal spline
		 * @param s a tension parameter determining the spline's "tightness"
		 * @param closed indicates if the cardinal spline should be a closed
		 *  shape. False by default.
		 */
		public static function drawCardinal(g:Graphics, p:Array<Dynamic>, ?npts:Int=-1,
			?s:Float=0.15, ?closed:Bool=false) : Void
		{
			// compute the size of the path
	        var len:UInt = (npts < 0 ? p.length : 2*npts);
	        
	        if (len < 6)
	            throw new Error("Cardinal splines require at least 3 points");
	        
	        var dx1:Number, dy1:Number, dx2:Number, dy2:Number;
	        g.moveTo(p[0], p[1]);
	        
	        // compute first control points
	        if (closed) {
	            dx2 = p[2]-p[len-2];
	            dy2 = p[3]-p[len-1];
	        } else {
	            dx2 = p[4]-p[0]
	            dy2 = p[5]-p[1];
	        }

	        // iterate through control points
	        var i:UInt = 0;
	        i=2;
	           while (i<len-2) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[i+2] - p[i-2];
	            dy2 = p[i+3] - p[i-1];
	            
	            drawCubic(g, p[i-2],    p[i-1],
						     p[i-2]+s*dx1, p[i-1]+s*dy1,
	                         p[i]  -s*dx2, p[i+1]-s*dy2,
	                         p[i],         p[i+1], false);
	        	i+=2;
	           }
	        
	        // finish spline
	        if (closed) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[0] - p[i-2];
	            dy2 = p[1] - p[i-1];
	            drawCubic(g, p[i-2], p[i-1], p[i-2]+s*dx1, p[i-1]+s*dy1,
	            			 p[i]-s*dx2, p[i+1]-s*dy2, p[i], p[i+1], false);
	            
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[2] - p[len-2];
	            dy2 = p[3] - p[len-1];
	            drawCubic(g, p[len-2], p[len-1], p[len-2]+s*dx1, p[len-1]+s*dy1,
	            	p[0]-s*dx2, p[1]-s*dy2, p[0], p[1], false);
	        } else {
	        	drawCubic(g, p[i-2], p[i-1], p[i-2]+s*dx1, p[i-1]+s*dy1,
	        		p[i]-s*dx2, p[i+1]-s*dy2, p[i], p[i+1], false);
	        }
		}
		
		/**
		 * A helper function for consolidating end points and control points
		 * for a spline into a single array.
		 * @param x1 the x-coordinate for the first end point
		 * @param y1 the y-coordinate for the first end point
		 * @param controlPoints an array of control points
		 * @param x2 the x-coordinate for the second end point
		 * @param y2 the y-coordinate for the second end point
		 * @param p the array in which to store the consolidated points.
		 *  If null, a new array will be created and returned.
		 * @return the consolidated array of all points
		 */
		public static function consolidate(x1:Number, y1:Number,
			controlPoints:Array<Dynamic>, x2:Number, y2:Number, ?p:Array<Dynamic>=null):Array<Dynamic>
		{
			var len:Int = 4 + controlPoints.length;
			if (!p) {
				p = new Array(len);
			} else {
				while (p.length < len) p.push(0);
			}
			
			Arrays.copy(controlPoints, p, 0, 2);
			p[0] = x1;
			p[1] = y1;
			p[len-2] = x2;
			p[len-1] = y2;
			return p;
		}
		
	} // end of class Shapes
