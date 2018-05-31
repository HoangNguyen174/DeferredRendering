#version 400
in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;

out vec4 o_fragColor;

uniform sampler2D u_noiseTexture;

void main()
{
	vec4 pixelFragmentColor;

	vec4 noise = texture2D( u_noiseTexture, v_textureCoords );

	vec3 grayScale = vec3( 0.299 , 0.587, 0.114 );
	vec3 sepiaScale = vec3( 1.2, 1.0, 0.8 );

	float gray = dot( noise.rgb, grayScale );
	float sepia = dot( noise.rgb, sepiaScale );

	vec3 color = vec3( sepia, sepia, sepia );
	color = vec3( gray, gray, gray );
	
	//color = mix( vec3( 0.1, 0.1, 0.1 ), noise.rgb, 0.5 );
	//color = noise.rgb;

	pixelFragmentColor = vec4( color, 1.0 );

	o_fragColor = vec4( pixelFragmentColor.rgb * v_color.r, 1.0 );
}