package away3d.entities
{
	import away3d.animators.ParticleAnimator;
	import away3d.animators.states.ParticleFollowState;
	import away3d.bounds.BoundingSphere;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	
	public class FollowParticleContainer extends ObjectContainer3D
	{
		
		private var _identityTransform:Matrix3D = new Matrix3D;
		private var _followTarget:TargetObject3D;
		private var _meshes:Vector.<Mesh> = new Vector.<Mesh>;
		
		public function FollowParticleContainer()
		{
			_followTarget = new TargetObject3D(this);
			addChild(_followTarget);
		}
		
		
		public function addFollowParticle(mesh:Mesh):void
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (!animator)
				throw(new Error("not a particle mesh"));
			var followState:ParticleFollowState = animator.getAnimationStateByName("ParticleFollowLocalDynamic") as ParticleFollowState;
			if (!followState)
				throw(new Error("not a follow particle"));
			followState.followTarget = _followTarget;
			addChild(mesh);
			_meshes.push(mesh);
		}
		
		public function removeFollowParticle(mesh:Mesh):void
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (!animator)
				throw(new Error("not a particle mesh"));
			var followState:ParticleFollowState = animator.getAnimationStateByName("ParticleFollowLocalDynamic") as ParticleFollowState;
			if (!followState)
				throw(new Error("not a follow particle"));
			followState.followTarget = null;
			removeChild(mesh);
			_meshes.splice(_meshes.indexOf(mesh), 1);
		}
		
		public function get originalSceneTransform():Matrix3D
		{
			return super.sceneTransform;
		}
		
		override public function get sceneTransform():Matrix3D
		{
			return _identityTransform;
		}
		
		public function updateBounds(center:Vector3D):void
		{
			for each (var mesh:Mesh in _meshes)
			{
				var bounds:BoundingSphere = mesh.bounds as BoundingSphere;
				bounds.fromSphere(center, bounds.radius);
			}
		
		}
	}
}
import away3d.containers.ObjectContainer3D;
import away3d.core.math.MathConsts;
import away3d.entities.FollowParticleContainer;

import flash.geom.Matrix3D;
import flash.geom.Orientation3D;
import flash.geom.Vector3D;

class TargetObject3D extends ObjectContainer3D
{
	private var _container:FollowParticleContainer;
	private var _helpTransform:Matrix3D = new Matrix3D;
	
	private var specificPos:Vector3D = new Vector3D;
	private var specificEulers:Vector3D = new Vector3D;
	
	public function TargetObject3D(container:FollowParticleContainer)
	{
		_container = container;
	}
	
	private function validateTransform():void
	{
		if (_sceneTransformDirty)
		{
			
			_helpTransform.copyFrom(_container.originalSceneTransform);
			var comps:Vector.<Vector3D> = _helpTransform.decompose();
			this.specificPos = comps[0];
			//TODO: find a better way to implement it
			specificEulers.x = 0;
			specificEulers.y = 0;
			specificEulers.z = 0;
			var parent:ObjectContainer3D = _container;
			while (parent)
			{
				specificEulers.x += parent.rotationX;
				specificEulers.y += parent.rotationY;
				specificEulers.z += parent.rotationZ;
				parent = parent.parent;
			}
			_sceneTransformDirty = false;
			_container.updateBounds(position);
		}
	}
	
	override public function get x():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.x;
	}
	
	override public function get y():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.y;
	}
	
	override public function get z():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.z;
	}
	
	override public function get position():Vector3D
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos;
	}
	
	override public function get rotationX():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.x;
	}
	
	override public function get rotationY():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.y;
	}
	
	override public function get rotationZ():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.z;
	}

}
