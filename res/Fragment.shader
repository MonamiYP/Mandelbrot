#version 330 core

out vec4 fragmentColour;

uniform vec2 u_screenSize;
uniform vec3 u_cameraPos;
uniform int u_maxIteration;

vec2 ds_add(vec2 ds_num1, vec2 ds_num2) {
    vec2 ds_ans;
    float t1, t2, e;

    t1 = ds_num1.x + ds_num2.x;
    e = t1 - ds_num1.x;
    t2 = ((ds_num2.x - e) + (ds_num1.x - (t1 - e))) + ds_num1.y + ds_num2.y;

    ds_ans.x = t1 + t2;
    ds_ans.y = t2 - (ds_ans.x - t1);
    return ds_ans;
}

vec2 ds_mul(vec2 dsa, vec2 dsb) {
    vec2 dsc;
    float c11, c21, c2, e, t1, t2;
    float a1, a2, b1, b2, cona, conb, split = 8193.;

    cona = dsa.x * split;
    conb = dsb.x * split;
    a1 = cona - (cona - dsa.x);
    b1 = conb - (conb - dsb.x);
    a2 = dsa.x - a1;
    b2 = dsb.x - b1;

    c11 = dsa.x * dsb.x;
    c21 = a2 * b2 + (a2 * b1 + (a1 * b2 + (a1 * b1 - c11)));

    c2 = dsa.x * dsb.y + dsa.y * dsb.x;

    t1 = c11 + c2;
    e = t1 - c11;
    t2 = dsa.y * dsb.y + ((c2 - e) + (c11 - (t1 - e))) + c21;

    dsc.x = t1 + t2;
    dsc.y = t2 - (dsc.x - t1);

    return dsc;
}

vec4 burning_boat(vec4 z, vec4 c) {
    vec4 new_z = vec4(abs(z.x), abs(z.y), abs(z.z), abs(z.w));
    vec2 zr = ds_add(ds_mul(new_z.xy, new_z.xy), -ds_mul(new_z.zw, new_z.zw));
    vec2 zi = ds_mul(vec2(2.0, 0.0), ds_mul(new_z.xy, new_z.zw));

    return vec4(zr, zi) + c;
}

vec4 mandelbrot_double(vec4 z, vec4 c) {
    vec2 zr = ds_add(ds_mul(z.xy, z.xy), -ds_mul(z.zw, z.zw));
    vec2 zi = ds_mul(vec2(2.0, 0.0), ds_mul(z.xy, z.zw));

    return vec4(zr, zi) + c;
}

vec2 mandelbrot(vec2 z, vec2 c) {
    float zr = z.x * z.x - z.y * z.y;
    float zi = 2.0 * z.x * z.y;

    return vec2(zr, zi) + c;
}

float fractal(vec4 c) {
    vec4 z = vec4(0.0);
    float iteration = 0.0;
    while (iteration < u_maxIteration) {
        z = mandelbrot_double(z, c);
        if (length(z.xz) > 4.0)
            return iteration;
        iteration++;
    }
    return iteration;
}

// float fractal(vec2 c) {
//     vec2 z = vec2(0.0);
//     float iteration = 0.0;
//     while (iteration < u_maxIteration) {
//         z = mande(z, c);
//         if (length(z) > 4.0)
//             return iteration;
//         iteration++;
//     }
//     return iteration;
// }

void main()
{
    vec2 norm = (gl_FragCoord.xy - 0.5*u_screenSize.xy) / u_screenSize.y;
    float zoom = pow(10, u_cameraPos.z);
    vec2 c_pre = norm  * zoom  + vec2(u_cameraPos.x, u_cameraPos.y);
    vec4 c = vec4(c_pre.x, 0, c_pre.y, 0);

    float iteration = fractal(c);

    if (iteration == u_maxIteration) {
        fragmentColour = vec4(0, 0, 0, 1);
    } else {
        fragmentColour = vec4((-cos(0.2*iteration)+1.0)/1.0,
                      (-cos(0.13*iteration)+1.0)/2.0,
                      (-cos(0.1*iteration)+1.0)/1.5,
                        1.0);
        //fragmentColour =  vec4(iteration/u_maxIteration * 0.9 + 0.8, iteration/u_maxIteration * 0.3 + 0.2, 0, 1); 
    }
}