#version 400

in vec2 v_texCoords;

uniform sampler2D u_ssaoTexture;

out vec4 o_fragColor;

void main() 
{
    vec2 texelSize = 1.0 / vec2( textureSize( u_ssaoTexture, 0 ) );
    float result = 0.0;
    for ( int x = -2; x < 2; ++x ) 
    {
        for ( int y = -2; y < 2; ++y ) 
        {
            vec2 offset = vec2( float(x), float(y) ) * texelSize;
            result += texture( u_ssaoTexture, v_texCoords + offset ).r;
        }
    }
    o_fragColor = vec4 ( vec3( result / 16.0 ), 1.0 );
}