package away3d.animators
{
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.entities.Mesh;
	import away3d.events.ParticleGroupEvent;
	
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
			for each( var event:ParticleGroupEventProperty in eventList)
			{
				if(event.customName == "end")
				{
					_duration = event.occurTime * 1000;
					break;
				}
			}
		}
		
		public function set looping(value:Boolean):void
		{
			_looping = value;
		}

		override protected function updateState(time:int):void
		{
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				animator.time =  -animatorTimeOffset[index] + time * animator.playbackSpeed;
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
	
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return null;
		}
		
		override public function hasAnimationSet():Boolean
		{
			return false;
		}
		
		override public function hasAnimationNode():Boolean
		{
			return false;
		}
	}

}
