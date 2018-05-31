#version 400

uniform mat4 u_worldToScreenMatrix;
uniform vec3 u_cameraWorldPos;
uniform float u_time;

layout ( points ) in;
layout ( triangle_strip, max_vertices = 18 ) out;
out vec4 v_worldPosition;
out vec2 v_texCoords;
out vec3 v_normal;

const float grassWidth = 0.2;
const float grassHeight = 0.2;

mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

void main()
{
	float halfWidth = grassWidth * 0.5;
	float halfHeight = grassHeight * 0.5;
	vec3 center = gl_in[0].gl_Position.xyz;
	vec3 pixelToCamera = normalize( u_cameraWorldPos - center );
	vec3 up = vec3( 0.0, 0.0, 1.0 );
	vec3 right = vec3( -0.0, -1.0, 0.0 );
	vec3 forward = normalize( cross( up, right ) );
	vec3 vertexPos = center;
	vec3 displacement = vec3( sin( u_time * 0.14434 ) * 0.5f, 0.0,0.0 ) * 0.1;
	vec3 displacement2 = vec3( sin( u_time * 0.123 ) * -0.89f, 0.0,0.0 ) * 0.1;
	vec3 displacement3 = vec3( sin( u_time * -0.1231 ) * 0.74f, 0.0,0.0 ) * 0.1;

	//generate geometry for one face
	vertexPos = center + halfWidth * right - halfHeight * up;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 0.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos + displacement, 1.0 ) ;
	v_texCoords = vec2( 0.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement, 1.0 );
	EmitVertex();

	vertexPos.z -= grassHeight;
	vertexPos -= right * grassWidth;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 1.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos  + displacement, 1.0 ) ;
	v_texCoords = vec2( 1.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement, 1.0 );
	EmitVertex();

	EndPrimitive();

	mat4 rotation = rotationMatrix( up, 240 );
	vec4 newRight = rotation * vec4( right, 0.0 );
	right = normalize( newRight.xyz );
	 
	vertexPos = center + halfWidth * right - halfHeight * up;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 0.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos + displacement2, 1.0 ) ;
	v_texCoords = vec2( 0.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement2, 1.0 );
	EmitVertex();

	vertexPos.z -= grassHeight;
	vertexPos -= right * grassWidth;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 1.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos  + displacement2, 1.0 ) ;
	v_texCoords = vec2( 1.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement2, 1.0 );
	EmitVertex();

	EndPrimitive();

	rotation = rotationMatrix( up, 120 );
	newRight = rotation * vec4( right, 0.0 );
	right = normalize( newRight.xyz );
	 
	//right = vec3( 0.0, -1.0, 0.0 );
	vertexPos = center + halfWidth * right - halfHeight * up ;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 0.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos + displacement3, 1.0 ) ;
	v_texCoords = vec2( 0.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement3, 1.0 );
	EmitVertex();

	vertexPos.z -= grassHeight;
	vertexPos -= right * grassWidth;
	v_worldPosition = vec4( vertexPos, 1.0 ) ;
	v_texCoords = vec2( 1.0, 1.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos, 1.0 );
	EmitVertex();

	vertexPos.z += grassHeight;
	v_worldPosition = vec4( vertexPos  + displacement3, 1.0 ) ;
	v_texCoords = vec2( 1.0, 0.0 );
	v_normal = up;
	gl_Position = u_worldToScreenMatrix * vec4( vertexPos + displacement3, 1.0 );
	EmitVertex();

	EndPrimitive();
}