#version 330 core

out vec4 fragmentColour;

uniform vec2 u_screenSize;
uniform vec3 u_cameraPos;
uniform int u_maxIteration;

vec2 ds_set(float num) {
    return vec2(num, 0.0);
}

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

vec2 burning_boat(vec2 z, vec2 c) {
    vec2 new_z = vec2(abs(z.x), abs(z.y));
    vec2 zr_double = ds_add(ds_mul(ds_set(new_z.x), ds_set(new_z.x)), -ds_mul(ds_set(new_z.y), ds_set(new_z.y)));
    vec2 zi_double = ds_mul(ds_set(2.0), ds_mul(ds_set(new_z.x), ds_set(new_z.y)));

    float zr = zr_double.x;
    float zi = zi_double.x;

    return vec2(zr, zi) + c;
}

vec2 mandelbrot_double(vec2 z, vec2 c) {
    vec2 zr_double = ds_add(ds_mul(ds_set(z.x), ds_set(z.x)), -ds_mul(ds_set(z.y), ds_set(z.y)));
    vec2 zi_double = ds_mul(ds_set(2.0), ds_mul(ds_set(z.x), ds_set(z.y)));

    float zr = zr_double.x;
    float zi = zi_double.x;

    return vec2(zr, zi) + c;
}

vec2 mandelbrot(vec2 z, vec2 c) {
    float zr = z.x * z.x - z.y * z.y;
    float zi = 2.0 * z.x * z.y;

    return vec2(zr, zi) + c;
}

float fractal(vec2 c) {
    vec2 z = vec2(0.0);
    float iteration = 0.0;
    while (iteration < u_maxIteration) {
        z = burning_boat(z, c);
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

    float iteration = fractal(c);

    if (iteration == u_maxIteration) {
        fragmentColour = vec4(0, 0, 0, 1);
    } else {
        fragmentColour = vec4((-cos(0.22*float(iteration))+1.0)/2.0,
                      (-cos(0.025*float(iteration))+1.0)/2.0,
                      (-cos(0.08*float(iteration))+1.0)/2.0,
                      1.0);
        //fragmentColour =  vec4(iteration/u_maxIteration * 0.9 + 0.8, iteration/u_maxIteration * 0.3 + 0.2, 0, 1); 
    }
}