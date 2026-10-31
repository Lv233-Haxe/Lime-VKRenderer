#version 450

// Verification shader: the cell color IS the tint written into the dynamic
// UBO slice, so a render-to-FBO + readback can assert every slice byte-exact.
// (The textured path is covered by the cube pipeline sampling the offscreen
// render; this one isolates UBO correctness.)
layout(location = 0) in vec2 vUV;
layout(location = 1) in vec4 vTint;

layout(location = 0) out vec4 outColor;

void main()
{
    outColor = vTint;
}
