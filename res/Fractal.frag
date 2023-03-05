#version 450 core
out vec4 FragColor;

in vec4 color;

uniform vec2 screenSize;
uniform vec3 cameraPosition;
uniform int maxIT;

void main()
{
    vec2 pos = vec2 (gl_FragCoord);
    vec2 uv = (pos.xy - 0.5*screenSize.xy) / screenSize.y;
    float zoom =  pow (10, cameraPosition.z);

    vec2 z = vec2(0, 0);
    vec2 c = uv  * zoom;
    c += vec2(cameraPosition.x, cameraPosition.y);
    float it = 0;

    for (float i = 0; i < maxIT; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + c;
        if (length(z) > 2) {
            break;
        }
        it++;
    }

    float f = it/maxIT;
    vec3 col = vec3(f);
    FragColor =  vec4(col, 1); 
} 
