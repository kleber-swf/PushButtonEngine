package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputData;
	import com.ffcreations.util.DelegateContainer;
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.events.MouseEvent;
	
	public class ToggleGroup extends EntityComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static const SELECTION_CHANGED:String = "selectionChanged";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _options:Array;
		private var _maxSelection:int = -1;
		private var _selectedIndex:int = -1;
		private var _delegateContainer:DelegateContainer = new DelegateContainer();
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function set options(value:Array):void
		{
			var i:int;
			var length:int;
			if (_options != null)
			{
				for (i = 0, length = _options.length; i < length; i++)
				{
					_options.pop().delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onSelect);
				}
				_options = null;
			}
			
			if (value == null)
			{
				_options = null;
				return;
			}
			length = value.length;
			_options = new Array(length);
			var opt:Toggle;
			for (i = 0; i < length; i++)
			{
				opt = value[i];
				opt.delegateContainer.addDelegateCallback(MouseEvent.MOUSE_UP, onSelect);
				opt.group();
				_options[i] = opt;
			}
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex == value)
			{
				return;
			}
			for (var i:int = 0; i < _options.length; i++)
			{
				_options[i].selected = i == value;
			}
			_selectedIndex = value;
			_delegateContainer.callDelegate(SELECTION_CHANGED, value);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onRemove():void
		{
			for (var i:int = 0, length:int = _options.length; i < length; i++)
			{
				_options.pop().delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onSelect);
			}
			_options = null;
			_delegateContainer.clear();
			_delegateContainer = null;
			super.onRemove();
		}
		
		private function onSelect(data:MouseInputData):Boolean
		{
			selectedIndex = _options.indexOf(data.component);
			return true;
		}
	}
}
