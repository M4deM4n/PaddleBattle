#version 330


in vec2 fragTexCoord; // unused
out vec4 finalColor;

uniform float u_targetHeight;
uniform vec2  u_ballPos;
uniform float u_ballRadius;
uniform float u_distortRadius;
uniform float u_gridSize;
uniform float u_lineWidth;
uniform vec3  u_bgColor;
uniform vec3  u_lineColor;
uniform vec3  u_glowColor;

void main() {
    // gl_FragCoord is bottom-left origin (OpenGL). Game code uses top-left
    // origin, so flip Y once here and everything downstream stays in the
    // same coordinate system as ball.position.
    vec2 p = vec2(gl_FragCoord.x, u_targetHeight - gl_FragCoord.y);

    // Ball distortion
    //
    // The falloff uses smoothstep instead of a linear ramp so its slope reaches
    // zero at the boundary (dist == u_distortRadius). With a linear falloff the
    // slope changes abruptly there, which shows up as a visible circular
    // "ring" in fine grids -- feathering with smoothstep removes it.
    //
    //   smoothstep(edge0, edge1, x): edge0 > edge1 reverses the ramp, so
    //   this returns 1 at dist=0, smoothly falling to 0 at dist=u_distortRadius.
    vec2 gp = p;
    float dist = length(p - u_ballPos);
    float falloff = smoothstep(u_distortRadius, 0.0, dist);
    float strength = u_distortRadius * 0.15 * falloff;
    if (dist > 0.0) {
        gp += normalize(p - u_ballPos) * strength;
    }

    // Grid
    vec2  cell     = gp / u_gridSize;
    vec2  cellFrac = abs(fract(cell) - 0.5);        // 0 on a line, 0.5 in middle
    vec2  fw       = max(fwidth(cell), vec2(1e-6));
    float pixelDist = min(cellFrac.x / fw.x, cellFrac.y / fw.y);
    float gridLine  = 1.0 - smoothstep(u_lineWidth, u_lineWidth + 1.0, pixelDist);

    // Color
    vec3 color = mix(u_bgColor, u_lineColor, gridLine);

    // Glow
    float glow = max(0.0, 1.0 - (dist / (u_ballRadius * 4.0)));
    color += u_glowColor * glow * 0.4;

    finalColor = vec4(color, 1.0);
}