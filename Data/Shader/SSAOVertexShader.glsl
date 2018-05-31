#version 400

in vec3 a_vertexPosition;
in vec2 a_vertexTexCoords;

out vec2 v_texCoords;

void main()
{
    gl_Position = vec4(a_vertexPosition, 1.0f);
    v_texCoords = a_vertexTexCoords;
}