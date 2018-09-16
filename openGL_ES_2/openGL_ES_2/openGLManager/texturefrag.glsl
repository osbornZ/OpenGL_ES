precision mediump float;

uniform sampler2D image;

varying vec2 vTexcoord;

void main()
{
//    gl_FragColor = texture2D(image, vTexcoord);
    gl_FragColor = vec4(vec3(1.0-texture2D(image, vTexcoord)),1.0);
}
