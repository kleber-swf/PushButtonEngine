package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
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
		
		private var _components:Array = new Array()//Vector has a very slow splice
		private var _lockedPriority:int;
		
		//private var _mouseData:MouseInputData;
		private var _scenePosition:Point = new Point();
		
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
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		
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
		//				var c:MouseInputComponent = _components[i] as MouseInputComponent;
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
			_components.splice(getInsertIndex(component.priority, 0, _components.length-1), 0, component);
		}
		
		private function getInsertIndex(priority:int, start:int, end:int):int
		{
			if (end <= start)
			{
				return start;
			}
			var middle:int = start + int((end - start) * 0.5);
			if (_components[middle].priority == priority)
			{
				return middle;
			}
			if (_components[middle].priority > priority)
			{
				return getInsertIndex(priority, middle + 1, end);
			}
			return getInsertIndex(priority, start, middle - 1);
		}
		
		public function removeComponent(component:IMouseInputComponent):void
		{
			var index:int = _components.indexOf(component);
			if (index >= 0)
			{
				_components.splice(index, 1);
			}
			index = _mouseMoveOldList.indexOf(component);
			if (index >= 0)
			{
				_mouseMoveOldList.splice(index, 1);
			}
		}
		
		internal function updatePriority(component:IMouseInputComponent):void
		{
			removeComponent(component);
			addComponent(component);
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function move(event:MouseEvent):void
		{
			// Find all components that are under mouse scene position
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority <= component.priority && component != _mouseDownComponent && component.enabled && component.contains(_scenePosition))
				{
					_mouseMoveNewList.push(component);
				}
			}
			
			// if there is no component under mouse scene position, then empties the old list
			if (_mouseMoveNewList.length == 0)
			{
				if (_mouseMoveOldList.length > 0)
				{
					for each (component in _mouseMoveOldList)
					{
						component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseEvent.MOUSE_OUT, event, component, _scenePosition));
					}
					_mouseMoveOldList.length = 0;
					_mouseMoveNewList.length = 0;
				}
				return;
			}
			
			// for each component in new list: 
			var callMouseMove:Boolean = true;
			var e:MouseInputEvent;
			for each (component in _mouseMoveNewList)
			{
				var index:int = _mouseMoveOldList.indexOf(component);
				// if it's not in the old list, then mouse just entered (over)
				if (index < 0)
				{
					e = new MouseInputEvent(MouseEvent.MOUSE_OVER, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
				}
				// if it's on the old list, then mouse is moving inside it
				else if (callMouseMove)
				{
					e = new MouseInputEvent(MouseEvent.MOUSE_MOVE, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					callMouseMove = !e._propagationStopped;
				}
			}
			
			// for each component in old list:
			for each (component in _mouseMoveOldList)
			{
				// if it's not in the new list, then mouse just leave (out)
				if (_mouseMoveNewList.indexOf(component) < 0)
				{
					component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseEvent.MOUSE_OUT, event, component, _scenePosition));
				}
			}
			_mouseMoveOldList = _mouseMoveNewList.slice();
			_mouseMoveNewList.length = 0;
		}
		
		private function drag(event:MouseEvent):void
		{
			if (!_mouseDownComponent)
			{
				return;
			}
			if (_dragStarted)
			{
				_mouseDownComponent.position = _scenePosition.subtract(_initialDownLocalPosition);
				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(DRAG_MOVE, event, _mouseDownComponent, _scenePosition));
			}
			else
			{
				if (_initialDownScenePosition.subtract(_scenePosition).length >= _pixelsToStartDrag)
				{
					if (_mouseDownComponent.canDrag(_mouseDownComponent))
					{
						_dragStarted = true;
						_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(DRAG_START, event, _mouseDownComponent, _scenePosition));
					}
				}
			}
		}
		
		private function drop(event:MouseEvent):void
		{
			var dropSuccess:Boolean = false;
			var e:MouseInputEvent;
			var p:Boolean;
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority <= component.priority && component != _mouseDownComponent && component.acceptDrop && component.enabled && component.contains(_scenePosition) && component.canDrop(_mouseDownComponent))
				{
					dropSuccess = true;
					e = new MouseInputEvent(DROP, event, _mouseDownComponent, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					p = e._propagationStopped;
					e = new MouseInputEvent(DRAG_STOP, event, _mouseDownComponent, _scenePosition);
					_mouseDownComponent.eventDispatcher.dispatchEvent(e);
					if (p || e._propagationStopped)
					{
						break;
					}
				}
			}
			if (!dropSuccess)
			{
				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(DRAG_STOP, event, null, _scenePosition));
			}
			_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseEvent.MOUSE_UP, event, _mouseDownComponent, _scenePosition));
			_dragStarted = false;
			_mouseDownComponent = null;
		}
		
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
				if (component.enabled && component.contains(_scenePosition))
				{
					var e:MouseInputEvent = new MouseInputEvent(event.type, event, component, _scenePosition);
					if (component.draggable)
					{
						_mouseDownComponent = component;
						_mouseMoveOldList.splice(_mouseMoveOldList.indexOf(_mouseDownComponent), 1);
						_initialDownScenePosition = _scenePosition;
						_initialDownLocalPosition = e.localPosition;
					}
					component.eventDispatcher.dispatchEvent(e);
					if (e._propagationStopped)
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
			drag(event);
			move(event);
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
				drop(event);
				return;
			}
			
			_mouseDownComponent = null;
			
			var e:MouseInputEvent;
			for each (var component:IMouseInputComponent in _components)
			{
				if (_lockedPriority > component.priority)
				{
					break;
				}
				if (component.enabled && component.contains(_scenePosition))
				{
					_mouseMoveOldList.push(component);
					e = new MouseInputEvent(event.type, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					if (e._propagationStopped)
					{
						return;
					}
				}
			}
		}
		
		
		private function setupMouseData(event:MouseEvent):void
		{
			_scenePosition.x = event.localX;
			_scenePosition.y = event.localY;
			_scenePosition = PBE.scene.transformScreenToScene(_scenePosition);
		}
	}
}
