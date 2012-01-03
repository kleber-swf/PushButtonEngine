package com.ffcreations.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.rendering2D.SimpleShapeRenderer;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * Draws a shape filled with a bitmap. A mix of SpriteRenderer and ShapeRenderer.
	 * It does not uses scale to resize itself.
	 *
	 * @see com.pblabs.rendering2D.SimpleShapeRenderer
	 * @see com.pblabs.rendering2D.SpriteRenderer
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class BitmapShapeRenderer extends SimpleShapeRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _fileName:String = null;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
		private var _resource:ImageResource = null;
		private var _bitmapData:BitmapData = null;
		private var _repeat:Boolean = true;
		private var _smooth:Boolean = false;
		private var _bitmapTransformMatrix:Matrix = null;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Transform matrix to the bitmap.
		 * @see flash.geom.Matrix
		 * @default null
		 */
		public function get bitmapTransformMatrix():Matrix
		{
			return _bitmapTransformMatrix;
		}
		
		/**
		 * @private
		 */
		public function set bitmapTransformMatrix(value:Matrix):void
		{
			_bitmapTransformMatrix = value;
			redraw();
		}
		
		/**
		 * Indicates if the ImageResource has failed loading
		 */
		[EditorData(ignore="true")]
		public function get failed():Boolean
		{
			return _failed;
		}
		
		/**
		 * Resource (file)name of the ImageResource
		 */
		public function get fileName():String
		{
			return _fileName;
		}
		
		/**
		 * @private
		 */
		public function set fileName(value:String):void
		{
			if (fileName != value)
			{
				if (_resource)
				{
					PBE.resourceManager.unload(_resource.filename, ImageResource);
					_resource = null;
				}
				_fileName = value;
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(fileName, ImageResource, imageLoadCompleted, imageLoadFailed, false);
			}
		}
		
		/**
		 * Indicates if the ImageResource has been loaded
		 */
		[EditorData(ignore="true")]
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/**
		 * Indicates if the resource loading is in progress
		 */
		[EditorData(ignore="true")]
		public function get loading():Boolean
		{
			return _loading;
		}
		
		
		/**
		 * Should the bitmap repeat when filling the shape?
		 * @default true
		 * @see flash.display.Graphics#beginBitmapFill
		 */
		public function get repeat():Boolean
		{
			return _repeat;
		}
		
		/**
		 * @private
		 */
		public function set repeat(value:Boolean):void
		{
			_repeat = value;
			redraw();
		}
		
		/**
		 * Loaded ImageResource
		 */
		[EditorData(ignore="true")]
		public function get resource():ImageResource
		{
			return _resource;
		}
		
		/**
		 * Should the upscale use nearest-neighbor (false) or bilinear (true) algorithm?
		 * @default false
		 * @see flash.display.Graphics#beginBitmapFill
		 */
		public function get smooth():Boolean
		{
			return _smooth;
		}
		
		/**
		 * @private
		 */
		public function set smooth(value:Boolean):void
		{
			_smooth = value;
			redraw();
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			if (!_resource && fileName != null && fileName != "" && !loading)
			{
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(fileName, ImageResource, imageLoadCompleted, imageLoadFailed, false);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			if (_resource)
			{
				_resource.removeEventListener(ResourceEvent.LOADED_EVENT, onResourceUpdated);
				PBE.resourceManager.unload(_resource.filename, ImageResource);
				_resource = null;
				_loaded = false;
			}
			_bitmapData = null;
			_bitmapTransformMatrix = null;
			
			super.onRemove();
		}
		
		/**
		 * This function will be called if the ImageResource has been loaded correctly
		 */
		private function imageLoadCompleted(res:ImageResource):void
		{
			_loading = false;
			_loaded = true;
			_failed = false;
			_resource = res;
			_resource.addEventListener(ResourceEvent.LOADED_EVENT, onResourceUpdated, false, 0, true);
			_bitmapData = res.image.bitmapData;
			onImageLoadComplete();
			redraw();
		}
		
		/**
		 * Called when the image is ready and the _displayObject is set.
		 */
		protected function onImageLoadComplete():void
		{
		
		}
		
		/**
		 * This function will be called if the ImageResource has failed loading
		 */
		private function imageLoadFailed(res:ImageResource):void
		{
			_loading = false;
			_failed = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function redraw():void
		{
			// Get references.
			var s:Sprite = displayObject as Sprite;
			if (!s)
			{
				throw new Error("displayObject null or not a Sprite!");
			}
			var g:Graphics = s.graphics;
			
			// Don't forget to clear.
			g.clear();
			
			// Prep line/fill settings.
			if (_lineAlpha > 0)
			{
				g.lineStyle(_lineSize, _lineColor, _lineAlpha);
			}
			if (_bitmapData == null)
			{
				g.beginFill(_fillColor, _fillAlpha);
			}
			else
			{
				g.beginBitmapFill(_bitmapData, _bitmapTransformMatrix, _repeat, _smooth);
			}
			
			// Draw one or both shapes.
			if (isSquare)
			{
				g.drawRect(position.x - size.x * 0.5, position.y - size.y * 0.5, size.x, size.y);
			}
			
			if (isCircle)
			{
				g.drawCircle(0, 0, radius);
			}
			
			g.endFill();
			
			// Sanity check.
			if (!isCircle && !isSquare)
			{
				Logger.error(this, "redraw", "Neither square nor circle, what am I?");
			}
		}
		
		/**
		 * Updates the transform but without scaling the object.
		 */
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
			displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		protected function onResourceUpdated(event:ResourceEvent = null):void
		{
			imageLoadCompleted(_resource);
		}
	}
}
