package flare.util;

	import flash.utils.ByteArray;
	
	/**
	 * Utility methods for working with String instances. The
	 * <code>format</code> method provides a powerful mechanism for formatting
	 * and templating strings.
	 */
	class Strings
	{	
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function new() {
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Creates a new string by repeating an input string.
		 * @param s the string to repeat
		 * @param reps the number of times to repeat the string
		 * @return a new String containing the repeated input
		 */
		public static function repeat(s:String, reps:Int):String
		{
			if (reps == 1) return s;
			
			var b:ByteArray = new ByteArray();
			for (var i:UInt=0; i<reps; ++i)
				b.writeUTFBytes(s);
			b.position = 0;
			return b.readUTFBytes(b.length);
		}
		
		/**
		 * Aligns a string by inserting padding space characters as needed.
		 * @param s the string to align
		 * @param align an integer indicating both the desired length of
		 *  the string (the absolute value of the input) and the alignment
		 *  style (negative for left alignment, positive for right alignment)
		 * @return the aligned string, padded or truncated as necessary
		 */
		public static function align(s:String, align:Int):String
		{
			var left:Bool = align < 0;
			var len:Int = left?-align:align, slen:Int = s.length;
			if (slen > len) {
				return left ? s.substr(0,len) : s.substr(slen-len, len);
			} else {
				var pad:String = repeat(' ',len-slen);
				return left ? s + pad : pad + s;
			}
		}
		
		/**
		 * Pads a number with a specified number of "0" digits on
		 * the left-hand-side of the number.
		 * @param x an input number
		 * @param digits the number of "0" digits to pad by
		 * @return a padded string representation of the input number
		 */
		public static function pad(x:Number, digits:Int):String
		{
			var neg:Bool = (x < 0);
			x = Math.abs(x);
			var e:Int = 1 + int(Math.log(x) / Math.LN10);
			var s:String = String(x);
			;while (e<digits) { s = '0' + s; 	e++;}
			return neg ? "-"+s : s;
		}
		
		/**
		 * Pads a string with zeroes up to given length.
		 * @param s the string to pad
		 * @param n the target length of the padded string
		 * @return the padded string. If the input string is already equal or
		 *  longer than n characters it is returned unaltered. Otherwise, it
		 *  is left-padded with zeroes up to form an n-character string.
		 */
		public static function padString(s:String, n:Int):String
		{
			return (s.length < n ? repeat("0",n-s.length) + s : s);
		}
		
		// --------------------------------------------------------------------

		/** Default formatting string for numbers. */
		inline public static var DEFAULT_NUMBER:String = "0.########";

		inline private static var _BACKSLASH:Int = '\\'.charCodeAt(0);
		inline private static var _LBRACE:Int = '{'.charCodeAt(0);
		inline private static var _RBRACE:Int = '}'.charCodeAt(0);
		inline private static var _QUOTE:Int = '"'.charCodeAt(0);
		inline private static var _APOSTROPHE:Int = '\''.charCodeAt(0);
	
		/**
		 * Outputs a formatted string using a set of input arguments and string
		 * formatting directives. This method uses the String formatting
		 * conventions of the .NET framework, providing a very flexible system
		 * for mapping input values into various string representations. For
		 * examples and reference documentation for string formatting options,
		 * see
		 * <a href="http://blog.stevex.net/index.php/string-formatting-in-csharp/">
		 * this example page</a> or
		 * <a href="http://msdn2.microsoft.com/en-us/library/fbxft59x.aspx">
		 * Microsoft's documentation</a>.
		 * @param fmt a formatting string. Format strings include markup
		 *  indicating where input arguments should be placed in the string,
		 *  along with optional formatting directives. For example,
		 *  <code>{1}, {0}</code> writes out the second value argument, a
		 *  comma, and then the first value argument.
		 * @param args value arguments to be placed within the formatting
		 *  string.
		 * @return the formatted string.
		 */
		public static function format(fmt:String, args:Array<Dynamic>):String
		{
			var b:ByteArray = new ByteArray(), a:Array<Dynamic>;
			var esc:Bool = false;
			var c:Number, idx:Int, ialign:Int;
			var idx0:Int, idx1:Int, idx2:Int;
			var s:String, si:String, sa:String, sf:String;
			
			for (i in 0...fmt.length) {
				c = fmt.charCodeAt(i);
				if (c == _BACKSLASH) {
					// note escape char
					if (esc) b.writeUTFBytes('\\');
					esc = true;
				}
				else if (c == _LBRACE) {
					// process pattern
					if (esc) {
						b.writeUTFBytes('{');
						esc = false;
					} else {
						// get pattern boundary
						idx = fmt.indexOf("}", i);
						if (idx < 0)
							throw new ArgumentError("Invalid format string.");
						
						// extract pattern
						s = fmt.substring(i+1, idx);
						
						idx2 = s.indexOf(":");
						idx1 = s.indexOf(",");
						idx0 = Math.min(idx1<0 ? int.MAX_VALUE : idx1,
										idx2<0 ? int.MAX_VALUE : idx2);
						
						si = idx0==int.MAX_VALUE ? s : s.substring(0,idx0);
						sa = idx1<0 || idx1 > idx2 ? null : s.substring(idx1+1, idx2<0?s.length:idx2);
						sf = idx2<0 ? null : s.substring(idx2+1);
						
						try {
							if (sa != null) { ialign = int(sa); }
							pattern(b, sf, args[uint(si)]);
						} catch (x:*) {
							throw new ArgumentError("Invalid format string.");
						}
						i = idx;
					}
				} else {
					// by default, copy value to buffer
					b.writeUTFBytes(fmt.charAt(i));
				}
			}
			
			b.position = 0;
			s = b.readUTFBytes(b.length);
			
			// finally adjust string alignment as needed
			return (sa != null ? align(s, ialign) : s);
		}
			
		private static function pattern(b:ByteArray, pat:String, value:Dynamic):Void
		{
			if (pat == null) {
				b.writeUTFBytes(String(value));
			} else if (Std.is( value, Date)) {
				datePattern(b, pat, cast( value, Date));
			} else if (Std.is( value, Number)) {
				numberPattern(b, pat, Number(value));
			} else {
				b.writeUTFBytes(String(value));
			}
		}
		
		private static function count(s:String, c:Number, i:Int):Int
		{
			var n:Int = 0;
			for (n=0; i<s.length && s.charCodeAt(i)==c; ++i, ++n);
			return n;
		}

		// -- Date Formatting -------------------------------------------------

		/** Array of full names for days of the week. */
		inline public static var DAY_NAMES:Array<Dynamic> =
			["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
			 "Friday", "Saturday"];
		/** Array of abbreviated names for days of the week. */
		inline public static var DAY_ABBREVS:Array<Dynamic> =
			["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		/** Array of full names for months of the year. */
		inline public static var MONTH_NAMES:Array<Dynamic> =
			["January", "February", "March", "April", "May", "June",
			 "July", "August", "September", "October", "November", "December"];
		/** Array of abbreviated names for months of the year. */
		inline public static var MONTH_ABBREVS:Array<Dynamic> = 
			["Jan", "Feb", "Mar", "Apr", "May", "Jun",
			 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		/** Abbreviated string indicating "PM" time. */
		inline public static var PM1:String = "P";
		/** Full string indicating "PM" time. */
		inline public static var PM2:String = "PM";
		/** Abbreviated string indicating "AM" time. */
		inline public static var AM1:String = "A";
		/** Full string indicating "AM" time. */
		inline public static var AM2:String = "AM";
		/** String indicating "AD" time. */
		inline public static var AD:String = "AD";
		/** String indicating "BC" time. */
		inline public static var BC:String = "BC";		

		inline private static var _DATE:Int = 'd'.charCodeAt(0);
		inline private static var _FRAC:Int = 'f'.charCodeAt(0);
		inline private static var _FRAZ:Int = 'F'.charCodeAt(0);
		inline private static var _ERA:Int = 'g'.charCodeAt(0);
		inline private static var _HOUR:Int = 'h'.charCodeAt(0);
		inline private static var _HR24:Int = 'H'.charCodeAt(0);
		inline private static var _MINS:Int = 'm'.charCodeAt(0);
		inline private static var _MOS:Int = 'M'.charCodeAt(0);
		inline private static var _SECS:Int = 's'.charCodeAt(0);
		inline private static var _AMPM:Int = 't'.charCodeAt(0);
		inline private static var _YEAR:Int = 'y'.charCodeAt(0);
		inline private static var _ZONE:Int = 'z'.charCodeAt(0);

		/**
		 * Hashtable of standard formatting flags and their formatting patterns
		 */
		inline private static var _STD_DATE:Dynamic = {
			d: "MM/dd/yyyy",
			D: "dddd, dd MMMM yyyy",
			f: "dddd, dd MMMM yyyy HH:mm",
			F: "dddd, dd MMMM yyyy HH:mm:ss",
			g: "MM/dd/yyyy HH:mm",
			G: "MM/dd/yyyy HH:mm:ss",
			M: "MMMM dd",
			m: "MMMM dd",
			R: "ddd, dd MMM yyyy HH':'mm':'ss 'GMT'",
			r: "ddd, dd MMM yyyy HH':'mm':'ss 'GMT'",
			s: "yyyy-MM-ddTHH:mm:ss",
			t: "HH:mm",
			T: "HH:mm:ss",
			u: "yyyy-MM-dd HH:mm:ssZ",
			U: "yyyy-MM-dd HH:mm:ssZ", // must convert to UTC!
			Y: "yyyy MMMM",
			y: "yyyy MMMM"
		};

		private static function datePattern(b:ByteArray, p:String, d:Date):Void
		{
			var a:Int, i:Int, j:Int, n:Int, c:Number, s:String;
			
			// check for standard format flag, retrieve pattern if needed
			if (p.length == 1) {
				if (p == "U") d = Dates.toUTC(d);
				p = _STD_DATE[p];
				if (p == null) throw new ArgumentError("Invalid date format: "+p);
			}
			
			// process custom formatting pattern
			i=0;
			while (i<p.length) {
				c = p.charCodeAt(i);
				for (n=0,j=i; j<p.length && p.charCodeAt(j)==c; ++j, ++n);
				
				if (c == _DATE) {
					if (n >= 4) {
						b.writeUTFBytes(DAY_NAMES[d.day]);
					} else if (n == 3) {
						b.writeUTFBytes(DAY_ABBREVS[d.day]);
					} else if (n == 2) {
						b.writeUTFBytes(pad(d.date, 2));
					} else {
						b.writeUTFBytes(String(d.date));
					}
				}
				else if (c == _ERA) {
					b.writeUTFBytes(d.fullYear<0 ? BC : AD);
				}
				else if (c == _FRAC) {
					a = int(Math.round(Math.pow(10,n) * (d.time/1000 % 1)));
					b.writeUTFBytes(String(a));
				}
				else if (c == _FRAZ) {
					a = int(Math.round(Math.pow(10,n) * (d.time/1000 % 1)));
					s = String(a);
					for (a=s.length; s.charCodeAt(a-1)==_ZERO; --a);
					b.writeUTFBytes(s.substring(0,a));
				}
				else if (c == _HOUR) {
					a = (a=(int(d.hours)%12)) == 0 ? 12 : a;
					b.writeUTFBytes(n==2 ? pad(a,2) : String(a));
				}
				else if (c == _HR24) {
					a = int(d.hours);
					b.writeUTFBytes(n==2 ? pad(a,2) : String(a));
				}
				else if (c == _MINS) {
					a = int(d.minutes);
					b.writeUTFBytes(n==2 ? pad(a,2) : String(a));
				}
				else if (c == _MOS) {
					if (n >= 4) {
						b.writeUTFBytes(MONTH_NAMES[d.month]);
					} else if (n == 3) {
						b.writeUTFBytes(MONTH_ABBREVS[d.month]);
					} else {
						a = int(d.month+1);
						b.writeUTFBytes(n==2 ? pad(a,2) : String(a));
					}
				}
				else if (c == _SECS) {
					a = int(d.seconds);
					b.writeUTFBytes(n==2 ? pad(a,2) : String(a));
				}
				else if (c == _AMPM) {
					s = d.hours > 11 ? (n==2 ? PM2 : PM1) : (n==2 ? AM2 : AM1);
					b.writeUTFBytes(s);
				}
				else if (c == _YEAR) {
					if (n == 1) {
						b.writeUTFBytes(String(int(d.fullYear) % 100));
					} else {
						a = int(d.fullYear) % int(Math.pow(10,n));
						b.writeUTFBytes(pad(a, n));
					}
				}
				else if (c == _ZONE) {
					c = int(d.timezoneOffset / 60);
					if (c<0) { s='+'; c = -c; } else { s='-'; }
					b.writeUTFBytes(s + (n>1 ? pad(c, 2) : String(c)));
					if (n >= 3) {
						b.position = b.length;
						c = int(Math.abs(d.timezoneOffset) % 60);
						b.writeUTFBytes(':'+pad(c,2));
					}
				}
				else if (c == _BACKSLASH) {
					b.writeUTFBytes(p.charAt(i+1));
					n = 2;
				}
				else if (c == _APOSTROPHE) {
					a = p.indexOf('\'',i+1);
					b.writeUTFBytes(p.substring(i+1,a));
					n = 1 + a - i;
				}
				else if (c == _QUOTE) {
					a = p.indexOf('\"',i+1);
					b.writeUTFBytes(p.substring(i+1,a));
					n = 1 + a - i;
				}
				else if (c == _PERC) {
					if (n>1) throw new ArgumentError("Invalid date format: "+p);
				}
				else {
					b.writeUTFBytes(p.substr(i,n));
				}
				i += n;
				;
			}
		}
		
		// -- Number Formatting -----------------------------------------------
		
		inline private static var GROUPING:String = ';';
		inline private static var _ZERO:Int = '0'.charCodeAt(0);
		inline private static var _HASH:Int = '#'.charCodeAt(0);
		inline private static var _PERC:Int = '%'.charCodeAt(0);
		inline private static var _DECP:Int = '.'.charCodeAt(0);
		inline private static var _SEPR:Int = ','.charCodeAt(0);
		inline private static var _PLUS:Int = '+'.charCodeAt(0);
		inline private static var _MINUS:Int = '-'.charCodeAt(0);
		inline private static var _e:Int = 'e'.charCodeAt(0);
		inline private static var _E:Int = 'E'.charCodeAt(0);
		
		/** Separator for decimal (fractional) values. */
		inline public static var DECIMAL_SEPARATOR:String = '.';
		/** Separator for thousands values. */
		inline public static var THOUSAND_SEPARATOR:String = ',';
		/** String representing Not-a-Number (NaN). */
		inline public static var NaN:String = 'NaN';
		/** String representing positive infinity. */
		inline public static var POSITIVE_INFINITY:String = "+Inf";
		/** String representing negative infinity. */
		inline public static var NEGATIVE_INFINITY:String = "-Inf";
		
		inline private static var _STD_NUM:Dynamic = {
			c: "_S_#,0.", // currency
			d: "0", // integers
			e: "0.00e+0", // scientific
			f: 0, // fixed-point
			g: 0, // general
			n: "#,##0.", // number
			p: "%", // percent
			//r: 0, // round-trip
			x: 0  // hexadecimal
		};
		
		private static function numberPattern(b:ByteArray, p:String, x:Number):Void
		{
			var idx0:Int, idx1:Int, s:String = p.charAt(0).toLowerCase();
			var upper:Bool = s.charCodeAt(0) != p.charCodeAt(0);
			
			if (isNaN(x)) {
				// handle NaN
				b.writeUTFBytes(Strings.NaN);
			}
			else if (!isFinite(x)) {
				// handle infinite values
				b.writeUTFBytes(x<0 ? NEGATIVE_INFINITY : POSITIVE_INFINITY);
			}
			else if (p.length <= 3 && _STD_NUM[s] != null) {
				// handle standard formatting string
				var digits:Int = p.length==1 ? 2 : int(p.substring(1));
				
				if (s == 'c') {
					digits = p.length==1 ? 2 : digits;
					numberPattern(b, _STD_NUM[s]+repeat("0",digits), x);
				}
				else if (s == 'd') {
					b.writeUTFBytes(pad(Math.round(x), digits));
				}
				else if (s == 'e') {
					s = x.toExponential(digits);
					s = upper ? s.toUpperCase() : s.toLowerCase();
					b.writeUTFBytes(s);
				}
				else if (s == 'f') {
					b.writeUTFBytes(x.toFixed(digits));
				}
				else if (s == 'g') {
					var exp:Int = Math.log(Math.abs(x)) / Math.LN10;
					exp = (exp >= 0 ? int(exp) : int(exp-1));
					digits = (p.length==1 ? 15 : digits);
					if (exp < -4 || exp > digits) {
						s = upper ? 'E' : 'e';
						numberPattern(b, "0."+repeat("#",digits)+s+"+0", x);
					} else {
						numberPattern(b, "0."+repeat("#",digits), x);
					}
				}
				else if (s == 'n') {
					numberPattern(b, _STD_NUM[s]+repeat("0",digits), x);
				}
				else if (s == 'p') {
					numberPattern(b, _STD_NUM[s], x);
				}
				else if (s == 'x') {
					s = padString(x.toString(16), digits);
					s = upper ? s.toUpperCase() : s.toLowerCase();
					b.writeUTFBytes(s);
				}
				else {
					throw new ArgumentError("Illegal standard format: "+p);
				}
			}
			else {
				// handle custom formatting string
				// TODO: GROUPING designator is escaped or in string literal
				// TODO: Error handling?
				if ((idx0=p.indexOf(GROUPING)) >= 0) {
					if (x > 0) {
						p = p.substring(0, idx0);
					} else if (x < 0) {
						idx1 = p.indexOf(GROUPING, ++idx0);
						if (idx1 < 0) idx1 = p.length;
						p = p.substring(idx0, idx1);
						x = -x;
					} else {
						idx1 = 1 + p.indexOf(GROUPING, ++idx0);
						p = p.substring(idx1);
					}
				}
				formatNumber(b, p, x);
			}
		}
		
		/**
		 * 0: Zero placeholder
		 * #: Digit placeholder
		 * .: Decimal point (any duplicates are ignored)
		 * ,: Thosand separator + scaling
		 * %: Percentage placeholder
		 * e/E: Scientific notation
		 * 
		 * if has comma before dec point, use grouping
		 * if grouping right before dp, divide by 1000
		 * if percent and no e, multiply by 100
		 */
		private static function formatNumber(b:ByteArray, p:String, x:Number):Void
		{
			var i:Int, j:Int, c:Number, n:Int=1, digit:Int=0;
			var pp:Int=-1, dp:Int=-1, ep:Int=-1, ep2:Int=-1, sp:Int=-1;
			var nd:Int=0, nf:Int=0, ne:Int=0, max:Int=p.length-1;
			var xd:Number, xf:Number, xe:Int=0, zd:Int=0, zf:Int=0;
			var sd:String, sf:String, se:String;
			var hash:Bool = false;
			
			// ----------------------------------------------------------------
			// first pass: extract info from the formatting pattern
			
			for (i in 0...p.length) {
				c = p.charCodeAt(i);
				if (c == _ZERO || c == _HASH) {
					if (dp == -1) {
						if (nd==0) hash = true;
						nd++;
					} else nf++;
				}
				else if (c == _DECP) {
					if (dp == -1) dp = i;
				}
				else if (c == _SEPR) {
					if (sp == -1) sp = i;
				}
				else if (c == _PERC) {
					if (pp == -1) pp = i;
				}
				else if (c == _e || c == _E) {
					if (ep >= 0) continue;
					ep = i;
					if (i<max && (c=p.charCodeAt(i+1))==_PLUS || c==_MINUS) ++i;
					for (;i<max && p.charCodeAt(i+1)==_ZERO; ++i, ++ne);
					ep2 = i;
					if (p.charCodeAt(ep2) != _ZERO) { ep = ep2 = -1; ne=0; }
				}
				else if (c == _BACKSLASH) {
					++i;
				}
				else if (c == _APOSTROPHE) {
					// skip string literal
					for(i=i+1; i<p.length && (c==_BACKSLASH || (c=p.charCodeAt(i))!=_APOSTROPHE); ++i);
				}
				else if (c == _QUOTE) {
					// skip string literal
					for(i=i+1; i<p.length && (c==_BACKSLASH || (c=p.charCodeAt(i))!=_QUOTE); ++i);
				}
			}
			
			
			// ----------------------------------------------------------------
			// extract information for second pass
			
			// process grouping separators and thousands scaling
			var group:Bool = false, adj:Bool = true;
			if (sp >= 0) {
				if (dp >= 0) {
					i = dp;
				} else {
					i = p.length;
					while (i>sp) {
						c = p.charCodeAt(i-1);
						if (c==_ZERO || c==_HASH || c==_SEPR) break;
						--i;
					}
				}
				;
				while (--i >= sp) {
					if (p.charCodeAt(i) == _SEPR) {
						if (adj) { x /= 1000; } else { group = true; break; }
					} else {
						adj = false;
					}
					;
				}
			}
			// process percentage
			if (pp >= 0) {
				x *= 100;
			}
			// process negative number
			if (x < 0) {
				b.writeUTFBytes('-');
				x = Math.abs(x);
			}
			// process power of ten for scientific format
			if (ep >= 0) {
				c = Math.log(x) / Math.LN10;
				xe = (c>=0 ? int(c) : int(c-1)) - (nd-1);
				x = x / Math.pow(10, xe);
			}
			// round the number as needed
			c = Math.pow(10, nf);
			x = Math.round(c*x) / c;
			// separate number into component parts
			xd = nf > 0 ? Math.floor(x) : Math.round(x);
			xf = x - xd;
			// create strings for integral and fractional parts
			sd = pad(xd, nd);
			sf = (xf+1).toFixed(nf).substring(2); // add 1 to avoid AS3 bug
			if (hash) for (; zd<sd.length && sd.charCodeAt(zd)==_ZERO; ++zd);
			for (zf=sf.length; --zf>=0 && sf.charCodeAt(zf)==_ZERO;);
			
			
			// ----------------------------------------------------------------
			// second pass: format the number
			
			var inFraction:Bool = false;
			for (i in 0...p.length) {
				c = p.charCodeAt(i);
				if (i == dp) {
					if (zf >= 0 || p.charCodeAt(i+1) != _HASH)
						b.writeUTFBytes(DECIMAL_SEPARATOR);
					inFraction = true;
					n = 0;
				}
				else if (i == ep) {
					b.writeUTFBytes(p.charAt(i));
					if ((c=p.charCodeAt(i+1)) == _PLUS && xe > 0)
						b.writeUTFBytes('+');
					b.writeUTFBytes(pad(xe, ne));
					i = ep2;
				}
				else if (!inFraction && n==0 && (c==_HASH || c==_ZERO)
						 && sd.length-zd > nd) {
					if (group) {
						n=zd;
						while (n<=sd.length-nd) {
							b.writeUTFBytes(sd.charAt(n));
							if ((j=(sd.length-n-1)) > 0 && j%3 == 0)
								b.writeUTFBytes(THOUSAND_SEPARATOR);
							++n;
						}	
					} else {
						n = sd.length - nd + 1;
						b.writeUTFBytes(sd.substr(zd, n-zd));
					}
				}
				else if (c == _HASH) {
					if (inFraction) {
						if (n <= zf) b.writeUTFBytes(sf.charAt(n));
					} else if (n >= zd) {
						b.writeUTFBytes(sd.charAt(n));
						if (group && (j=(sd.length-n-1)) > 0 && j%3 == 0)
							b.writeUTFBytes(THOUSAND_SEPARATOR);
					}
					++n;
				}
				else if (c == _ZERO) {
					if (inFraction) {
						b.writeUTFBytes(n>=sf.length ? '0' : sf.charAt(n));
					} else {
						b.writeUTFBytes(sd.charAt(n));
						if (group && (j=(sd.length-n-1)) > 0 && j%3 == 0)
							b.writeUTFBytes(THOUSAND_SEPARATOR);
					}
					++n;
				}
				else if (c == _BACKSLASH) {
					b.writeUTFBytes(p.charAt(++i));
				}
				else if (c == _APOSTROPHE) {
					for(j=i+1; j<p.length && (c==_BACKSLASH || (c=p.charCodeAt(j))!=_APOSTROPHE); ++j);
					if (j-i > 1) b.writeUTFBytes(p.substring(i+1,j));
					i=j;
				}
				else if (c == _QUOTE) {
					for(j=i+1; j<p.length && (c==_BACKSLASH || (c=p.charCodeAt(j))!=_QUOTE); ++j);
					if (j-i > 1) b.writeUTFBytes(p.substring(i+1,j));
					i=j;
				}
				else {
					if (c != _DECP && c != _SEPR) b.writeUTFBytes(p.charAt(i));
				}
			}
		}
		
	} // end of class Strings
