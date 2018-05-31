#version 400

uniform sampler2D u_fontTexture;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;

out vec4 o_fragColor;

void main()
{
	vec4 pixelFragmentColor = texture2D( u_fontTexture, v_textureCoords );
	
	o_fragColor = vec4( pixelFragmentColor.rgb * v_color.rgb , pixelFragmentColor.a );
}