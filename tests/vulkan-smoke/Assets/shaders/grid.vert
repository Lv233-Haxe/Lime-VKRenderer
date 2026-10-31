#version 450

// Per-object slice from a dynamic UBO: one vkBindDescriptorSets dynamic offset
// per draw picks the 256-byte slice (mat4 + padding) out of the shared buffer.
layout(binding = 0, std140) uniform Slice
{
    mat4 mvp;
    vec4 tint;
} slice;

layout(location = 0) in vec2 inPos;
layout(location = 1) in vec2 inUV;
layout(location = 2) in vec4 inColor;

layout(location = 0) out vec2 vUV;
layout(location = 1) out vec4 vTint;

void main()
{
    vUV = inUV;
    vTint = slice.tint;
    gl_Position = slice.mvp * vec4(inPos, 0.0, 1.0);
}
