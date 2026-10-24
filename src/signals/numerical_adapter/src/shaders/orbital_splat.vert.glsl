#version 300 es
precision highp float;

// Full-screen quad vertex in normalized device coordinates [-1, 1]^2
layout(location = 0) in vec2 a_position;

// Half-extent of the orbital plane viewport in Astronomical Units (AU)
uniform vec2 u_orbital_half_extent_au;

// Interpolated orbital-plane coordinates (x, y) in AU
out vec2 v_orbital_xy;

void main() {
    v_orbital_xy = a_position * u_orbital_half_extent_au;
    gl_Position = vec4(a_position, 0.0, 1.0);
}
