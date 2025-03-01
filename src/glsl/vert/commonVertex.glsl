uniform vec3 center;
uniform vec2 xy;
varying vec2 vxy;

void main() {
    vec3 offset = position - center;
    vxy = offset.xy / xy.xy;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}