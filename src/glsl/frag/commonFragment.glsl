varying vec2 vxy;

// 例子来自https://www.shadertoy.com/view/tsjfDh#
void main() {
    float size = 2.0;
    // vec2 uv = gl_FragCoord.xy / vxy;
    vec2 tiledUV = fract(vxy * size);
    vec2 square = abs(tiledUV * 2. - 1.);
    vec2 sharpSquare = step(0.8, square);
    float result = sharpSquare.x + sharpSquare.y;

    gl_FragColor = vec4(0.21, 0.03, 0.03, 1.0) * result;
}
