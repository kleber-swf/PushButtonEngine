package com.ffcreations.ui.mouse
{
	import com.ffcreations.ffc_internal;
	import com.ffcreations.ui.mouse.dnd.DraggableComponent;
	import com.ffcreations.ui.mouse.dnd.DropAreaComponent;
	import com.pblabs.engine.PBE;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	use namespace ffc_internal;
	
	/**
	 * <p>Manages the mouse input. Just mouse up, mouse down and mouse drag.</p>
	 *
	 * <p>When mouse is pressed or released, it verifies (using MouseInputComponent.layerIndex) wich of its components (MouseInputComponents) was clicked. The first component (highest layerIndex) under the mouse pointer is returned.<br />
	 * If the result MouseInputComponent tells to passThrough after its execution, the MouseInputManager continues to check for other elements that is under the mouse position.</p>
	 *
	 * @see MouseInputComponent
	 * @see DropAreaComponent
	 * @see DraggableComponent
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public final class MouseInputManager
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static var DragLayerIndex:uint = 100;
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _components:Vector.<MouseInputComponent> = new Vector.<MouseInputComponent>();
		private var _dragCorrection:Point;
		private var _dragComponent:DraggableComponent;
		
		private var _currentMouseData:MouseInputData = new MouseInputData();
		private var _pixelsToStartDrag:uint;
		private var _positionBeforeDrag:Point = new Point();
		private var _bufferPoint:Point = new Point();
		private var _lockLayer:int = 0;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Gets the current DraggableComponent.
		 */
		ffc_internal function get dragComponent():DraggableComponent
		{
			return _dragComponent;
		}
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		/**
		 * Listen to the mouse events on the stages.
		 */
		public function MouseInputManager()
		{
			//			PBE.mainStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//			PBE.mainStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			PBE.inputManager.addDelegateCallback(MouseEvent.MOUSE_DOWN, onMouseDown);
			PBE.inputManager.addDelegateCallback(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public function lockLayersUnder(layer:int):void
		{
			_lockLayer = layer;
		}
		
		internal function addComponent(component:MouseInputComponent):void
		{
			// TODO improve this linear search (maybe binary search?)
			var index:int = component.layerIndex;
			for (var i:int = 0, len:int = _components.length; i < len; i++)
			{
				if (_components[i].layerIndex < index)
				{
					_components.splice(i, 0, component);
					return;
				}
			}
			_components.push(component);
		}
		
		internal function removeComponent(component:MouseInputComponent):void
		{
			var index:int = _components.indexOf(component);
			if (index >= 0)
			{
				_components.splice(index, 1);
			}
		}
		
		internal function updateLayerIndex(component:MouseInputComponent):void
		{
			removeComponent(component);
			addComponent(component);
		}
		
		/**
		 * Starts drag the given component.
		 * @param component			The component to drag.
		 * @param lockCenter		Whether to lock the center of the component to the mouse position.
		 * @param pixelsToStartDrag	Amout of pixels that the user should drag before the drag actually starts.
		 */
		ffc_internal function startDrag(component:DraggableComponent, lockCenter:Boolean, pixelsToStartDrag:uint):void
		{
			_currentMouseData._component = component;
			_currentMouseData._action = MouseInputData.MOUSE_DOWN;
			_currentMouseData.lockCenter = lockCenter;
			_positionBeforeDrag.x = _currentMouseData._event.stageX;
			_positionBeforeDrag.y = _currentMouseData._event.stageY;
			_pixelsToStartDrag = pixelsToStartDrag;
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onBeforeDrag);
		}
		
		private function dropFail():void
		{
			if (_dragComponent)
			{
				_dragComponent.dropFail();
				_dragComponent = null;
			}
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onBeforeDrag);
		}
		
		ffc_internal function stopDrag():void
		{
			if (_dragComponent)
			{
				_dragComponent.stopDrag();
				_dragComponent = null;
			}
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onBeforeDrag);
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private final function onBeforeDrag(event:MouseEvent):void
		{
			_bufferPoint.x = event.stageX;
			_bufferPoint.y = event.stageY;
			if (_positionBeforeDrag.subtract(_bufferPoint).length < _pixelsToStartDrag)
			{
				return;
			}
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onBeforeDrag);
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			_currentMouseData._action = MouseInputData.MOUSE_DRAG;
			_dragComponent = _currentMouseData._component as DraggableComponent;
			_dragComponent.startDrag(_currentMouseData, DragLayerIndex);
			if (_currentMouseData.lockCenter)
			{
				_dragCorrection = new Point();
				_dragComponent.drag(_currentMouseData);
			}
			else
			{
				_dragCorrection = _dragComponent.scenePosition.subtract(_currentMouseData._scenePos);
			}
		}
		
		private final function onDrag(event:MouseEvent):void
		{
			_bufferPoint.x = event.stageX;
			_bufferPoint.y = event.stageY;
			_currentMouseData._scenePos = PBE.scene.transformScreenToScene(_bufferPoint).add(_dragCorrection);
			_dragComponent.drag(_currentMouseData);
		}
		
		private final function onMouseDown(event:MouseEvent):void
		{
			_bufferPoint.x = event.stageX;
			_bufferPoint.y = event.stageY;
			var scenePos:Point = _currentMouseData._scenePos = PBE.scene.transformScreenToScene(_bufferPoint);
			_currentMouseData._action = MouseInputData.MOUSE_DOWN;
			_currentMouseData._event = event;
			
			for each (var component:MouseInputComponent in _components)
			{
				if (_lockLayer > component.layerIndex)
				{
					break;
				}
				if (component.enabled && component.visible && component.contains(scenePos))
				{
					if (!component.mouseDown(_currentMouseData))
					{
						_currentMouseData._component = component;
						return;
					}
				}
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			var i:int = 0;
			var len:int;
			var component:MouseInputComponent;
			_bufferPoint.x = event.stageX;
			_bufferPoint.y = event.stageY;
			var scenePos:Point = _currentMouseData._scenePos = PBE.scene.transformScreenToScene(_bufferPoint);
			_currentMouseData._action = MouseInputData.MOUSE_UP;
			
			// Handle drop
			if (_dragComponent != null)
			{
				_currentMouseData._component = _dragComponent;
				for (len = _components.length; i < len; i++)
				{
					component = _components[i];
					if (component is DropAreaComponent && component.enabled && component.visible && component.contains(scenePos))
					{
						if (!component.mouseUp(_currentMouseData))
						{
							return;
						}
					}
				}
				dropFail();
				return;
			}
			
			//TODO this shouldn't be inside the "Handle drop" statement?
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onBeforeDrag);
			
			i = 0;
			for (len = _components.length; i < len; i++)
			{
				component = _components[i];
				if (_lockLayer > component.layerIndex)
				{
					break;
				}
				if (component.enabled && component.visible && component.contains(scenePos))
				{
					_currentMouseData._component = component;
					if (!component.mouseUp(_currentMouseData))
					{
						return;
					}
				}
			}
		}
	}
}
