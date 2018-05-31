#version 400

in vec3 a_vertexPosition;

void main()
{
	gl_Position = vec4( a_vertexPosition, 1.0 );
}
