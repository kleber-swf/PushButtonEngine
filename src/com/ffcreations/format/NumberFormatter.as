package com.ffcreations.format {
	import com.pblabs.engine.debug.Logger;
	
	import flash.globalization.NumberFormatter;
	
	public class NumberFormatter implements IFormatter {
		private var _formatter:flash.globalization.NumberFormatter;
		private var _decimalSeparator:String;
		private var _fractionalDigits:int;
		private var _groupingSeparator:String;
		private var _useGrouping:Boolean;
		
		public function set lang(value:String):void {
			if (value == _formatter.actualLocaleIDName)
				return;
			_formatter = new flash.globalization.NumberFormatter(value);
			_formatter.decimalSeparator = _decimalSeparator;
			_formatter.fractionalDigits = _fractionalDigits;
			_formatter.groupingSeparator = _groupingSeparator;
			_formatter.useGrouping = _useGrouping;
		}
		
		public function set decimalSeparator(value:String):void { _formatter.decimalSeparator = _decimalSeparator = value; }
		
		public function set fractionalDigits(value:int):void { _formatter.fractionalDigits = _fractionalDigits = value; }
		
		public function set groupingSeparator(value:String):void { _formatter.groupingSeparator = _groupingSeparator = value; }
		
		public function set leadingZero(value:Boolean):void { _formatter.useGrouping = _useGrouping = value; }
		
		public function get lastOperationStatus():String { return _formatter.lastOperationStatus; }
		
		public function NumberFormatter(lang:String = "en-US") {
			_formatter = new flash.globalization.NumberFormatter(lang);
			_decimalSeparator = _formatter.decimalSeparator;
			_fractionalDigits = _formatter.fractionalDigits;
			_groupingSeparator = _formatter.groupingSeparator;
			_useGrouping = _formatter.useGrouping;
		}
		
		public function format(value:*):String {
			const v:Number = value ? parseFloat(value.toString()) : NaN;
			return isNaN(v) ? "" : _formatter.formatNumber(v);
		}
	
	}
}
