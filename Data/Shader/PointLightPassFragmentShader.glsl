#version 400

uniform sampler2D u_positionTexture; 
uniform sampler2D u_normalTexture;
uniform sampler2D u_diffuseTexture;

uniform vec3 u_lightPosition;
uniform vec4 u_lightColorAndBrightness;
uniform float u_lightInnerRadius;
uniform float u_lightOuterRadius;
uniform float u_viewportWidth;
uniform float u_viewportHeight;

//layout (location = 4) out vec4 o_fragColor; 
out vec4 o_fragColor;

float SmoothStep( float value )
{
	return ( 3.0 * value * value - 2.0 * value * value * value );
}

void main()
{
	vec2 texCoords = gl_FragCoord.xy / vec2( u_viewportWidth, u_viewportHeight ); 
	vec3 pixelPosition = texture2D( u_positionTexture, texCoords ).xyz;
	vec3 pixelNormal = texture2D( u_normalTexture, texCoords ).xyz;
	pixelNormal = normalize( pixelNormal );
	vec3 pixelDiffuseColor = texture2D( u_diffuseTexture, texCoords ).xyz;

	vec3 displacementToLight = u_lightPosition - pixelPosition;
	vec3 directionToLight = normalize( displacementToLight );
	float distanceToLight = length( displacementToLight );

	float lightIntensityFromRadius = clamp( ( u_lightOuterRadius - distanceToLight  ) / ( u_lightOuterRadius - u_lightInnerRadius ) ,0.0, 1.0 );

	float lightIntensity = clamp( dot( directionToLight, pixelNormal ), 0.0, 1.0 );

	lightIntensity *= ( lightIntensityFromRadius * u_lightColorAndBrightness.a );

	lightIntensity = SmoothStep( lightIntensity );

	vec3 lightColor = u_lightColorAndBrightness.rgb * lightIntensity;

	vec3 pixelFragmentColor = lightColor * pixelDiffuseColor;

	o_fragColor = vec4( pixelFragmentColor, 1.0 );
//	o_fragColor = vec4( pixelDiffuseColor.xyz, 1.0 );
//	o_fragColor = vec4( pixelPosition.xyz, 1.0 );
//	o_fragColor = vec4( lightIntensity, 0.f, 0.f, 1.f );
//	o_fragColor = vec4( 1.0 );

}