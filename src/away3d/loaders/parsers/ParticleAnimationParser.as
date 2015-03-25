package away3d.loaders.parsers
{
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import away3d.arcane;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.bounds.BoundingSphere;
	import away3d.core.base.ParticleGeometry;
	import away3d.entities.EntityLayerType;
	import away3d.entities.Mesh;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.materials.MaterialSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.nodes.ParticleNodeSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.nodes.ParticleTimeNodeSubParser;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	
	use namespace arcane;
	
	public class ParticleAnimationParser extends CompositeParserBase
	{
		private var _particleMesh:Mesh;
		private var _particleAnimator:ParticleAnimator;
		private var _particleAnimationSet:ParticleAnimationSet;
		private var _particleGeometry:ParticleGeometry;
		private var _bounds:Number;
		private var _displayLevel:int;
		private var _animatorLayer:int;
		
		private var _nodeParsers:Vector.<ParticleNodeSubParserBase>;
		private var _particleMaterialParser:MaterialSubParserBase;
		private var _particlegeometryParser:ParticleGeometryParser;
		private var _globalValues:Vector.<ValueSubParserBase>;
		
		
		public function ParticleAnimationParser()
		{
		}
		
		public static function supportsType(extension:String):Boolean
		{
			extension = extension.toLowerCase();
			return extension == "pam";
		}
		
		public static function supportsData(data:*):Boolean
		{
			return false;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				//bounds
				_bounds = _data.bounds;
				
				//display level
				_displayLevel = _data.displayLevel;
				
				_animatorLayer = _data.animatorLayer;
				//material
				var object:Object = _data.material;
				var id:Object = object.id;
				var subData:Object = object.data;
				var parserCls:Class = MatchingTool.getMatchedClass(id, AllSubParsers.ALL_MATERIALS);
				if (!parserCls)
				{
					dieWithError("Unknown matierla parser");
				}
				
				_particleMaterialParser = new parserCls();
				addSubParser(_particleMaterialParser);
				_particleMaterialParser.parseAsync(subData);
				
				
				//animation nodes:
				_nodeParsers = new Vector.<ParticleNodeSubParserBase>;
				
				var nodeDatas:Array = _data.nodes;
				
				for each (var nodedata:Object in nodeDatas)
				{
					subData = nodedata.data;
					id = nodedata.id;
					parserCls = MatchingTool.getMatchedClass(id, AllSubParsers.ALL_PARTICLE_NODES);
					
					if (!parserCls)
					{
						dieWithError("Unknown node parser");
					}
					
					var nodeParser:ParticleNodeSubParserBase = new parserCls;
					addSubParser(nodeParser);
					nodeParser.parseAsync(subData);
					_nodeParsers.push(nodeParser);
				}
				
				var globalValuesDatas:Array = _data.globalValues;
				if (globalValuesDatas)
				{
					_globalValues = new Vector.<ValueSubParserBase>;
					for each (var valuedata:Object in globalValuesDatas)
					{
						subData = valuedata.data;
						id = valuedata.id;
						parserCls = MatchingTool.getMatchedClass(id, AllSubParsers.ALL_GLOBAL_VALUES);
						if (!parserCls)
						{
							dieWithError("Unknown node parser");
						}
						var valueParser:ValueSubParserBase = new parserCls(null);
						addSubParser(valueParser);
						valueParser.parseAsync(subData);
						_globalValues.push(valueParser);
					}
				}
				
				
				//geometry:
				var geometryData:Object = _data.geometry;
				if (geometryData.embed)
				{
					_particlegeometryParser = new ParticleGeometryParser();
					addSubParser(_particlegeometryParser);
					_particlegeometryParser.parseAsync(geometryData.data);
				}
				else
				{
					addDependency("geometry", new URLRequest(geometryData.url), true);
				}
			}
			
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				generateAnimation();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			if (resourceDependency.id == "geometry")
			{
				_particlegeometryParser = new ParticleGeometryParser();
				addSubParser(_particlegeometryParser);
				_particlegeometryParser.parseAsync(resourceDependency.data);
			}
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		
		private function generateAnimation():void
		{
			//animation Set:
			var timeNode:ParticleTimeNodeSubParser = _nodeParsers[0] as ParticleTimeNodeSubParser;
			_particleAnimationSet = new ParticleAnimationSet(timeNode.usesDuration, timeNode.usesLooping, timeNode.usesDelay);
			var len:int = _nodeParsers.length;
			var handlers:Vector.<SetterBase> = new Vector.<SetterBase>();
			if (_globalValues)
			{
				for each (var valueParser:ValueSubParserBase in _globalValues)
				{
					handlers.push(valueParser.setter);
				}
			}
			for (var i:int; i < _nodeParsers.length; i++)
			{
				if (i != 0)
					_particleAnimationSet.addAnimation(_nodeParsers[i].particleAnimationNode);
				var setters:Vector.<SetterBase> = _nodeParsers[i].setters;
				for each (var setter:SetterBase in setters)
				{
					handlers.push(setter);
				}
			}
			var particleInitializer:ParticleInitializer = new ParticleInitializer(handlers);
			_particleAnimationSet.initParticleFunc = particleInitializer.initHandler;
			finalizeAsset(_particleAnimationSet);
			//animator:
			_particleAnimator = new ParticleAnimator(_particleAnimationSet);
			
			//mesh:
			_particleMesh = new Mesh(_particlegeometryParser.particleGeometry, _particleMaterialParser.material);
			_particleMesh.overwriteBounds = true;
			_particleMesh.userMax.setTo(_bounds, _bounds, _bounds);
			_particleMesh.userMin.setTo(-_bounds, -_bounds, -_bounds);
			_particleMesh.bounds = new BoundingSphere();
			_particleMesh.displayLevel = _displayLevel;
			_particleMesh.zOffset = _animatorLayer;
			
			if (_data.hasOwnProperty("shareAnimationGeometry"))
			{
				_particleMesh.shareAnimationGeometry = _data.shareAnimationGeometry;
			}
			if (_data.hasOwnProperty("name"))
			{
				_particleMesh.name = _data.name;
			}
			//_particleMesh.showBounds = true;
			_particleMesh.animator = _particleAnimator;
			var extensions:Array = _data.extensions;
			if (extensions)
			{
				for each (var extension:Object in extensions)
				{
					if(_data.extensions[0]["id"] == "entityLayer")
					{
						_particleMesh.layerType = _data.extensions[0]["data"];
					}
					else if (_data.extensions[0]["id"] == "heat") // compatible with old format
						_particleMesh.layerType = EntityLayerType.HEAT_LAYER;
					else if (_data.extensions[0]["id"] == "phantom")
						_particleMesh.layerType = EntityLayerType.PHANTOM|EntityLayerType.DEFAULT;;
				}
			}
			finalizeAsset(_particleMesh);
		}
		
		public function get particleMesh():Mesh
		{
			return _particleMesh;
		}
	}

}


import away3d.animators.data.ParticleProperties;
import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;


class ParticleInitializer
{
	private var _setters:Vector.<SetterBase>;
	
	public function ParticleInitializer(setters:Vector.<SetterBase>)
	{
		_setters = setters;
	}
	
	public function initHandler(prop:ParticleProperties):void
	{
		var setter:SetterBase;
		if (prop.index == 0)
		{
			for each (setter in _setters)
			{
				setter.startPropsGenerating(prop);
			}
		}
		
		for each (setter in _setters)
		{
			setter.setProps(prop);
		}
		
		if (prop.index == prop.total - 1)
		{
			for each (setter in _setters)
			{
				setter.finishPropsGenerating(prop);
			}
		}
	}
}
