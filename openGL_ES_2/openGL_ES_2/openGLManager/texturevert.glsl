attribute vec3 position;
attribute vec2 texcoord;

varying vec2 vTexcoord;

void main()
{
    gl_Position = vec4(position, 1.0);
    vTexcoord = vec2(texcoord.x,1.0-texcoord.y);
}
