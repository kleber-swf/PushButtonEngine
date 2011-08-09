package com.ffcreations.ui.mouse.dnd
{
	import flash.geom.Point;
	
	/**
	 * Interface to position controllers of <code>DropArea</code>s.
	 * @see DropArea
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public interface IDropPositionController
	{
		/**
		 * Sets the DropArea for this controller.
		 */
		function set dropArea(value:DropAreaComponent):void;
		
		/**
		 * Called when an item is just dropped on the given <code>DropArea</code>.
		 * @param dropArea		DropArea that contains this controller.
		 * @param items			Complete items list.
		 * @param addIndex		Index (from items list) where an item is added.
		 * @param removeIndex	Index (from items list) where an item is removed (when replaced).
		 *
		 * @see DropArea#dropOnEmptySpace
		 * @see DropArea#dropOnOccupiedSpace
		 * @see DropArea#dropWhenFull
		 */
		function dropItem(items:Vector.<DraggableComponent>, addIndex:int, removeIndex:int):void;
		
		/**
		 * Called when an item is just dragged on the given <code>DropArea</code>. The item is removed from the list before this method is called.
		 * @param dropArea		DropArea that contains this controller.
		 * @param items			Complete items list.
		 * @param index			Index (from items list) where the item was before the drag action.
		 */
		function dragItem(items:Vector.<DraggableComponent>, index:int):void;
		
		/**
		 * Gets the item at the given position.
		 * @param dropArea	DropArea that contains this controller.
		 * @param items		Complete items list.
		 * @param pos		Position to verify.
		 * @return The index of the item that contains <code>pos</code>.
		 */
		function getItemIndexAt(items:Vector.<DraggableComponent>, pos:Point):int;
		
		/**
		 * Called when the related DropAreaComponent is removed from its owner.
		 */
		function clear():void;
	}
}
