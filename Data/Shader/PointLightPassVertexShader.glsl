#version 400

in vec3 a_vertexPosition;

uniform mat4 u_viewMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_modelMatrix;

void main()
{
	vec4 screenPosition = u_projectionMatrix * u_viewMatrix * u_modelMatrix * vec4( a_vertexPosition, 1.0 );

	gl_Position = screenPosition;
}