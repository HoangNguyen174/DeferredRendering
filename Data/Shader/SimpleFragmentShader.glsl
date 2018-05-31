#version 400

uniform int u_disableFragmentShader;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;

out vec4 o_fragColor;

void main()
{
	if( u_disableFragmentShader == 1 )
		return;

	vec4 pixelFragmentColor = v_color;

	o_fragColor = pixelFragmentColor;
}