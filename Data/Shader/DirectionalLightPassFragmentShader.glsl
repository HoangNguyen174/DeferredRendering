#version 400

uniform sampler2D u_positionTexture; 
uniform sampler2D u_normalTexture;
uniform sampler2D u_diffuseTexture;
uniform sampler2D u_shadowTexture;
uniform sampler2D u_ssaoTexture;

uniform vec3 u_lightPosition;
uniform vec4 u_lightColorAndBrightness;
uniform vec3 u_lightDirection;

uniform vec3 u_cameraPosition;
uniform mat4 u_lightViewMatrix;
uniform mat4 u_lightProjectionMatrix;

uniform float u_viewportWidth;
uniform float u_viewportHeight;
uniform float u_lightAmbientness;

out vec4 o_fragColor;

float CalculateShadowFactor( vec3 pixelPosition, vec3 pixelNormal )
{
	mat4 cameraWorldToProjectedLightSpace = u_lightProjectionMatrix * u_lightViewMatrix;
	vec4 projectedCameraDir = cameraWorldToProjectedLightSpace * vec4( pixelPosition, 1.0 );
	projectedCameraDir.xyz = projectedCameraDir.xyz / projectedCameraDir.w;

	vec2 texCoords;
	texCoords.x = projectedCameraDir.x * 0.5 + 0.5;
	texCoords.y = projectedCameraDir.y * 0.5 + 0.5;

	float bias = 0.0001;
	vec3 lightDir = normalize( u_lightDirection );

//	bias = max( 0.005 * ( 1.0 - dot( pixelNormal, lightDir ) ), 0.0005 );

	float closestDepth = texture2D( u_shadowTexture, texCoords ).r;
	float currentDepth = ( projectedCameraDir.z * 0.5 + 0.5 );

	float shadow = 0.0;
	vec2 texelSize = 1.0 / textureSize( u_shadowTexture, 0 );
	for(int x = -1; x <= 1; ++x)
	{
	    for(int y = -1; y <= 1; ++y)
	    {
	        float pcfDepth = texture2D( u_shadowTexture, texCoords.xy + vec2(x, y) * texelSize ).r; 
	        shadow += ( ( currentDepth - bias ) < pcfDepth ? 1.0 : 0.3 );        
	    }    
	}
	shadow /= 9.0;

	return shadow;
}

void main()
{
	vec2 texCoords = gl_FragCoord.xy / vec2( u_viewportWidth, u_viewportHeight ); 
	vec3 pixelPosition = texture2D( u_positionTexture, texCoords ).xyz;
	vec3 pixelNormal = texture2D( u_normalTexture, texCoords ).xyz;
	pixelNormal = normalize( pixelNormal );
	vec3 pixelDiffuseColor = texture2D( u_diffuseTexture, texCoords ).xyz;

	vec3 lightColor = u_lightColorAndBrightness.rgb;
	float lightBrightness = u_lightColorAndBrightness.a;
	vec3 lightDirection = u_lightDirection;

	float lightDiffuseIntensity = dot( -lightDirection, pixelNormal );

	vec3 lightDiffuseColor = clamp( lightColor * lightBrightness *  lightDiffuseIntensity , vec3( 0.0 ), vec3( 1.0 ) );

	float ambientOcclusion = texture( u_ssaoTexture, texCoords ).r;

	vec3 ambientColor = clamp( vec3 ( u_lightAmbientness * ambientOcclusion ), vec3(0.0), vec3(1.0) );

	vec3 cameraToPixel = pixelPosition - u_cameraPosition;

	float shadowFactor = CalculateShadowFactor( pixelPosition, pixelNormal );

	vec3 totalColor = ambientColor + lightDiffuseColor * shadowFactor;
	
	vec3 pixelFragmentColor = pixelDiffuseColor * totalColor;

	o_fragColor = vec4( pixelFragmentColor, 1.0 );

}

