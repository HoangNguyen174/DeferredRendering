#version 400

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;

uniform mat4 u_mvp;

void main()
{
	vec4 screenPosition = u_mvp * vec4( a_vertexPosition, 1.0 );
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	
	gl_Position = screenPosition; 
}