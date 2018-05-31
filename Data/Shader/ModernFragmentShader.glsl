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

uniform sampler2D u_diffuseTexture;
uniform sampler2D u_normalTexture;
uniform sampler2D u_emissiveTexture;
uniform sampler2D u_specularTexture;
uniform sampler2D u_depthTexture;

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

uniform int u_isNormalMapOn;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;
in mat4 v_tangentToWorldMatrix;
in mat4 v_worldToTangentMatrix;
in float v_noise;

out vec4 o_fragColor;

float SmoothStep( float value )
{
	return ( 3.0 * value * value - 2.0 * value * value * value );
}

vec2 ParallaxOcclusionRayTrace( float zStep, vec2 texStep, int sampleCount )
{
	int maxSampleIndex = sampleCount;
	int sampleIndex = 0;
	vec2 currentTexOffset;
	vec2 prevTexOffset;
	vec2 finalTexOffset;
	float currentRayZ = 1.0 - zStep;
	float prevRayZ = 1.0;
	float currentHeight = 0;
	float prevHeight = 0;

	for( sampleIndex = 0; sampleIndex < maxSampleIndex; sampleIndex++ )
	{
		currentHeight = texture2D( u_depthTexture, v_textureCoords  + currentTexOffset ).r;

		if( currentHeight > currentRayZ )
		{
			float t = ( prevHeight - prevRayZ )/ ( prevHeight - currentHeight + currentRayZ - prevRayZ );

			finalTexOffset = prevTexOffset + t * texStep;

			return v_textureCoords + finalTexOffset;
		}
		else
		{
			prevTexOffset = currentTexOffset;
			prevRayZ = currentRayZ;
			prevHeight = currentHeight;

			currentTexOffset += texStep;

			currentRayZ -= zStep;
		}
	}

	return v_textureCoords + finalTexOffset;
}

float SelfShadow( float zStep, vec2 texStep, int sampleCount, vec2 texCoords, float currentRayZ)
{
	int maxSampleIndex = sampleCount;
	int sampleIndex = 0;
	vec2 currentTexOffset;
	float shadowFactor = 1.0;
	float currentHeight;

	for( sampleIndex = 0; sampleIndex < maxSampleIndex; sampleIndex++ )
	{
		currentHeight = texture2D( u_depthTexture, texCoords + currentTexOffset ).r;

		if( currentHeight > currentRayZ )
		{
			shadowFactor = 0.3;
			return shadowFactor;
		}
		else
		{
			currentTexOffset += texStep;
			currentRayZ += zStep;
		}
	}
	return shadowFactor;
}

void main()
{
	vec2 texCoords;
	float depth = 1.0;
	float heightScale = 0.1;
	int maxSampleCount = 64;
	int minSampleCount = 8;
	float shadowFactor = 1.0;
	vec3 pixelToCamera = u_cameraWorldPosition - v_worldPosition;
	vec3 surfaceNormal = normalize( v_normal );

	float distPixToCam = length( pixelToCamera );
	vec3 pixToCamNormalize = normalize( pixelToCamera );
	vec3 pixToCamInTangentSpace = ( v_worldToTangentMatrix * vec4( pixToCamNormalize, 0.0 ) ).xyz;

	texCoords = v_textureCoords;

	//simple parallax--------------------------------------------------------------------------------------------
	if( enableParallax == 1 )
	{
		float height = texture2D( u_depthTexture, v_textureCoords ).r;
		float v = height * u_scaleBias.x - u_scaleBias.y;

		vec2 parallaxTexCoords = v_textureCoords + ( pixToCamInTangentSpace.xy * v );
		texCoords = parallaxTexCoords;
	}
	//-----------------------------------------------------------------------------------------------------------

	//Occlusion Parallax-----------------------------------------------------------------------------------------

	if( enableOcclusionParallax == 1 )
	{
		vec3 viewDirectionInTangentSpace = -pixToCamInTangentSpace;
		vec2 maxParallelOffsetVector =  -viewDirectionInTangentSpace.xy * ( heightScale / viewDirectionInTangentSpace.z );

		int sampleCount = int( mix( minSampleCount, maxSampleCount, dot( pixelToCamera, surfaceNormal ) ) );

		float zStep = 1.0 / sampleCount;
		vec2 texStep = maxParallelOffsetVector * zStep;

		texCoords = ParallaxOcclusionRayTrace( zStep, texStep, sampleCount );
		//------------------------------------------------------------------------------------------------------------

		//soft shadow-------------------------------------------------------------------------------------------------
		vec3 pixelToLight = normalize( u_lightPositions[0] - v_worldPosition );
		vec3 pixelToLightTangentSpace = ( v_worldToTangentMatrix * vec4( pixelToLight, 0.0 ) ).xyz;
		vec2 lightParallelOffsetVector = vec2( pixelToLightTangentSpace.xy ) * ( heightScale / pixelToLightTangentSpace.z );
		sampleCount = int( mix( minSampleCount, maxSampleCount, dot( pixelToLight, surfaceNormal ) ) );
		zStep = 1.0 / sampleCount;
		texStep = lightParallelOffsetVector * zStep;
		float currentHeight = texture2D( u_depthTexture, texCoords ).r + 0.1 * zStep;
		shadowFactor = SelfShadow( zStep, texStep, sampleCount, texCoords, currentHeight );
	}

	//decode normal map
	vec4 normalTexel = texture2D( u_normalTexture, texCoords );
	vec3 normalVectorInTangentSpace = ( 2.0 * normalTexel.rgb ) - 1.0;
	vec4 normalVectorInWorldSpace;
	vec4 pixelFragmentColor;

	vec4 diffuseTexel = texture2D( u_diffuseTexture, texCoords );

	if( u_isNormalMapOn == 0 )
	{
		normalVectorInWorldSpace = vec4( v_normal, 0.0 );
	}
	else
	{
		normalVectorInWorldSpace = v_tangentToWorldMatrix * vec4(normalVectorInTangentSpace, 0.0);
	}
	//Used to Calculate direct light----------------------------------------------------------------------------------------
	vec3 totalDirectLightColor; 
	vec3 displacementToLight;
	vec3 directionToPointLight;
	float distanceToLight;
	float dotOfForwardDirectionAndToPixel;
	float lightIntensityFromCone;
	float lightIntensityFromRadius;
	float lightIntensityOfNonDirectLight;
	float lightIntensityOfDirectLight;
	float lightTotalIntensity;
	vec3 lightColor;

	//Used to Calculate Specular light----------------------------------------------------------------------------------------
	vec3 cameraToPixel = v_worldPosition - u_cameraWorldPosition;
	vec3 directionCameraToPixel = normalize( cameraToPixel );
	vec4 specularTexel = texture2D( u_specularTexture, texCoords );
	float glossiness = specularTexel.b;
	float reflectivity = specularTexel.r;
	vec3 idealDirectionTolight = reflect( directionCameraToPixel , normalVectorInWorldSpace.xyz);
	vec3 totalSpecularColor;

	for(int i = 0; i < MAX_LIGHT_NUM; i++)
	{
		float ambient = u_lightAmbientness[i];
		ambient = 0;
		//Direct light------------------------------------------------------------------------------------------
		vec3 lightForwardDirection = normalize( u_lightForwardDirection[i] );
		displacementToLight = u_lightPositions[i] - v_worldPosition.xyz;
		directionToPointLight = normalize( displacementToLight );
		distanceToLight = length( displacementToLight );
		dotOfForwardDirectionAndToPixel = dot( directionToPointLight, -lightForwardDirection);
		lightIntensityFromCone = clamp( ( dotOfForwardDirectionAndToPixel - u_lightOuterApertureDot[i] ) / ( u_lightInnerApertureDot[i] - u_lightOuterApertureDot[i] ),0.0, 1.0);
		lightIntensityFromCone *= ( 1 - ambient);
		lightIntensityFromCone += ambient;
		lightIntensityFromCone = clamp ( lightIntensityFromCone, 0.0, 1.0 );

		lightIntensityFromRadius = clamp( ( u_lightOuterRadius[i] - distanceToLight  ) / ( u_lightOuterRadius[i] - u_lightInnerRadius[i] ) ,0.0,1.0);
		lightIntensityFromRadius *= ( 1 - ambient);
		lightIntensityFromRadius += ambient;
		lightIntensityFromRadius = clamp ( lightIntensityFromRadius, 0.0, 1.0 );

		lightIntensityOfNonDirectLight = clamp( dot( directionToPointLight, normalVectorInWorldSpace.xyz ), 0.0, 1.0 ) * (1.0 - u_isDirectionalLight[i]);
		lightIntensityOfDirectLight = clamp( dot( -lightForwardDirection, normalVectorInWorldSpace.xyz ), 0.0, 1.0 ) * u_isDirectionalLight[i];
		lightTotalIntensity = lightIntensityFromCone * lightIntensityFromRadius * ( lightIntensityOfNonDirectLight + lightIntensityOfDirectLight ) * u_lightColorAndBrightness[i].a;
		lightTotalIntensity = SmoothStep(lightTotalIntensity);

		lightColor =  u_lightColorAndBrightness[i].rgb * lightTotalIntensity;
		totalDirectLightColor += lightColor;
		//------------------------------------------------------------------------------------------------------

		//Specular light----------------------------------------------------------------------------------------
		float specularIntensityOfNonDirectLight = clamp( dot( idealDirectionTolight, directionToPointLight ),0.0,1.0 ) * (1.0 - u_isDirectionalLight[i]);
		float specularIntensityOfDirectLight = clamp( dot( -lightForwardDirection , idealDirectionTolight ),0.0,1.0 ) * ( u_isDirectionalLight[i] );
		float specularIntensity = specularIntensityOfNonDirectLight + specularIntensityOfDirectLight;
		specularIntensity = pow ( specularIntensity, 1.0 + 16.0 * glossiness );
		specularIntensity *= ( lightIntensityFromCone * lightIntensityFromRadius * reflectivity * u_lightColorAndBrightness[i].a );
		totalSpecularColor += ( specularIntensity * u_lightColorAndBrightness[i].rgb );
		//------------------------------------------------------------------------------------------------------
	}
	vec4 surfaceColor = v_color;
	pixelFragmentColor = surfaceColor * diffuseTexel;

	pixelFragmentColor.rgb *= clamp( totalDirectLightColor * shadowFactor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	pixelFragmentColor.rgb += clamp( totalSpecularColor * shadowFactor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	//fog-------------------------------------------------------------------------------------------------------
	vec3 cameraToPixelDirection = normalize( cameraToPixel );
	float distancePixelToCamera = length(cameraToPixel);
	float fogIntensity = clamp( ( distancePixelToCamera - u_fogStartDistance ) / ( u_fogEndDistance - u_fogStartDistance ),0.0,1.0);
	fogIntensity *= u_fogColor.a;
	//----------------------------------------------------------------------------------------------------------

	vec4 finalColor = vec4( pixelFragmentColor.rgb * ( 1.0 - fogIntensity ) + ( u_fogColor.rgb * fogIntensity ), pixelFragmentColor.a );

	vec4 emissiveTexel = texture2D( u_emissiveTexture, texCoords );
	finalColor += emissiveTexel;

	o_fragColor = finalColor;
}