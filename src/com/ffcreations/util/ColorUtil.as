package com.ffcreations.util {
	
	/**
	 * Some Color Utilities methods to help.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public final class ColorUtil {
		/** Extracts the <code>red</code> component of an hexadecimal color value. */
		public static function extractRed(c:uint):uint { return ((c >> 16) & 0xFF); }
		
		/** Extracts the <code>green</code> component of an hexadecimal color value. */
		public static function extractGreen(c:uint):uint { return ((c >> 8) & 0xFF); }
		
		/** Extracts the <code>blue</code> component of an hexadecimal color value. */
		public static function extractBlue(c:uint):uint { return (c & 0xFF); }
		
		/** Combine the three color values to an hexadecimal */
		public static function combineRGB(r:uint, g:uint, b:uint):uint { return ((r << 16) | (g << 8) | b); }
	}
}
