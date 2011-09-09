package com.ffcreations.rendering2D
{
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.SpriteRenderer;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A Renderer with a mask.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class MaskRenderer extends SpriteRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _maskSize:Point = new Point();
		protected var _maskPosition:Point = new Point();
		protected var _maskRegistrationPoint:Point = new Point(0.5, 0.5);
		
		/**
		 * Where to get the mask size property.
		 */
		public var maskSizeProperty:PropertyReference;
		
		/**
		 * Where to get the mask offset property.
		 */
		public var maskPositionProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Mask registration point. Keep the value beetween 0 and 1 to get an inner point.
		 */
		public function get maskRegistrationPoint():Point
		{
			return _maskRegistrationPoint;
		}
		
		/**
		 * @private
		 */
		public function set maskRegistrationPoint(value:Point):void
		{
			_maskRegistrationPoint = value;
			_transformDirty = true;
		}
		
		/**
		 * Mask position relative to the displayObject center.
		 */
		public function get maskPosition():Point
		{
			return _maskPosition;
		}
		
		/**
		 * @private
		 */
		public function set maskPosition(value:Point):void
		{
			_maskPosition = value;
			_transformDirty = true;
		}
		
		/**
		 * Mask size.
		 */
		public function get maskSize():Point
		{
			return _maskSize;
		}
		
		
		/**
		 * @private
		 */
		public function set maskSize(value:Point):void
		{
			_maskSize = value;
			_transformDirty = true;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		protected override function updateProperties():void
		{
			super.updateProperties();
			if (maskPositionProperty)
			{
				var offset:Point = owner.getProperty(maskPositionProperty);
				if (!(offset.x == _maskPosition.x && offset.y == _maskPosition.y))
				{
					_maskPosition = offset;
					_transformDirty = true;
				}
			}
			if (maskSizeProperty)
			{
				var size:Point = owner.getProperty(maskSizeProperty);
				if (!(size.x == _maskSize.x && size.y == _maskSize.y))
				{
					_maskSize = size;
					_transformDirty = true;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function updateTransform(updateProps:Boolean = false):void
		{
			super.updateTransform(updateProps);
			
			if (!_displayObject || !bitmapData)
			{
				return;
			}
			var mask:Sprite = _displayObject.mask as Sprite;
			
			with (mask.graphics)
			{
				clear();
				beginFill(0, 1);
				drawRect(0, 0, 1, 1);
				endFill();
			}
			
			var maskScaleX:Number = _scale.x * _maskSize.x;
			var maskScaleY:Number = _scale.y * _maskSize.y;
			
			//TODO make the transformation relative to the displayObject registrationPoint
			var matrix:Matrix = mask.transform.matrix;
			matrix.identity();
			matrix.scale(maskScaleX, maskScaleY);
			matrix.translate(-_maskRegistrationPoint.x * maskScaleX + maskPosition.x + (bitmapData.width) * 0.5, -_maskRegistrationPoint.y * maskScaleY + maskPosition.y + (bitmapData.height) * 0.5);
			mask.transform.matrix = matrix;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onImageLoadComplete():void
		{
			_displayObject.mask = (_displayObject as Sprite).addChild(new Sprite());
			_transformDirty = true;
		}
	}
}
