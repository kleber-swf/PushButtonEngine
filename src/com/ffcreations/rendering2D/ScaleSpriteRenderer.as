package com.ffcreations.rendering2D
{
	import com.pblabs.rendering2D.SpriteRenderer;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class ScaleSpriteRenderer extends SpriteRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _scale9Grid:Rectangle;
		
		/**
		 * The source bitmap.
		 */
		protected var _source:BitmapData;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * The 9-slice grid.
		 * @see flash.display.DisplayObject#scale9Grid
		 */
		public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}
		
		/**
		 * @private
		 */
		public function set scale9Grid(value:Rectangle):void
		{
			_scale9Grid = value;
			redraw();
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * Redraws the sprite.
		 */
		protected function redraw():void
		{
			if (!_source)
			{
				return;
			}
			if (!_scale9Grid)
			{
				_displayObject.scale9Grid = null;
				return;
			}
			var gridX:Array = [_scale9Grid.left, _scale9Grid.right, _source.width];
			var gridY:Array = [_scale9Grid.top, _scale9Grid.bottom, _source.height];
			
			var sprite:Sprite = new Sprite();
			var graphics:Graphics = sprite.graphics;
			
			graphics.clear();
			
			var left:Number = 0;
			for (var i:int = 0; i < 3; i++)
			{
				var top:Number = 0;
				for (var j:int = 0; j < 3; j++)
				{
					graphics.beginBitmapFill(_source);
					graphics.drawRect(left, top, gridX[i] - left, gridY[j] - top);
					graphics.endFill();
					top = gridY[j];
				}
				left = gridX[i];
			}
			sprite.scale9Grid = _scale9Grid;
			
			_displayObject = sprite;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onImageLoadComplete():void
		{
			_source = bitmapData;
			redraw();
		}
	}
}
