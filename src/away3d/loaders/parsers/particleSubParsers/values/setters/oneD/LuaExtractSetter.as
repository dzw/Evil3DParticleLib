package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class LuaExtractSetter extends SetterBase
	{
		private var _varName:String;
		private var _luaState:int;
		
		public function LuaExtractSetter(propName:String, varName:String)
		{
			super(propName);
			_varName = varName;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			_luaState = prop.luaState;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			if (_luaState && _varName)
			{
				prop[_propName] = getVarValue(_luaState, _varName);
			}
			else
				prop[_propName] = 0;
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			if (_luaState && _varName)
			{
				return getVarValue(_luaState, _varName);
			}
			else
				return 0;
		}
		
		[Inline]
		final private function getVarValue(luaState:int, varName:String):Number
		{
			if(varName.indexOf(".")!=-1)// for example: pos.x
			{
				var vars:Array = varName.split(".");
				Lua.lua_getglobal(luaState, vars[0]);
				Lua.lua_getfield(luaState, -1, vars[1]);
				Lua.lua_remove(luaState, -2);
				return Lua.lua_tonumberx(luaState, -1, 0);
			}
			else
			{
				Lua.lua_getglobal(luaState, varName);
				return Lua.lua_tonumberx(luaState, -1, 0);
			}
		}
	}
}
