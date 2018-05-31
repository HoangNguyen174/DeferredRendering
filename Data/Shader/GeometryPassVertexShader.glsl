#version 400

uniform mat4 u_boneTM[100];

uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat4 u_WorldToScreenMatrix;
uniform mat4 u_LocalToWorldMatrix;
uniform mat4 u_modelMatrix;

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
out vec3 v_normalInView;
out mat4 v_tangentToWorldMatrix;
out vec4 v_screenPosition;
out vec4 v_screenPositionStatic;
out mat4 v_worldToTangentMatrix;
out float v_noise;
out vec3 v_viewPosition;

float SmoothStep( float value )
{
	return ( 3.0 * value * value - 2.0 * value * value * value );
}

void main()
{
	mat4 mvp = u_projectionMatrix * u_viewMatrix * u_modelMatrix;

	mat4 localToWorldMatrixNoTranslation = transpose( u_LocalToWorldMatrix );
	localToWorldMatrixNoTranslation[3][0] = 0.0;
	localToWorldMatrixNoTranslation[3][1] = 0.0;
	localToWorldMatrixNoTranslation[3][2] = 0.0;
	localToWorldMatrixNoTranslation[3][3] = 1.0;

	vec4 tempNorm = localToWorldMatrixNoTranslation * vec4( a_vertexNormal.xyz, 1.0 );
	vec4 tempTangent = localToWorldMatrixNoTranslation * vec4( a_vertexTangent.xyz, 1.0 );
	vec4 tempBiTangent = localToWorldMatrixNoTranslation * vec4( a_vertexBitangent.xyz, 1.0 ); 

	vec3 normalAttribTangent = normalize( tempTangent.xyz );
	vec3 normalAttribBitangent = normalize( tempBiTangent.xyz  );
	vec3 normalAttribNormal = normalize( tempNorm.xyz );

	mat4 tangentToWorldMatrix = mat4( vec4( normalAttribTangent, 0.0),
									  vec4( normalAttribBitangent, 0.0),
							          vec4( normalAttribNormal, 0.0),
							          vec4( 0.0, 0.0, 0.0, 1.0) );

	v_worldToTangentMatrix = transpose(tangentToWorldMatrix);
	v_tangentToWorldMatrix = tangentToWorldMatrix;
	v_color = a_vertexColor;
	v_textureCoords = a_vertexTexCoords;
	vec4 worldPosTemp = transpose(u_LocalToWorldMatrix) * vec4( a_vertexPosition.xyz, 1.0 );
	vec3 staticPixelWorldPosition = worldPosTemp.xyz;

	vec4 normalTemp = localToWorldMatrixNoTranslation * vec4( a_vertexNormal.xyz, 0.0 );
	v_normal = normalTemp.xyz;

	v_worldPosition = worldPosTemp.xyz;
	v_screenPositionStatic = mvp * vec4( v_worldPosition.xyz, 1.0 ) * a_isStatic;

	vec4 pos = vec4(0,0,0,0);
	vec4 norm = vec4(0,0,0,0);

	int vertexBoneIndex[4];
	float vertexBoneWeight[4];

	vertexBoneIndex[0] = int(a_vertexBoneIndex.x);
	vertexBoneIndex[1] = int(a_vertexBoneIndex.y);
	vertexBoneIndex[2] = int(a_vertexBoneIndex.z);
	vertexBoneIndex[3] = int(a_vertexBoneIndex.w);

	vertexBoneWeight[0] = a_vertexBoneWeight.x;
	vertexBoneWeight[1] = a_vertexBoneWeight.y;
	vertexBoneWeight[2] = a_vertexBoneWeight.z;
	vertexBoneWeight[3] = a_vertexBoneWeight.w;

	for( int i = 0; i < 4; i++ )
	{
		int boneIndex = vertexBoneIndex[i];
		pos += ( vec4( a_vertexPosition.xyz, 1.0 ) * u_boneTM[boneIndex] ) * vertexBoneWeight[i];
		norm += ( vec4( a_vertexNormal.xyz, 0.0 ) * u_boneTM[boneIndex] ) * vertexBoneWeight[i];
	}

	v_screenPosition = mvp * pos;

	vec3 animatePixelWorldPosition = ( u_modelMatrix * pos ).xyz;

	v_worldPosition = staticPixelWorldPosition * a_isStatic + animatePixelWorldPosition * ( 1.0 - a_isStatic );
	
	vec4 finalPos = v_screenPositionStatic * a_isStatic + v_screenPosition * ( 1.0 - a_isStatic );

	vec4 finalNorm = norm * ( 1.0 - a_isStatic ) + vec4( v_normal.xyz, 0.0 ) * a_isStatic;

	v_normal = finalNorm.xyz;

	mat3 normalMatrix = transpose( inverse ( mat3( u_viewMatrix * u_modelMatrix ) ) );
	v_normalInView = normalMatrix * v_normal;

	v_viewPosition = ( u_viewMatrix * vec4( v_worldPosition, 1.0 ) ).xyz;

	gl_Position = finalPos;
}
