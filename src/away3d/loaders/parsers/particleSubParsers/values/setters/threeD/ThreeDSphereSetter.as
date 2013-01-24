package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class ThreeDSphereSetter extends SetterBase
	{
		private var _innerRadius:Number;
		private var _outerRadius:Number;
		private var _centerX:Number;
		private var _centerY:Number;
		private var _centerZ:Number;
		
		public function ThreeDSphereSetter(propName:String, innerRadius:Number, outerRadius:Number, centerX:Number, centerY:Number, centerZ:Number)
		{
			super(propName);
			_innerRadius = innerRadius;
			_outerRadius = outerRadius;
			_centerX = centerX;
			_centerY = centerY;
			_centerZ = centerZ;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var radius:Number = Math.random() * (_outerRadius - _innerRadius) + _innerRadius;
			return new Vector3D(radius * Math.sin(degree1) * Math.cos(degree2) + _centerX, radius * Math.cos(degree1) * Math.cos(degree2) + _centerY, radius * Math.sin(degree2) + _centerZ);
		}
	}

}
