package com.ffcreations.ui.components {
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	/**
	 * Provides some methods to handle with a group of <code>Toggle</code> components.
	 * When one of its componets is selected, the others are unselected.
	 * @see com.ffcreations.ui.components.Toggle
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class ToggleGroup extends TickedComponent {
		
		private var _options:Array;
		private var _maxSelection:int = -1;
		private var _selectedIndex:int = -1;
		private var _layerIndex:int = 0;
		private var _position:Point = new Point();
		private var _pos:Point = new Point();
		private var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		private var _priority:int;
		private var _enabled:Boolean = true;
		
		/**
		 * Position offset of the component.
		 */
		public var positionOffset:Point = new Point();
		
		/**
		 * If set, prosition will be set to this.
		 */
		public var positionProperty:PropertyReference;
		
		/**
		 * Enabled state of this component. If set, the <code>enabled</code>
		 * state of all <code>Toggle</code> components inside this group
		 * will be set.
		 */
		public function get enabled():Boolean { return _enabled; }
		
		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void {
			if (value == _enabled)
				return;
			_enabled = value;
			for each (var opt:Toggle in _options)
				opt.enabled = value;
		}
		
		/**
		 * EventDispatcher where the mouse events are dispatched.
		 */
		public function get eventDispatcher():IEventDispatcher { return _eventDispatcher; }
		
		/**
		 * Layer index of this component. If set, the <code>layerIndex</code>
		 * property of all <code>Toggle</code> components inside this group
		 * will be set.
		 */
		public function get layerIndex():int { return _layerIndex; }
		
		/**
		 * @private
		 */
		public function set layerIndex(value:int):void {
			if (_layerIndex == value)
				return;
			_layerIndex = value;
			for each (var opt:Toggle in _options)
				opt.layerIndex = value;
		}
		
		/**
		 * A set of <code>Toggle</code> components to add to the group.
		 */
		[TypeHint(type="com.ffcreations.ui.components.Toggle")]
		public function set options(value:Array):void {
			var i:int;
			var length:int;
			if (_options != null) {
				for (i = 0, length = _options.length; i < length; i++)
					_options.pop().eventDispatcher.removeEventListener(MouseInputEvent.MOUSE_UP, onSelect);
				_options = null;
			}
			
			if (value == null) {
				_options = null;
				return;
			}
			length = value.length;
			_options = new Array(length);
			var opt:Toggle;
			for (i = 0; i < length; i++) {
				opt = value[i];
				opt.group();
				opt.eventDispatcher.addEventListener(MouseInputEvent.MOUSE_UP, onSelect);
				_options[i] = opt;
			}
		}
		
		/**
		 * The group position.
		 */
		public function get position():Point { return _position; }
		
		/**
		 * @private
		 */
		public function set position(value:Point):void { _pos = value; }
		
		/**
		 * Priority of this component. If set, the <code>priority</code>
		 * property of all <code>Toggle</code> components inside this group
		 * will be set.
		 */
		public function get priority():int { return _priority; }
		
		/**
		 * @private
		 */
		public function set priority(value:int):void {
			if (_priority == value)
				return;
			_priority = value;
			for each (var opt:Toggle in _options)
				opt.priority = value;
		}
		
		/**
		 * The index of the selected <code>Toggle</code> component
		 * inside the group. Set it to force a selection.
		 */
		public function get selectedIndex():int { return _selectedIndex; }
		
		/**
		 * @private
		 */
		public function set selectedIndex(value:int):void {
			if (_selectedIndex == value)
				return;
			select(value)
		}
		
		/**
		 * The value of the selected option.
		 * @return
		 */
		public function get selectedValue():* {
			_options[_selectedIndex].value;
		}
		
		/**
		 * @private
		 */
		public function set selectedValue(value:*):void {
			for (var i:int = 0; i < _options.length; i++) {
				if (_options[i].value != value)
					continue;
				selectedIndex = i;
				return;
			}
		}
		
		private function select(value:int):void {
			if (_options) {
				for (var i:int = 0; i < _options.length; i++)
					_options[i].selected = i == value;
				_eventDispatcher.dispatchEvent(new PropertyChangedEvent(PropertyChangedEvent.SELECTION_CHANGED, value >= 0 && _options[value].value ? _options[value].value : value));
			}
			_selectedIndex = value;
		}
		
		/**
		 * Add an option to the end of the <code>options</code> list.
		 * If the option is already inside the list, just return its index.
		 * @param option The <code>Toggle</code> to add to the list.
		 * @return The option index.
		 */
		public function addOption(option:Toggle):int {
			if (_options == null)
				_options = new Array();
			var index:int = _options.indexOf(option);
			if (_options.indexOf(option) >= 0)
				return index;
			option.group();
			option.eventDispatcher.addEventListener(MouseInputEvent.MOUSE_UP, onSelect);
			index = _options.push(option) - 1;
			if (index == _selectedIndex)
				select(index);
			return index;
		}
		
		/**
		 * Removes an option previously added to the <code>options</code> list.
		 * @param option The <code>Toggle</code> to remove from the list.
		 */
		public function removeOption(option:Toggle):void {
			if (_options == null)
				return;
			var index:int = _options.indexOf(option);
			if (index < 0)
				return;
			_options.splice(index, 1);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void {
			super.onAdd();
			if (_selectedIndex >= 0)
				select(_selectedIndex);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void {
			for (var i:int = 0, length:int = _options.length; i < length; i++)
				_options.pop().eventDispatcher.removeEventListener(MouseInputEvent.MOUSE_UP, onSelect);
			_options = null;
			super.onRemove();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function onTick(deltaTime:Number):void {
			updateProperties();
		}
		
		/**
		 * Updates all *Properties fields.
		 */
		protected function updateProperties():void {
			if (positionProperty) {
				var pos:Point = owner.getProperty(positionProperty, _pos);
				if (pos.x != _pos.x && pos.y != _pos.y)
					_position = pos.add(positionOffset);
			}
		}
		
		private function onSelect(event:MouseInputEvent):void {
			selectedIndex = _options.indexOf(event.component);
		}
	}
}
