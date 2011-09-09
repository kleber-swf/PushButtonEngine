package com.ffcreations.ui.textfield
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import spark.primitives.Line;
	import flash.text.TextLineMetrics;
	
	/**
	 * Component to create and handle a <code>TextField</code>.
	 * @see flash.text.TextField
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public class TextFieldComponent extends DisplayObjectRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _field:TextField = new TextField();
		protected var _autoHeight:Boolean;
		
		/**
		 * Property where to get the text for this component.
		 */
		public var textProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Font anti-alias. Possible values: normal, advanced.
		 * @see flash.text.AntiAliasType
		 * @see flash.text.TextField#antiAliasType
		 */
		public function set antiAlias(value:String):void
		{
			_field.antiAliasType = value;
		}
		
		/**
		 * Whether this component sets its height automatically or not.
		 */
		public function set autoHeight(value:Boolean):void
		{
			_autoHeight = value;
			_transformDirty = true;
		}
		
		/**
		 * Set the autoSize property. Possible values: left, right, center and none.
		 * @see flash.text.TextFieldAutoSize
		 * @see flash.text.TextField#autoSize
		 */
		public function set autoSize(value:String):void
		{
			_field.autoSize = value;
		}
		
		/**
		 * Whether the field has background or not.
		 * @see #backgroundColor
		 * @see flash.text.TextField#background
		 */
		public function set background(value:Boolean):void
		{
			_field.background = value;
		}
		
		/**
		 * Set the background color. Inplies on <code>background = true</code>.
		 * @see #background
		 * @see flash.text.TextField#backgroundColor
		 */
		public function set backgroundColor(value:uint):void
		{
			_field.background = true;
			_field.backgroundColor = value;
		}
		
		/**
		 * Whether the field has border.
		 * @see #borderColor
		 * @see flash.text.TextField#border
		 */
		public function set border(value:Boolean):void
		{
			_field.border = value;
		}
		
		/**
		 * Set the border color. <code>Inplies border = true</code>.
		 * @see #border
		 * @see flash.text.TextField#borderColor
		 */
		public function set borderColor(value:uint):void
		{
			_field.border = true;
			_field.borderColor = value;
		}
		
		/**
		 * Whether the field is editable.
		 * @see flash.text.TextField#type
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
		}
		
		/**
		 * Whether the fonts used to the field are embedded.
		 */
		public function set embedFonts(value:Boolean):void
		{
			_field.embedFonts = value;
		}
		
		/**
		 * The html text for this component.
		 */
		public function get htmlText():String
		{
			return _field.htmlText;
		}
		
		/**
		 * @private
		 */
		public function set htmlText(value:String):void
		{
			_field.htmlText = value;
			if (_autoHeight)
			{
				_transformDirty = true;
			}
		}
		
		/**
		 * The maximum number of characters that the field accepts.
		 * @see flash.text.TextField#maxChars
		 */
		public function set maxChars(value:int):void
		{
			_field.maxChars = value;
		}
		
		/**
		 * Whether the field text is multiline.
		 * @see flash.text.TextField#multiline
		 * @see flash.text.TextField#wordWrap
		 */
		public function set multiline(value:Boolean):void
		{
			_field.multiline = _field.wordWrap = value;
		}
		
		/**
		 * Whether the field is for password input.
		 * @see flash.text.TextField#displayAsPassword
		 */
		public function set password(value:Boolean):void
		{
			_field.displayAsPassword = value;
		}
		
		/**
		 * If set, restricts the input of this component to given regex.
		 * @see flash.text.TextField#restrict
		 */
		public function set restrict(value:String):void
		{
			_field.restrict = value;
		}
		
		/**
		 * Whether the field is selectable
		 * @see flash.text.TextField#selectable
		 */
		public function set selectable(value:Boolean):void
		{
			_field.selectable = value;
		}
		
		/**
		 * Whether the tab is enabled for this component.
		 * @see flash.text.TextField#tabEnabled
		 */
		public function set tabEnabled(value:Boolean):void
		{
			_field.tabEnabled = value;
		}
		
		/**
		 * The tab index (if tab is enabled).
		 * @see flash.text.TextField#tabIndex
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
			_field.text = value;
			if (_autoHeight)
			{
				_transformDirty = true;
			}
		}
		
		/**
		 * TextFormat for this component.
		 * @see flash.text.TextFormat
		 * @see flash.text.TextField#defaultTextFormat
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
			_field.text = _field.text;
			_transformDirty = true;
		}
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		/**
		 * Just creates a <code>TextField</code> and set it to <code>displayObject<code>.
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
			if (textProperty)
			{
				text = owner.getProperty(textProperty, "");
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
			
			var size:Point = sizeProperty != null ? owner.getProperty(sizeProperty) as Point : this.size;
			var width:int;
			var height:int;
			
			if (size == null)
			{
				width = _field.textWidth;
				height = _field.textHeight;
			}
			else
			{
				width = size.x;
				height = size.y;
				
				if (width <= 0)
				{
					width = _field.textWidth;
				}
				if (_autoHeight)
				{
					height = (_field.defaultTextFormat && _field.defaultTextFormat.size ? _field.defaultTextFormat.size as Number : 12) * _field.numLines + 4; // 4: gutter
				}
			}
			if (_field.border)
			{
				width += 2;
				height += 2;
			}
			
			_field.width = width;
			_field.height = height;
			registrationPoint = new Point(width * 0.5, height * 0.5);
			
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
		 * @see flash.text.TextField#appendText.
		 */
		public function appendText(text:String):void
		{
			_field.appendText(text);
		}
		
		public function focus():void
		{
			PBE.mainStage.focus = _field;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			super.onRemove();
			_field = null;
		}
	}
}
