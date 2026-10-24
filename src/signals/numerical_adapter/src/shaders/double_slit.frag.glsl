#version 300 es
precision highp float;

in vec2 v_detector_xy;
out vec4 frag_color;

// Model selector:
// 0 = Fraunhofer N-slit reference
// 1 = Huygens-Steiner parallel-axis barycentric coherence (Qian & Izadi 2023)
// 2 = Gr(2,4) real Plucker channel model
// 3 = Gr_C(2,4) complex twistor crossing-minor model (|Delta_02^C * Delta_13^C|^2)
// 4 = De Broglie-Bohm / Madelung Pilot-Wave hydrodynamic model
// 5 = Wigner phase-space marginal model
// 6 = Gr_>=0(2,4) unphased crossing-minor proxy
uniform int u_model_kind;

// Aperture & grating geometry parameters (u_num_slits > 0)
uniform int u_num_slits;
uniform float u_slit_width;
uniform float u_slit_height;
uniform float u_slit_separation;
uniform float u_wavelength;
uniform float u_screen_distance;
uniform float u_single_slit_scale;

// Coherence, Gr_C(2,4) barycentric shift, Pilot-Wave, Wigner, and OAM parameters
uniform float u_barycentric_shift;
uniform float u_visibility;
uniform float u_non_equilibrium_residual;
uniform float u_decoherence_rate;
uniform float u_oam_decoherence_rate;
uniform int u_delta_oam;
uniform float u_azimuth_phi;
uniform bool u_use_local_polar_azimuth;
uniform bool u_render_error_map;

const float PI = 3.14159265358979323846;
const int MAX_SLITS = 64;

float unnormalized_sinc(float u) {
    if (abs(u) < 1e-6) {
        return 1.0 - (u * u) / 6.0;
    }
    return sin(u) / u;
}

float rectangular_slit_envelope(float x, float y) {
    float denom = max(u_wavelength * u_screen_distance, 1e-12);
    float sx = unnormalized_sinc(PI * u_slit_width * x / denom);
    float sy = unnormalized_sinc(PI * u_slit_height * y / denom);
    return (sx * sx) * (sy * sy);
}

// Complex 2x2 determinant for a 2x4 complex matrix M_C stored as two rows of 4 complex numbers
vec2 complex_mul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 complex_sub(vec2 a, vec2 b) {
    return a - b;
}

float complex_norm_sq(vec2 z) {
    return dot(z, z);
}

// Evaluate |Delta_02^C * Delta_13^C|^2 for complexGr24ChannelMatrix(z1, z2) = [[1, 1, 0, -1], [0, z1, 1, z2]]
float complex_gr24_crossing_factor(vec2 z1, vec2 z2) {
    // Columns of M_C:
    // col 0 = (1, 0), col 1 = (1, z1), col 2 = (0, 1), col 3 = (-1, z2)
    // Delta_02^C = 1 * 1 - 0 * 0 = 1
    // Delta_13^C = 1 * z2 - (-1) * z1 = z1 + z2
    vec2 delta_02 = vec2(1.0, 0.0);
    vec2 delta_13 = z1 + z2;
    vec2 crossing = complex_mul(delta_02, delta_13);
    return complex_norm_sq(crossing);
}

// Multi-slit (N > 0) interference factor G_N(V, beta) = N + 2 V sum_{0 <= j < k < N} cos(2(k-j)beta)
float multi_slit_interference_factor(int n_slits, float visibility, float beta) {
    int n = clamp(n_slits, 1, MAX_SLITS);
    float pair_sum = 0.0;
    for (int j = 0; j < MAX_SLITS; ++j) {
        if (j >= n) break;
        for (int k = j + 1; k < MAX_SLITS; ++k) {
            if (k >= n) break;
            float step_diff = float(k - j);
            pair_sum += cos(2.0 * step_diff * beta);
        }
    }
    return float(n) + 2.0 * visibility * pair_sum;
}

float evaluate_model_intensity(int model_kind, float x, float y, float phi) {
    int n_slits = max(u_num_slits, 1);
    float env = rectangular_slit_envelope(x, y);
    float denom = max(u_wavelength * u_screen_distance, 1e-12);
    float beta = (PI * u_slit_separation * x / denom) + 0.5 * float(u_delta_oam) * phi;
    float d_bary = clamp(u_barycentric_shift, -1.0, 1.0);
    float v_bary = sqrt(max(0.0, 1.0 - d_bary * d_bary));

    if (model_kind == 0) {
        // 0: Fraunhofer N-slit reference (V = 1)
        return u_single_slit_scale * env * multi_slit_interference_factor(n_slits, 1.0, beta);
    } else if (model_kind == 1) {
        // 1: Huygens-Steiner parallel-axis barycentric coherence
        return u_single_slit_scale * env * multi_slit_interference_factor(n_slits, u_visibility, beta);
    } else if (model_kind == 2) {
        // 2: Gr(2,4) real Plucker channel model with w_A = 1 + d_bary, w_B = 1 - d_bary, sqrt(w_A w_B) = v_bary
        return u_single_slit_scale * env * multi_slit_interference_factor(n_slits, v_bary, beta);
    } else if (model_kind == 3) {
        // 3: Gr_C(2,4) complex twistor crossing-minor evaluator |Delta_02^C * Delta_13^C|^2
        if (n_slits == 2) {
            float a = sqrt(max(0.0, 1.0 + d_bary));
            float b = sqrt(max(0.0, 1.0 - d_bary));
            vec2 z1 = vec2(a * cos(beta), a * sin(beta));
            vec2 z2 = vec2(b * cos(beta), -b * sin(beta));
            return u_single_slit_scale * env * complex_gr24_crossing_factor(z1, z2);
        }
        return u_single_slit_scale * env * multi_slit_interference_factor(n_slits, v_bary, beta);
    } else if (model_kind == 4) {
        // 4: Pilot-Wave (De Broglie-Bohm) model
        float i_fraun = u_single_slit_scale * env * multi_slit_interference_factor(n_slits, 1.0, beta);
        return i_fraun + u_non_equilibrium_residual;
    } else if (model_kind == 5) {
        // 5: Wigner phase-space marginal with spatial and quadratic OAM decoherence
        float oam_sq = float(u_delta_oam * u_delta_oam);
        float v_wigner = exp(-(u_decoherence_rate + u_oam_decoherence_rate * oam_sq));
        return u_single_slit_scale * env * multi_slit_interference_factor(n_slits, v_wigner, beta);
    } else {
        // 6: Real positive Grassmannian Gr_>=0(2,4) unphased crossing-minor proxy (V = 0)
        return u_single_slit_scale * env * float(n_slits);
    }
}

void main() {
    float x = v_detector_xy.x;
    float y = v_detector_xy.y;
    float phi = u_use_local_polar_azimuth ? atan(y, x) : u_azimuth_phi;

    float candidate = evaluate_model_intensity(u_model_kind, x, y, phi);
    float reference = evaluate_model_intensity(0, x, y, phi);
    float peak = max(float(max(u_num_slits, 1) * max(u_num_slits, 1)) * u_single_slit_scale, 1e-12);

    if (u_render_error_map) {
        float rel_err = abs(candidate - reference) / max(reference, peak * 1e-3);
        float c = clamp(rel_err, 0.0, 1.0);
        frag_color = vec4(c, 0.25 * c, 1.0 - c, 1.0);
    } else {
        float norm_i = clamp(candidate / peak, 0.0, 1.0);
        frag_color = vec4(norm_i, pow(norm_i, 0.75), sqrt(norm_i), 1.0);
    }
}
