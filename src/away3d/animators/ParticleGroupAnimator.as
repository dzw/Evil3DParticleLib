package away3d.animators
{
	import flash.display3D.Context3DProgramType;
	
	import away3d.animators.data.AnimationRegisterCache;
	import away3d.animators.data.AnimationSubGeometry;
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.animators.states.ParticleStateBase;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.events.ParticleGroupEvent;
	import away3d.materials.passes.MaterialPassBase;
	
	/**
	 * ...
	 * @author
	 */
	public class ParticleGroupAnimator extends AnimatorBase implements IAnimator
	{
		private var animators:Vector.<ParticleAnimator> = new Vector.<ParticleAnimator>;
		private var animatorTimeOffset:Vector.<int>;
		private var numAnimator:int;
		private var eventList:Vector.<ParticleGroupEventProperty>;
		
		public function ParticleGroupAnimator(particleAnimationMeshes:Vector.<Mesh>, instanceProperties:Vector.<ParticleInstanceProperty>, eventList:Vector.<ParticleGroupEventProperty>)
		{
			super(null);
			numAnimator = particleAnimationMeshes.length;
			animatorTimeOffset = new Vector.<int>(particleAnimationMeshes.length, true);
			for (var index:int; index < numAnimator; index++)
			{
				var mesh:Mesh = particleAnimationMeshes[index];
				var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
				animators.push(animator);
				if (instanceProperties[index])
					animatorTimeOffset[index] = instanceProperties[index].timeOffset * 1000;
			}
			
			this.eventList = eventList;
		}

		override public function start(beginTime:Number = NaN):void
		{
			super.start(beginTime);
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				animator.update(_time);	
				animator.resetTime(animatorTimeOffset[index]);
			}
		}
	
		override protected function updateState(time:int):void
		{
			for each (var animator:ParticleAnimator in animators)
			{
				animator.time = time;
			}
			if (eventList)
			{
				for each (var eventProperty:ParticleGroupEventProperty in eventList)
				{
					if ((eventProperty.occurTime * 1000 - _lastTime) * (eventProperty.occurTime * 1000 - _time) <= 0)
					{
						if (hasEventListener(ParticleGroupEvent.OCCUR))
							dispatchEvent(new ParticleGroupEvent(ParticleGroupEvent.OCCUR, eventProperty));
					}
				}
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
	
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{

		}
		
		/**
		 * @inheritDoc
		 */
		public function testGPUCompatibility(pass:MaterialPassBase):void
		{
			
		}
	}

}
