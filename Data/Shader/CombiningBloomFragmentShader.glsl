#version 400
uniform sampler2D u_originalTexture;
uniform sampler2D u_bloomTexture;
uniform sampler2D u_bloomTextureHalfRes;
uniform sampler2D u_bloomTextureAFourthRes;

in vec2 v_textureCoords;
in vec4 v_color;
in vec4 v_screenPosition;

out vec4 o_fragColor;

uniform float u_bloomIntensity;
uniform float u_originalIntensity;
uniform float u_bloomSaturation;
uniform float u_originalSaturation;

vec4 AdjustSaturation( vec4 color, float saturation )

{
    float greyScale = dot( color.rgb, vec3( 0.3, 0.59, 0.11 ) );
    vec4 grey = vec4( greyScale, greyScale, greyScale, 1.0 );
    return mix( grey, color, saturation );
}

void main()
{
	vec4 bloomColor = texture2D( u_bloomTexture, v_textureCoords );
	vec4 bloomColorHalfRes = texture2D( u_bloomTextureHalfRes, v_textureCoords );
	vec4 bloomColorAFourthRes = texture2D( u_bloomTextureAFourthRes, v_textureCoords );

	bloomColor = bloomColor + bloomColorHalfRes + bloomColorAFourthRes;

	vec4 originalColor = texture2D( u_originalTexture, v_textureCoords );

	bloomColor = AdjustSaturation( bloomColor, u_bloomSaturation ) * u_bloomIntensity;
	originalColor = AdjustSaturation( originalColor, u_originalSaturation ) * u_originalIntensity ;

	originalColor *= ( 1.0 - clamp( bloomColor, vec4( 0.0 ), vec4( 1.0 ) ) );

	vec4 fragmentColor = originalColor + bloomColor;

	o_fragColor = fragmentColor; 
}