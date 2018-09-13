precision mediump float;
varying vec3 outColor;
void main()
{
//    lowp float gray = dot((outColor),vec3(0.299,0.587,0.114));
//    gl_FragColor = vec4(gray,gray,gray,1.0);
      gl_FragColor = vec4(outColor,1.0);
}
