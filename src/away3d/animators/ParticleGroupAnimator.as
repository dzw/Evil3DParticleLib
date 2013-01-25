package away3d.animators
{
	import away3d.entities.Mesh;
	import away3d.loaders.parsers.particleSubParsers.utils.ParticleInstanceProperty;
	
	/**
	 * ...
	 * @author
	 */
	public class ParticleGroupAnimator extends AnimatorBase
	{
		private var animators:Vector.<ParticleAnimator> = new Vector.<ParticleAnimator>;
		private var animatorTimeOffset:Vector.<int>;
		private var numAnimator:int;
		
		public function ParticleGroupAnimator(particleAnimationMeshes:Vector.<Mesh>, instanceProperties:Vector.<ParticleInstanceProperty>)
		{
			super(null);
			numAnimator = particleAnimationMeshes.length;
			animatorTimeOffset = new Vector.<int>(particleAnimationMeshes.length, true);
			for (var index:int; index < numAnimator; index++)
			{
				var mesh:Mesh = particleAnimationMeshes[index];
				var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
				animators.push(animator);
				animator.autoUpdate = false;
				if (instanceProperties[index])
					animatorTimeOffset[index] = instanceProperties[index].timeOffset * 1000;
			}
		}
		
		override public function start():void
		{
			super.start();
			_absoluteTime = 0;
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				animator.resetTime(_absoluteTime + animatorTimeOffset[index]);
			}
		}
		
		override protected function updateDeltaTime(dt:Number):void
		{
			_absoluteTime += dt;
			for each (var animator:ParticleAnimator in animators)
			{
				animator.time = _absoluteTime;
			}
		}
		
		public function resetTime(offset:int = 0):void
		{
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				animator.resetTime(offset + animatorTimeOffset[index]);
			}
		}
	
	}

}
