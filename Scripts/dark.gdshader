shader_type canvas_item;

const int MAX_LIGHTS = 16;

uniform int light_count = 0;
uniform vec2 light_points[MAX_LIGHTS * 4];
uniform int light_sizes[MAX_LIGHTS];

uniform float time = 0.0; // <-- send from script

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment()
{
    vec2 uv = FRAGCOORD.xy;

    bool visible = false;

    float min_edge_dist = 1e10;

    for (int i = 0; i < light_count; i++) {

        int count = light_sizes[i];

        bool inside = true;

        for (int j = 0; j < count; j++) {

            int k = (j + 1) % count;

            vec2 a = light_points[i * 4 + j];
            vec2 b = light_points[i * 4 + k];

            float cross_value =
                (uv.x - a.x) * (b.y - a.y) -
                (uv.y - a.y) * (b.x - a.x);

            float edge_dist = abs(cross_value);
            min_edge_dist = min(min_edge_dist, edge_dist);

            if (cross_value > 0.0) {
                inside = false;
                break;
            }
        }

        if (inside) {
            visible = true;
            break;
        }
    }

    // ----------------------------
    // ✨ EDGE GLOW + SOFTNESS
    // ----------------------------

    float edge_width = 12.0;
    float glow = smoothstep(edge_width, 0.0, min_edge_dist);

    // ----------------------------
    // 🌊 SHIMMER
    // ----------------------------

    float shimmer =
        sin(uv.y * 0.03 + time * 3.0) * 0.5 + 0.5;

    glow *= shimmer;

    // ----------------------------
    // ✨ SPARKLE NOISE
    // ----------------------------

    float spark = hash(uv * 0.5 + time);
    glow += step(0.985, spark) * 0.8;

    // ----------------------------
    // 🌫 FINAL COLOR
    // ----------------------------

    if (visible) {

        // inside light = faint magical haze instead of pure cut
        COLOR = vec4(0.6, 0.8, 1.0, 0.05 + glow * 0.05);

    } else {

        float darkness = 0.7 - glow * 0.4;

        COLOR = vec4(0.0, 0.0, 0.0, darkness);
    }
}