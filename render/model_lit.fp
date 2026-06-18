#version 140

in mediump vec2 var_texcoord0;
in mediump vec3 var_normal;
in highp vec4 var_light_pos;
in mediump float var_use_shadow;

out vec4 out_fragColor;

uniform mediump sampler2D tex0;
uniform mediump sampler2D shadow_map;

float get_shadow() {
    highp vec3 proj = var_light_pos.xyz / var_light_pos.w;
    proj = proj * 0.5 + 0.5;
    if (proj.x < 0.0 || proj.x > 1.0 || proj.y < 0.0 || proj.y > 1.0 || proj.z > 1.0)
        return 1.0;
    highp float stored = texture(shadow_map, proj.xy).r;
    highp float bias = 0.003;
    return (proj.z - bias > stored) ? 0.45 : 1.0;
}

void main()
{
    // Shadow depth pass: write depth to R channel
    if (var_use_shadow < -0.5) {
        out_fragColor = vec4(gl_FragCoord.z, 0.0, 0.0, 1.0);
        return;
    }

    vec3 N = normalize(var_normal);
    vec3 L = normalize(vec3(0.35, 0.7, 0.55));
    float diff = max(dot(N, L), 0.0);
    vec3 Lf = normalize(vec3(-0.2, 0.5, -0.3));
    float fill = max(dot(N, Lf), 0.0) * 0.18;
    vec3 sun_tint = vec3(1.0, 0.96, 0.82);
    vec3 sky_tint = vec3(0.72, 0.78, 0.88);
    vec3 tint = mix(sky_tint, sun_tint, diff);
    float light = 0.52 + 0.42 * diff + fill;

    float shadow = 1.0;
    if (var_use_shadow > 0.5) {
        shadow = get_shadow();
    }

    vec4 albedo = texture(tex0, var_texcoord0.xy);
    out_fragColor = vec4(albedo.rgb * tint * light * shadow, 1.0);
}
