#version 330

in vec2 fragTexCoord; // unused
out vec4 finalColor;

uniform float u_time;
uniform vec2  u_resolution;
uniform float u_rotationSpeed;   // rad/sec; original was 1/7 ≈ 0.143
uniform vec3  u_stripeColorA;    // dark base, original vec3(0.02, 0.02, 0.32)
uniform vec3  u_stripeColorB;    // aberration base, original vec3(0.77, 0.07, 0.26)
uniform vec3  u_highlightColor;  // stripe fill, original vec3(1.0, 0.98, 0.94)

// Replaces the audio-texture waveform sampled by interpolate() in the original.
float wave(float x) {
    return sin(x * 12.0 + u_time * 0.4) * 0.6
         + sin(x * 23.0 + u_time * 0.7) * 0.3;
}

void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    // Zoom-in intro from the original is dropped; hold the settled state.
    float t = 1.0;
    float texel  = 1.0 / u_resolution.y;
    float zoomTx = texel / (1.0 + t);

    uv /= t;

    vec2 v_center = -uv;
    float angle = atan(v_center.y, v_center.x);
    float d = length(v_center);
    angle += d;

    float variance = 0.70 * sin(wave(d / 2.1)) * (1.0 / (1.0 + d)) * 1.3;
    angle += variance;
    angle -= u_time * u_rotationSpeed;

    float stripe = sin(angle * 9.0) * 0.5 + 0.5;

    // AA scales with distance so lines near the centre don't shimmer.
    float aa = max((zoomTx / (d + 0.0001)) * 10.0, 0.1);
    float stripeWidth = 0.6;
    stripe = smoothstep(stripe - aa, stripe + aa, stripeWidth);

    float ab = 32.0 * stripe / stripeWidth * variance * d * t;
    // float ab = 32.0 * stripe / stripeWidth * d * t;
    vec3 stripeColor = mix(u_stripeColorA, u_stripeColorB, ab);
    // vec4 final = vec4(mix(stripeColor, u_highlightColor, stripe), 1.0);

    finalColor = vec4(mix(stripeColor, u_highlightColor, stripe), 1.0);
    finalColor.rgb *= (mod(gl_FragCoord.y, 2.0) < 1.0) ? 0.15 : 1.0;
}