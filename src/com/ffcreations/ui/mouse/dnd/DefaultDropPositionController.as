package com.ffcreations.ui.mouse.dnd
{
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.geom.Point;
	
	public class DefaultDropPositionController implements IDropPositionController
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		/**
		 * If set, put the DraggableComponent in this position when the drop succeeds.
		 */
		public var finalPositionProperty:PropertyReference;
		
		/**
		 * If set, adds this offset to the DraggableComponent position.
		 */
		public var finalPositionOffset:Point = new Point();
		
		private var _dropArea:DropAreaComponent;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function set dropArea(value:DropAreaComponent):void
		{
			_dropArea = value;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function dropItem(items:Vector.<DraggableComponent>, addIndex:int, removeIndex:int):void
		{
			for (var i:int = addIndex; i < items.length; i++)
			{
				var pos:Point;
				if (finalPositionProperty)
				{
					pos = _dropArea.owner.getProperty(finalPositionProperty) as Point;
				}
				else
				{
					pos = _dropArea.scenePosition;
				}
				items[i].updatePosition(pos.add(finalPositionOffset));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function dragItem(items:Vector.<DraggableComponent>, index:int):void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndexAt(items:Vector.<DraggableComponent>, pos:Point):int
		{
			return -1;
		}
	}
}
