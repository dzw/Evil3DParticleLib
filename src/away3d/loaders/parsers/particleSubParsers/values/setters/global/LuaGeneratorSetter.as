package away3d.loaders.parsers.particleSubParsers.values.setters.global
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import away3d.animators.data.ParticleProperties;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.math.Matrix3DUtils;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.primitives.LineShape;
	import away3d.primitives.SubLineShape;
	
	public class LuaGeneratorSetter extends SetterBase
	{
		private var _luaState:int;
		private var _code:String;
		private var _id:String;
		private var _subGeoms:Vector.<GeometryData>;
		private var _lineShapes:Vector.<LineShapeData>;
		
		private static var refs:Dictionary = new Dictionary(true);
		private static var id:uint;
		//public for editor
		public static const geomCode:String = "__instanceLuaGeneratorSetter = nil\n" + 
			"function __initGeomCode()\n" +
			" __instanceLuaGeneratorSetter = flash.callstatic(\"away3d.loaders.parsers.particleSubParsers.values.setters.global.LuaGeneratorSetter\", \"getInstanceById\", thisId)\n" +
			"end\n" +
			"function getModelVertexNum(name)\n" +
			" return flash.asnumber(flash.call(__instanceLuaGeneratorSetter, \"getModelVertexNum\", name))\n" +
			"end\n"+
			"function getModelVertexPositionByIndex(name,index)\n" +
			" local vec = flash.call(__instanceLuaGeneratorSetter, \"getModelVertexPositionByIndex\", name, index)\n" +
			" local result = {x=flash.asnumber(flash.getprop(vec,\"x\"));y=flash.asnumber(flash.getprop(vec,\"y\"));z=flash.asnumber(flash.getprop(vec,\"z\"))}\n" +
			" return result\n" +
			"end\n";
		public static const lineShapeCode:String = "__instanceLuaGeneratorSetter = nil\n" + 
			"function __initLineShapeCode()\n" +
			" __instanceLuaGeneratorSetter = flash.callstatic(\"away3d.loaders.parsers.particleSubParsers.values.setters.global.LuaGeneratorSetter\", \"getInstanceById\", thisId)\n" +
			"end\n" +
			"function getsubLineShapeVertexNum(name,index)\n" +
			" return flash.asnumber(flash.call(__instanceLuaGeneratorSetter, \"getsubLineShapeVertexNum\", name, index))\n" +
			"end\n"+
			"function getSubLineShapeNum(name)\n" +
			" return flash.asnumber(flash.call(__instanceLuaGeneratorSetter, \"getSubLineShapeNum\", name))\n" +
			"end\n"+
			"function getSubShapeVertexPositionByIndex(name,subLineIndex,pIndex)\n" +
			" local vec = flash.call(__instanceLuaGeneratorSetter, \"getSubShapeVertexPositionByIndex\", name, subLineIndex, pIndex)\n" +
			" local result = {x=flash.asnumber(flash.getprop(vec,\"x\"));y=flash.asnumber(flash.getprop(vec,\"y\"));z=flash.asnumber(flash.getprop(vec,\"z\"))}\n" +
			" return result\n" +
			"end\n"+
			"function getLineShapePositionByNumber(name,subLineIndex,number)\n" +
			" local vec = flash.call(__instanceLuaGeneratorSetter, \"getLineShapePositionByNumber\", name, subLineIndex, number)\n" +
			" local result = {x=flash.asnumber(flash.getprop(vec,\"x\"));y=flash.asnumber(flash.getprop(vec,\"y\"));z=flash.asnumber(flash.getprop(vec,\"z\"))}\n" +
			" return result\n" +
			"end\n";
		
		public static function getInstanceById(id:String):LuaGeneratorSetter
		{
			return refs[id];
		}
		
		public function LuaGeneratorSetter(propName:String, code:String)
		{
			super(propName);
			_code = "function __main()\n" + code + "\nend\n";
			_id = (id++).toString();
			refs[_id] = this;
		}
		
		public function addSubGeometry(subGeom:CompactSubGeometry, name:String):void
		{
			if(!_subGeoms)
			{
				_subGeoms = new Vector.<GeometryData>;
				_code += geomCode;
			}
			var data:GeometryData = new GeometryData;
			data.subGeom = subGeom;
			data.name = name;
			_subGeoms.push(data);
		}
		
		public function addLineShape(lineShape:LineShape, name:String):void
		{
			if(!_lineShapes)
			{
				_lineShapes = new Vector.<LineShapeData>;
				_code += lineShapeCode;
			}
			var data:LineShapeData = new LineShapeData;
			data.lineShape = lineShape;
			data.name = name;
			_lineShapes.push(data);
		}
		
		//lua function
		public function getModelVertexNum(name:String):Number
		{
			var geomData:GeometryData = findGeometryDataByName(name);
			if(geomData)
				return geomData.subGeom.numVertices;
			return 0;
		}
		
		/**
		 * Used to get the number of vertices of a specified subLineShape in a LineShape
		 * @param name the shape's name
		 * @param subLineIndex the index of the subLineShape in the lineShape
		 * 
		 * @return the number of vertices in the subline
		 * 
		 */
		public function getsubLineShapeVertexNum(name:String, subLineIndex:int):Number
		{
			var subLine:SubLineShape = findSubLineShape(name, subLineIndex);
			var result:int;
			if(subLine) 
			{				
				result = subLine.numVertices;
			}
			
			return result;
		}	
				
		//lua function
		public function getModelVertexPositionByIndex(name:String, index:int):Vector3D
		{
			var geomData:GeometryData = findGeometryDataByName(name);
			var result:Vector3D = Matrix3DUtils.CALCULATION_VECTOR3D;
			result.x = result.y = result.z = 0;
			if(geomData) 
			{
				var subGeom:CompactSubGeometry = geomData.subGeom;
				if(index<0)
					index = 0;
				else if(index > subGeom.numVertices-1)
					index = subGeom.numVertices - 1;
				var pos:int = index*subGeom.vertexStride + subGeom.vertexOffset;
				result.x = subGeom.vertexData[pos];
				result.y = subGeom.vertexData[pos+1];
				result.z = subGeom.vertexData[pos+2];
				
			}
			return result;
		}
						
		//lua function
		/**
		 * This method returns a vertex's position on the specified subLineShape.
		 * @param name the shape's name
		 * @param subLineIndex the index of the subLineShape in lineShape
		 * @param pIndex the vertex index in the subLine to get
		 * 
		 * @return the position vector3d of the index
		 * 
		 */
		public function getSubShapeVertexPositionByIndex(name:String, subLineIndex:int, pIndex:int):Vector3D
		{
			var subLine:SubLineShape = findSubLineShape(name, subLineIndex);
			var result:Vector3D = Matrix3DUtils.CALCULATION_VECTOR3D;
			result.x = result.y = result.z = 0;
			if(subLine) 
			{				
				if(pIndex < 0)
					pIndex = 0;
				else if(pIndex >= subLine.numVertices)
					pIndex = subLine.numVertices - 1;
				result = subLine.getVertexByIndex(pIndex);
			}
				
			return result;
		}
		
		/**
		 * This method returns a point vector interpolated on the specified subLineShape.
		 * @param name the shape's name
		 * @param subLineIndex the index of the subLineShape in lineShape
		 * @param number a value between 0 and 1, the position along the curve, where 0 is the start and 1 is the end.
		 * 
		 * @return the position of the interpolated point
		 * 
		 */
		public function getLineShapePositionByNumber(name:String, subLineIndex:int, number:Number):Vector3D
		{
			var subLine:SubLineShape = findSubLineShape(name, subLineIndex);
			var result:Vector3D = Matrix3DUtils.CALCULATION_VECTOR3D;
			result.x = result.y = result.z = 0;
			if(subLine) 
			{				
				result = subLine.interpolateLine(number);
			}
			return result;
		}
		
		//lua function
		/**
		 * 
		 * @param name the shape's name
		 * @return the number of subLineShape in a LineShape
		 * 
		 */
		public function getSubLineShapeNum(name:String):int
		{
			var data:LineShapeData = findLineShapeDataByName(name);
			var result:int;
			if(data) 
			{				
				result = data.lineShape.subLinesNum;
			}
			return result;
		}
		
		private function findGeometryDataByName(name:String):GeometryData
		{
			if(!_subGeoms)
				return null;
			for each(var geomData:GeometryData in _subGeoms)
			{
				if(geomData.name==name)
					return geomData;
			}
			return null;
		}
		
		private function findSubLineShape(name:String, subLineIndex:int):SubLineShape
		{
			if(!_lineShapes)
				return null;
			for each(var data:LineShapeData in _lineShapes)
			{
				if(data.name == name)
				{
					if(subLineIndex < 0)
						subLineIndex = 0;
					else if(subLineIndex >= data.lineShape.subLinesNum)
						subLineIndex = data.lineShape.subLinesNum - 1;
					
					return data.lineShape.getLineByIndex(subLineIndex);
				}
			}
			return null;
		}
		
		private function findLineShapeDataByName(name:String):LineShapeData
		{
			if(!_lineShapes)
				return null;
			for each(var data:LineShapeData in _lineShapes)
			{
				if(data.name == name)
				{					
					return data;
				}
			}
			return null;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			_luaState = Lua.luaL_newstate();
			Lua.luaL_openlibs(_luaState);
			Lua.lua_getglobal(_luaState, "math");
			Lua.lua_getfield(_luaState, -1, "randomseed");
			Lua.lua_remove(_luaState, -2);
			Lua.lua_pushnumber(_luaState, Math.random() * 10000);
			Lua.lua_callk(_luaState, 1, 0, 0, null);
			prop.luaState = _luaState;
			
			Lua.lua_pushstring(_luaState,_id);
			Lua.lua_setglobal(_luaState, "thisId");
			
			var err:int = Lua.luaL_loadstring(_luaState, _code + geomCode);
			if (err)
				onError("Lua Parse Error " + err + ": " + Lua.luaL_checklstring(_luaState, 1, 0));

			err = Lua.lua_pcallk(_luaState, 0, Lua.LUA_MULTRET, 0, 0, null);
			if (err)
				onError("Lua Execute Error " + err + ": " + Lua.luaL_checklstring(_luaState, 1, 0));
			
			if(_subGeoms)
			{
				Lua.lua_getglobal(_luaState, "__initGeomCode");
				Lua.lua_callk(_luaState, 0, 0, 0, null);
			}
			if(_lineShapes)
			{
				Lua.lua_getglobal(_luaState, "__initLineShapeCode");
				Lua.lua_callk(_luaState, 0, 0, 0, null);
			}
		}
		
		private function onError(e:*):void
		{
			trace(e);
			Lua.lua_close(_luaState);
			_luaState = 0;
			throw(new Error(e));
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			Lua.lua_pushnumber(_luaState, prop.index);
			Lua.lua_setglobal(_luaState, "index");
			Lua.lua_pushnumber(_luaState, prop.total);
			Lua.lua_setglobal(_luaState, "total");
			Lua.lua_getglobal(_luaState, "__main");
			Lua.lua_callk(_luaState, 0, 0, 0, null);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			Lua.lua_close(_luaState);
			_luaState = 0;
		}
	}
}

import away3d.core.base.CompactSubGeometry;
import away3d.primitives.LineShape;

class GeometryData
{
	public var subGeom:CompactSubGeometry;
	public var name:String;
}

class LineShapeData
{
	public var lineShape:LineShape;
	public var name:String;
}

