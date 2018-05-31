#version 400

uniform mat4 u_modelMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;

in vec3 a_vertexPosition;

void main()
{
	mat4 mvp = u_projectionMatrix * u_viewMatrix * u_modelMatrix;
	gl_Position = mvp * vec4( a_vertexPosition, 1.0 );
}