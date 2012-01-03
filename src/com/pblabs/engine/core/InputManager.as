/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;
	
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * The input manager wraps the default input events produced by Flash to make
	 * them more game friendly. For instance, by default, Flash will dispatch a
	 * key down event when a key is pressed, and at a consistent interval while it
	 * is still held down. For games, this is not very useful.
	 *
	 * <p>The InputMap class contains several constants that represent the keyboard
	 * and mouse. It can also be used to facilitate responding to specific key events
	 * (OnSpacePressed) rather than generic key events (OnKeyDown).</p>
	 *
	 * @see InputMap
	 */
	public class InputManager extends EventDispatcher implements ITickedObject
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _keyState:Array = new Array(); // The most recent information on key states
		private var _keyStateOld:Array = new Array(); // The state of the keys on the previous tick
		private var _justPressed:Array = new Array(); // An array of keys that were just pressed within the last tick.
		private var _justReleased:Array = new Array(); // An array of keys that were just released within the last tick.
		public var mouseLocked:Boolean = false;
		public var keyLocked:Boolean = false;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		private var _mouseEnabled:Object = new Object();
		
		/**
		 * Whether the mouse input is enabled.
		 */
		public function get mouseMoveEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_MOVE];
		}
		
		/**
		 * @private
		 */
		public function set mouseMoveEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_MOVE, value);
		}
		
		/**
		 * Whether the mouse out state is enabled.
		 */
		public function get mouseOutEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_OUT];
		}
		
		/**
		 * @private
		 */
		public function set mouseOutEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_OUT, value);
		}
		
		/**
		 * Whether the mouse over state is enabled.
		 */
		public function get mouseOverEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_OVER];
		}
		
		/**
		 * @private
		 */
		public function set mouseOverEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_OVER, value);
		}
		
		/**
		 * Whether the mouse wheel state is enabled.
		 */
		public function get mouseWheelEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_WHEEL];
		}
		
		/**
		 * @private
		 */
		public function set mouseWheelEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_WHEEL, value);
		}
		
		/**
		 * Whether the mouse up state is enabled.
		 */
		public function get mouseUpEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_UP];
		}
		
		/**
		 * @private
		 */
		public function set mouseUpEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_UP, value);
		}
		
		/**
		 * Whether the mouse down state is enabled.
		 */
		public function get mouseDownEnabled():Boolean
		{
			return _mouseEnabled[MouseEvent.MOUSE_DOWN];
		}
		
		/**
		 * @private
		 */
		public function set mouseDownEnabled(value:Boolean):void
		{
			enableMouseProperty(MouseEvent.MOUSE_DOWN, value);
		}
		
		private function enableMouseProperty(value:String, enable:Boolean):void {
			_mouseEnabled[value] = enable;
			if (value)
			{
				PBE.mainClass.parent.addEventListener(value, onMouse, false, 0, true);
			}
			else
			{
				PBE.mainClass.parent.removeEventListener(value, onMouse);
			}
		}
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function InputManager()
		{
			PBE.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			PBE.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			mouseDownEnabled = true;
			mouseUpEnabled = true;
			mouseMoveEnabled = true;
			mouseOverEnabled = true;
			mouseOutEnabled = true;
			mouseWheelEnabled = true;
			
			// Add ourselves with the highest priority, so that our update happens at the beginning of the next tick.
			// This will keep objects processing afterwards as up-to-date as possible when using keyJustPressed() or keyJustReleased()
			PBE.processManager.addTickedObject(this, Number.MAX_VALUE);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function onTick(deltaTime:Number):void
		{
			// This function tracks which keys were just pressed (or released) within the last tick.
			// It should be called at the beginning of the tick to give the most accurate responses possible.
			
			var cnt:int;
			
			for (cnt = 0; cnt < _keyState.length; cnt++)
			{
				if (_keyState[cnt] && !_keyStateOld[cnt])
				{
					_justPressed[cnt] = true;
				}
				else
				{
					_justPressed[cnt] = false;
				}
				
				if (!_keyState[cnt] && _keyStateOld[cnt])
				{
					_justReleased[cnt] = true;
				}
				else
				{
					_justReleased[cnt] = false;
				}
				
				_keyStateOld[cnt] = _keyState[cnt];
			}
		}
		
		/**
		 * Returns whether or not a key was pressed since the last tick.
		 */
		public function keyJustPressed(keyCode:int):Boolean
		{
			return _justPressed[keyCode];
		}
		
		/**
		 * Returns whether or not a key was released since the last tick.
		 */
		public function keyJustReleased(keyCode:int):Boolean
		{
			return _justReleased[keyCode];
		}
		
		/**
		 * Returns whether or not a specific key is down.
		 */
		public function isKeyDown(keyCode:int):Boolean
		{
			return _keyState[keyCode];
		}
		
		/**
		 * Returns true if any key is down.
		 */
		public function isAnyKeyDown():Boolean
		{
			for each (var b:Boolean in _keyState)
			{
				if (b)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Simulates a key press. The key will remain 'down' until SimulateKeyUp is called
		 * with the same keyCode.
		 *
		 * @param keyCode The key to simulate. This should be one of the constants defined in
		 * InputMap
		 *
		 * @see InputMap
		 */
		public function simulateKeyDown(keyCode:int):void
		{
			onKeyDown(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyCode));
		}
		
		/**
		 * Simulates a key release.
		 *
		 * @param keyCode The key to simulate. This should be one of the constants defined in
		 * InputMap
		 *
		 * @see InputMap
		 */
		public function simulateKeyUp(keyCode:int):void
		{
			onKeyUp(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyCode));
		}
		
		/**
		 * Simulates clicking the mouse button.
		 */
		public function simulateMouseDown():void
		{
			onMouse(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		/**
		 * Simulates releasing the mouse button.
		 */
		public function simulateMouseUp():void
		{
			onMouse(new MouseEvent(MouseEvent.MOUSE_UP));
		}
		
		/**
		 * Simulates moving the mouse button. All this does is dispatch a mouse
		 * move event since there is no way to change the current cursor position
		 * of the mouse.
		 */
		public function simulateMouseMove():void
		{
			onMouse(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, Math.random() * 100, Math.random() * 100));
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (keyLocked || !PBE.processManager.isTicking)
			{
				return;
			}
			if (_keyState[event.keyCode])
			{
				return;
			}
			
			_keyState[event.keyCode] = true;
			dispatchEvent(event);
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (keyLocked || !PBE.processManager.isTicking)
			{
				return;
			}
			_keyState[event.keyCode] = false;
			dispatchEvent(event);
		}
		
		private function onMouse(event:MouseEvent):void
		{
			if (mouseLocked || !PBE.processManager.isTicking)
			{
				return;
			}
			event.localX = event.stageX;
			event.localY = event.stageY;
			dispatchEvent(event);
		}
	}
}

