package com.pblabs.engine.scripting {
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.engine.serialization.ISerializable;
	import com.pblabs.engine.util.DynamicObjectUtil;
	
	import flash.geom.Point;
	
	import r1.deval.D;
	
	/**
	 * ExpressionReference is the wrapper for the D.eval class to run expressions in PBE.
	 * This is a very powerful class because you can access components on the entity that
	 * this reference belongs to by passing the Self property from an IEntity to this class.
	 *
	 * An expression that is run by an ExpressionReference instance also has access to the global references in a game
	 * that can be found on the PBE.GLOBAL_DYNAMIC_OBJECT object such as the Game object or Accelerometer, etc.
	 *
	 * #see com.pblabs.engine.core.GlobalExpressionManager
	 *
	 * Expressions also have access to all the static methods on the Math class such as cos(), sin(), random(), etc...
	 *
	 * <listing version="1.0">
	 * 	var expression : ExpressionReference = new ExpressionReference("(Self.Spatial.position.x * 10) - Game.Mouse.stageX", entity.Self);
	 * 	var val : Number = expression.value;
	 *
	 * 	//OR concatenate an evaluation
	 * 	var newVal : Number = expression.eval( "cos( (Self.Spatial.position.y * 10) )" ).value;
	 *
	 * 	//VERY IMPORTANT
	 * 	//Destory all expression references when finished using it.
	 * 	expression.destroy();
	 * </listing>
	 **/
	public class ExpressionReference implements ISerializable {
		private var _cachedExpression:Boolean = false;
		private var _value:*;
		private var _dynamicThisObject:Object = new Object();
		
		private static var _initialized:Boolean = false;
		
		public function ExpressionReference(expression:Object = null, selfContext:Object = null) {
			this.expression = String(expression);
			
			DynamicObjectUtil.copyDynamicObject(PBE.GLOBAL_DYNAMIC_OBJECT, _dynamicThisObject);
			
			this.selfContext = selfContext;
			initialize();
		}
		
		public function eval(str:String, context:Object = null, thisObject:* = null):ExpressionReference {
			this.expression = str;
			evaluateExpression(context, thisObject);
			return this;
		}
		
		/*--Serialization-----------------------------------------------------------------------------------------------*/
		/**
		 * @inheritDoc
		 */
		public function serialize(xml:XML):void {
			var expressionXML:XML = new XML("<![CDATA[" + _expression + "]]>");
			if (_dynamicThisObject && _dynamicThisObject.Self && _dynamicThisObject.Self["name"])
				xml.@thisObjectName = _dynamicThisObject.Self.name;
			xml.appendChild(expressionXML);
		}
		
		/**
		 * @inheritDoc
		 */
		public function deserialize(xml:XML):* {
			/*if(_expression && _expression !== xml.toString())
			   Logger.warn(this, "deserialize", "Overwriting property; was '" + _property + "', new value is '" + xml.toString() + "'");*/
			_expression = xml.toString();
			if (_dynamicThisObject && (xml.contains("thisObjectName") || xml.toString().indexOf("thisObjectName"))) {
				var entity:IEntity = PBE.lookupEntity(xml.@thisObjectName);
				if (!entity) {
					PBE.callLater(deserialize, [xml]);
					return this;
				}
				_dynamicThisObject.selfContext = entity.Self;
					//}else{
					//Logger.error(this, "deserialize", "Fatal Error deserializing Expression Reference. The @thisObjectName property is missing from the xml node tag");
			}
			return this;
		}
		
		public function destroy():void {
			DynamicObjectUtil.clearDynamicObject(_dynamicThisObject);
			_dynamicThisObject = null;
			_value = null;
			_expression = null;
		}
		
		/*-----------------------------------------------------------------------------------------------------------
		 *                                          Private Method
		   -------------------------------------------------------------------------------------------------------------*/
		private function evaluateExpression(context:Object = null, thisObject:* = null):void {
			if (thisObject == null) {
				thisObject = _dynamicThisObject;
				
				if (context)
					thisObject.Self = context;
			}
			_cachedExpression = true;
			_value = D.eval(_expression, context, thisObject);
		}
		
		private function parseExpression():void {
			//TODO Pull Out PropertyReferences
		}
		
		private function initialize():void {
			if (_initialized)
				return;
			
			D.importStaticMethods(Math);
			D.importClass(Point);
			D.importClass(PBE);
			D.importFunction("setPoint", ExpressionUtils.setPoint);
			D.importFunction("getEntity", ExpressionUtils.getEntity);
			_initialized = true;
		}
		
		/*-----------------------------------------------------------------------------------------------------------
		 *                                          Getter & Setters
		   -------------------------------------------------------------------------------------------------------------*/
		/**
		 * The evaluated value of the expression
		 */
		public function get value():* {
			evaluateExpression();
			return _value;
		}
		
		private var _expression:String = null;
		
		/**
		 * The string to the expression that this evaluates.
		 */
		public function get expression():String { return _expression; }
		
		public function set expression(str:String):void {
			if (str == null)
				return;
			
			if (_expression !== str)
				_cachedExpression = false;
			
			_expression = str;
			parseExpression();
		}
		
		public function set selfContext(obj:Object):void {
			if (!obj)
				return;
			//Copy Data to internal Object
			_dynamicThisObject.Self = obj;
		}
		
		public function get dynamicThisObject():Object { return _dynamicThisObject; }
	}
}
import com.pblabs.engine.PBE;
import com.pblabs.engine.entity.IEntity;

import flash.geom.Point;

class ExpressionUtils {
	public static function setPoint(x:Number, y:Number):Point {
		return new Point(x, y);
	}
	
	public static function getEntity(name:String):Object {
		var entity:Object = PBE.lookupEntity(name);
		return entity ? entity.Self : null;
	}
}
