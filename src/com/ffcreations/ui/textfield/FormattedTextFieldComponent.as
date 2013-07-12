package com.ffcreations.ui.textfield {
	import com.ffcreations.format.NumberFormatter;
	import com.pblabs.engine.entity.PropertyReference;
	
	public class FormattedTextFieldComponent extends TextFieldComponent {
		private var _formatter:NumberFormatter;
		private var _value:String;
		
		public var formatterProperty:PropertyReference;
		
		public function get formatter():NumberFormatter { return _formatter; }
		
		public function set formatter(value:NumberFormatter):void {
			_formatter = value;
			_transformDirty = true;
		}
		
		public override function set text(value:String):void {
			if (_value == value)
				return;
			super.text = value;
		}
		
		protected override function setText(value:String):void {
			_value = value;
			super.setText(_formatter ? _formatter.format(value) : value);
		}
		
		protected override function updateCustomProperties():void {
			super.updateCustomProperties();
			if (!formatterProperty)
				return;
			
			var formatter:NumberFormatter = owner.getProperty(formatterProperty);
			if (formatter == null || formatter == _formatter)
				return;
			_formatter = formatter;
			setText(_text);
		}
	}
}
