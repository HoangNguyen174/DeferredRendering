#version 400
uniform sampler2D u_colorTexture;
uniform sampler2D u_depthTexture;

uniform float u_time;
uniform mat4 u_WorldToScreenMatrix;
uniform float u_deltaTime;
uniform vec2 u_blurDirection;
uniform float u_blurRadius;
uniform vec2 u_resolution;
uniform int u_enableBlur;

in vec3 v_worldPosition;
in vec2 v_textureCoords;
in vec4 v_color;
in vec4 v_screenPosition;

out vec4 o_fragColor;

mat3 SobelMatrixSx = mat3 ( vec3( -1.0, -2.0, -1.0 ),
							vec3(  0.0,  0.0,  0.0 ),
							vec3( 1.0, 2.0,  1.0 ) );

mat3 SobelMatrixSy = mat3 ( vec3( -1.0, 0.0,  1.0 ),
							vec3( -2.0,  0.0, 2.0 ),
							vec3( -1.0, 2.0,  1.0 ) );

const float SCREEN_WIDTH = 1600.0;
const float SCREEN_HEIGHT = 900.0;

vec4 GetblurTexelAtTexCoords( const vec2 texCoords )
{
	 const float distortionSampleStepSize = 0.005;
	 vec4 blurColor;
	 float scale = 0.9;

	 for( int yStep = 0; yStep <= 2; ++yStep )
	 {
		for( int xStep = 0; xStep <= 2; ++xStep )
		{
			vec2 texCoordOffset = vec2( xStep * distortionSampleStepSize, yStep * distortionSampleStepSize );
			vec4 nearbyTexel = texture2D( u_colorTexture, texCoords + texCoordOffset );
			blurColor += nearbyTexel;
		}
	}

	blurColor *= scale;
	return blurColor;
}

vec4 GetZoomBlurColor( const vec2 texCoords )
{
	vec4 zoomBlurColor;
	vec2 texCoordCenter = vec2( 0.5, 0.5 );
	vec2 displacementCenter = texCoords - texCoordCenter;
	float distanceFromCenter = length( displacementCenter );
	const int numDistortionSample = 10;
	
	for( int i = 0 ; i < numDistortionSample; ++i )
	{
		vec2 texCoordsOffset = displacementCenter * float(i) * 0.01;
		vec2 distortPixelTexcoods = texCoords + texCoordsOffset;
		vec4 pixelAwayFromCenter = texture2D( u_colorTexture, distortPixelTexcoods );
		zoomBlurColor += pixelAwayFromCenter ;
	}

	zoomBlurColor /= float( numDistortionSample );

	return zoomBlurColor;
}

vec4 GetRadicalBlurColor()
{
	vec4 zoomBlurColor;
	vec2 texCoordCenter = vec2( 0.5, 0.5 );
	vec2 displacementCenter = v_textureCoords - texCoordCenter;
	float distanceFromCenter = length( displacementCenter );
	float angleFromCenter = atan( displacementCenter.y , displacementCenter.x);
	const int numDistortionSample = 10;
	
	for( int i = 0 ; i < numDistortionSample; ++i )
	{
		//radical blur
		vec2 distortDisplacementOffset = distanceFromCenter * vec2( cos(angleFromCenter), sin(angleFromCenter) );
		vec2 distortPixelTexcoods = v_textureCoords + distortDisplacementOffset;
		vec4 pixelAwayFromCenter = texture2D( u_colorTexture, distortPixelTexcoods );
		zoomBlurColor += pixelAwayFromCenter ;

		angleFromCenter += 0.01;
	}

	zoomBlurColor /= float( numDistortionSample );
	zoomBlurColor = clamp( zoomBlurColor, vec4(0.0,0.0,0.0,0.0), vec4(1.0,1.0,1.0,1.0) );
	return zoomBlurColor;
}

vec4 GetDontStarveEffect()
{
	vec2 texCoordCenter = vec2( 0.5, 0.5 );
  	vec2 displacementCenter = v_textureCoords - texCoordCenter;
	float distanceFromCenter = length( displacementCenter );
	vec4 dontStarvePixelColor;
	float scale = 0.1;
	float magnitude = scale * distanceFromCenter;

	vec2 realTexCoords = v_textureCoords;
	vec2 bogusTexCoords = realTexCoords +  0.01 * vec2(cos( u_time ), sin( u_time ));

	vec4 realTexel = texture2D(u_colorTexture, realTexCoords);
	vec4 bogusTexel = texture2D(u_colorTexture, bogusTexCoords);

	vec4 blendPixel = ( 0.7 * realTexel ) + (0.3 * bogusTexel  );
	//blendPixel.r = ( 1.0 - magnitude  * blendPixel.r) + (magnitude * vec4(1.0,0.0,0.0,1.0) );
	dontStarvePixelColor = blendPixel;

	return dontStarvePixelColor;
}

float luma ( vec3 color )
{
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

vec4 GetPixelFromSobelEdgeDetection( const vec2 texCoords )
{
	float dx = 1.0 / SCREEN_WIDTH;
	float dy = 1.0 / SCREEN_HEIGHT;
	const float edgeThreshold = 0.05 ;

	//compute luma from 8 neigbour pixel;
	float northWestPixel = luma ( texture2D( u_colorTexture, texCoords + vec2( -dx, dy ) ).rgb );
	float westPixel		 = luma ( texture2D( u_colorTexture, texCoords + vec2( -dx, 0.0 ) ).rgb );
	float southWestPixel = luma ( texture2D( u_colorTexture, texCoords + vec2( -dx, -dy ) ).rgb );
	float southPixel	 = luma ( texture2D( u_colorTexture, texCoords + vec2( 0.0, dy ) ).rgb );
	float northPixel	 = luma ( texture2D( u_colorTexture, texCoords + vec2( 0.0, -dy ) ).rgb );
	float northEastPixel = luma ( texture2D( u_colorTexture, texCoords + vec2(  dx, dy ) ).rgb );
	float eastPixel		 = luma ( texture2D( u_colorTexture, texCoords + vec2(	dx, 0.0  ) ).rgb );
	float southEastPixel = luma ( texture2D( u_colorTexture, texCoords + vec2(  dx, -dy ) ).rgb );

	float Sx = northWestPixel + 2 * westPixel + southWestPixel - ( northEastPixel + 2 * eastPixel + southEastPixel );
	float Sy = northWestPixel + 2 * southPixel + northEastPixel - ( southWestPixel + 2 * northPixel + southEastPixel );

	float dist = Sx * Sx + Sy * Sy;

	if( dist > edgeThreshold )
		return vec4( 1.0 );//texture2D( u_colorTexture, texCoords );
	else 
		return vec4( 0.0,0.0,0.0,1.0);//vec4( 0.35,0.35,0.35,1.0 );
}

vec4 GetPixelFromLen( const vec2 texCoords )
{
	vec2 pixelCenter = vec2( 0.5, 0.5 );
	vec2 pixelToCenterDisplacement = pixelCenter - texCoords;
	pixelToCenterDisplacement.x *= SCREEN_WIDTH / SCREEN_HEIGHT;
	float distFromPixelToCenter = length( pixelToCenterDisplacement );
	vec4 pixelInLen;
	float magnitude = 0.5;
	vec4 normalColor = texture2D( u_colorTexture, texCoords );

	//if( abs( pixelToCenterDisplacement.y ) < 0.25 && abs( pixelToCenterDisplacement.x ) < 0.25 * SCREEN_HEIGHT/SCREEN_WIDTH  )
	if( distFromPixelToCenter < 0.25 )
	{
		vec2 offsetTexCoords = pixelToCenterDisplacement * magnitude;
		vec2 newTexCoords = texCoords + offsetTexCoords;
		pixelInLen = texture2D( u_colorTexture, newTexCoords );
		return pixelInLen;
	}
	else
		return GetPixelFromSobelEdgeDetection( texCoords );//vec4 ( 1.0 - GetZoomBlurColor( texCoords ).rgb, 1.0 );
}

vec4 GetTwoPassBlurPixel( vec2 texCoords )
{
	vec4 sum = vec4( 0.0 );

	float dx = 1.0 / u_resolution.x;
	float dy = 1.0 / u_resolution.y;
	float horizontalStep = u_blurDirection.x;
	float verticalStep = u_blurDirection.y;

	sum += texture2D( u_colorTexture, vec2( texCoords.x - 4.0 * horizontalStep * dx, texCoords.y - 4.0 * verticalStep * dy ) ) * 0.0162162162;
	sum += texture2D( u_colorTexture, vec2( texCoords.x - 3.0 * horizontalStep * dx, texCoords.y - 3.0 * verticalStep * dy ) ) * 0.0540540541;
	sum += texture2D( u_colorTexture, vec2( texCoords.x - 2.0 * horizontalStep * dx, texCoords.y - 2.0 * verticalStep * dy ) ) * 0.1216216216;
	sum += texture2D( u_colorTexture, vec2( texCoords.x - 1.0 * horizontalStep * dx, texCoords.y - 1.0 * verticalStep * dy ) ) * 0.1945945946;
																				 										  
	sum += texture2D( u_colorTexture, texCoords )  * 0.2270270270;				 										  
																				 										  
	sum += texture2D( u_colorTexture, vec2( texCoords.x + 4.0 * horizontalStep * dx, texCoords.y + 4.0 * verticalStep * dy ) ) * 0.1945945946;
	sum += texture2D( u_colorTexture, vec2( texCoords.x + 3.0 * horizontalStep * dx, texCoords.y + 3.0 * verticalStep * dy ) ) * 0.1216216216;
	sum += texture2D( u_colorTexture, vec2( texCoords.x + 2.0 * horizontalStep * dx, texCoords.y + 2.0 * verticalStep * dy ) ) * 0.0540540541;
	sum += texture2D( u_colorTexture, vec2( texCoords.x + 1.0 * horizontalStep * dx, texCoords.y + 1.0 * verticalStep * dy ) ) * 0.0162162162;

	return sum;
}

void main()
{
	vec4 fragColor;
	vec4 surfaceColor = v_color;
	vec2 texCoords = v_textureCoords;

	vec4 colorTexel = texture2D( u_colorTexture, texCoords );
	vec4 depthTexel = texture2D( u_depthTexture, texCoords );
	//colorTexel = GetblurTexelAtTexCoords( texCoords );
	//colorTexel = GetZoomBlurColor( texCoords );
	//colorTexel = GetRadicalBlurColor();
	//colorTexel = GetDontStarveEffect();
	//colorTexel = GetPixelFromSobelEdgeDetection( texCoords );
	//colorTexel = GetPixelFromLen( texCoords );
	//colorTexel = GetUnderWaterCausticPixel();

	fragColor = colorTexel;

	if( u_enableBlur == 1.0 )
		fragColor = GetTwoPassBlurPixel( texCoords );

	o_fragColor = fragColor;// * surfaceColor;
}

//tint lime yellow color *= Vec3(0.5,1.0,0.3);



