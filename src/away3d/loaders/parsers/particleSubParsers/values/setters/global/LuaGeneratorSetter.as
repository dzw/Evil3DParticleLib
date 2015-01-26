package away3d.loaders.parsers.particleSubParsers.values.setters.global
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import away3d.animators.data.ParticleProperties;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.math.Matrix3DUtils;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class LuaGeneratorSetter extends SetterBase
	{
		private var _luaState:int;
		private var _code:String;
		private var _id:String;
		private var _subGeoms:Vector.<GeometryData>;
		
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
		
		
		//lua function
		public function getModelVertexNum(name:String):Number
		{
			var geomData:GeometryData = findGeometryDataByName(name);
			if(geomData)
				return geomData.subGeom.numVertices;
			else
				return 0;
		}
		//lua function
		public function getModelVertexPositionByIndex(name:String, index:int):Vector3D
		{
			var geomData:GeometryData = findGeometryDataByName(name);
			var result:Vector3D = Matrix3DUtils.CALCULATION_VECTOR3D;
			result.x = result.y = result.z = 0;
			if(geomData) {
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

class GeometryData
{
	public var subGeom:CompactSubGeometry;
	public var name:String;
}
