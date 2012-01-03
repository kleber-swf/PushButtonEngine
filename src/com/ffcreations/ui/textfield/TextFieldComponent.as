package com.ffcreations.ui.textfield
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * Component to create and handle a <code>TextField</code>.
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html flash.text.TextField
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public class TextFieldComponent extends DisplayObjectRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _text:String;
		private var _htmlText:String;
		private var _defaultSize:Point = new Point();
		
		protected var _field:TextField = new TextField();
		protected var _autoHeight:Boolean;
		protected var _minSize:Point = new Point();
		protected var _maxSize:Point = new Point(3000, 5000);
		
		/**
		 * Property where to get the text for this component.
		 */
		public var textProperty:PropertyReference;
		
		/**
		 * Multiplier to the size to automatically calculate <code>registrationPoint</code>.
		 * This is helpful when the <code>autoSize</code> or <code>autoHeight</code> are set.
		 * @see #registrationPoint
		 * @see #autoSize
		 * @see #autoHeight
		 */
		public var registrationPointFactor:Point;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Font anti-alias. Possible values: normal, advanced.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#antiAliasType flash.text.TextField.antiAliasType
		 */
		public function get antiAlias():String
		{
			return _field.antiAliasType;
		}
		
		/**
		 * @private
		 */
		public function set antiAlias(value:String):void
		{
			_field.antiAliasType = value;
		}
		
		/**
		 * Whether this component sets its height automatically or not.
		 */
		public function get autoHeight():Boolean
		{
			return _autoHeight;
		}
		
		/**
		 * @private
		 */
		public function set autoHeight(value:Boolean):void
		{
			_autoHeight = value;
			_transformDirty = true;
		}
		
		/**
		 * Set the autoSize property. Possible values: left, right, center and none.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#autoSize flash.text.TextField.autoSize
		 */
		public function get autoSize():String
		{
			return _field.autoSize;
		}
		
		/**
		 * @private
		 */
		public function set autoSize(value:String):void
		{
			_field.autoSize = value;
			_transformDirty = true;
		}
		
		/**
		 * Whether the field has background or not.
		 * @see #backgroundColor
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#background flash.text.TextField.background
		 */
		public function get background():Boolean
		{
			return _field.background;
		}
		
		/**
		 * @private
		 */
		public function set background(value:Boolean):void
		{
			_field.background = value;
		}
		
		/**
		 * Set the background color. Inplies on <code>background = true</code>.
		 * @see #background
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#backgroundColor flash.text.TextField.backgroundColor
		 */
		public function get backgroundColor():uint
		{
			return _field.backgroundColor;
		}
		
		/**
		 * @private
		 */
		public function set backgroundColor(value:uint):void
		{
			_field.background = true;
			_field.backgroundColor = value;
		}
		
		/**
		 * Whether the field has border.
		 * @see #borderColor
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#border flash.text.TextField.border
		 */
		public function get border():Boolean
		{
			return _field.border;
		}
		
		/**
		 * @private
		 */
		public function set border(value:Boolean):void
		{
			_field.border = value;
		}
		
		/**
		 * Set the border color. <code>Inplies border = true</code>.
		 * @see #border
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#borderColor flash.text.TextField.borderColor
		 */
		public function get borderColor():uint
		{
			return _field.borderColor;
		}
		
		/**
		 * @private
		 */
		public function set borderColor(value:uint):void
		{
			_field.border = true;
			_field.borderColor = value;
		}
		
		/**
		 * Whether the field is editable.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#type flash.text.TextField.type
		 */
		public function get editable():Boolean
		{
			return _field.type == TextFieldType.INPUT;
		}
		
		/**
		 * @private
		 */
		public function set editable(value:Boolean):void
		{
			_field.type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			_field.mouseEnabled = value;
		}
		
		/**
		 * Whether the fonts used to the field are embedded.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#embedFonts flash.text.TextField.embedFonts
		 */
		public function get embedFonts():Boolean
		{
			return _field.embedFonts;
		}
		
		/**
		 * @private
		 */
		public function set embedFonts(value:Boolean):void
		{
			_field.embedFonts = value;
		}
		
		/**
		 * The html text for this component.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#htmlText flash.text.TextField.htmlText
		 */
		public function get htmlText():String
		{
			return _htmlText;
		}
		
		/**
		 * @private
		 */
		public function set htmlText(value:String):void
		{
			_htmlText = value;
			_transformDirty = true;
		}
		
		/**
		 * The maximum number of characters that the field accepts.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#maxChars flash.text.TextField.maxChars
		 */
		public function get maxChars():int
		{
			return _field.maxChars;
		}
		
		/**
		 * @private
		 */
		public function set maxChars(value:int):void
		{
			_field.maxChars = value;
		}
		
		/**
		 * Text field maximum size.
		 */
		public function get maxSize():Point
		{
			return _maxSize;
		}
		
		/**
		 * @private
		 */
		public function set maxSize(value:Point):void
		{
			_maxSize = value;
		}
		
		/**
		 * Text field minimum size. 
		 */
		public function get minSize():Point
		{
			return _minSize;
		}
		
		/**
		 * @private
		 */
		public function set minSize(value:Point):void
		{
			_minSize = value;
		}
		
		/**
		 * Whether the field text is multiline.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#multiline flash.text.TextField.multiline
		 */
		public function get multiline():Boolean
		{
			return _field.multiline;
		}
		
		/**
		 * @private
		 */
		public function set multiline(value:Boolean):void
		{
			_field.multiline = value;
		}
		
		/**
		 * Whether the field is for password input.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#displayAsPassword flash.text.TextField.displayAsPassword
		 */
		public function get password():Boolean
		{
			return _field.displayAsPassword;
		}
		
		/**
		 * @private
		 */
		public function set password(value:Boolean):void
		{
			_field.displayAsPassword = value;
		}
		
		/**
		 * If set, restricts the input of this component to given regex.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#restrict flash.text.TextField.restrict
		 */
		public function get restrict():String
		{
			return _field.restrict;
		}
		
		/**
		 * @private
		 */
		public function set restrict(value:String):void
		{
			_field.restrict = value;
		}
		
		/**
		 * Whether the field is selectable
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#selectable flash.text.TextField.selectable
		 */
		public function get selectable():Boolean
		{
			return _field.selectable;
		}
		
		/**
		 * @private
		 */
		public function set selectable(value:Boolean):void
		{
			_field.selectable = value;
			_field.mouseEnabled = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function set size(value:Point):void
		{
			_defaultSize = value;
		}
		
		/**
		 * Attaches a style sheet to the text field.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#selectable flash.text.TextField.styleSheet
		 */
		public function set styleSheet(value:String):void
		{
			var s:StyleSheet = new StyleSheet();
			s.parseCSS(value);
			_field.styleSheet = s;
			_field.htmlText = _field.htmlText;
			_transformDirty = true;
		}
		
		/**
		 * Whether the tab is enabled for this component.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#tabEnabled flash.text.TextField.tabEnabled
		 */
		public function get tabEnabled():Boolean
		{
			return _field.tabEnabled;
		}
		
		/**
		 * @private
		 */
		public function set tabEnabled(value:Boolean):void
		{
			_field.tabEnabled = value;
		}
		
		/**
		 * The tab index (if tab is enabled).
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#tabIndex flash.text.TextField.tabIndex
		 */
		public function get tabIndex():int
		{
			return _field.tabIndex;
		}
		
		/**
		 * @private
		 */
		public function set tabIndex(value:int):void
		{
			_field.tabIndex = value;
		}
		
		/**
		 * The text for this component.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#text flash.text.TextField.text
		 */
		public function get text():String
		{
			return _field.text;
		}
		
		/**
		 * @private
		 */
		public function set text(value:String):void
		{
			if (text == value)
			{
				return;
			}
			_text = value;
			_transformDirty = true;
		}
		
		/**
		 * TextFormat for this component.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextFormat.html flash.text.TextFormat
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#defaultTextFormat flash.text.TextField.defaultTextFormat
		 */
		public function get textFormat():TextFormat
		{
			return _field.defaultTextFormat;
		}
		
		/**
		 * @private
		 */
		public function set textFormat(value:TextFormat):void
		{
			_field.defaultTextFormat = value;
			_field.setTextFormat(value);
			_field.text = _field.text;
			_field.htmlText = _field.htmlText;
			_transformDirty = true;
		}
		
		/**
		 * Whether the field should wrap its text.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#wordWrap flash.text.TextField.wordWrap
		 */
		public function get wordWrap():Boolean
		{
			return _field.wordWrap;
		}
		
		/**
		 * @private
		 */
		public function set wordWrap(value:Boolean):void
		{
			_field.wordWrap = value;
		}
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		/**
		 * Just creates a <code>TextField</code> and set it to <code>displayObject</code>.
		 */
		public function TextFieldComponent()
		{
			displayObject = _field;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 **/
		protected override function updateProperties():void
		{
			super.updateProperties();
			if (alpha > 0 && textProperty)
			{
				text = owner.getProperty(textProperty, "");
			}
		}
		
		private function updateText():void
		{
			if (_htmlText)
			{
				_field.htmlText = _htmlText;
			}
			else if (_text)
			{
				_field.text = _text;
			}
		}
		
		/**
		 * @inheritDoc
		 **/
		public override function updateTransform(updateProps:Boolean = false):void
		{
			if (!displayObject)
			{
				return;
			}
			
			if (updateProps)
			{
				updateProperties();
			}
			
			var autoSize:Boolean = _field.autoSize != TextFieldAutoSize.NONE;
			
			// specify the default size
			var size:Point;
			if (!autoSize)
			{
				size = sizeProperty != null ? owner.getProperty(sizeProperty) as Point : _defaultSize.clone();
			}
			if (!size)
			{
				size = _minSize.clone();
			}
			
			_field.width = size.x;
			_field.height = size.y;
			
			// put the text
			updateText();
			
			if (autoSize || size.x <= 0)
			{
				size.x = _field.textWidth + 4; //gutter
			}
			if (_autoHeight || size.y <= 0)
			{
				size.y = int(_field.getLineMetrics(0).height + (1 - Number.MIN_VALUE)) * _field.numLines + 4; // gutter
			}
			
			// assure that the size is inside the range 
			size.x = Math.min(_maxSize.x, Math.max(_minSize.x, size.x));
			size.y = Math.min(_maxSize.y, Math.max(_minSize.y, size.y));
			
			// resize according to the content
			_field.width = size.x;
			_field.height = size.y;
			
			// put the text again
			updateText();
			if (_autoHeight)
			{
				size.y = int(_field.getLineMetrics(0).height + (1 - Number.MIN_VALUE)) * _field.numLines + 4; // gutter
				_field.height = size.y;
			}
			_size = size;
			
			// calculates the registration point
			if (registrationPointFactor)
			{
				registrationPoint = new Point(size.x * registrationPointFactor.x, size.y * registrationPointFactor.y);
			}
			
			// applies transformations
			_transformMatrix.identity();
			_transformMatrix.scale(_scale.x, _scale.y);
			_transformMatrix.translate(-_registrationPoint.x * _scale.x, -_registrationPoint.y * _scale.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
			_transformMatrix.translate(_position.x + _positionOffset.x, _position.y + _positionOffset.y);
			
			displayObject.transform.matrix = _transformMatrix;
			displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}
		
		/**
		 * Appends a text to the end of the current text.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#appendText flash.text.TextField.appendText
		 */
		public function appendText(text:String):void
		{
			_field.appendText(text);
			if (_autoHeight)
			{
				_transformDirty = true;
			}
		}
		
		/**
		 * Requires the stage focus to this text field. 
		 */
		public function focus():void
		{
			PBE.mainStage.focus = _field;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			_field = null;
			super.onRemove();
		}
	}
}
