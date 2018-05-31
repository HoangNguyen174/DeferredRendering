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

uniform vec3 u_cameraWorldPos;

uniform sampler2D u_diffuseTexture;

in vec4 v_worldPosition;
in vec2 v_texCoords;
in vec3 v_normal;

out vec4 o_fragColor;

void main()
{
	vec3 pixelToCamera = normalize( u_cameraWorldPos - v_worldPosition.xyz );
	vec4 diffuseTexel = texture2D( u_diffuseTexture, v_texCoords );
	vec4 pixelFragmentColor;

	if( diffuseTexel.a == 0.0 )
		discard;

	vec3 directionToFirstLight;
	vec3 totalLightColor = vec3( 0.0, 0.0, 0.0 );
	for(int i = 0; i < MAX_LIGHT_NUM; i++)
	{
		vec3 displacementToLight = u_lightPositions[i] - v_worldPosition.xyz;
		vec3 directionToLight = normalize( displacementToLight );
		if( i == 0 )
			directionToFirstLight = directionToLight;

		float lightIntensity = clamp( dot( directionToLight, v_normal ), -1.0, 1.0 );
		float convertedLightIntensity = ( lightIntensity + 1.0 ) * 0.5;

		vec3 lightColor = ( convertedLightIntensity * u_lightColorAndBrightness[i].rgb );
		totalLightColor += lightColor;
	}

	pixelFragmentColor = diffuseTexel;

	pixelFragmentColor.rgb *=  clamp( totalLightColor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	o_fragColor = vec4( pixelFragmentColor.rgb, 1.0 );
	//o_fragColor = vec4( v_normal, 1.0 );
	//o_fragColor = diffuseTexel;
}