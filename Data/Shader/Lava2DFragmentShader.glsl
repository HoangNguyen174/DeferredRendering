#version 400

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;
in vec3 a_vertexNormal;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;
out vec3 v_normal;
out vec4 v_screenPosition;

void main()
{
	v_worldPosition = a_vertexPosition;
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_normal = a_vertexNormal;

	v_screenPosition = u_WorldToScreenMatrix * vec4( v_worldPosition, 1.0 );

	gl_Position = v_screenPosition;
}