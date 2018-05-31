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

uniform sampler2D u_grassTexture;
uniform sampler2D u_snowTexture;
uniform sampler2D u_rockTexture;

uniform vec3 u_lightPosition;
uniform float u_time;
uniform vec3 u_cameraWorldPosition;
uniform float u_deltaTime;

uniform mat4 u_ModelViewMatrix;

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

out vec4 o_fragColor;

const int CHUNK_WIDTH_X = 8;
const int CHUNK_DEPTH_Y = 8;
const int CHUNK_HEIGHT_Z = 32;
const float WATER_LEVEL = 6.0;

void main()
{
	vec3 pixelToCamera = u_cameraWorldPosition - v_worldPosition;

	float distanceFromPixelToCamera = length( pixelToCamera );

	vec3 surfaceNormal = normalize( v_normal );
	vec3 displacementToLight;
	vec3 directionToPointLight;
	float lightIntensity = 0;
	vec3 lightColor;
	vec3 totalLightColor;
	vec3 totalDirectLightColor;
	vec4 pixelFragmentColor;

	float tighten = 0.04679;
	float weightXY = abs( surfaceNormal.z ) - tighten;
	float weightXZ = abs( surfaceNormal.y ) - tighten;
	float weightZY = abs( surfaceNormal.x ) - tighten;
	float totalWeight = weightXY + weightXZ + weightZY;

	weightXY /= totalWeight;
	weightXZ /= totalWeight;
	weightZY /= totalWeight;

	float scale = 0.5;

	vec3 minWorldCoords;
	minWorldCoords.x = floor( v_worldPosition.x / CHUNK_WIDTH_X ) * CHUNK_WIDTH_X ;
	minWorldCoords.y = floor( v_worldPosition.y / CHUNK_DEPTH_Y ) * CHUNK_DEPTH_Y ;
	minWorldCoords.z = 0;

	vec2 texCoordsXY;
	texCoordsXY.x = abs( v_worldPosition.x - minWorldCoords.x ) / CHUNK_WIDTH_X;
	texCoordsXY.y = abs( v_worldPosition.y - minWorldCoords.y ) / CHUNK_DEPTH_Y;

	vec2 texCoordsXZ;
	texCoordsXZ.x = abs( v_worldPosition.x - minWorldCoords.x ) / CHUNK_WIDTH_X;
	texCoordsXZ.y = abs( v_worldPosition.z - minWorldCoords.z ) / CHUNK_HEIGHT_Z;

	vec2 texCoordsZY;
	texCoordsZY.x = abs( v_worldPosition.z - minWorldCoords.z ) / CHUNK_HEIGHT_Z;
	texCoordsZY.y = abs( v_worldPosition.y - minWorldCoords.y ) / CHUNK_DEPTH_Y;

	vec4 diffuseTexelXY = texture2D( u_grassTexture, texCoordsXY * scale );
	vec4 diffuseTexelXZ = texture2D( u_grassTexture, texCoordsXZ * scale );
	vec4 diffuseTexelZY = texture2D( u_grassTexture, texCoordsZY * scale );
	vec4 grassDiffuseTexel;
	grassDiffuseTexel = weightXY * diffuseTexelXY + weightXZ * diffuseTexelXZ + weightZY * diffuseTexelZY ;

	diffuseTexelXY = texture2D( u_rockTexture, texCoordsXY * scale );
	diffuseTexelXZ = texture2D( u_rockTexture, texCoordsXZ * scale );
	diffuseTexelZY = texture2D( u_rockTexture, texCoordsZY * scale );
	vec4 rockDiffuseTexel;
	rockDiffuseTexel = weightXY * diffuseTexelXY + weightXZ * diffuseTexelXZ + weightZY * diffuseTexelZY ;

	diffuseTexelXY = texture2D( u_snowTexture, texCoordsXY * scale );
	diffuseTexelXZ = texture2D( u_snowTexture, texCoordsXZ * scale );
	diffuseTexelZY = texture2D( u_snowTexture, texCoordsZY * scale );
	vec4 snowDiffuseTexel;
	snowDiffuseTexel = weightXY * diffuseTexelXY + weightXZ * diffuseTexelXZ + weightZY * diffuseTexelZY ;

	for(int i = 0; i < MAX_LIGHT_NUM; i++)
	{
		displacementToLight = u_lightPositions[i] - v_worldPosition.xyz;
		directionToPointLight = normalize( displacementToLight );
		lightIntensity = clamp( dot( directionToPointLight, surfaceNormal ), 0.0, 1.0 );

		lightColor = ( lightIntensity * u_lightColorAndBrightness[i].rgb );
		totalDirectLightColor += lightColor;
	}

	vec4 surfaceColor = v_color;

	vec4 totalDiffuseTexel;

	totalDiffuseTexel =	  v_vertexTerrainWeight.x * grassDiffuseTexel 
						+ v_vertexTerrainWeight.y * rockDiffuseTexel
						+ v_vertexTerrainWeight.z * snowDiffuseTexel;

	pixelFragmentColor = surfaceColor * clamp( totalDiffuseTexel, vec4(0.0,0.0,0.0,0.0), vec4(1.0,1.0,1.0,1.0) );

	pixelFragmentColor.rgb *= clamp( totalDirectLightColor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	o_fragColor = pixelFragmentColor;
}

