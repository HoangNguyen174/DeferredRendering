#version 400

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;
in vec3 a_vertexNormal;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;
out vec3 v_normal;

uniform mat4 u_vp;
uniform mat4 u_modelMatrix;
uniform mat4 u_normalTransform;

void main()
{
	vec4 screenPosition = u_vp * u_modelMatrix * vec4( a_vertexPosition, 1.0 );
	v_worldPosition = a_vertexPosition;
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_normal = a_vertexNormal;
	gl_Position = screenPosition; 
}