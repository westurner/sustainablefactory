#version 300 es
precision highp float;

// Full-screen triangle / quad vertex attribute in normalized device coordinates [-1, 1]^2
layout(location = 0) in vec2 a_position;

// Physical detector-plane half-extents (meters)
uniform vec2 u_detector_half_extent;

// Interpolated physical detector coordinates (x, y) in meters
out vec2 v_detector_xy;

void main() {
    v_detector_xy = a_position * u_detector_half_extent;
    gl_Position = vec4(a_position, 0.0, 1.0);
}
