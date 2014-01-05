
vec2 accel(vec2 p)
{
    float l = 1.0/length(p);
    
    return -p * (l * l * l);
}


vec4 f(vec4 x)
{
    const vec2 ExplosionPlace = vec2(123.0, 456.0);
    
    vec4 p = vec4(ExplosionPlace, ExplosionPlace);
    vec4 v = x;
    
    const float dt = 0.1;
    
    for (int i = 0; i < 100; i++) {
        
        vec2 a1 = accel(vec2(p.x, p.y));
        vec2 a2 = accel(vec2(p.z, p.w));
        vec4 a = vec4(a1, a2);
        
        p += v*dt;
        v += a*dt;
    }

    return p;
}

