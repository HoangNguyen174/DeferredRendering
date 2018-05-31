#version 110

varying vec4 v_color;

void main()
{
	v_color = gl_Color;
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}