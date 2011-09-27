package com.ffcreations.ui.mouse.old.dnd
{
	import flash.geom.Point;
	
	/**
	 * Organizes a <code>DropArea</code> in a grid.
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public class GridDropPositionController implements IDropPositionController
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _cols:int = 1;
		private var _offset:Point = new Point();
		private var _initialPos:Point = new Point();
		private var _dropArea:DropAreaComponent;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Number of columns of the grid
		 */
		public function get cols():int
		{
			return _cols;
		}
		
		/**
		 * @private
		 */
		public function set cols(value:int):void
		{
			_cols = value;
			//TODO update positions
		}
		
		/**
		 * @inheritDoc
		 */
		public function set dropArea(value:DropAreaComponent):void
		{
			_dropArea = value;
		}
		
		/**
		 * Initial position of the grid. Relative to the dropArea position.
		 * @default (0,0)
		 */
		public function get initialPos():Point
		{
			return _initialPos;
		}
		
		/**
		 * @private
		 */
		public function set initialPos(value:Point):void
		{
			_initialPos = value;
		}
		
		/**
		 * Offset between each item on the grid.
		 * @default (0,0)
		 */
		public function get offset():Point
		{
			return _offset;
		}
		
		/**
		 * @private
		 */
		public function set offset(value:Point):void
		{
			_offset = value;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function dropItem(items:Vector.<DraggableComponent>, addIndex:int, removeIndex:int):void
		{
			updatePositions(items, (removeIndex < 0 || removeIndex >= addIndex) ? addIndex : 0);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dragItem(items:Vector.<DraggableComponent>, index:int):void
		{
			updatePositions(items, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndexAt(items:Vector.<DraggableComponent>, pos:Point):int
		{
			//if (!autoOrganize)
			//{
			//	var position:Point = pos.subtract(dropArea.scenePosition.add(initialPos));
			//	var row:int = int(position.y / offset.y);
			//	var col:int = int(position.x / offset.x);
			//	if (col > cols-1) {
			//		
			//	}
			//	var p:int = row * cols + col;
			//	return p;
			//}
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i].contains(pos))
				{
					return i;
				}
			}
			return -1;
		}
		
		private function updatePositions(items:Vector.<DraggableComponent>, startIndex:int):void
		{
			var position:Point = _dropArea.scenePosition.add(_initialPos);
			for (var i:int = startIndex; i < items.length; i++)
			{
				var row:int = int(i / cols);
				var col:int = (i % cols);
				items[i].updatePosition(position.add(new Point(_offset.x * col, _offset.y * row)));
			}
		}
		
		public function clear():void
		{
			_dropArea = null;
		}
	}
}
