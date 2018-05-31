#version 400
const int MAX_LIGHT_NUM = 16;
uniform vec3 u_lightPositions[MAX_LIGHT_NUM];
uniform vec4 u_lightColorAndBrightness[MAX_LIGHT_NUM];
uniform vec3 u_lightForwardDirection[MAX_LIGHT_NUM];
uniform int u_isDirectionalLight[MAX_LIGHT_NUM];

uniform vec3 u_buildingLightColor;
uniform int u_renderGlowPart;
uniform sampler2D u_diffuseTexture;
uniform int u_isLightOn;

//fog
uniform float u_fogStartDistance;
uniform float u_fogEndDistance;
uniform vec4 u_fogColor;
uniform vec3 u_cameraWorldPosition;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;

out vec4 o_fragColor;

const float WINDOW_LIGHT_THRESHOLD = 0.3;

float SmoothStep( float value )
{
	return ( 3.0 * value * value - 2.0 * value * value * value );
}

void main()
{
	vec4 pixelFragmentColor;
	vec4 color;
	
	color = v_color;

	if( color.a > 0.5 )
	{
		pixelFragmentColor = texture2D( u_diffuseTexture, v_textureCoords ) * color;
		pixelFragmentColor.rgb *= u_isLightOn;
	}
	else
		pixelFragmentColor = vec4( v_color.rgb, 1.0 );

	if( u_renderGlowPart == 1 )
	{
		if( pixelFragmentColor.r > WINDOW_LIGHT_THRESHOLD ||
		    pixelFragmentColor.g > WINDOW_LIGHT_THRESHOLD ||
			pixelFragmentColor.b > WINDOW_LIGHT_THRESHOLD )
				pixelFragmentColor.rgb *= u_buildingLightColor;
		else
			pixelFragmentColor.rgb = vec3 ( 0.0 );
	}

	vec3 totalLightColor = vec3( 0.0, 0.0, 0.0 );
	for(int i = 0; i < MAX_LIGHT_NUM; i++)
	{
		vec3 displacementToLight = u_lightPositions[i] - v_worldPosition.xyz;
		vec3 directionToLight = normalize( displacementToLight );
		vec3 lightForwardDirection = normalize( u_lightForwardDirection[i] );

		float lightIntensityOfNonDirectLight = clamp( dot( directionToLight, v_normal ), 0.0, 1.0 ) * ( 1.0 - u_isDirectionalLight[i] );
		float lightIntensityOfDirectLight = clamp( dot( -lightForwardDirection, v_normal ), 0.0, 1.0 ) * u_isDirectionalLight[i];

		float lightIntensity = ( lightIntensityOfNonDirectLight + lightIntensityOfDirectLight );
		lightIntensity = SmoothStep( lightIntensity );

		vec3 lightColor = lightIntensity * u_lightColorAndBrightness[i].rgb;
		totalLightColor += lightColor;
	}

	float fogStrength = u_fogColor.a;
	vec3 cameraToPixel = v_worldPosition - u_cameraWorldPosition;
	vec3 cameraToPixelDir = normalize( cameraToPixel );
	float cameraToPixelDistance = length( cameraToPixel );
	float fogIntensity = clamp( ( cameraToPixelDistance - u_fogStartDistance ) / ( u_fogEndDistance - u_fogStartDistance ), 0.0, 1.0 );
	fogIntensity *= fogStrength;
	fogIntensity = pow( fogIntensity, 4 );

	//totalLightColor = mix( totalLightColor, vec3( 1.0 ), 0.0 );

	//pixelFragmentColor.rgb *= clamp( totalLightColor, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0) );

	vec4 finalColor;// = vec4( pixelFragmentColor.rgb * ( 1.0 - fogIntensity ) + ( u_fogColor.rgb * fogIntensity ), pixelFragmentColor.a );

	if( u_renderGlowPart != 1 )
		finalColor = vec4( pixelFragmentColor.rgb * ( 1.0 - fogIntensity ) + ( u_fogColor.rgb * fogIntensity ), pixelFragmentColor.a );
	else
		finalColor = vec4( pixelFragmentColor.rgb, 1.0 );

	o_fragColor = finalColor;
}