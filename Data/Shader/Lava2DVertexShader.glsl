#version 400

uniform sampler3D u_diffuseTexture;
uniform float u_time;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;

out vec4 o_fragColor;

void main()
{
	o_fragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}