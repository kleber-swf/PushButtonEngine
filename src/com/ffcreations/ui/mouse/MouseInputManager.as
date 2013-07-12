package com.ffcreations.ui.mouse {
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
	public class MouseInputManager {
		
		private var _components:Array = new Array();
		private var _lockedPriority:int;
		
		private var _scenePosition:Point = new Point();
		
		// mouse move
		private var _mouseMoveOldList:Array = new Array();
		private var _mouseMoveNewList:Array = new Array();
		
		// drag and drop
		private var _mouseDragComponent:IMouseInputComponent;
		private var _initialDownLocalPosition:Point;
		private var _pixelsToStartDrag:int = 10;
		private var _initialDownScenePosition:Point;
		private var _dragStarted:Boolean = false;
		private var _mouseDownComponent:IMouseInputComponent;
		
		/**
		 * Locks the input lower then the given value.
		 * @param value Minimum priority that components has to have to respond to mouse events.
		 * @default 0
		 */
		public function get lockedPriority():int { return _lockedPriority; }
		
		/** @private */
		public function set lockedPriority(value:int):void { _lockedPriority = value; }
		
		/**
		 * Called once and automatically by PBE class.
		 * @see com.pblabs.engine.PBE#mouseInputManager
		 */
		public function MouseInputManager() {
			//PBE.mainStage.mouseChildren = false;
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			PBE.inputManager.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		/**
		 * Adds a <code>IMouseInputComponent</code> to the components list.
		 * Only componentes added to this list is verified to respond to mouse inputs
		 * @param component The <code>IMouseInputComponent</code> to add;
		 */
		public function addComponent(component:IMouseInputComponent):void {
			if (_components.indexOf(component) < 0)
				_components.splice(getInsertIndex(component.priority, 0, _components.length - 1), 0, component);
			//			var s:String = component.priority.toString() + ":";
			//			for each (var d:IMouseInputComponent in _components) {
			//				s += " " + d.priority.toString();
			//			}
			//			trace(s);
		}
		
		private function getInsertIndex(priority:int, start:int, end:int):int {
			if (end <= start) {
				return (_components.length > start && _components[start].priority > priority) ? start + 1 : start;
					//return (start == _components.length - 1 || (_components.length > start && _components[start].priority > priority)) ? start + 1 : start;
			}
			var middle:int = start + Math.round((end - start) * 0.5);
			if (_components[middle].priority == priority)
				return middle;
			if (_components[middle].priority > priority)
				return getInsertIndex(priority, middle + 1, end);
			return getInsertIndex(priority, start, middle - 1);
		}
		
		/**
		 * Removes a <code>IMouseInputComponent</code> from the components list.
		 * @param component The <code>IMouseInputComponent</code> to remove;
		 */
		public function removeComponent(component:IMouseInputComponent):void {
			var index:int = _components.indexOf(component);
			if (index >= 0)
				_components.splice(index, 1);
			index = _mouseMoveOldList.indexOf(component);
			if (index >= 0)
				_mouseMoveOldList.splice(index, 1);
		}
		
		/**
		 * Updates the priority of the given <code>IMouseInputComponent</code> in the
		 * components list.
		 * @param component The <code>IMouseComponent</code> which the priority was updated.
		 */
		public function updatePriority(component:IMouseInputComponent):void {
			removeComponent(component);
			addComponent(component);
		}
		
		internal function getComponents():Array {
			return _components;
		}
		
		private function move(event:MouseEvent):void {
			// Find all components that are under mouse scene position
			for each (var component:IMouseInputComponent in _components) {
				if (_lockedPriority <= component.priority && component != _mouseDragComponent && component.enabled && component.contains(_scenePosition))
					_mouseMoveNewList.push(component);
			}
			
			// if there is no component under mouse scene position, then empties the old list
			if (_mouseMoveNewList.length == 0) {
				if (_mouseMoveOldList.length > 0) {
					for each (component in _mouseMoveOldList)
						component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_OUT, event, component, _scenePosition));
					_mouseMoveOldList.length = 0;
					_mouseMoveNewList.length = 0;
				}
				return;
			}
			
			// for each component in new list: 
			var callMouseMove:Boolean = true;
			var e:MouseInputEvent;
			for each (component in _mouseMoveNewList) {
				var index:int = _mouseMoveOldList.indexOf(component);
				// if it's not in the old list, then mouse just entered (over)
				if (index < 0) {
					e = new MouseInputEvent(MouseInputEvent.MOUSE_OVER, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
				}
				// if it's on the old list, then mouse is moving inside it
				else if (callMouseMove) {
					e = new MouseInputEvent(MouseInputEvent.MOUSE_MOVE, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					callMouseMove = !e._propagationStopped;
				}
			}
			
			// for each component in old list:
			for each (component in _mouseMoveOldList) {
				// if it's not in the new list, then mouse just leave (out)
				if (_mouseMoveNewList.indexOf(component) < 0)
					component.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_OUT, event, component, _scenePosition));
			}
			_mouseMoveOldList = _mouseMoveNewList.slice();
			_mouseMoveNewList.length = 0;
		}
		
		private function drag(event:MouseEvent):void {
			if (!_mouseDragComponent)
				return;
			if (_dragStarted) {
				_mouseDragComponent.position = _scenePosition.subtract(_initialDownLocalPosition);
				_mouseDragComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_MOVE, event, _mouseDragComponent, _scenePosition));
			} else {
				if (_initialDownScenePosition.subtract(_scenePosition).length >= _pixelsToStartDrag) {
					if (_mouseDragComponent.canDrag()) {
						_dragStarted = true;
						_mouseDragComponent.dragging = true;
						if (_mouseDragComponent.container) {
							_mouseDragComponent.container.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.ITEM_DRAG_START, event, _mouseDragComponent, _scenePosition));
							_mouseDragComponent.container = null;
						}
						_mouseDragComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_START, event, _mouseDragComponent, _scenePosition));
					}
				}
			}
		}
		
		private function drop(event:MouseEvent):void {
			var dropSuccess:Boolean = false;
			var e:MouseInputEvent;
			var p:Boolean;
			for each (var component:IMouseInputComponent in _components) {
				if (_lockedPriority <= component.priority && component != _mouseDragComponent && component.enabled && component.contains(_scenePosition) && component.acceptDrop && _mouseDragComponent.
					canDrop && component.canDropItem(_mouseDragComponent)) {
					dropSuccess = true;
					e = new MouseInputEvent(MouseInputEvent.DROP, event, _mouseDragComponent, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					p = e._propagationStopped;
					_mouseDragComponent.dragging = false;
					_mouseDragComponent.container = component;
					e = new MouseInputEvent(MouseInputEvent.DRAG_STOP, event, component, _scenePosition);
					_mouseDragComponent.eventDispatcher.dispatchEvent(e);
					if (p || e._propagationStopped)
						break;
				}
			}
			if (!dropSuccess) {
				_mouseDragComponent.dragging = false;
				_mouseDragComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.DRAG_STOP, event, null, _scenePosition));
				_mouseDragComponent.container = null;
			}
			//			if (_mouseDownComponent.eventDispatcher)
			//			{
			//				_mouseDownComponent.eventDispatcher.dispatchEvent(new MouseInputEvent(MouseInputEvent.MOUSE_UP, event, _mouseDownComponent, _scenePosition));
			//			}
			_dragStarted = false;
			_mouseDragComponent = null;
		}
		
		private function onMouseDown(event:MouseEvent):void {
			if (!PBE.scene)
				return;
			setupMouseData(event);
			
			for each (var component:IMouseInputComponent in _components) {
				if (_lockedPriority > component.priority)
					return;
				if (component.enabled && component.contains(_scenePosition)) {
					var e:MouseInputEvent = new MouseInputEvent(event.type, event, component, _scenePosition);
					if (component.draggable) {
						_mouseDragComponent = component;
						_mouseMoveOldList.splice(_mouseMoveOldList.indexOf(_mouseDragComponent), 1);
						_initialDownScenePosition = _scenePosition.clone();
						_initialDownLocalPosition = _mouseDragComponent.lockCenter ? new Point() : e.localPosition.clone();
					}
					_mouseDownComponent = component;
					component.eventDispatcher.dispatchEvent(e);
					if (e._propagationStopped)
						return;
				}
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if (!PBE.scene)
				return;
			setupMouseData(event);
			drag(event);
			if (PBE.inputManager.mouseOverEnabled && PBE.inputManager.mouseOutEnabled)
				move(event);
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if (!PBE.scene)
				return;
			setupMouseData(event);
			
			if (_dragStarted) {
				drop(event);
				return;
			}
			
			_mouseDragComponent = null;
			
			if (_mouseDownComponent != null) {
				if (_mouseDownComponent.contains(_scenePosition)) {
					if (_mouseDownComponent.enabled) {
						if (_mouseMoveOldList.indexOf(_mouseDownComponent) < 0)
							_mouseMoveOldList.push(_mouseDownComponent);
						e = new MouseInputEvent(event.type, event, _mouseDownComponent, _scenePosition);
						_mouseDownComponent.eventDispatcher.dispatchEvent(e);
						if (e._propagationStopped)
							return;
					}
				} else
					_mouseDownComponent.cancelInput();
				_mouseDownComponent = null;
				return;
			}
			
			var e:MouseInputEvent;
			for each (var component:IMouseInputComponent in _components) {
				if (_lockedPriority > component.priority)
					return;
				if (component.enabled && component.contains(_scenePosition)) {
					if (_mouseMoveOldList.indexOf(component) < 0)
						_mouseMoveOldList.push(component);
					e = new MouseInputEvent(event.type, event, component, _scenePosition);
					component.eventDispatcher.dispatchEvent(e);
					if (e._propagationStopped)
						return;
				}
			}
		}
		
		private function setupMouseData(event:MouseEvent):void {
			_scenePosition.x = event.localX;
			_scenePosition.y = event.localY;
			_scenePosition = PBE.scene.transformScreenToScene(_scenePosition);
		}
	}
}
