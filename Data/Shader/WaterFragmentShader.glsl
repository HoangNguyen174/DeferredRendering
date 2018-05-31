#version 400
const int MAX_LIGHT_NUM = 16;
uniform vec3 u_lightPositions[MAX_LIGHT_NUM];
uniform vec4 u_lightColorAndBrightness[MAX_LIGHT_NUM];
uniform float u_lightInnerApertureDot[MAX_LIGHT_NUM];
uniform float u_lightOuterApertureDot[MAX_LIGHT_NUM];
uniform float u_lightInnerRadius[MAX_LIGHT_NUM];
uniform float u_lightOuterRadius[MAX_LIGHT_NUM];
uniform float u_lightAmbientness[MAX_LIGHT_NUM];
uniform vec3 u_lightForwardDirection[MAX_LIGHT_NUM];
uniform int u_isDirectionalLight[MAX_LIGHT_NUM];

uniform sampler3D Noise3;

uniform int enableOcclusionParallax;
uniform int enableParallax;

uniform sampler2D u_refractionDiffuseTexture;
uniform sampler2D u_normalTexture;
uniform sampler2D u_reflectionDiffuseTexture;

uniform vec3 u_lightPosition;
uniform float u_time;
uniform vec3 u_cameraWorldPosition;
uniform float u_deltaTime;


//fog
uniform float u_fogStartDistance;
uniform float u_fogEndDistance;
uniform vec4 u_fogColor;

//paralax
uniform vec2 u_scaleBias;

uniform vec4 u_clipPlane;

uniform int u_isNormalMapOn;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;
in mat4 v_tangentToWorldMatrix;
in mat4 v_worldToTangentMatrix;
in float v_noise;
in vec3 v_vertexTerrainWeight;
in vec4 v_screenPosition;

out vec4 o_fragColor;

const float WATER_LEVEL = 3.0;

void main()
{
	vec4 finalColor;
	vec3 waterNormalVector = vec3( 0.0, 0.0, 1.0 );
	const float waveLength = 0.05f;
	const float waveHeight = 0.05f;
	vec3 windDirection = vec3( 0.0, 1.0, 0.0 );
	vec3 pixelToCamera = normalize( u_cameraWorldPosition - v_worldPosition );
	float fresnelTerm = dot( pixelToCamera, waterNormalVector );

	vec4 projCoords = v_screenPosition / v_screenPosition.w;

	projCoords = ( projCoords + 1.0 ) * 0.5;
	projCoords = clamp( projCoords, 0.0, 1.0 );

	vec4 invertedProj = projCoords;
	invertedProj.y = 1.0 - projCoords.y;

	vec3 windDir = normalize( windDirection );
	vec3 perpDir = cross( windDirection, vec3( 0, 0, 1 ) );

	float yDot = dot( v_textureCoords, windDirection.xy );
	float xDot = dot( v_textureCoords, perpDir.xy );
	vec2 move = vec2( xDot, yDot );
	move.y += ( u_time * 0.005 );

	vec2 normalTexCoords = ( v_textureCoords + move ) / waveLength;
	vec4 normalTexel = texture2D( u_normalTexture, normalTexCoords );
	vec3 waterSurfaceNormal = normalize( 2.0 * normalTexel.rgb - 1.0 );

	vec2 perturbation = waveHeight * waterSurfaceNormal.rg * 2.0; 

	vec4 refractionDiffuseTexel = texture2D( u_refractionDiffuseTexture, projCoords.xy + perturbation );

	vec2 reflectionTexCoords;

	if( u_cameraWorldPosition.z < WATER_LEVEL )
	{
		reflectionTexCoords = projCoords.xy;
	}
	else
	{
		reflectionTexCoords = invertedProj.xy;
	}

	vec4 reflectionDiffuseTexel = texture2D( u_reflectionDiffuseTexture, reflectionTexCoords.xy + perturbation );

	vec4 combinedColor = mix( refractionDiffuseTexel, reflectionDiffuseTexel, fresnelTerm );
	vec4 dullColor = vec4( 0.3, 0.3, 0.6, 1.0 );
	combinedColor = mix( combinedColor, dullColor, 0.2 );

	vec3 displacementToLight;
	vec3 directionToLight;
	float lightIntensity;
	vec3 lightColor;
	vec3 totalDirectLightColor;
	vec3 totalSpecularLightColor;

	vec3 idealDirectionTolight = reflect( -pixelToCamera , waterSurfaceNormal );

	for( int i = 0; i < MAX_LIGHT_NUM; i++ )
	{
		displacementToLight = u_lightPositions[i] - v_worldPosition.xyz;
		directionToLight = normalize( displacementToLight );

		if( u_cameraWorldPosition.z < WATER_LEVEL )
			waterSurfaceNormal *= -1;
		lightIntensity = clamp( dot( directionToLight, waterSurfaceNormal ), 0.0, 1.0 );
		lightColor = ( lightIntensity * u_lightColorAndBrightness[i].rgb );
		totalDirectLightColor += lightColor;

		//specular light
		float specularIntensityOfLight = clamp( dot( idealDirectionTolight, directionToLight ),0.0,1.0 );
		specularIntensityOfLight = pow( specularIntensityOfLight, 36 );
		totalSpecularLightColor += ( specularIntensityOfLight * u_lightColorAndBrightness[i].rgb );
	}

	vec4 surfaceColor = v_color;

	finalColor =  combinedColor * surfaceColor ;

	//finalColor.rgb *= clamp( totalDirectLightColor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	//finalColor.rgb += clamp( totalSpecularLightColor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	finalColor = clamp( finalColor, vec4(0.0,0.0,0.0,0.0), vec4(1.0,1.0,1.0,1.0) );

	o_fragColor = finalColor;
}