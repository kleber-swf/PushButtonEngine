package com.ffcreations.util
{
	
	/**
	 * Some Utils methods to help.
	 * 
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public final class FFUtil
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		/**
		 * Rounds the gigen <code>value</code> to the nearest <code>value</code>.
		 * @param roundTo	Reference value.
		 * @param value		Value to round.
		 * @return The parameter <code>value</code> rounded to the nearest
		 * multiple of <code>roundTo</code>.
		 */
		public static function roundToNearest(roundTo:Number, value:Number):Number
		{
			value /= roundTo;
			return (value > 0 ? value + 0.5 | 0 : value - 0.5 | 0) * roundTo;
		}
		
		/**
		 * Ceils the gigen <code>value</code> to the nearest <code>value</code>.
		 * @param roundTo	Reference value.
		 * @param value		Value to round.
		 * @return An <code>Number</code> that is both closest to, and greater than
		 * or equal to, the parameter <code>roundTo</code>.
		 */
		public static function ceilToNearest(roundTo:Number, value:Number):Number
		{
			value /= roundTo;
			return (value >= 0 ? int(value + 1) : int(value)) * roundTo;
		}
		
		/**
		 * Floors the gigen <code>value</code> to the nearest <code>value</code>.
		 * @param roundTo	Reference value.
		 * @param value		Value to round.
		 * @return The <code>Number</code> that is both closest to, and less than
		 * or equal to, the parameter <code>roundTo</code>. 
		 */
		public static function floorToNearest(roundTo:Number, value:Number):Number
		{
			value /= roundTo;
			return (value < 0 ? int(value - 1) : int(value)) * roundTo;
		}
	}
}
