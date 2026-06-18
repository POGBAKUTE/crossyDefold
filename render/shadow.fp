#version 140

in mediump vec2 var_pos;
out vec4 out_fragColor;

void main()
{
    float dist = length(var_pos);
    float alpha = smoothstep(0.5, 0.08, dist) * 0.60;
    out_fragColor = vec4(0.0, 0.0, 0.0, alpha);
}
