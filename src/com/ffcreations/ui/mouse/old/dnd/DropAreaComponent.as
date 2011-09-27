
package com.ffcreations.ui.mouse.old.dnd
{
	import com.ffcreations.ffc_internal;
	import com.ffcreations.ui.mouse.old.MouseInputComponent;
	import com.ffcreations.ui.mouse.old.MouseInputData;
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	import flash.geom.Point;
	
	use namespace ffc_internal;
	
	/**
	 * <p>An area to drop DraggableItems.</p>
	 * <p>When a DropArea is created, it is placed above all other MouseInputComponents, because it must be the first to process an mouse event.</p>
	 * <p>It works with three rules, that tells what to do when the user drops an item on the DropArea, inside an empty space(<code>dropOnEmptySpace</code>), inside an occupied space (<code>dropOnOccupiedSpace</code>) or inside whichever place with the items list full (<code>dropWhenFull</code>).</p>
	 * @see DraggableComponent
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public class DropAreaComponent extends MouseInputComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		/**
		 * <p>Used in <code>dropWhenFull</code> rule.</p>
		 * <p>When a DraggableComponent is dropped and the maxItems is reached, removes the last item to make room for the new item.</p>
		 * @see #dropWhenFull
		 * @see #maxItems
		 * @see #items
		 */
		public static const REMOVE_LAST:String = "remove_last";
		
		/**
		 * <p>Used in <code>dropWhenFull</code> rule.</p>
		 * <p>When a DraggableComponent is dropped and the maxItems is reached, removes the first item to make room for the new item.</p>
		 * @see #dropActionOnFull
		 * @see #maxItems
		 * @see #items
		 */
		public static const REMOVE_FIRST:String = "remove_first";
		
		/**
		 * <p>Used in <code>dropOnEmptySpace</code>, <code>dropOnOccupiedSpace</code> and <code>dropWhenFull</code> rules.</p>
		 * <p>Denies the drop on any rule.</p>
		 * @see #dropOnEmptySpace
		 * @see #dropOnOccupiedSpace
		 * @see #dropWhenFull
		 *
		 */
		public static const DENY:String = "deny";
		
		/**
		 * <p>Used in <code>dropOnEmptySpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an empty space, adds it to the begging of the items list.</p>
		 * @see #dropOnEmptySpace
		 */
		public static const SHIFT:String = "shift";
		
		/**
		 * <p>Used in <code>dropOnEmptySpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an empty space, adds it to the end of the items list.</p>
		 * @see #dropOnEmptySpace
		 */
		public static const PUSH:String = "push";
		
		/**
		 * <p>Used in <code>dropOnOccupiedSpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an space already occupied by another item, adds the new item to the position before the old one.</p>
		 * @see #dropOnOccupiedSpace
		 */
		public static const ADD_BEFORE:String = "add_before";
		
		/**
		 * <p>Used in <code>dropOnOccupiedSpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an space already occupied by another item, adds the new item to the position after the old one.</p>
		 * @see #dropOnOccupiedSpace
		 */
		public static const ADD_AFTER:String = "add_after";
		
		/**
		 * <p>Used in <code>dropOnOccupiedSpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an space already occupied by another item, replaces the old item by the new one.</p>
		 * @see #dropOnOccupiedSpace
		 */
		public static const REPLACE:String = "replace";
		
		/**
		 * <p>Used in <code>dropOnOccupiedSpace<code> rule.
		 * <p>When a DraggableComponent is dropped on an space already occupied by another item, does nothing and follow the <code>dropOnEmptySpace</code> rule.</p>
		 * @see #dropOnOccupiedSpace
		 */
		public static const NONE:String = "none";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _items:Vector.<DraggableComponent> = new Vector.<DraggableComponent>();
		private var _dropPositionController:IDropPositionController;
		private var _dropOnEmptySpace:String = PUSH;
		private var _dropOnOccupiedSpace:String = ADD_BEFORE;
		private var _dropWhenFull:String = DENY;
		
		/**
		 * What masks the DropArea acceps.
		 * @see DraggableComponent#mask.
		 */
		public var accepts:Array;
		
		
		/**
		 * Maximum number of DraggableComponents. A value less than or equals to 0 indicates that the DropArea has no maximum items.
		 */
		public var maxItems:int = 0;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * This rules applies when the usar drops an item on an empty space. The values can be one of the follow:
		 * <ul>
		 * 	<li><code>shift</code>: add the new item to the beggining of the list.</li>
		 * 	<li><code>push</code>: add the new item to the end of the list.</li>
		 * 	<li><code>deny</code>: denies the drop on the list.</li>
		 * </ul>
		 * @see #SHIFT
		 * @see #PUSH
		 * @see #DENY
		 * @default PUSH
		 */
		public function set dropOnEmptySpace(value:String):void
		{
			if (!(value == SHIFT || value == PUSH || value == DENY))
			{
				Logger.error(this, "dropOnEmptySpace", "dropOnEmptySpace was [" + value + "] and was expected one of the values: [" + SHIFT + ", " + PUSH + ", " + DENY + "].");
				return;
			}
			_dropOnEmptySpace = value;
		}
		
		
		/**
		 * This rule applies when the user drops an item on a space already occupied by another item. The values can be one of the follow:
		 * <ul>
		 * 	<li><code>add_before</code>: add the new item before the occupied space.</li>
		 * 	<li><code>add_after</code>: add the new item after the occupied space.</li>
		 * 	<li><code>none</code>: does nothing and follow the rule dropOnEmptySpace</code>.</li>
		 * 	<li><code>replace</code>: replaces the item on the occupied space by the new item.</li>
		 * 	<li><code>deny</code>: denies the drop on occupied spaces</li>
		 * </ul>
		 * @see	#ADD_BEFORE
		 * @see #ADD_AFTER
		 * @see #NONE
		 * @see #REPLACE
		 * @see #DENY
		 * @default	ADD_BEFORE
		 */
		public function set dropOnOccupiedSpace(value:String):void
		{
			if (!(value == ADD_BEFORE || value == ADD_AFTER || value == REPLACE || value == DENY || value == NONE))
			{
				Logger.error(this, "dropOnOccupiedSpace", "dropOnOccupiedSpace was [" + value + "] and was expected one of the values: [" + ADD_BEFORE + ", " + ADD_AFTER + ", " + REPLACE + ", " + DENY +
							 ", " + NONE + "].");
				return;
			}
			_dropOnOccupiedSpace = value;
		}
		
		/**
		 * Controlls the position of the items.
		 * @default DefaultDropPositionController
		 */
		public function get dropPositionController():IDropPositionController
		{
			return _dropPositionController;
		}
		
		/**
		 * @private
		 */
		public function set dropPositionController(value:IDropPositionController):void
		{
			value.dropArea = this;
			_dropPositionController = value;
		}
		
		/**
		 * This rules applies when the user drops an item on a list that already have <code>maxItems</code> items. This rules is the strongest, it means that it will override other rules when needed. The values can be one of the follow:
		 * <ul>
		 * 	<li><code>remove_first</code>: removes the first item in the list to make room to the new item.</li>
		 * 	<li><code>remove_last</code>: removes the last item in the list to make room to the new item.</li>
		 * 	<li><code>deny</code>: denies drop actions when the items list is full</li>
		 * </ul>
		 * @see #REMOVE_FIRST
		 * @see #REMOVE_LAST
		 * @see #DENY
		 * @default DENY
		 */
		public function set dropWhenFull(value:String):void
		{
			if (!(value == REMOVE_FIRST || value == REMOVE_LAST || value == DENY))
			{
				Logger.error(this, "dropActionOnFull", "dropActionOnFull was [" + value + "] and was expected one of the values: [" + REMOVE_FIRST + ", " + REMOVE_LAST + ", " + DENY + "].");
				return;
			}
			_dropWhenFull = value;
		}
		
		/**
		 * Items that is in the DragArea.
		 * @return A copy of the items that is in the DragArea.
		 */
		public function get items():Vector.<DraggableComponent>
		{
			return _items.slice();
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onRemove():void
		{
			super.onRemove();
			_items = null;
			if (_dropPositionController)
			{
				_dropPositionController.clear();
				_dropPositionController = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			if (_dropPositionController == null)
			{
				dropPositionController = new DefaultDropPositionController();
			}
			super.onAdd();
		}
		
		private final function dropItem(comp:DraggableComponent):Boolean
		{
			var addIndex:int = addIndex = getItemIndexAt(comp.scenePosition);
			var removeIndex:int = -1;
			if (addIndex >= 0)
			{
				switch (_dropOnOccupiedSpace)
				{
					case DENY:
					{
						comp.dropFail();
						return false;
					}
					
					case NONE:
					{
						addIndex = -1;
						break;
					}
					
					case ADD_BEFORE:
					{
						addIndex = getItemIndexAt(comp.scenePosition);
						if (addIndex < 0)
						{
							addIndex = 0;
						}
						break;
					}
					
					case ADD_AFTER:
					{
						addIndex = getItemIndexAt(comp.scenePosition);
						addIndex = (addIndex < 0) ? -1 : addIndex + 1;
						break;
					}
					
					case REPLACE:
					{
						addIndex = removeIndex = getItemIndexAt(comp.scenePosition);
						break;
					}
				}
			}
			
			if (addIndex < 0)
			{
				switch (_dropOnEmptySpace)
				{
					case DENY:
					{
						comp.dropFail();
						return false;
					}
					
					case SHIFT:
					{
						addIndex = 0;
						break;
					}
					
					case PUSH:
						break;
				}
			}
			
			if (maxItems > 0 && _items.length == maxItems)
			{
				if (_dropWhenFull == DENY)
				{
					comp.dropFail();
					return false;
				}
				if (removeIndex < 0)
				{
					switch (_dropWhenFull)
					{
						case REMOVE_FIRST:
						{
							removeIndex = 0;
							if (addIndex > 0)
							{
								addIndex--;
							}
							break;
						}
						
						case REMOVE_LAST:
						{
							removeIndex = _items.length - 1;
							break;
						}
					}
				}
			}
			
			if (removeIndex >= 0)
			{
				_items.splice(removeIndex, 1)[0].replaced();
			}
			if (addIndex >= 0)
			{
				_items.splice(addIndex, 0, comp);
			}
			else
			{
				addIndex = _items.push(comp) - 1;
			}
			
//			PBE.mouseInputManager.stopDrag();
			_dropPositionController.dropItem(_items, addIndex, removeIndex);
			var a:Boolean = onDropItem(comp);
			var b:Boolean = comp.dropSuccess(this);
			return a || b;
		}
		
		public function addItem(comp:DraggableComponent):void
		{
			dropItem(comp);
		}
		
		public function removeItem(comp:DraggableComponent):void
		{
			itemDragStarted(comp);
			comp.dropFail();
		}
		
		private function getItemIndexAt(pos:Point):int
		{
			return _dropPositionController.getItemIndexAt(items, pos);
		}
		
		/**
		 * Called when an item is succeeded dropped.
		 * @param comp	The component that was dropped.
		 * @return Whether the mouse event execution should pass to other components (true) or stop here (false).
		 */
		protected function onDropItem(comp:DraggableComponent):Boolean
		{
			return false;
		}
		
		internal function itemDragStarted(comp:DraggableComponent):void
		{
			var index:int = _items.indexOf(comp);
			if (index < 0)
			{
				Logger.fatal(this, "dragStated", "Component [" + comp.name + "] is not in drag area [" + name + "].");
			}
			_items.splice(index, 1)[0]._dropArea = null;
			_dropPositionController.dragItem(_items, index);
		}
		
		/**
		 * Whether the item can be dropped. Overrite it to make specific implementations.
		 * @param comp	The item that was just dropped.
		 * @return	Whether the item can be dropped.
		 */
		protected function canDrop(comp:DraggableComponent):Boolean
		{
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onMouseUp(data:MouseInputData):Boolean
		{
//			var comp:DraggableComponent = PBE.mouseInputManager.dragComponent;
			var comp:DraggableComponent=null;
			if (comp == null)
			{
				return true;
			}
			
			if (!canDrop(comp) || !comp.canDrop(data))
			{
				return comp.dropFail();
			}
			
			if (accepts != null)
			{
				var name:String = comp.mask;
				for each (var s:String in accepts)
				{
					if (name == s)
					{
						return dropItem(comp);
					}
				}
				return true;
			}
			else
			{
				return dropItem(comp);
			}
			return false;
		}
	}
}
