#version 300 es
precision highp float;

in vec2 v_orbital_xy;
out vec4 frag_color;

const float PI = 3.14159265358979323846;
const int MAX_SPLATS = 32;
const int MAX_SINKS = 16;

// Splat roles:
// 0 = Body / Attractor / Sink / Source core splat
// 1 = Complex Gr_C(2,4) orbital field splat (sigma1 = sigma0*sqrt(1+e), sigma2 = sigma0*sqrt(1-e))
// 2 = DDF MovingSheath shear-jammed field splat (sigma1 = sigma0/gamma_phi, sigma2 = sigma0)
// 3 = Gravitomagnetic / Kerr-Lense-Thirring vortex swirl splat
uniform int u_splat_count;
uniform vec4 u_splat_center_weight_role[MAX_SPLATS]; // (center_x, center_y, weight, float(role))
uniform vec4 u_splat_sigma_angle_norm[MAX_SPLATS];   // (sigma1, sigma2, orientation_angle, norm_factor)

// Explicit N-body attractors / sinks / sources: (pos_x, pos_y, signed_strength_gm, core_softening)
// Positive strength = sink/attractor (Phi_phi < 0); negative strength = repulsive source
uniform int u_sink_count;
uniform vec4 u_sinks[MAX_SINKS];

// Highlighted precessing planetary orbit parameters:
// (semi_major_axis_au, eccentricity, eta_precession, perihelion_angle_varpi)
uniform vec4 u_orbit_params;
uniform bool u_show_gr24_field;
uniform bool u_show_ddf_sheath_field;
uniform bool u_show_sink_potential;
uniform bool u_show_orbit_curve;
uniform bool u_enable_twistor_phase_fringe;

// Evaluate a single L1-normed 2D anisotropic Tensor Gaussian Splat:
// G(x, y) = w * N(Sigma) * exp(-0.5 * ((u1 / sigma1)^2 + (u2 / sigma2)^2))
float evaluate_normed_tensor_splat(vec2 xy, vec4 center_weight_role, vec4 sigma_angle_norm) {
    vec2 d = xy - center_weight_role.xy;
    float weight = center_weight_role.z;
    float sigma1 = max(sigma_angle_norm.x, 1e-6);
    float sigma2 = max(sigma_angle_norm.y, 1e-6);
    float theta = sigma_angle_norm.z;
    float norm_factor = sigma_angle_norm.w;

    float c = cos(theta);
    float s = sin(theta);
    float u1 = d.x * c + d.y * s;
    float u2 = -d.x * s + d.y * c;

    float q_mahalanobis = (u1 * u1) / (sigma1 * sigma1) + (u2 * u2) / (sigma2 * sigma2);
    return weight * norm_factor * exp(-0.5 * q_mahalanobis);
}

// Evaluate dual-layer Gr_C(2,4) twistor splat intensity:
// I_splat(x, y) = G(x, y) * |Delta_02^C Delta_13^C|^2
//               = G(x, y) * (|w_A^C|^2 + |w_B^C|^2 + 2 |w_A^C||w_B^C| cos(Delta_phi))
// where |w_A^C||w_B^C| / (0.5*(|w_A^C|^2 + |w_B^C|^2)) = 2*sigma1*sigma2 / (sigma1^2 + sigma2^2) = V.
float evaluate_twistor_modulated_splat(vec2 xy, vec4 center_weight_role, vec4 sigma_angle_norm) {
    float g = evaluate_normed_tensor_splat(xy, center_weight_role, sigma_angle_norm);
    if (!u_enable_twistor_phase_fringe) {
        return g;
    }
    vec2 d = xy - center_weight_role.xy;
    float sigma1 = max(sigma_angle_norm.x, 1e-6);
    float sigma2 = max(sigma_angle_norm.y, 1e-6);
    float theta = sigma_angle_norm.z;
    float u1 = d.x * cos(theta) + d.y * sin(theta);
    float vis = (2.0 * sigma1 * sigma2) / (sigma1 * sigma1 + sigma2 * sigma2);
    float delta_phi = 2.0 * PI * u1 / max(0.5 * (sigma1 + sigma2), 1e-4);
    return g * (1.0 + vis * cos(delta_phi));
}

// Evaluate N-body superfluid Bernoulli sink/source enthalpy field
float evaluate_sink_source_field(vec2 xy) {
    int n = clamp(u_sink_count, 0, MAX_SINKS);
    float phi_sum = 0.0;
    for (int j = 0; j < MAX_SINKS; ++j) {
        if (j >= n) break;
        vec2 r_vec = xy - u_sinks[j].xy;
        float gm = u_sinks[j].z;
        float eps = max(u_sinks[j].w, 1e-4);
        float r = sqrt(dot(r_vec, r_vec) + eps * eps);
        phi_sum += gm / r;
    }
    return phi_sum;
}

// Evaluate proximity to the precessing polar conic r(phi) = p / (1 + e cos((1 - eta)(phi - varpi)))
float evaluate_precessing_orbit_ring(vec2 xy) {
    float a = max(u_orbit_params.x, 1e-6);
    float e = clamp(u_orbit_params.y, 0.0, 0.999);
    float eta = u_orbit_params.z;
    float varpi = u_orbit_params.w;

    float r = length(xy);
    float phi = atan(xy.y, xy.x);
    float p = a * (1.0 - e * e);
    float r_orbit = p / (1.0 + e * cos((1.0 - eta) * (phi - varpi)));
    float dr = abs(r - r_orbit);
    return exp(-(dr * dr) / (0.015 * a * 0.015 * a));
}

void main() {
    vec2 xy = v_orbital_xy;
    int n_splats = clamp(u_splat_count, 0, MAX_SPLATS);

    float body_sink_splat_acc = 0.0;
    float gr24_field_acc = 0.0;
    float ddf_sheath_acc = 0.0;
    float vortex_swirl_acc = 0.0;

    for (int i = 0; i < MAX_SPLATS; ++i) {
        if (i >= n_splats) break;
        int role = int(round(u_splat_center_weight_role[i].w));
        float val = evaluate_twistor_modulated_splat(
            xy,
            u_splat_center_weight_role[i],
            u_splat_sigma_angle_norm[i]
        );
        if (role == 0) {
            body_sink_splat_acc += val;
        } else if (role == 1 && u_show_gr24_field) {
            gr24_field_acc += val;
        } else if (role == 2 && u_show_ddf_sheath_field) {
            ddf_sheath_acc += val;
        } else if (role == 3) {
            vortex_swirl_acc += val;
        }
    }

    float sink_pot = u_show_sink_potential ? evaluate_sink_source_field(xy) : 0.0;
    float orbit_ring = u_show_orbit_curve ? evaluate_precessing_orbit_ring(xy) : 0.0;

    // Color channels:
    // Gold/Amber: Attractors / Sinks / Sources + Precessing Orbit Ring
    // Cyan/Blue: Complex Gr_C(2,4) Madelung Orbital Field Splat
    // Magenta/Violet: DDF Shear-Jammed MovingSheath Field Splat + Vortex Swirl
    vec3 col_sink = vec3(1.0, 0.78, 0.25) * clamp(body_sink_splat_acc + 0.15 * abs(sink_pot) + 0.6 * orbit_ring, 0.0, 1.0);
    vec3 col_gr24 = vec3(0.15, 0.82, 0.96) * clamp(gr24_field_acc, 0.0, 1.0);
    vec3 col_ddf  = vec3(0.92, 0.28, 0.78) * clamp(ddf_sheath_acc + vortex_swirl_acc, 0.0, 1.0);

    vec3 final_rgb = clamp(col_sink + col_gr24 + col_ddf, 0.0, 1.0);
    frag_color = vec4(final_rgb, 1.0);
}
