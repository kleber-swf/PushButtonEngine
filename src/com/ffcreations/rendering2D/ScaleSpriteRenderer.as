package com.ffcreations.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A Sprite that is scaled by a scale grid.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class ScaleSpriteRenderer extends DisplayObjectRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _fileName:String;
		protected var _loading:Boolean;
		protected var _loaded:Boolean;
		protected var _resource:ImageResource;
		protected var _failed:Boolean;
		
		protected var _scaleDirty:Boolean;
		protected var _scale9Grid:Rectangle;
		protected var _source:BitmapData;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
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
			if (_fileName != value)
			{
				if (_resource)
				{
					PBE.resourceManager.unload(_resource.filename, ImageResource);
					_resource = null;
				}
				_fileName = value;
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(_fileName, ImageResource, imageLoadCompleted, imageLoadFailed, false);
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
		 * Loaded ImageResource
		 */
		[EditorData(ignore="true")]
		public function get resource():ImageResource
		{
			return _resource;
		}
		
		/**
		 * The 9-slice grid.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html#scale9Grid flash.display.DisplayObject.scale9Grid
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
			_transformDirty = true;
			_scaleDirty = true;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
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
			// set the registration (alignment) point to the sprite's center
			registrationPoint = new Point(res.image.bitmapData.width * 0.5, res.image.bitmapData.height * 0.5);
			// set the bitmapData of this render object
			_source = res.image.bitmapData;			
			var s:Sprite = new Sprite();
			s.mouseChildren = false;
			s.mouseEnabled = false;
			_displayObject = s;
			onImageLoadComplete();
			//redraw();
			_scaleDirty=true;
		}
		
		public override function set size(value:Point):void
		{
			super.size = value;
		}
		
		/**
		 * Called when the image is ready and the _displayObject is set.
		 */
		protected function onImageLoadComplete():void
		{
		}
		
		protected override function addToScene():void
		{
			super.addToScene();
			_scaleDirty=true;
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
		protected override function onAdd():void
		{
			super.onAdd();
			if (!loading && !_resource && _fileName != null && _fileName != "")
			{
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(_fileName, ImageResource, imageLoadCompleted, imageLoadFailed, false);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			if (_resource)
			{
				PBE.resourceManager.unload(_resource.filename, ImageResource);
				_resource = null;
				_loaded = false;
			}
			_fileName = null;
			_scale9Grid = null;
			_source = null;
			
			super.onRemove();
		}
		
		/**
		 * Redraws the sprite.
		 */
		protected function redraw():void
		{
			if (!_loaded)
			{
				return;
			}
			
			var graphics:Graphics = (_displayObject as Sprite).graphics;
			
			if (!_scale9Grid)
			{
				graphics.clear();
				graphics.beginBitmapFill(_source);
				graphics.drawRect(0, 0, _source.width, _source.height);
				graphics.endFill();
				_displayObject.scale9Grid = null;
				_scaleDirty = false;
				return;
			}
			var gridX:Array = [_scale9Grid.left, _scale9Grid.right, _source.width];
			var gridY:Array = [_scale9Grid.top, _scale9Grid.bottom, _source.height];
			
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
			_displayObject.scale9Grid = _scale9Grid;
			_scaleDirty = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function onFrame(elapsed:Number):void
		{
			if (_scaleDirty)
			{
				redraw();
			}
			super.onFrame(elapsed);
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
