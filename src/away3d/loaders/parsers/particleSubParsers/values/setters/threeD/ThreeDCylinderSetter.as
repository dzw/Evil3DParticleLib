package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class ThreeDCylinderSetter extends SetterBase
	{
		private var _innerRadius:Number;
		private var _outerRadius:Number;
		private var _height:Number;
		private var _centerX:Number;
		private var _centerY:Number;
		private var _centerZ:Number;
		
		public function ThreeDCylinderSetter(propName:String, innerRadius:Number, outerRadius:Number, height:Number, centerX:Number, centerY:Number, centerZ:Number)
		{
			super(propName);
			_innerRadius = innerRadius;
			_outerRadius = outerRadius;
			_height = height;
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
			var h:Number = Math.random() * _height - _height / 2;
			var r:Number = _outerRadius * Math.pow(Math.random() * (1 - _innerRadius / _outerRadius) + _innerRadius / _outerRadius, 1 / 2);
			var degree1:Number = Math.random() * Math.PI * 2;
			return new Vector3D(r * Math.cos(degree1) + _centerX, h + _centerY, r * Math.sin(degree1) + _centerZ);
		}
	}

}
