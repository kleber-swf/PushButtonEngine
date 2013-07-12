package com.ffcreations.format {
	
	public interface IFormatter {
		function set lang(value:String):void;
		function set decimalSeparator(value:String):void;
		function set fractionalDigits(value:int):void;
		function set groupingSeparator(value:String):void;
		function set leadingZero(value:Boolean):void;
		function format(value:*):String;
		function get lastOperationStatus():String;
	}
}
