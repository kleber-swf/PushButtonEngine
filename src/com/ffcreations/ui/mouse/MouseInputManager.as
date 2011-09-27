package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class MouseInputManager
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_STOP:String = "dragStop";
		public static const DRAG_MOVE:String = "dragMove";
		public static const DROP:String = "drop";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _components:Vector.<IMouseInputComponent> = new Vector.<IMouseInputComponent>();
		private var _lockedPriority:int;
		
		private var _mouseData:MouseInputData = new MouseInputData();
		private var _point:Point = new Point();
		
		// mouse move
		private var _mouseMoveOldList:Array = new Array();
		private var _mouseMoveNewList:Array = new Array();
		
		// drag and drop
		private var _mouseDownComponent:IMouseInputComponent;
		private var _initialDownLocalPosition:Point;
		private var _pixelsToStartDrag:int = 10;
		private var _initialDownScenePosition:Point;
		private var _dragStarted:Boolean = false;
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function MouseInputManager()
		{
			PBE.inputManager.addDelegateCallback(MouseEvent.MOUSE_DOWN, onMouseDown);
			PBE.inputManager.addDelegateCallback(MouseEvent.MOUSE_UP, onMouseUp);
			PBE.inputManager.addDelegateCallback(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			//TEMP
//			var t:Timer = new Timer(200, 0);
//			t.addEventListener(TimerEvent.TIMER, function tt(e:TimerEvent):void {
//				t.removeEventListener(TimerEvent.TIMER, tt);
//				t.stop();
//				t = null;
//				redraw();
//			});
//			
//			t.start();
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
//		/** TEMP */
//		public function redraw():void
//		{
//			var g:Graphics = PBE.mainClass.graphics;
//			g.clear();
//			for (var i:int = _components.length - 1; i >= 0; i--)
//			{
//				var c:MouseInputComponent = _components[i];
//				var a:Point = PBE.scene.transformSceneToScreen(new Point(c.sceneBounds.x, c.sceneBounds.y));
//				g.lineStyle(1, c.fc, 1);
//				g.beginFill(c.fc, 1);
//				g.drawRect(a.x, a.y, c.sceneBounds.width, c.sceneBounds.height);
//				g.endFill();
//			}
//		}
		
		public function lockInputUnderPriority(value:int):void
		{
			_lockedPriority = value;
		}
		
		public function addComponent(component:IMouseInputComponent):void
		{
			// TODO improve this linear search (maybe binary search?)
			var componentPriority:int = component.priority;
			for (var i:int = 0, len:int = _components.length; i < len; i++)
			{
				if (_components[i].priority < componentPriority)
				{
					_components.splice(i, 0, component);
					return;
				}
			}
			_components.push(component);
		}
		
		public function removeComponent(component:IMouseInputComponent):void
		{
			var index:int = _components.indexOf(component);
			if (index >= 0)
			{
				_components.splice(index, 1);
			}
			index = _mouseMoveOldList.indexOf(component);
			if (index >= 0) {
				_mouseMoveOldList.splice(index, 1);
			}
		}
		
		internal function updatePriority(component:IMouseInputComponent):void
		{
			removeComponent(component);
			addComponent(component);
		}
		
		private function setupComponentData(component:IMouseInputComponent, type:String):void
		{
			_mouseData.localPosition = _mouseData.scenePosition.subtract(component.position);
			_mouseData.component = component;
			_mouseData.type = type;
		}
		
		private function move():void
		{
			// Find all components that are under mouse scene position
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority <= component.priority && component != _mouseDownComponent && component.enabled && component.contains(_mouseData.scenePosition))
				{
					_mouseMoveNewList.push(component);
				}
			}
			
			// if there is no component under mouse scene position, then empties the old list
			if (_mouseMoveNewList.length == 0)
			{
				for each (component in _mouseMoveOldList)
				{
					setupComponentData(component, MouseEvent.MOUSE_OUT);
					component.delegateContainer.callDelegate(_mouseData.type, _mouseData);
				}
				_mouseMoveOldList.length = 0;
				_mouseMoveNewList.length = 0;
				return;
			}
			
			// for each component in new list: 
			var callMouseMove:Boolean = true;
			for each (component in _mouseMoveNewList)
			{
				var index:int = _mouseMoveOldList.indexOf(component);
				// if it's not in the old list, then mouse just entered (over)
				if (index < 0)
				{
					setupComponentData(component, MouseEvent.MOUSE_OVER);
					component.delegateContainer.callDelegate(_mouseData.type, _mouseData);
				}
				// if it's on the old list, then mouse is moving inside it
				else if (callMouseMove)
				{
					setupComponentData(component, MouseEvent.MOUSE_MOVE);
					callMouseMove = !component.delegateContainer.callDelegate(_mouseData.type, _mouseData);
				}
			}
			
			// for each component in old list:
			for each (component in _mouseMoveOldList)
			{
				// if it's not in the new list, then mouse just leave (out)
				if (_mouseMoveNewList.indexOf(component) < 0)
				{
					setupComponentData(component, MouseEvent.MOUSE_OUT);
					component.delegateContainer.callDelegate(_mouseData.type, _mouseData);
				}
			}
			_mouseMoveOldList = _mouseMoveNewList.slice();
			_mouseMoveNewList.length = 0;
		}
		
		private function drag():void
		{
			if (!_mouseDownComponent)
			{
				return;
			}
			if (_dragStarted)
			{
				_mouseData.localPosition = _initialDownLocalPosition;
				_mouseData.component = _mouseDownComponent;
				_mouseData.type = DRAG_MOVE;
				_mouseDownComponent.position = _mouseData.scenePosition.subtract(_initialDownLocalPosition);
				_mouseDownComponent.delegateContainer.callDelegate(_mouseData.type, _mouseData);
			}
			else
			{
				if (_initialDownScenePosition.subtract(_mouseData.scenePosition).length >= _pixelsToStartDrag)
				{
					_mouseData.localPosition = _initialDownLocalPosition;
					_mouseData.component = _mouseDownComponent;
					_mouseData.type = MouseEvent.MOUSE_MOVE;
					if (_mouseDownComponent.canDrag(_mouseData))
					{
						_dragStarted = true;
						_mouseData.type = DRAG_START;
						_mouseDownComponent.delegateContainer.callDelegate(_mouseData.type, _mouseData);
					}
				}
			}
		}
		
		private function drop():Boolean
		{
			var dropSuccess:Boolean = false;
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority <= component.priority && component != _mouseDownComponent && component.acceptDrop && component.enabled && component.contains(_mouseData.scenePosition))
				{
					_mouseData.component = _mouseDownComponent;
					_mouseData.type = DROP;
					_mouseData.localPosition = _mouseData.scenePosition.subtract(component.position);
					if (component.canDrop(_mouseData))
					{
						dropSuccess = true;
						var r:Boolean = component.delegateContainer.callDelegate(_mouseData.type, _mouseData);
						_mouseData.component = component;
						_mouseData.type = DRAG_STOP;
						_mouseDownComponent.delegateContainer.callDelegate(_mouseData.type, _mouseData);
						if (r)
						{
							break;
						}
					}
				}
			}
			if (!dropSuccess)
			{
				setupComponentData(_mouseDownComponent, DRAG_STOP);
				_mouseData.component = null;
				_mouseDownComponent.delegateContainer.callDelegate(_mouseData.type, _mouseData);
			}
			_dragStarted = false;
			_mouseDownComponent = null;
			return true;
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onMouseDown(event:MouseEvent):void
		{
			if (!PBE.scene)
			{
				return;
			}
			setupMouseData(event);
			
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority > component.priority)
				{
					break;
				}
				if (component.enabled && component.contains(_mouseData.scenePosition))
				{
					setupComponentData(component, event.type);
					if (component.draggable)
					{
						_mouseDownComponent = component;
						_mouseMoveOldList.splice(_mouseMoveOldList.indexOf(_mouseDownComponent), 1);
						_initialDownScenePosition = _mouseData.scenePosition;
						_initialDownLocalPosition = _mouseData.localPosition;
					}
					if (component.delegateContainer.callDelegate(_mouseData.type, _mouseData))
					{
						return;
					}
				}
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (!PBE.scene)
			{
				return;
			}
			setupMouseData(event);
			drag();
			move();
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			if (!PBE.scene)
			{
				return;
			}
			setupMouseData(event);
			
			if (_dragStarted)
			{
				drop();
			}
			_mouseDownComponent = null;
			
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority > component.priority)
				{
					break;
				}
				if (component.enabled && component.contains(_mouseData.scenePosition))
				{
					setupComponentData(component, event.type);
					if (component.delegateContainer.callDelegate(_mouseData.type, _mouseData))
					{
						return;
					}
				}
			}
		}
		
		
		private function setupMouseData(event:MouseEvent):void
		{
			_point.x = event.stageX;
			_point.y = event.stageY;
			
			//_mouseData.event = event;
			_mouseData.scenePosition = PBE.scene.transformScreenToScene(_point);
		}
	}
}
