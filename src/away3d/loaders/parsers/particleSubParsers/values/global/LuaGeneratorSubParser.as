package away3d.loaders.parsers.particleSubParsers.values.global
{
	import flash.net.URLRequest;
	
	import away3d.arcane;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Geometry;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.global.LuaGeneratorSetter;
	
	use namespace arcane;
	public class LuaGeneratorSubParser extends ValueSubParserBase
	{
		public function LuaGeneratorSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_setter = new LuaGeneratorSetter(_propName, _data.code);
				if (_data.geoms)
				{
					for(var i:int=0;i<_data.geoms.length;i++ )
					{
						addDependency(i.toString(), new URLRequest(_data.geoms[i].url));
					}
				}
			}
			if (super.proceedParsing() == PARSING_DONE)
			{
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var assets:Vector.<IAsset> = resourceDependency.assets;
			var len:int = assets.length;
			for (var i:int; i < len; i++)
			{
				var asset:IAsset = assets[i];
				if (asset.assetType == AssetType.GEOMETRY)
				{
					LuaGeneratorSetter(_setter).addSubGeometry(Geometry(asset).subGeometries[0] as CompactSubGeometry, _data.geoms[int(resourceDependency.id)].name);
					return;//only retrive the first one
				}
			}
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.LuaGeneratorSubParser;
		}
	}
}
