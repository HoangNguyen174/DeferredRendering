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

uniform sampler2D u_grassTexture;
uniform sampler2D u_snowTexture;
uniform sampler2D u_rockTexture;

uniform vec3 u_lightPosition;
uniform float u_time;
uniform mat4 u_WorldToScreenMatrix;
uniform mat4 u_LocalToWorldMatrix;
uniform vec3 u_cameraWorldPosition;
uniform float u_deltaTime;

uniform mat4 u_ModelViewMatrix;

uniform float u_fogStartDistance;
uniform float u_fogEndDistance;
uniform vec4 u_fogColor;

uniform vec4 u_clipPlane;

in vec3 a_vertexPosition;
in vec4 a_vertexColor;
in vec2 a_vertexTexCoords;
in vec3 a_vertexNormal;
in vec3 a_vertexTangent;
in vec3 a_vertexBitangent;
in int a_vertexBoneIndex[4];
in float a_vertexBoneWeight[4];
in float a_isStatic;
in vec3 a_vertexTerrainWeight;

out vec3 v_worldPosition;
out vec2 v_textureCoords;
out vec4 v_color;
out vec3 v_normal;
out mat4 v_tangentToWorldMatrix;
out vec4 v_screenPosition;
out mat4 v_worldToTangentMatrix;
out float v_noise;
out vec3 v_vertexTerrainWeight;

out float gl_ClipDistance[1];

void main()
{
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	v_worldPosition = a_vertexPosition;
	v_normal = a_vertexNormal;

	v_vertexTerrainWeight = a_vertexTerrainWeight;

	v_screenPosition = u_WorldToScreenMatrix * vec4( v_worldPosition, 1.0 );

	gl_Position = v_screenPosition;
	//gl_ClipDistance[0] = dot( vec4( v_worldPosition,1.0), u_clipPlane );
}
