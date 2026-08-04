#version 330

in vec2 fragTexCoord; // unused
out vec4 finalColor;

uniform float u_time;
uniform vec2  u_resolution;
uniform vec3  u_bgColor;   // e.g. vec3(0.01, 0.16, 0.42)
uniform vec3  u_rectColor; // e.g. vec3(0.01, 0.26, 0.57)

const float noiseIntensity  = 2.8;
const float noiseDefinition = 0.6;
const vec2  glowPos         = vec2(-2.0, 0.0);

const float total         = 60.0;
const float minSize       = 0.03;
const float maxSize       = 0.08 - minSize;
const float yDistribution = 0.5;

float random(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(in vec2 p) {
    p *= noiseIntensity;
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(random(i + vec2(0.0, 0.0)),
                   random(i + vec2(1.0, 0.0)), u.x),
               mix(random(i + vec2(0.0, 1.0)),
                   random(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(in vec2 uv) {
    uv *= 5.0;
    mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
    float f  = 0.5000 * noise(uv); uv = m * uv;
          f += 0.2500 * noise(uv); uv = m * uv;
          f += 0.1250 * noise(uv); uv = m * uv;
          f += 0.0625 * noise(uv);
    return 0.5 + 0.5 * f;
}

vec3 bg(vec2 uv) {
    float velocity  = u_time / 1.6;
    float intensity = sin(uv.x * 3.0 + velocity * 2.0) * 1.1 + 1.5;
    uv.y -= 2.0;
    vec2 bp = uv + glowPos;
    uv *= noiseDefinition;

    float rb = fbm(vec2(uv.x * 0.5 - velocity * 0.03, uv.y)) * 0.1;
    uv += rb;

    float rz = fbm(uv * 0.9 + vec2(velocity * 0.35, 0.0));
    rz *= dot(bp * intensity, bp) + 1.2;

    vec3 col = u_bgColor / (0.1 - rz);
    return sqrt(abs(col));
}

float rectangle(vec2 uv, vec2 pos, float width, float height, float blur) {
    pos = (vec2(width, height) + 0.01) * 0.5 - abs(uv - pos);
    pos = smoothstep(0.0, blur, pos);
    return pos.x * pos.y;
}

mat2 rotate2d(float a) {
    return mat2(cos(a), -sin(a),
                sin(a),  cos(a));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    vec3 color = bg(uv) * (2.0 - abs(uv.y * 2.0));

    float velX = -u_time / 8.0;
    float velY =  u_time / 10.0;
    for (float i = 0.0; i < total; i++) {
        float index = i / total;
        float rnd   = random(vec2(index));
        vec3 pos;
        pos.x = fract(velX * rnd + index) * 4.0 - 2.0;
        pos.y = sin(index * rnd * 1000.0 + velY) * yDistribution;
        pos.z = maxSize * rnd + minSize;

        vec2 uvRot = uv - pos.xy + pos.z * 0.5;
        uvRot = rotate2d(i + u_time * 0.5) * uvRot;
        uvRot += pos.xy + pos.z * 0.5;

        float rect = rectangle(uvRot, pos.xy, pos.z, pos.z,
                               (maxSize + minSize - pos.z) * 0.5);
        color += u_rectColor * rect * pos.z / maxSize;
    }

    finalColor = vec4(color, 1.0);
    finalColor.rgb *= (mod(gl_FragCoord.y, 2.0) < 1.0) ? 0.15 : 1.0;
}