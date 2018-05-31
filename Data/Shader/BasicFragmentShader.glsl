#version 110

uniform sampler2D u_myTexture;
varying vec4 v_color;

void main()
{
	gl_FragColor = v_color * texture2D(u_myTexture, gl_TexCoord[0].xy);
}