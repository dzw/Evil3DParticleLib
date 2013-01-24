package away3d.loaders.parsers.particleSubParsers.values.setters.matrix
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Matrix;
	
	public class Matrix2DUVCompositeSetter extends SetterBase
	{
		private var _numColumns:int;
		private var _numRows:int;
		private var _selectedValue:SetterBase;
		
		public function Matrix2DUVCompositeSetter(propName:String, numColumns:int, numRows:int, selectedValue:SetterBase)
		{
			super(propName);
			_numColumns = numColumns;
			_numRows = numRows;
			_selectedValue = selectedValue;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var matrix:Matrix = new Matrix;
			matrix.scale(1 / _numColumns, 1 / _numRows);
			var index:int = _selectedValue.generateOneValue(index, total) % (_numColumns * _numRows);
			//index %= _numColumns * _numRows;
			var row:int = index / _numColumns;
			var column:int = index % _numColumns;
			matrix.translate(column / _numColumns, row / _numRows);
			return matrix;
		}
	
	}
}
