package com.ffcreations.ui.components
{
	import com.ffcreations.rendering2D.ScaleSpriteRenderer;
	import com.ffcreations.ui.mouse.IMouseInputComponent;
	import com.ffcreations.ui.mouse.MouseInputData;
	import com.ffcreations.util.DelegateContainer;
	import com.pblabs.engine.PBE;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class GUIComponent extends ScaleSpriteRenderer implements IMouseInputComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		private static var zeroPoint:Point = new Point();
		private static var _indexes:Object = {"mouseOut":0, "mouseOver":1, "mouseDown":2, "mouseUp":1};
		public static var SELECTED:String = "selected";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _target:BitmapData;
		private var _sourceRect:Rectangle;
		private var _stateDirty:Boolean;
		private var _state:String;
		
		protected var _enabled:Boolean = true;
		protected var _selected:Boolean = false;
		protected var _acceptDrop:Boolean;
		protected var _delegateContainer:DelegateContainer = new DelegateContainer();
		protected var _draggable:Boolean;
		protected var _priority:int;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get acceptDrop():Boolean
		{
			return _acceptDrop;
		}
		
		public function set acceptDrop(value:Boolean):void
		{
			_acceptDrop = value;
		}
		
		public function get delegateContainer():DelegateContainer
		{
			return _delegateContainer;
		}
		
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_stateDirty = true;
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function set priority(value:int):void
		{
			_priority = value;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if (_selected == value)
			{
				return;
			}
			_selected = value;
			_delegateContainer.call(SELECTED, value);
			_stateDirty = true;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			super.onAdd();
			PBE.mouseInputManager.addComponent(this);
			_delegateContainer.addCallback(MouseEvent.MOUSE_OVER, onMouse);
			_delegateContainer.addCallback(MouseEvent.MOUSE_OUT, onMouse);
			_delegateContainer.addCallback(MouseEvent.MOUSE_DOWN, onMouse);
			_delegateContainer.addCallback(MouseEvent.MOUSE_UP, onMouse);
		}
		
		protected override function onRemove():void
		{
			_target = null;
			_sourceRect = null;
			_state = null;
			_delegateContainer = null;
			_delegateContainer.clear();
			_delegateContainer = null;
			PBE.mouseInputManager.removeComponent(this);
			super.onRemove();
		}
		
		private function onMouse(data:MouseInputData):void
		{
			_state = data.type;
			_stateDirty = true;
			data.stopPropagation();
		}
		
		protected function updateState():void
		{
			if (_enabled)
			{
				if (!_indexes.hasOwnProperty(_state))
				{
					return;
				}
				_sourceRect.x = _target.width * _indexes[_state];
			}
			else
			{
				_sourceRect.x = _target.width * 3;
			}
			_sourceRect.y = _target.height * (_selected ? 1 : 0);
			_stateDirty = false;
			_transformDirty = true;
			_scaleDirty = true;
		}
		
		protected override function onImageLoadComplete():void
		{
			_sourceRect = new Rectangle(0, 0, int(_source.width * 0.25), int(_source.height * 0.5));
			_target = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
			_registrationPoint = new Point(_sourceRect.width * 0.5, _sourceRect.height * 0.5);
			_state = MouseEvent.MOUSE_OUT;
			_stateDirty = true;
		}
		
		public override function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			if (_stateDirty)
			{
				updateState();
			}
		}
		
		protected override function redraw():void
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
			trace(owner.name, "redraw", _state);
			
			_target.copyPixels(_source, _sourceRect, zeroPoint);
			
			var gridX:Array = [_scale9Grid.left, _scale9Grid.right, _target.width];
			var gridY:Array = [_scale9Grid.top, _scale9Grid.bottom, _target.height];
			
			var graphics:Graphics = (_displayObject as Sprite).graphics;
			
			graphics.clear();
			
			var left:Number = 0;
			for (var i:int = 0; i < 3; i++)
			{
				var top:Number = 0;
				for (var j:int = 0; j < 3; j++)
				{
					graphics.beginBitmapFill(_target);
					graphics.drawRect(left, top, gridX[i] - left, gridY[j] - top);
					graphics.endFill();
					top = gridY[j];
				}
				left = gridX[i];
			}
			_displayObject.scale9Grid = _scale9Grid;
			_scaleDirty = false;
		}
		
		public function canDrag(data:MouseInputData):Boolean
		{
			return _draggable;
		}
		
		public function canDrop(data:MouseInputData):Boolean
		{
			return false;
		}
		
		public function contains(point:Point):Boolean
		{
			return isRegistered ? pointOccupied(point, null) : false;
		}
	}

}
