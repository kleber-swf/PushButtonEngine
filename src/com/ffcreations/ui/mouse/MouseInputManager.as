package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Manager for mouse inputs.
	 * Checks the mouse inputs (move, up and down) and redirects the event to the components
	 * under the mouse pointer.
	 *
	 * @see com.ffcreations.ui.mouse.MouseInputComponent
	 * @see com.ffcreations.ui.mouse.MouseInputEvent
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class MouseInputManager
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _components:Array = new Array();
		private var _lockedPriority:int;
		
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
		
		/**
		 * Called once and automatically by PBE class.
		 * @see com.pblabs.engine.PBE#mouseInputManager
		 */
		public function MouseInputManager()
		{
			//PBE.mainStage.mouseChildren = false;
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * Adds a <code>IMouseInputComponent</code> to the components list.
		 * Only componentes added to this list is verified to respond to mouse inputs
		 * @param component The <code>IMouseInputComponent</code> to add;
		 */
		public function addComponent(component:IMouseInputComponent):void
		{
			if (_components.indexOf(component) < 0)
			{
				_components.splice(getInsertIndex(component.priority, 0, _components.length - 1), 0, component);
			}
		}
		
		private function getInsertIndex(priority:int, start:int, end:int):int
		{
			if (end <= start)
			{
				return (start == _components.length - 1 && _components[start].priority > priority) ? start + 1 : start;
			}
			var middle:int = start + Math.round((end - start) * 0.5);
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
		
		/**
		 * Removes a <code>IMouseInputComponent</code> from the components list.
		 * @param component The <code>IMouseInputComponent</code> to remove;
		 */
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
		
		/**
		 * Updates the priority of the given <code>IMouseInputComponent</code> in the
		 * components list.
		 * @param component The <code>IMouseComponent</code> which the priority was updated.
		 */
		public function updatePriority(component:IMouseInputComponent):void
		{
			removeComponent(component);
			addComponent(component);
		}
		
		/**
		 * Locks the input lower then the given value.
		 * @param value Minimum priority that components has to have to respond to mouse events.
		 * @default 0
		 */
		public function lockInputUnderPriority(value:int):void
		{
			_lockedPriority = value;
		}
		
		internal function getComponents():Array
		{
			return _components;
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
						component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_OUT, event, component, _scenePosition));
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
					e = new MouseInputEvent(MouseInputEvent.MOUSE_OVER, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
				}
				// if it's on the old list, then mouse is moving inside it
				else if (callMouseMove)
				{
					e = new MouseInputEvent(MouseInputEvent.MOUSE_MOVE, event, component, _scenePosition);
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
					component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_OUT, event, component, _scenePosition));
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
				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_MOVE, event, _mouseDownComponent, _scenePosition));
			}
			else
			{
				if (_initialDownScenePosition.subtract(_scenePosition).length >= _pixelsToStartDrag)
				{
					if (_mouseDownComponent.canDrag())
					{
						_dragStarted = true;
						_mouseDownComponent.dragging = true;
						if (_mouseDownComponent.container)
						{
							_mouseDownComponent.container.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.ITEM_DRAG_START, event, _mouseDownComponent, _scenePosition));
							_mouseDownComponent.container = null;
						}
						_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_START, event, _mouseDownComponent, _scenePosition));
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
					e = new MouseInputEvent(MouseInputEvent.DROP, event, _mouseDownComponent, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					p = e._propagationStopped;
					_mouseDownComponent.dragging = false;
					_mouseDownComponent.container = component;
					e = new MouseInputEvent(MouseInputEvent.DRAG_STOP, event, component, _scenePosition);
					_mouseDownComponent.eventDispatcher.dispatchEvent(e);
					if (p || e._propagationStopped)
					{
						break;
					}
				}
			}
			if (!dropSuccess)
			{
				_mouseDownComponent.dragging = false;
				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_STOP, event, null, _scenePosition));
				_mouseDownComponent.container = null;
			}
			if (_mouseDownComponent.eventDispatcher)
			{
				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_UP, event, _mouseDownComponent, _scenePosition));
			}
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
						_initialDownScenePosition = _scenePosition.clone();
						_initialDownLocalPosition = e.localPosition.clone();
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
					if (_mouseMoveOldList.indexOf(component) < 0)
					{
						_mouseMoveOldList.push(component);
					}
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
