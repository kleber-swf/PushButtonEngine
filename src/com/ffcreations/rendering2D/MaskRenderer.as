package com.ffcreations.rendering2D
{
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.SpriteRenderer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.primitives.Graphic;
	
	/**
	 * A Renderer with a mask.
	 * This component can be particularly confusing because of <code>maskPosition<code>
	 * and <code>maskRegistrationPoint<code> properties, so, here is an example:
	 * @example Suppose you want to create a volume bar. Set the parameters as follow:
	 * <pre>
	 * // position the mask on the left border of the texture
	 * maskRenderer.maskPostion = new Point(-0.5, 0);
	 * // position the mask registration point on its left border
	 * maskRenderer.maskRegistrationPoint = new Point(-0.5, 0);
	 * </pre>
	 * This will make the mask be resized (through the <code>maskScale</code> property)
	 * only in the right side. Just like a volume bar should be.
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class MaskRenderer extends SpriteRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _maskScale:Point = new Point(1, 1);
		protected var _maskPosition:Point = new Point();
		protected var _maskRegistrationPoint:Point = new Point();
		
		/**
		 * Where to get the mask scale property.
		 */
		public var maskScaleProperty:PropertyReference;
		
		/**
		 * Where to get the mask offset property.
		 */
		public var maskPositionProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Mask position relative to the displayObject center.
		 * Keep the values between -0.5 and 0.5 to get an inner texture position.
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
		 * Mask registration point.
		 * Keep the values beetween -0.5 and 0.5 to get an inner mask point.
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
		 * Mask scale.
		 */
		public function get maskScale():Point
		{
			return _maskScale;
		}
		
		
		/**
		 * @private
		 */
		public function set maskScale(value:Point):void
		{
			_maskScale = value;
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
			if (maskScaleProperty)
			{
				var size:Point = owner.getProperty(maskScaleProperty);
				if (!(size.x == _maskScale.x && size.y == _maskScale.y))
				{
					_maskScale = size;
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
			
			var g:Graphics = mask.graphics;
			g.clear();
			g.beginFill(0, 1);
			g.drawRect(0, 0, 1, 1);
			g.endFill();
			
			var w:Number = bitmapData.width;
			var h:Number = bitmapData.height;
			
			var maskScaleX:Number = _scale.x * w * _maskScale.x;
			var maskScaleY:Number = _scale.y * h * _maskScale.y;
			
			var matrix:Matrix = mask.transform.matrix;
			matrix.identity();
			matrix.scale(maskScaleX, maskScaleY);
			matrix.translate(
				-maskScaleX * (_maskRegistrationPoint.x + _registrationPoint.x / w) + (maskPosition.x + 0.5) * w,
				-maskScaleY * (_maskRegistrationPoint.y + _registrationPoint.y / h) + (maskPosition.y + 0.5) * h);
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
