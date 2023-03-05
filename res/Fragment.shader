#version 330 core

out vec4 fragmentColour;

uniform vec2 u_screenSize;
uniform int u_maxIteration;
uniform vec2 u_xLim;
uniform vec2 u_yLim;

vec2 computeNextIteration(vec2 z, vec2 c) {
    float zr = z.x * z.x - z.y * z.y;
    float zi = 2.0 * z.x * z.y;

    return vec2(zr, zi) + c;
}

int mandelbrot(vec2 c) {
    vec2 z = vec2(0.0);
    int iteration = 0;
    while ((z.x * z.x + z.y * z.y) < 4.0 && iteration < u_maxIteration) {
        z = computeNextIteration(z, c);
        iteration++;
    }
    return iteration;
}

void main() {
    //vec2 c = (gl_FragCoord.xy - 0.5 * u_screenSize) / u_screenSize.y;
    vec2 c = vec2(gl_FragCoord.x * (u_xLim.y - u_xLim.x) / u_screenSize.x + u_xLim.x,
        gl_FragCoord.y * (u_yLim.y - u_yLim.x) / u_screenSize.y + u_yLim.x);

    int iteration = mandelbrot(c);

    fragmentColour = vec4(vec3(iteration/u_maxIteration), 1);
}