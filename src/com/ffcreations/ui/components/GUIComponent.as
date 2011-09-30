package com.ffcreations.ui.components
{
	import com.ffcreations.rendering2D.ScaleSpriteRenderer;
	import com.ffcreations.ui.mouse.IMouseInputComponent;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.utils.StringUtil;
	
	/**
	 * Component to easy handle with gui components, like buttons.
	 * Considerations:
	 * <ul>
	 * <li>The image given in <code>fileName</code> field must be a sprite sheet containing the states of the
	 * component</li>
	 * <li>The <code>states</code> field must be set with an <code>Array</code> containing each state of this image in order</li>
	 * <li>Each sub-image is a 9-sliced image, so you need to set the <code>grid9Scale</code> field properly</li>
	 * <li>The default is consider a 2x4 sprite sheet like this:<br />
	 * <pre>           out  over  down  disabled </pre>
	 * <pre>          _____ _____ _____ _____    </pre>
	 * <pre>         |     |     |     |     |   </pre>
	 * <pre>  normal |  0  |  1  |  2  |  3  |   </pre>
	 * <pre>         |_____|_____|_____|_____|   </pre>
	 * <pre>         |     |     |     |     |   </pre>
	 * <pre>selected |  4  |  5  |  6  |  7  |   </pre>
	 * <pre>         |_____|_____|_____|_____|   </pre>
	 * </li>
	 * </ul>
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class GUIComponent extends ScaleSpriteRenderer implements IMouseInputComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		private static var zeroPoint:Point = new Point();
		
		/**
		 * Event type called when the component is selected.
		 */
		public static var SELECTED:String = "selected";
		
		private static var _componentStates:Array = new Array("normal", "selected");
		private static var _mouseStates:Object = { "out":"mouseOut", "over":"mouseOver", "down":"mouseDown", "disabled":"disabled" };
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _states:Object = { "normal:mouseOut":0,
				"normal:mouseOver":1,
				"normal:mouseUp":1,
				"normal:mouseDown":2,
				"normal:disabled":3,
				"selected:mouseOut":4,
				"selected:mouseUp":4,
				"selected:mouseOver":5,
				"selected:mouseDown":6,
				"selected:disabled":7 };
		
		private var _target:BitmapData;
		private var _sourceRect:Rectangle;
		private var _stateDirty:Boolean;
		private var _state:String;
		private var _grid:Point = new Point(4, 2);
		private var _visible:Boolean = true;
		
		protected var _enabled:Boolean = true;
		protected var _selected:Boolean = false;
		protected var _acceptDrop:Boolean;
		protected var _draggable:Boolean;
		protected var _priority:int;
		protected var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function get acceptDrop():Boolean
		{
			return _acceptDrop;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set acceptDrop(value:Boolean):void
		{
			_acceptDrop = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return _enabled && _alpha > 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_stateDirty = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		/**
		 * Columns count (x) and rows count (y) of the image.
		 */
		public function set imageDivider(value:Point):void
		{
			_grid = value;
			updateSourceRect();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get priority():int
		{
			return _priority;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set priority(value:int):void
		{
			_priority = value;
			if (isRegistered)
			{
				PBE.mouseInputManager.updatePriority(this);
			}
		}
		
		/**
		 * Whether the component is selected.
		 * @return
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 * @private
		 */
		public function set selected(value:Boolean):void
		{
			if (_selected == value)
			{
				return;
			}
			_selected = value;
			_eventDispatcher.dispatchEvent(new Event(SELECTED));
			// TODO pass value to the event
			_stateDirty = true;
		}
		
		/**
		 * An <code>Array</code> where its key is the image grid index and each value is
		 * a comma separated <code>String</code> of state values.
		 * State values are formed by two <code>String</code>s separated by a ":".
		 * <p>
		 * The first <code>String</code> is the component state and can be one of the follow
		 * values:
		 * <ul>
		 * <li><code>normal</code>: when the component is in your normal state.</li>
		 * <li><code>selected</code>: when the component is in your selected state.</li>
		 * </ul>
		 * </p>
		 * <p>
		 * The second <code>String</code> is the mouse state and can be one of the follow
		 * values:
		 * <ul>
		 * <li><code>out</code>: when the mouse is out the component.</li>
		 * <li><code>over</code>: when the mouse is over the component. </li>
		 * <li><code>up</code>: when the mouse is just released inside the component.</li>
		 * <li><code>down</code>: when the mouse is down inside the component.</li>
		 * <li><code>disabled</code>: when the component is disabled for mouse inputs.</li>
		 * </ul>
		 * </p>
		 * @example 
		 * <listing version="3.0">
		 * var button:GUIComponent = new GUIComponent();
		 * 
		 * // An 2x4 sprite sheet
		 * button.fileName = "../assets/some/file.png";
		 * 
		 * // Set it as so (columns, rows)
		 * button.imageDivider = new Point(4, 2);
		 * 
		 * // The scale9Grid considering each sprite in the image as a separated image
		 * button.scale9Grid = new Rectangle(16, 16, 16, 16);
		 * 
		 * // Set the states related to each sprite sheet index
		 * button.states = [
		 * 		"normal:out",                   // index 0 of the sprite sheet (0,0)
		 * 		"normal:over, normal:up",       // index 1 of the sprite sheet (0,1)
		 * 		"normal:down",                  // index 2 of the sprite sheet (0,2)
		 * 		"normal:disabled",              // index 3 of the sprite sheet (0,3)
		 * 		"selected:out",                 // index 4 of the sprite sheet (1,0)
		 * 		"selected:over, selected:up",   // index 5 of the sprite sheet (1,1)
		 * 		"selected:down",                // index 6 of the sprite sheet (1,2)
		 * 		"selected:disabled"             // index 7 of the sprite sheet (1,3)
		 * ];
		 * </listing>
		 * @default
		 */
		public function set states(value:Array):void
		{
			if (value == null)
			{
				_states = new Object();
				return;
			}
			for (var i:int = 0; i < value.length; i++)
			{
				var states:Array = value[i].split(",");
				for each (var state:String in states)
				{
					var s:Array = state.split(":");
					if (s.length != 2)
					{
						Logger.warn(this, "states", "State must be a string like 'normal:out' or 'selected:over'.");
						continue;
					}
					var csi:int = _componentStates.indexOf(StringUtil.trim(s[0]));
					var st:String = StringUtil.trim(s[1]);
					if (csi < 0 || !_mouseStates.hasOwnProperty(st))
					{
						Logger.warn(this, "states", "Wrong state: '" + state + "'.");
						continue;
					}
					_states[_componentStates[csi] + ":" + _mouseStates[st]] = i;
				}
			}
		}
		
		/**
		 * Whether the component is visible.
		 */
		public function get visible():Boolean
		{
			return _visible;
		}
		
		/**
		 * @private
		 */
		public function set visible(value:Boolean):void
		{
			if (_visible == value)
			{
				return;
			}
			_visible = value;
			alpha = value ? 1 : 0;
			if (value)
			{
				PBE.mouseInputManager.addComponent(this);
			}
			else
			{
				PBE.mouseInputManager.removeComponent(this);
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
			super.onAdd();
			if (_visible)
			{
				PBE.mouseInputManager.addComponent(this);
			}
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, int.MIN_VALUE, true);
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_UP, onMouse, false, int.MIN_VALUE, true);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			_target = null;
			_sourceRect = null;
			_state = null;
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_OVER, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_OUT, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			PBE.mouseInputManager.removeComponent(this);
			super.onRemove();
		}
		
		/**
		 * Updates the state when <code>_stateDirty</code> is set.
		 */
		protected function updateState():void
		{
			if (!_sourceRect)
			{
				return;
			}
			var state:String;
			if (_enabled)
			{
				state = (_selected ? "selected" : "normal") + ":" + _state;
			}
			else
			{
				state = (_selected ? "selected" : "normal") + ":disabled";
			}
			
			if (_states.hasOwnProperty(state))
			{
				var index:int = _states[state];
				_sourceRect.x = int(_target.width * (index % _grid.x));
				_sourceRect.y = int(_target.height * int(index / _grid.x));
				_transformDirty = true;
				_scaleDirty = true;
			}
			
			_stateDirty = false;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onImageLoadComplete():void
		{
			updateSourceRect();
			_state = MouseEvent.MOUSE_OUT;
			_stateDirty = true;
		}
		
		private function updateSourceRect():void
		{
			if (!_source)
			{
				return;
			}
			_sourceRect = new Rectangle(0, 0, int(_source.width * (1 / _grid.x)), int(_source.height * (1 / _grid.y)));
			_target = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
			_registrationPoint = new Point(_sourceRect.width * 0.5, _sourceRect.height * 0.5);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			if (_stateDirty)
			{
				updateState();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function redraw():void
		{
			if (!isRegistered || !_source || !_target)
			{
				return;
			}
			if (!_scale9Grid)
			{
				_displayObject.scale9Grid = null;
				return;
			}
			
			_target.copyPixels(_source, _sourceRect, zeroPoint);
			
			var gridX:Array = [_scale9Grid.left, _scale9Grid.right, _target.width];
			var gridY:Array = [_scale9Grid.top, _scale9Grid.bottom, _target.height];
			
			var graphics:Graphics = (_displayObject as Sprite).graphics;
			
			graphics.clear();
			
			var left:Number = 0;
			for (var i:int = 0; i < 3; i++)
			{
				var top:Number = 0;
				for (var j:int = 0; j < 3; j++)
				{
					graphics.beginBitmapFill(_target);
					graphics.drawRect(left, top, gridX[i] - left, gridY[j] - top);
					graphics.endFill();
					top = gridY[j];
				}
				left = gridX[i];
			}
			_displayObject.scale9Grid = _scale9Grid;
			_scaleDirty = false;
		}
		
		/**
		 * Whether this component can be draggad at the moment that the drag starts.
		 * @return <code>True</code> if can be dragged, or <code>false</code> otherwise.
		 * @default The value in <code>draggable</code> field.
		 */
		public function canDrag():Boolean
		{
			return _draggable;
		}
		
		/**
		 * If this component accepts drop, this method is called when a <code>IMouseInputComponent</code>
		 * is about to be dropped inside it.
		 * @param component	The <code>IMouseInputComponent</code> that is dropped inside this component.
		 * @return <code>True</code> if the given <code>IMouseInputComponent</code> can be dropped inside
		 * this component or <code>false</code> otherwise.
		 * @default The value in <code>acceptDrop</code> field.
		 */
		public function canDrop(component:IMouseInputComponent):Boolean
		{
			return _acceptDrop;
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains(point:Point):Boolean
		{
			return isRegistered ? pointOccupied(point, null) : false;
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onMouse(data:MouseInputEvent):void
		{
			_state = data.type;
			_stateDirty = true;
			data.stopImmediatePropagation();
		}
	}

}
