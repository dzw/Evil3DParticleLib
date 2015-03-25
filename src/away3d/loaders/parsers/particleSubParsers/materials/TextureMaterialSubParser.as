package away3d.loaders.parsers.particleSubParsers.materials
{
	import flash.net.URLRequest;
	
	import away3d.Away3D;
	import away3d.arcane;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.color.ConstColorValueSubParser;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.textures.BitmapAsyncTexture;
	import away3d.textures.EtfBitmapAsyncTexture;
	import away3d.textures.Texture2DBase;

	use namespace arcane;
	
	public class TextureMaterialSubParser extends MaterialSubParserBase
	{
		private var _texture:TextureMaterial;
		
		private var _repeat:Boolean;
		private var _smooth:Boolean;
		private var _alphaBlending:Boolean;
		private var _alphaThreshold:Number = 0;
		private var _useColorTransform:Boolean;
		private var _colorTransformValue:ConstColorValueSubParser;
		
		public function TextureMaterialSubParser()
		{
		
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_repeat = _data.repeat;
				_smooth = _data.smooth;
				_alphaBlending = _data.alphaBlending;
				_alphaThreshold = _data.alphaThreshold;
				
				if(_data.useColorTransform)
				{
					_useColorTransform = _data.useColorTransform;
					
					var object:Object;
					var Id:Object;
					var subData:Object;
					
					object = _data.colorTransform;
					subData = object.data;
					_colorTransformValue = new ConstColorValueSubParser(null);
					addSubParser(_colorTransformValue);
					_colorTransformValue.parseAsync(subData);				
				}
				
				if (_data.url)
				{
					var path:String = _data.url;
					if(Away3D.USE_ATF_FOR_TEXTURES)
						path+=".atf";
					var req:URLRequest = new URLRequest(path);
					if(Away3D.USE_ASYNC_TEXTURES)
					{
						var hasAlpha:Boolean = true;
						if(path.toLocaleLowerCase().indexOf(".jpg")!=-1)
							hasAlpha = false;
						var texture:BitmapAsyncTexture;
						if(Away3D.USE_TEXTURES_ETF_FORMAT && hasAlpha)
						{
							req.url += ".etf";
							texture = new EtfBitmapAsyncTexture();
						}
						else
						{
							texture = new BitmapAsyncTexture(hasAlpha);
						}
						dispatchAskForAsyncURL(req);
						texture.load(req);
						finalizeAsset(texture);
						_texture = new TextureMaterial(texture, _smooth, _repeat);
						_texture.bothSides = _data.bothSide;
						_texture.alphaBlending = _alphaBlending;
						_texture.blendMode = _data.blendMode ? _data.blendMode : _blendMode ;
						_texture.alphaThreshold = _alphaThreshold;
						if(_useColorTransform)
							_texture.colorTransform = _colorTransformValue.setter.generateOneValue(0,1);
						finalizeAsset(_texture);
					}
					else
						addDependency("default1", req, false, null, true);
				}
				else
				{
					dieWithError("no texture url");
					return MORE_TO_PARSE;
				}
			}
			return super.proceedParsing();
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var assets:Vector.<IAsset> = resourceDependency.assets;
			var len:int = assets.length;
			for (var i:int; i < len; i++)
			{
				var asset:IAsset = assets[i];
				if (asset.assetType == AssetType.TEXTURE)
				{
					//retire the first bitmapTexture
					_texture = new TextureMaterial(asset as Texture2DBase, _smooth, _repeat);
					_texture.bothSides = _bothSide;
					_texture.alphaBlending = _alphaBlending;
					_texture.blendMode = _blendMode;
					_texture.alphaThreshold = _alphaThreshold;
					if(_useColorTransform)
						_texture.colorTransform = _colorTransformValue.setter.generateOneValue(0,1);
					finalizeAsset(_texture);
					return;
				}
			}
			dieWithError("resolveDependencyFailure");
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			//create a material with default texture2dbase
			_texture = new TextureMaterial(DefaultMaterialManager.getDefaultCompressedTexture(0), _smooth, _repeat);
			_texture.bothSides = _bothSide;
			_texture.alphaBlending = _alphaBlending;
			_texture.blendMode = _blendMode;
			_texture.alphaThreshold = _alphaThreshold;
			if(_useColorTransform)
				_texture.colorTransform = _colorTransformValue.setter.generateOneValue(0,1);
			finalizeAsset(_texture);
			
//			dieWithError("resolveDependencyFailure");
		}
		
		override public function get material():MaterialBase
		{
			return _texture;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.TextureMaterialSubParser;
		}
	
	}

}
