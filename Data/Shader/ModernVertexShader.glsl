#version 400

const int MAX_LIGHT_NUM = 16;
uniform vec3 u_lightPositions[MAX_LIGHT_NUM];
uniform vec4 u_lightColorAndBrightness[MAX_LIGHT_NUM];
uniform float u_lightInnerApertureDot[MAX_LIGHT_NUM];
uniform float u_lightOuterApertureDot[MAX_LIGHT_NUM];
uniform float u_lightInnerRadius[MAX_LIGHT_NUM];
uniform float u_lightOuterRadius[MAX_LIGHT_NUM];
uniform float u_lightAmbientness[MAX_LIGHT_NUM];
uniform vec3 u_lightForwardDirection[MAX_LIGHT_NUM];
uniform int u_isDirectionalLight[MAX_LIGHT_NUM];

uniform sampler2D u_diffuseTexture;
uniform sampler2D u_normalTexture;
uniform sampler2D u_emissiveTexture;
uniform sampler2D u_specularTexture;
uniform sampler2D u_depthTexture;

uniform vec3 u_lightPosition;
uniform float u_time;
uniform mat4 u_WorldToScreenMatrix;
uniform vec3 u_cameraWorldPosition;
uniform float u_deltaTime;

uniform float u_fogStartDistance;
uniform float u_fogEndDistance;
uniform vec4 u_fogColor;

uniform vec2 u_scaleBias;

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;
in vec3 a_vertexNormal;
in vec3 a_vertexTangent;
in vec3 a_vertexBitangent;
in vec4 a_vertexBoneIndex;
in vec4 a_vertexBoneWeight;
in float a_isStatic;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;
out vec3 v_normal;
out mat4 v_tangentToWorldMatrix;
out vec4 v_screenPosition;
out mat4 v_worldToTangentMatrix;
out float v_noise;

void main()
{
	vec3 normalAttribTangent = normalize( a_vertexTangent );
	vec3 normalAttribBitangent = normalize( a_vertexBitangent );
	vec3 normalAttribNormal = normalize( a_vertexNormal );

	mat4 tangentToWorldMatrix = mat4( vec4( normalAttribTangent, 0.0),
									  vec4( normalAttribBitangent, 0.0),
							          vec4( normalAttribNormal, 0.0),
							          vec4( 0.0, 0.0, 0.0, 1.0) );
	
	v_worldToTangentMatrix = transpose(tangentToWorldMatrix);
	v_tangentToWorldMatrix = tangentToWorldMatrix;
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_worldPosition = a_vertexPosition;
	v_normal = a_vertexNormal;
	
	v_screenPosition = u_WorldToScreenMatrix * vec4( v_worldPosition, 1.0 );

	gl_Position = v_screenPosition;
}
