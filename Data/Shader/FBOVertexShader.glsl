#version 400

uniform float u_time;
uniform mat4 u_WorldToScreenMatrix;
uniform float u_deltaTime;

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_screenPosition;
out vec4 v_color;

void main()
{
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_worldPosition = a_vertexPosition;

	v_screenPosition = u_WorldToScreenMatrix * vec4( v_worldPosition, 1.0 );

	gl_Position = v_screenPosition;
}

