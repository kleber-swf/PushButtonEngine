/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.spritesheet {
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.JSONResource;
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.utils.ObjectUtil;
	
	/**
	 * Divide a spritesheet into cells based on the rect coordinates in the loaded JSONResource
	 */
	public class PackedSheetDivider implements ISpriteSheetDivider {
		private var _frames:Vector.<CoordinateDataVO>;
		
		/**
		 * @inheritDoc
		 */
		public function getFrameArea(index:int):Rectangle {
			if (!_owningSheet)
				throw new Error("OwningSheet must be set before calling this!");
			
			if (!_frames || _frames.length < 0) {
				if (resource && resource.isLoaded) {
					buildFrames();
					getFrameArea(index);
				}
				return new Rectangle(0, 0, 1, 1);
			}
			
			return _frames[index].frameBounds;
		}
		
		protected function buildFrames():void {
			if (!resource || !resource.isLoaded)
				return;
			
			if (!_frames)
				_frames = new Vector.<CoordinateDataVO>();
			
			while (_frames.length > 0)
				_frames.splice(0, 1);
			
			//Building list of rectangles that point to frames
			var objectDataObject:* = ObjectUtil.getClassInfo(resource.jsonData.frames);
			
			for (var i:int = 0; i < objectDataObject.properties.length; i++) {
				var frameData:Object = resource.jsonData.frames[objectDataObject.properties[i]];
				_frames.push(new CoordinateDataVO(
							 new Rectangle(frameData.frame.x, frameData.frame.y, frameData.frame.w, frameData.frame.h),
							 new Point(frameData.sourceSize.w, frameData.sourceSize.h),
							 new Rectangle(frameData.spriteSourceSize.x, frameData.spriteSourceSize.y, frameData.spriteSourceSize.w, frameData.spriteSourceSize.h),
							 frameData.rotated,
							 frameData.trimmed,
							 i
							 ));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		[EditorData(ignore="true")]
		public function set owningSheet(value:ISpriteSheet):void {
			/*if(_owningSheet && value)
			   Logger.warn(this, "set OwningSheet", "Already assigned to a sheet, reassigning may result in unexpected behavior.");*/
			_owningSheet = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get frameCount():int {
			if (!_frames)
				return 0;
			return _frames.length;
		}
		
		/**
		 * The resource that holds the json data with frame coordinates
		 */
		private var _resource:JSONResource;
		
		public function get resource():JSONResource { return _resource; }
		
		public function set resource(obj:JSONResource):void {
			_resource = obj;
			buildFrames();
			//if(_owningSheet) _owningSheet.divider = this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():ISpriteSheetDivider {
			var c:PackedSheetDivider = new PackedSheetDivider();
			c.resource = resource;
			return c;
		}
		
		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			_owningSheet = null;
			_resource = null;
			_frames = null;
		}
		
		private var _owningSheet:ISpriteSheet;
	}
}
import flash.geom.Point;
import flash.geom.Rectangle;

final class CoordinateDataVO {
	public var frameBounds:Rectangle;
	public var originalFrameSize:Point;
	public var originalFrameTrimmedBounds:Rectangle;
	public var rotated:Boolean;
	public var trimmed:Boolean;
	public var index:int;
	
	public function CoordinateDataVO(frameBounds:Rectangle, originalFrameSize:Point, originalFrameTrimmedBounds:Rectangle, rotated:Boolean, trimmed:Boolean, index:int):void {
		this.frameBounds = frameBounds;
		this.originalFrameSize = originalFrameSize;
		this.originalFrameTrimmedBounds = originalFrameTrimmedBounds;
		this.rotated = rotated;
		this.trimmed = trimmed;
		this.index = index;
	}
}
