package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;

	public class ParticleBillboardNodeSubParser extends ParticleNodeSubParserBase
	{
		public function ParticleBillboardNodeSubParser()
		{
			super();
			_particleAnimationNode = new ParticleBillboardNode();
		}

		public static function get identifier():*
		{
			return AllIdentifiers.ParticleBillboardNodeSubParser;
		}
	}
}
