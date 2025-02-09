shader_type spatial;
render_mode vertex_lighting, world_vertex_coords;

uniform sampler2D texture_1;
uniform sampler2D texture_2;
uniform vec2 scale = vec2(0.5);

varying vec3 world_pos;

void vertex() {
    world_pos = VERTEX;
}

void fragment() {
    vec2 world_uv = world_pos.xz * scale;

    vec4 tex1 = texture(texture_1, world_uv);
    vec4 tex2 = texture(texture_2, world_uv);

    ALBEDO = mix(tex1.rgb, tex2.rgb, smoothstep(0.0, 1.0, dot(COLOR.rgb, vec3(0.3))));
}