package flare.query;

	import flash.utils.ByteArray;
	
	/**
	 * Utility class providing functions for manipulating <code>String</code>
	 * objects. These functions are intended for use by the
	 * <code>Fn</code> operator.
	 */
	class StringUtil
	{
		public static function concat(args:Array<Dynamic>):String
		{
			return args.join("");
		}
		
		public static function concat_ws(sep:String, args:Array<Dynamic>):String
		{
			return args.join(sep);
		}
		
		public static function format(x:Number, d:Int):String
		{
			return x.toFixed(d);
		}
		
		public static function insert(s:String, pos:Int, len:Int, ns:String):String
		{
			var slen:Int = s.length;
			if (pos < 0 || pos > slen)
            	return s;
	        if (len < 0 || len > slen)
	            return s.substring(0,pos)+ns;
	        else
	            return s.substring(0,pos)+ns+s.substring(len);
		}
		
		public static function left(s:String, len:Int):String
		{
			return s.substring(0, len);
		}
		
		public static function length(s:String):Int
		{
			return s.length;
		}
		
		public static function lower(s:String):String
		{
			return s.toLowerCase();
		}
		
		public static function lpad(s:String, len:Int, pad:String):String
		{
			var strlen:Int = s.length;
	        if (strlen > len) {
	            return s.substring(0,len);
	        }
	        else if (strlen == len) {
	            return s;
	        }
	        else {
	        	var b:ByteArray = new ByteArray();
	        	var padlen:Int = pad.length;
	        	var diff:Int = len - strlen;

	            for (var i:Int=0; i<diff; i+=padlen)
	            	b.writeUTFBytes(pad);
	            if (b.length > diff)
	            	b.position = diff;
	            b.writeUTFBytes(s);
	            b.position = 0;
	            return b.readUTFBytes(b.length);
	        }
		}
		
		public static function position(sub:String, s:String):Int
		{
			return s.indexOf(sub);
		}
		
		public static function reverse(s:String):String
		{
			var b:ByteArray = new ByteArray();
        	var i:Int=s.length-1;
        	while (--i>=0) {
        		b.writeUTFBytes(s.charAt(i));
        		;
        	}
        	b.position = 0;
        	return b.readUTFBytes(b.length);
		}
		
		public static function repeat(s:String, count:Int):String
		{
			var b:ByteArray = new ByteArray();
        	for (i in 0...count) {
        		b.writeUTFBytes(s);
        	}
        	b.position = 0;
        	return b.readUTFBytes(b.length);
		}
		
		public static function replace(s:String, orig:String, replace:String):String
		{
			return s.replace(new RegExp(orig, "g"), replace);
		}
		
		public static function right(s:String, len:Int):String
		{
			return s.substring(s.length-len);
		}
		
		public static function rpad(s:String, len:Int, pad:String):String
		{
			var strlen:Int = s.length;
	        if (strlen > len) {
	            return s.substring(0,len);
	        }
	        else if (strlen == len) {
	            return s;
	        }
	        else {
	        	var b:ByteArray = new ByteArray();
	        	b.writeUTFBytes(s);
	        	var padlen:Int = pad.length;
	        	var diff:Int = len - strlen;

	            for (var i:Int=0; i<diff; i+=padlen)
	            	b.writeUTFBytes(pad);
	            b.position = 0;
	            return b.readUTFBytes(len);
	        }
		}
		
		public static function space(len:Int):String
		{
			return repeat(" ", len);
		}
		
		public static function substring(s:String, pos:Int, ?len:Int=-1):String
		{
			return len<0 ? s.substr(pos) : s.substr(pos, len);
		}
		
		public static function upper(s:String):String
		{
			return s.toUpperCase();
		}
		
		public static function startsWith(s:String, p:String):Bool
		{
			return s.indexOf(p) == 0;
		}
		
		public static function endsWith(s:String, p:String):Bool
		{
			var diff:Int = s.length - p.length;
			if (diff < 0) return false;
			for (i in 0...p.length) {
				if (s.charCodeAt(i+diff) != p.charCodeAt(i))
					return false;
			}
			return true;
		}

	} // end of class StringUtil
