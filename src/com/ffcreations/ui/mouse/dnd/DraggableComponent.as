package com.ffcreations.ui.mouse.dnd
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.ffcreations.ui.mouse.MouseInputComponent;
	
	/**
	 * <p>Component that controls the drag and drop action of an element.
	 * You must set the positionProperty and renderer properties of this component, otherwise it'll not work.</p>
	 *
	 * <p><ul>
	 * <li>When the mouse is pressed over a DraggableComponent, renderer.layerIndex is updated to DRAGGING_LAYER_INDEX and the drag action starts (onDragStart).</li>
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
		//   Static 
		//==========================================================
		
		/**
		 * Layer index that will be set automatically to renderer when a drag action starts.
		 * The old layer index will be restored on drop (when succeed or fails).
		 * Default value is int.MAX_VALUE, making the renderer always on top when dragging.
		 * @see #renderer
		 * @see #resetLayerIndex
		 * @default int.MAX_VALUE
		 */
		public static var DRAGGING_LAYER_INDEX:int = int.MAX_VALUE;
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
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
		
		private var _resetPositionProperty:PropertyReference;
		private var _resetPosition:Point;
		private var _oldLayerIndex:int;
		
		internal var dropArea:DropAreaComponent;
		
		
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
		public final function dropFail():Boolean
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
		
		internal function dropSuccess(dropArea:DropAreaComponent):Boolean
		{
			this.dropArea = dropArea;
			return onDropSuccess();
		}
		
		/**
		 * Called when drop action succeeds.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onDropSuccess():Boolean
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
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		/**
		 * Whether the element can be dragged or not. This method is called when the dragging action is about to start.
		 * @param event	The Flash MouseEvent associated (MouseEvent.MOUSE_DOWN).
		 * @return True if the element can be dragged or false otherwise.
		 */
		protected function canDrag(event:MouseEvent):Boolean
		{
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public override final function onMouseDown(event:MouseEvent):Boolean
		{
			if (!canDrag(event))
			{
				return false;
			}
			PBE.mouseInputManager.startDrag(this, lockCenter);
			if (renderer)
			{
				_oldLayerIndex = layerIndex;
			}
			if (dropArea)
			{
				dropArea.itemDragStarted(this);
			}
			
			return onStartDrag(event);
		}
		
		/**
		 * Called only when the component is dragged outside of a DropArea.
		 * The default action is fail.
		 * @param event	Flash MouseEvent (MouseEvent.MOUSE_UP).
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 * @see #dropFail
		 */
		public override function onMouseUp(event:MouseEvent):Boolean
		{
			return dropFail();
		}
		
		/**
		 * Called when the drag action just started.
		 * @param event	Flash MouseEvent (MouseEvent.MOUSE_DOWN).
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onStartDrag(event:MouseEvent):Boolean
		{
			return false;
		}
	}
}
