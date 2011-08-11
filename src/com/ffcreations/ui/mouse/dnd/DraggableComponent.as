package com.ffcreations.ui.mouse.dnd
{
	import com.ffcreations.ffc_internal;
	import com.ffcreations.ui.mouse.MouseInputComponent;
	import com.ffcreations.ui.mouse.MouseInputData;
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.geom.Point;
	
	use namespace ffc_internal;
	
	/**
	 * <p>Component that controls the drag and drop action of an element.
	 * You must set the positionProperty and renderer properties of this component, otherwise it'll not work.</p>
	 *
	 * <p><ul>
	 * <li>When the mouse is pressed over a DraggableComponent, renderer.layerIndex is updated to MouseInputManager.DragLayerIndex and the drag action starts (onDragStart).</li>
	 * <li>While the mouse is down, this component updates its positionProperty by the mouse current position.</li>
	 * <li>When the mouse is released over a DraggableComponent, the drop action fails (onDropFails) because no DropArea that acceps this component was found.</li>
	 * </ul></p>
	 *
	 * @see DropAreaComponent
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class DraggableComponent extends MouseInputComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _resetPositionProperty:PropertyReference;
		private var _resetPosition:Point;
		private var _oldLayerIndex:int;
		private var _oldLayerIndexProperty:PropertyReference;
		
		internal var dropArea:DropAreaComponent;
		
		/**
		 * Whether the drag component must lock the center of the dragged item in the mouse position.
		 */
		public var lockCenter:Boolean = false;
		
		/**
		 * Filters the DropArea acceptance.
		 * @see DropArea#accepts
		 */
		public var mask:String = "";
		
		/**
		 * Whether the component resets the position when drop fails.
		 */
		public var resetPositionOnDropFails:Boolean = true;
		
		public var finalPositionOffset:Point = new Point();
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Position where to put the component when drop fails.
		 */
		public function get resetPositionProperty():PropertyReference
		{
			return _resetPositionProperty;
		}
		
		/**
		 * @private
		 */
		public function set resetPositionProperty(value:PropertyReference):void
		{
			_resetPositionProperty = value;
			if (isRegistered && _resetPositionProperty)
			{
				_resetPosition = owner.getProperty(_resetPositionProperty, _resetPosition);
			}
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onRemove():void
		{
			super.onRemove();
			dropArea = null;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			if (isRegistered)
			{
				return;
			}
			if (!positionProperty)
			{
				var msg:String = "A positionProperty must be set.";
				Logger.error(this, "onAdd", msg);
				throw new Error(msg);
			}
			super.onAdd();
			_resetPosition = owner.getProperty(_resetPositionProperty ? _resetPositionProperty : positionProperty) as Point;
		}
		
		internal function replaced():void
		{
			dropFail();
			onReplaced();
		}
		
		/**
		 * Called when this item is replaced by another one by DropArea rules.
		 * @see DropArea#dropActionOnNotEmpty
		 */
		protected function onReplaced():void
		{
		}
		
		/**
		 * Called when drop action fails.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 * @see #onDropFail
		 */
		ffc_internal final function dropFail():Boolean
		{
			PBE.mouseInputManager.stopDrag();
			if (resetPositionOnDropFails)
			{
				owner.setProperty(positionProperty, _resetPosition);
			}
			resetLayerIndex();
			var passThrough:Boolean = onDropFail();
			dropArea = null;
			return passThrough;
		}
		
		/**
		 * Called when drop action fails.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onDropFail():Boolean
		{
			return false;
		}
		
		ffc_internal final function dropSuccess(dropArea:DropAreaComponent):Boolean
		{
			this.dropArea = dropArea;
			return onDropSuccess(dropArea);
		}
		
		/**
		 * Called when drop action succeeds.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onDropSuccess(dropArea:DropAreaComponent):Boolean
		{
			return false
		}
		
		/**
		 * Sets renderer.layerIndex. Saves the old layerIndex to reset.
		 * @param value Layer index to set.
		 */
		public function setRendererLayerIndex(value:int):void
		{
			if (renderer)
			{
				_oldLayerIndex = renderer.layerIndex;
				renderer.layerIndex = value;
				_oldLayerIndexProperty = renderer.layerIndexProperty;
				renderer.layerIndexProperty = null;
			}
		}
		
		/**
		 * Resets the renderer layerIndex.
		 */
		public function resetLayerIndex():void
		{
			if (renderer)
			{
				renderer.layerIndex = _oldLayerIndex;
				if (_oldLayerIndexProperty != null)
				{
					renderer.layerIndexProperty = _oldLayerIndexProperty;
					_oldLayerIndexProperty = null;
				}
			}
		}
		
		/**
		 * Updates the position of this element.
		 * @param value The new position.
		 * @see #positionProperty
		 * @see #position
		 */
		public function updatePosition(value:Point):void
		{
			if (positionProperty)
			{
				owner.setProperty(positionProperty, value);
			}
			else
			{
				position = value;
			}
		}
		
		/**
		 * Whether the element can be dragged or not. This method is called when the dragging action is about to start.
		 * @param data	Mouse data for this event.
		 * @return True if the element can be dragged or false otherwise.
		 */
		protected function canDrag(data:MouseInputData):Boolean
		{
			return true;
		}
		
		/**
		 * Whether the element can be dropped or not. This method is called when the drop action is about to start.
		 * @param data	Mouse data for this event.
		 * @return True if the element can be dropped or false otherwise.
		 */
		public function canDrop(data:MouseInputData):Boolean
		{
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onMouseDown(data:MouseInputData):Boolean
		{
			if (!canDrag(data))
			{
				return onDragFail(data);
			}
			PBE.mouseInputManager.startDrag(this, lockCenter);
			if (dropArea)
			{
				dropArea.itemDragStarted(this);
			}
			
			return onStartDrag(data);
		}
		
		/**
		 * Called when the drag action cannot be performed
		 * @param data	Mouse data for this event.
		 * @return Whether the event flow should pass through this component after its execution.
		 * @default true
		 */
		protected function onDragFail(data:MouseInputData):Boolean
		{
			return true;
		}
		
		/**
		 * Called only when the component is dragged outside of a DropArea.
		 * The default action is fail.
		 * @param data	Mouse data for this event.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 * @see #dropFail
		 */
		protected override function onMouseUp(data:MouseInputData):Boolean
		{
			return (PBE.mouseInputManager.dragComponent == this) ? dropFail() : true;
		}
		
		/**
		 * Called when the drag action just started.
		 * @param data	Mouse data for this event.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onStartDrag(data:MouseInputData):Boolean
		{
			return false;
		}
	}
}
