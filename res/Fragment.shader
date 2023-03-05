#version 330 core

out vec4 fragmentColour;

uniform vec2 u_screenSize;
uniform vec3 u_cameraPos;
uniform int u_maxIteration;

vec2 computeNextIteration(vec2 z, vec2 c) {
    float zr = z.x * z.x - z.y * z.y;
    float zi = 2.0 * z.x * z.y;

    return vec2(zr, zi) + c;
}

float mandelbrot(vec2 c) {
    vec2 z = vec2(0.0);
    float iteration = 0.0;
    while (iteration < u_maxIteration) {
        z = computeNextIteration(z, c);
        if (length(z) > 4.0)
            return iteration;
        iteration++;
    }
    return iteration;
}

void main()
{
    vec2 norm = (gl_FragCoord.xy - 0.5*u_screenSize.xy) / u_screenSize.y;
    float zoom = pow(10, u_cameraPos.z);
    vec2 c = norm  * zoom + vec2(u_cameraPos.x, u_cameraPos.y);

    float iteration = mandelbrot(c);
    fragmentColour =  vec4(vec3(iteration/u_maxIteration), 1); 
}