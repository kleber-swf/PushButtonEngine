package com.ffcreations.ui.components
{
	import com.ffcreations.rendering2D.ScaleSpriteRenderer;
	import com.ffcreations.ui.mouse.IMouseInputComponent;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.utils.StringUtil;
	
	public class GUIComponent extends ScaleSpriteRenderer implements IMouseInputComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		private static var zeroPoint:Point = new Point();
		public static var SELECTED:String = "selected";
		
		private static var _componentStates:Array = new Array("normal", "selected");
		private static var _mouseStates:Object = {"out":"mouseOut", "over":"mouseOver", "down":"mouseDown", "disabled":"disabled"};
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _states:Object = {"normal:mouseOut":0,
				"normal:mouseOver":1,
				"normal:mouseUp":1,
				"normal:mouseDown":2,
				"normal:disabled":3,
				"selected:mouseOut":4,
				"selected:mouseUp":4,
				"selected:mouseOver":5,
				"selected:mouseDown":6,
				"selected:disabled":7};
		
		private var _target:BitmapData;
		private var _sourceRect:Rectangle;
		private var _stateDirty:Boolean;
		private var _state:String;
		private var _grid:Point = new Point(4, 2);
		private var _visible:Boolean = true;
		
		protected var _enabled:Boolean = true;
		protected var _selected:Boolean = false;
		protected var _acceptDrop:Boolean;
		protected var _draggable:Boolean;
		protected var _priority:int;
		protected var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		
		
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
			return _enabled && _alpha > 0;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_stateDirty = true;
		}
		
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		/**
		 * (xCount, yCount) or (columns, rows)
		 */
		public function set imageDivider(value:Point):void
		{
			_grid = value;
			updateSourceRect();
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function set priority(value:int):void
		{
			_priority = value;
			if (isRegistered)
			{
				PBE.mouseInputManager.updatePriority(this);
			}
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
			_eventDispatcher.dispatchEvent(new Event(SELECTED));
			// TODO pass value to the event
			_stateDirty = true;
		}
		
		public function set states(value:String):void
		{
			var states:Array = value.split(",");
			_states = new Object();
			for (var i:int = 0; i < states.length; i++)
			{
				var state:String = states[i];
				var s:Array = state.split(":");
				if (s.length != 2)
				{
					Logger.warn(this, "states", "There is an error on indexes near '" + state + "'.");
					continue;
				}
				var csi:int = _componentStates.indexOf(StringUtil.trim(s[0]));
				var st:String = StringUtil.trim(s[1]);
				if (csi < 0 || !_mouseStates.hasOwnProperty(st))
				{
					Logger.warn(this, "states", "Wrong state: '" + state + "'.");
					continue;
				}
				_states[_componentStates[csi] + ":" + _mouseStates[st]] = i;
				if (st == "over")
				{
					_states[_componentStates[csi] + ":mouseUp"] = i;
				}
			}
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			if (_visible == value)
			{
				return;
			}
			_visible = value;
			alpha = value ? 1 : 0;
			if (value)
			{
				PBE.mouseInputManager.addComponent(this);
			}
			else
			{
				PBE.mouseInputManager.removeComponent(this);
			}
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			super.onAdd();
			if (_visible)
			{
				PBE.mouseInputManager.addComponent(this);
			}
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_UP, onMouse, false, int.MIN_VALUE, true);
		}
		
		protected override function onRemove():void
		{
			_target = null;
			_sourceRect = null;
			_state = null;
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_OVER, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_OUT, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			PBE.mouseInputManager.removeComponent(this);
			super.onRemove();
		}
		
		protected function updateState():void
		{
			if (!_sourceRect)
			{
				return;
			}
			var state:String;
			if (_enabled)
			{
				state = (_selected ? "selected" : "normal") + ":" + _state;
			}
			else
			{
				state = (_selected ? "selected" : "normal") + ":disabled";
			}
			
			if (_states.hasOwnProperty(state))
			{
				var index:int = _states[state];
				_sourceRect.x = int(_target.width * (index % _grid.x));
				_sourceRect.y = int(_target.height * int(index / _grid.x));
				_transformDirty = true;
				_scaleDirty = true;
			}
			
			_stateDirty = false;
		}
		
		protected override function onImageLoadComplete():void
		{
			updateSourceRect();
			_state = MouseEvent.MOUSE_OUT;
			_stateDirty = true;
		}
		
		private function updateSourceRect():void
		{
			if (!_source)
			{
				return;
			}
			_sourceRect = new Rectangle(0, 0, int(_source.width * (1 / _grid.x)), int(_source.height * (1 / _grid.y)));
			_target = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
			_registrationPoint = new Point(_sourceRect.width * 0.5, _sourceRect.height * 0.5);
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
			if (!isRegistered || !_source || !_target)
			{
				return;
			}
			if (!_scale9Grid)
			{
				_displayObject.scale9Grid = null;
				return;
			}
			
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
		
		public function canDrag(component:IMouseInputComponent):Boolean
		{
			return _draggable;
		}
		
		public function canDrop(component:IMouseInputComponent):Boolean
		{
			return false;
		}
		
		public function contains(point:Point):Boolean
		{
			return isRegistered ? pointOccupied(point, null) : false;
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onMouse(data:MouseInputEvent):void
		{
			_state = data.type;
			_stateDirty = true;
			data.stopImmediatePropagation();
		}
	}

}
