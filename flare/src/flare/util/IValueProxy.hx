package flare.util;

	/**
	 * Interface for classes that get and set named property values of objects.
	 */
	interface IValueProxy
	{
		/**
		 * Gets a named property value for an object. 
		 * @param object the object
		 * @param name the property name
		 * @return the value
		 */
		function getValue(object:Dynamic, name:String):Dynamic;
		
		/**
		 * Sets a named property value for an object.
		 * @param object the object
		 * @param name the property name
		 * @param value the value
		 */
		function setValue(object:Dynamic, name:String, value:Dynamic):Void;
		
		/**
		 * Returns a value proxy object for getting and setting values. 
		 * @param object the object
		 * @return a value proxy object upon which clients can get and set
		 *  properties directly
		 */
		function _S_(object:Dynamic):Dynamic;
		
	} // end of interface IValueProxy
