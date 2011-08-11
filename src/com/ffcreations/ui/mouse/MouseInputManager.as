package com.ffcreations.ui.mouse
{
	import com.ffcreations.ffc_internal;
	import com.ffcreations.ui.mouse.dnd.DraggableComponent;
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
		
		public static var DragLayerIndex:int = 100;
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _components:Vector.<MouseInputComponent> = new Vector.<MouseInputComponent>();
		private var _dragCorrection:Point;
		private var _dragComponent:DraggableComponent;
		
		private var _currentMouseData:MouseInputData = new MouseInputData();
		
		
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
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		internal function addComponent(component:MouseInputComponent):void
		{
			// TODO improve this linear search (maybe bimary search?)
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
		 * @param component		The component to drag.
		 * @param lockCenter	Whether to lock the center of the component to the mouse position.
		 */
		public function startDrag(component:DraggableComponent, lockCenter:Boolean):void
		{
			_currentMouseData._component = _dragComponent = component;
			_currentMouseData._action = MouseInputData.MOUSE_DRAG;
			component.setRendererLayerIndex(DragLayerIndex);
			if (lockCenter)
			{
				_dragCorrection = new Point();
				component.updatePosition(_currentMouseData._scenePos);
			}
			else
			{
				_dragCorrection = component.scenePosition.subtract(_currentMouseData._scenePos);
			}
			PBE.mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
		}
		
		private function dropFail():void
		{
			if (_dragComponent)
			{
				_dragComponent.dropFail();
			}
			stopDrag();
		}
		
		/**
		 * Stops the dragging on the current dragging component.
		 */
		public function stopDrag():void
		{
			if (_dragComponent)
			{
				_dragComponent.resetLayerIndex();
				_dragComponent = null;
			}
			PBE.mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onDrag(event:MouseEvent):void
		{
			_currentMouseData._scenePos = PBE.scene.transformScreenToScene(new Point(event.stageX, event.stageY)).add(_dragCorrection);
			_dragComponent.updatePosition(_currentMouseData._scenePos);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_currentMouseData._scenePos = PBE.scene.transformScreenToScene(new Point(event.stageX, event.stageY))
			_currentMouseData._action = MouseInputData.MOUSE_DOWN;
			
			for each (var component:MouseInputComponent in _components)
			{
				if (component.contains(_currentMouseData._scenePos))
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
			var scenePos:Point = PBE.scene.transformScreenToScene(new Point(event.stageX, event.stageY));
			//if (_currentMouseDownComponent)
			//{
			//	if (_currentMouseDownComponent.contains(scenePos))
			//	{
			//		_currentMouseDownComponent._onMouseUp(_currentMouseData);
			//		if (!_currentMouseDownComponent.passThroughOnMouseUp)
			//		{
			//			_currentMouseDownComponent = null;
			//			_currentMouseDownPos = null;
			//			return;
			//		}
			//		i = _components.indexOf(_currentMouseDownComponent) + 1;
			//	}
			//	_currentMouseDownComponent = null;
			//}
			_currentMouseData._scenePos = scenePos;
			_currentMouseData._action = MouseInputData.MOUSE_UP;
			
			var component:MouseInputComponent;
			for (var len:int = _components.length; i < len; i++)
			{
				component = _components[i];
				if (component.contains(scenePos))
				{
					_currentMouseData._component = component;
					if (!component.mouseUp(_currentMouseData))
					{
						return;
					}
				}
			}
			dropFail();
		}
	}
}
