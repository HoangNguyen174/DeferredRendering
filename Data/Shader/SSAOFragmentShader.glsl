#version 400

uniform sampler2D u_positionTexture; 
uniform sampler2D u_normalViewTexture;
uniform sampler2D u_ssaoNoiseTexture;
uniform sampler2D u_depthTexture;

uniform vec3	  u_ssaoKernel[64];
uniform	int		  u_kernelSize;
uniform float	  u_radius;
uniform vec2	  u_screenDimension;

uniform mat4	  u_projectionMatrix;
uniform mat4	  u_viewMatrix;

in vec2			  v_texCoords;

out vec4	      o_fragColor;

const float NEAR = 0.1;
const float FAR = 1000.0;

float LinearizeDepth( float depth )
{
    float z = depth * 2.0 - 1.0;
    return (2.0 * NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));	
}

void main()
{
	vec2 noiseScale = u_screenDimension / 8.0;

	vec2 texCoords = v_texCoords;
	int kernelSize = u_kernelSize;

	vec3 pixelPos = texture( u_positionTexture, texCoords ).xyz;
	vec3 pixelViewNormal = normalize( texture( u_normalViewTexture, texCoords ).xyz );
	vec3 randomVec = texture( u_ssaoNoiseTexture, texCoords * noiseScale ).xyz;

	vec3 tangent = normalize( randomVec - pixelViewNormal * dot( randomVec, pixelViewNormal ) );
	vec3 bitangent = normalize( cross( pixelViewNormal, tangent ) );
	mat3 tbn = mat3( tangent, bitangent, pixelViewNormal );

	vec3 pixelViewPos = pixelPos;//( u_viewMatrix * vec4( pixelPos, 1.0 ) ).xyz;
	pixelViewPos = ( u_viewMatrix * vec4( pixelPos, 1.0 ) ).xyz;

	float occlusion = 0.0;
	for( int i = 0; i < kernelSize; ++i )
	{
		vec3 ssaoSample = tbn * u_ssaoKernel[i];

		ssaoSample = pixelViewPos + ssaoSample * u_radius;

		vec4 projectedSample = vec4( ssaoSample, 1.0 );
		projectedSample = u_projectionMatrix * projectedSample;
		projectedSample.xy /= projectedSample.w;
		projectedSample.xy = projectedSample.xy * 0.5 + vec2( 0.5 );

		float sampleDepth = -texture( u_positionTexture, projectedSample.xy ).w;
	//	float sampleDepth = texture( u_depthTexture, projectedSample.xy ).r;
	//	sampleDepth = LinearizeDepth( sampleDepth );

		float rangeCheck = abs( pixelViewPos.z - sampleDepth ) < u_radius ? 1.0 : 0.0;
	//	float rangeCheck = smoothstep( 1.0, 0.0, u_radius / abs( pixelViewPos.z - sampleDepth ));
		occlusion += ( sampleDepth >= ssaoSample.z ? 1.0 : 0.0 ) * rangeCheck;
	}

	occlusion = 1.0 - ( occlusion / u_kernelSize );
	occlusion = pow( occlusion, 2 );

//	float depth = texture( u_depthTexture, texCoords ).r;
//	depth = LinearizeDepth( depth ) / FAR;

//	float depth1 = texture( u_positionTexture, texCoords ).w;
//	depth1 /= FAR;

	o_fragColor = vec4( vec3( occlusion ), 1.0 );
//	o_fragColor = vec4( u_ssaoKernel[40], 1.0 );
//	o_fragColor = vec4( depth );
//	o_fragColor = vec4( pixelViewNormal , 1.0 );
//	o_fragColor = vec4( pixelViewPos , 1.0 );
//	o_fragColor = texture2D( u_ssaoNoiseTexture, texCoords * noiseScale );
}
