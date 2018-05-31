#version 400

precision highp float;

uniform sampler2D u_diffuseTexture;
uniform sampler2D u_normalTexture;
uniform sampler2D u_emissiveTexture;
uniform sampler2D u_specularTexture;
uniform sampler2D u_depthTexture;

in vec3 v_worldPosition;
in vec3 v_viewPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec3 v_normal;
in vec3 v_normalInView;

layout (location = 0) out vec4 o_position;
layout (location = 1) out vec4 o_normal;  
layout (location = 2) out vec4 o_diffuseColor; 
layout (location = 3) out vec4 o_normalViewSpace; 

const float NEAR = 0.1;
const float FAR = 1000.0;

in vec4 gl_FragCoord ;

float LinearizeDepth( float depth )
{
    float z = depth * 2.0 - 1.0;
    return (2.0 * NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));	
}

void main()
{
	float depth = LinearizeDepth( gl_FragCoord.z );
	o_position = vec4( v_worldPosition, depth );
//	o_position = vec4( v_viewPosition, depth );
	o_normal = vec4( v_normal, 1.0 );
	o_diffuseColor = vec4( texture2D( u_diffuseTexture, v_textureCoords ).xyz, 1.0 );
	o_normalViewSpace = vec4( v_normalInView.xyz, 1.0 );
}