#version 330

in vec2 fragTexCoord; // unused
out vec4 finalColor;

uniform float u_time;
uniform vec2  u_resolution;
uniform vec3  u_hexColor; // e.g. vec3(0.8, 0.3, 0.1)
uniform vec3  u_bgColor;  // e.g. vec3(0.5, 0.3, 0.1)

mat2 rotMat(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }

const vec2 s = vec2(1.0, 1.7320508).yx;

vec4 getHex(vec2 p) {
    vec4 h = vec4(p, p - s / 2.0);
    vec4 iC = floor(h / s.xyxy) + 0.5;
    h -= iC * s.xyxy;
    return dot(h.xy, h.xy) < dot(h.zw, h.zw) ? vec4(h.xy, iC.xy) : vec4(h.zw, iC.zw + 0.5);
}

float sdHexagon(in vec2 p, in float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

float map(vec2 p) {
    vec4 hex = getHex(p);
    return -sdHexagon(hex.xy, 0.4);
}

void main() {
    vec2 res = u_resolution;
    vec2 p = 3.0 * (gl_FragCoord.xy - 0.5 * res) / res.y;
    p = p * rotMat(0.5 * cos(u_time * 0.3)) + u_time;

    float d  = map(p);
    float t  = 1.0 - smoothstep(0.0, 3.0 / res.y, d);
    float t2 = 1.0 - smoothstep(0.0, 3.0 / res.y, max(map(p + 0.05), -d));

    vec3 col = t * u_hexColor - 0.1 * t2 + (1.0 - t) * u_bgColor;
    col = pow(col, vec3(1.0) / 2.2);
    finalColor = vec4(col, 1.0);
}