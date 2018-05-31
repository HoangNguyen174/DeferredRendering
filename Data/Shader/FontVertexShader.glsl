#version 400

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;

uniform mat4 u_projectionViewMatrix;
uniform mat4 u_viewMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_modelMatrix;

void main()
{
	vec4 screenPosition = u_projectionViewMatrix * u_modelMatrix * vec4( a_vertexPosition, 1.0 );
	screenPosition = u_projectionMatrix * u_viewMatrix * u_modelMatrix * vec4( a_vertexPosition, 1.0 );
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_worldPosition = a_vertexPosition;

	gl_Position = screenPosition; 
}
