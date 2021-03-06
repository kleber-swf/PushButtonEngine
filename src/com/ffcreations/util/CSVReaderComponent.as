package com.ffcreations.util {
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.resource.TextResource;
	
	import mx.utils.StringUtil;
	
	/**
	 * Simple Component to load a table csv file.
	 * Tip: To embed a csv file, use mimeType="application/octet-stream" in Embed tag.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class CSVReaderComponent extends EntityComponent {
		
		private var _resource:TextResource;
		private var _fileName:String;
		private var _loading:Boolean;
		private var _failed:Boolean;
		private var _loaded:Boolean;
		private var _data:*;
		
		/** If set to true, the first column is considered titles to a map, <code>data</code> is an <code>Object</code> and all column indexes decrease by 1. */
		public var mapByFirstColumn:Boolean;
		
		/**
		 * Separator between columns.
		 * @default ;
		 */
		public var separator:String = ";";
		
		/**
		 * The table entire data.
		 * If <code>mapByFirstColumn</code> is set to true, data is a <code>Object</code>,
		 * otherwise is an <code>Array</code>.
		 * @see #mapByFirstColumn
		 */
		public function get data():* {
			return _data;
		}
		
		/** Indicates if the TextResource (csv) has failed loading. */
		public function get failed():Boolean { return _failed; }
		
		/** Resource (file)name of the TextResource (csv). */
		public function get fileName():String { return _fileName; }
		
		/** @private */
		public function set fileName(value:String):void {
			if (_fileName != value) {
				if (_resource) {
					PBE.resourceManager.unload(_resource.filename, TextResource);
					_resource = null;
				}
				_fileName = value;
				_loading = true;
				// Tell the ResourceManager to load the TextResource
				PBE.resourceManager.load(_fileName, TextResource, loadCompleted, loadFailed, false);
			}
		}
		
		/** Indicates if the TextResource (csv) has been loaded. */
		public function get loaded():Boolean { return _loaded; }
		
		/** Indicates if the resource loading is in progress. */
		public function get loading():Boolean { return _loading; }
		
		public function get numRows():int { return _data.length; }
		
		private function loadCompleted(res:TextResource):void {
			_loading = false;
			_loaded = true;
			_failed = false;
			_resource = res;
			const text:String = _resource.data;
			const buffer:Array = text.split("\r\n");
			const length:int = (!buffer[buffer.length - 1]) ? buffer.length - 1 : buffer.length;
			
			if (mapByFirstColumn)
				_mapToObject(buffer, length);
			else
				_mapToArray(buffer, length);
			
			onLoadComplete();
		}
		
		protected function onLoadComplete():void {
		
		}
		
		private function _mapToObject(buffer:Array, length:int):void {
			_data = new Object();
			
			var tmp:Array;
			for (var i:int = 0; i < length; i++) {
				tmp = buffer[i].split(separator);
				if (!StringUtil.trim(tmp[tmp.length - 1]))
					tmp.pop();
				if (tmp.length > 1)
					_data[tmp[0]] = tmp.slice(1);
			}
		}
		
		private function _mapToArray(buffer:Array, length:int):void {
			_data = new Array(length);
			
			var tmp:Array;
			for (var i:int = 0; i < length; i++) {
				tmp = buffer[i].split(separator);
				if (!StringUtil.trim(tmp[tmp.length - 1]))
					tmp.pop();
				_data[i] = tmp;
			}
		}
		
		private function loadFailed(res:TextResource):void {
			_loading = false;
			_failed = true;
		}
		
		/**
		 * Gets a cell from the table.
		 * @param row	Cell row. A <code>String</code> if <code>mapByFirstColumn</code> is <code>true</code> or an <code>int</code> if not
		 * @param col	Cell column.
		 * @return 		The cell data as String.
		 * @see			#mapByFirstColumn
		 * @see			#data
		 */
		public function getCell(row:*, col:int):String {
			if (mapByFirstColumn) {
				if (row is String)
					return (col < _data[row].length) ? _data[row][col] : null;
				Logger.warn(this, "getCell", "Trying to get a cell from an Object with a non-String key: '" + row + "'");
				return null;
			}
			if (row is int)
				return (row < _data.length && col < _data[row].length) ? _data[row][col] : null;
			Logger.warn(this, "getCell", "Trying to get a cell from an Array with a NaN key: '" + row + "'");
			return null;
		}
		
		/**
		 * Gets an entire row from the table.
		 * @param row	Row index. A <code>String</code> if <code>mapByFirstColumn</code> is <code>true</code> or an <code>int</code> if not
		 * @return 		An Array with all columns in the specified row.
		 * @see			#mapByFirstColumn
		 * @see			#data
		 */
		public function getRow(row:*):Array {
			if (mapByFirstColumn) {
				if (row is String)
					return _data[row];
			}
			if (row >= 0 && row < _data.length)
				return _data[row]
			return null;
			//return (!(_data is Array) || row < _data.length) ? _data[row] : null;
		}
		
		/**
		 * Gets an entire column from the table.
		 * If some row has no value for the (row,col) cell, an empty String is placed.
		 * @param col	Column index.
		 * @return 		An <code>Array</code> if <code>mapByFirstColumn</code> is <code>false</code>
		 * 					or an <code>Object</code> indexed by the key column if <code>false</code>.
		 * @see			#mapByFirstColumn
		 * @see			#data
		 */
		public function getColumn(col:int):* {
			var result:*;
			if (mapByFirstColumn) {
				result = new Object();
				for (var s:String in _data)
					result[s] = (col < _data[s].length ? _data[s][col] : "");
			} else {
				const length:int = _data.length;
				result = new Array(length);
				for (var i:int = 0; i < length; i++)
					result[i] = (col < _data[i].length ? _data[i][col] : "");
			}
			return result;
		}
		
		/**
		 * Get the key column as <code>Array</code>.
		 * Only works if <code>mapByFirstColumn</code> is <code>true</code>.
		 * @return An <code>Array</code> with all keys.
		 */
		public function getKeyColumn():Array {
			if (!mapByFirstColumn)
				return null;
			const result:Array = new Array(_data.length);
			var i:int = 0;
			for (var s:String in _data)
				result[i++] = s;
			return result;
		}
		
		/** @inheritDoc */
		protected override function onRemove():void {
			super.onRemove();
			_resource = null;
			_data.length = 0;
			_data = null;
		}
	}
}
