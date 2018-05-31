#version 400

uniform mat4 u_worldToScreenMatrix;
uniform vec3 u_cameraWorldPos;
uniform float u_time;

layout ( points ) in;
layout ( triangle_strip, max_vertices = 6 ) out;

out vec4 v_worldPosition;
out vec2 v_texCoords;
out vec3 v_normal;

const float billboardWidth = 1.0;
const float billboardHeight = 2.0;

void main()
{
	float halfWidth = billboardWidth * 0.5;
	float halfHeight = billboardHeight * 0.5;
	vec3 center = gl_in[0].gl_Position.xyz;
	vec3 pixelToCamera = normalize( u_cameraWorldPos - center );
	vec3 up = vec3( 0.0,0.0,1.0 );
	vec3 right = normalize( cross( pixelToCamera, up ) );
	vec3 forward = normalize( cross( up, right ) );

	///////////////////////////////
	//    1----3----5
	//	  | \  |\   |
	//	  |  \ | \  |
	//    |   \|  \ |
	//    |    \   \|
	//    0----2----4
	///////////////////////////////

	vec3 vertexPos;

	//vertex 0
	vertexPos = center + halfWidth * right - halfHeight * up ;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 0.0, 1.0 );
	v_normal = right;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	//vertex 1
	vertexPos.z += billboardHeight;
	v_worldPosition = vec4( vertexPos, 1.0 );
	v_texCoords = vec2( 0.0, 0.0 );
	v_normal = right;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	//vertex 2
	vertexPos.z -= billboardHeight;
	vertexPos -= halfWidth * right;
	v_worldPosition = vec4( vertexPos, 1.0 );
	v_texCoords = vec2( 0.5, 1.0 );
	v_normal = forward;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	//vertex 3
	vertexPos.z += billboardHeight;
	v_worldPosition = vec4( vertexPos, 1.0 );
	v_texCoords = vec2( 0.5, 0.0 );
	v_normal = forward;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	//vertex 4
	vertexPos.z -= billboardHeight;
	vertexPos -= halfWidth * right;
	v_worldPosition = vec4( vertexPos, 1.0 );
	v_texCoords = vec2( 1.0, 1.0 );
	v_normal = -right;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	//vertex 5
	vertexPos.z += billboardHeight;
	v_worldPosition = vec4( vertexPos, 1.0 );
	v_texCoords = vec2( 1.0, 0.0 );
	v_normal = -right;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	EndPrimitive();
}