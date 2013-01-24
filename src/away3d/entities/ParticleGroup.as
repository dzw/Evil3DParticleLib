package away3d.entities
{
	import away3d.animators.ParticleAnimator;
	import away3d.animators.ParticleGroupAnimator;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.states.ParticleFollowState;
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.parsers.particleSubParsers.utils.ParticleInstanceProperty;
	
	
	public class ParticleGroup extends ObjectContainer3D
	{
		protected var _animator:ParticleGroupAnimator;
		protected var _particleMeshes:Vector.<Mesh>;
		protected var _instanceProperties:Vector.<ParticleInstanceProperty>;
		
		protected var _followParticleContainer:FollowParticleContainer;
		
		protected var _showBounds:Boolean;
		
		public function ParticleGroup(particleMeshes:Vector.<Mesh>, instanceProperties:Vector.<ParticleInstanceProperty>)
		{
			_followParticleContainer = new FollowParticleContainer();
			addChild(_followParticleContainer);
			
			_particleMeshes = particleMeshes;
			_instanceProperties = instanceProperties;
			
			_animator = new ParticleGroupAnimator(particleMeshes, instanceProperties);
			
			for (var index:int; index < particleMeshes.length; index++)
			{
				var mesh:Mesh = particleMeshes[index];
				var instanceProperty:ParticleInstanceProperty = instanceProperties[index];
				if (instanceProperty)
					instanceProperty.apply(mesh);
				if (isFollowParticle(mesh))
				{
					_followParticleContainer.addFollowParticle(mesh);
				}
				else
				{
					addChild(mesh);
				}
			}
		}
		
		public function get particleMeshes():Vector.<Mesh>
		{
			return _particleMeshes;
		}
		
		public function get showBounds():Boolean
		{
			return _showBounds;
		}
		
		public function set showBounds(value:Boolean):void
		{
			_showBounds = value;
			for each (var mesh:Mesh in _particleMeshes)
			{
				mesh.showBounds = _showBounds;
			}
		}
		
		public function get animator():ParticleGroupAnimator
		{
			return _animator;
		}
		
		private function isFollowParticle(mesh:Mesh):Boolean
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (animator)
			{
				var followNode:ParticleFollowNode = animator.animationSet.getAnimation("ParticleFollowLocalDynamic") as ParticleFollowNode;
				if (followNode)
				{
					return true;
				}
			}
			return false;
		}
	
	}

}
