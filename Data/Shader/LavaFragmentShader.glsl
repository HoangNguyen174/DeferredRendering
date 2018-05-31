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

uniform sampler2D u_lavaTexture;
uniform sampler2D u_noiseTexture;

uniform vec3 u_lightPosition;
uniform float u_time;
uniform vec3 u_cameraWorldPosition;
uniform float u_deltaTime;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;
in mat4 v_TangentToWorldMatrix;
in vec4 v_screenPosition;
in mat4 v_worldToTangentMatrix;
in float v_noise;

out vec4 o_fragColor;

void main()
{
	float tighten = 0.04679;
	//tighten = 10.0;
	float weightXY = abs( v_normal.z ) - tighten;
	float weightXZ = abs( v_normal.y ) - tighten;
	float weightZY = abs( v_normal.x ) - tighten;
	float totalWeight = weightXY + weightXZ + weightZY;

	weightXY /= totalWeight;
	weightXZ /= totalWeight;
	weightZY /= totalWeight;

	vec2 texCoordsXY;
	texCoordsXY.x = v_textureCoords.x;
	texCoordsXY.y = v_textureCoords.y;

	vec2 texCoordsXZ;
	texCoordsXZ.x = v_textureCoords.x;
	texCoordsXZ.y = v_worldPosition.z;

	vec2 texCoordsZY;
	texCoordsZY.x = v_worldPosition.z;
	texCoordsZY.y = v_textureCoords.y;

	float scale = 2.0;

	vec2 position = -1.0 + 2.0 * v_textureCoords;

	vec4 noise = texture2D( u_noiseTexture, v_textureCoords );
	vec2 T1 = v_textureCoords + vec2( 1.5, -1.5 ) * u_time * 0.04;
	vec2 T2 = v_textureCoords + vec2( -0.5, 2.0 ) * u_time * 0.02;

	T1.x += noise.x * 2.0;
	T1.y += noise.y * 2.0;
	T2.x += noise.x * 0.2;
	T2.y += noise.y * 0.2;

	vec4 diffuseTexelXY = texture2D( u_lavaTexture, texCoordsXY * scale * T2 * 2.0 );
	vec4 diffuseTexelXZ = texture2D( u_lavaTexture, texCoordsXZ * scale * T2 * 2.0 );
	vec4 diffuseTexelZY = texture2D( u_lavaTexture, texCoordsZY * scale * T2 * 2.0 );
	vec4 diffuseTexel;
	diffuseTexel = weightXY * diffuseTexelXY + weightXZ * diffuseTexelXZ + weightZY * diffuseTexelZY ;

	float p = texture2D( u_noiseTexture, T1 * 2.0 ).a;
	
	vec4 color = texture2D( u_lavaTexture, T2 * 2.0 );
	//color = diffuseTexel;

	vec4 finalColor = color * vec4( p,p,p,p ) * 2.0 + ( color * color );

	if( finalColor.r > 1.0 )
		finalColor.bg += clamp( finalColor.r - 2.0, 0.0, 1.0 );
	if( finalColor.g > 1.0 )
		finalColor.rb += finalColor.g - 1.0;
	if( finalColor.b > 1.0 )
		finalColor.rg += finalColor.b - 1.0;

	//o_fragColor = texture2D( u_lavaTexture, v_textureCoords );
	o_fragColor = finalColor; 
}
