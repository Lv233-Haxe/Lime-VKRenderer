#version 450

// Vulkan2DRenderer batched quad vertex shader.
// inPos is ALREADY in NDC (the batcher applies the ortho transform CPU-side
// while expanding quads), so no uniform block is needed.

layout(location = 0) in vec2 inPos;
layout(location = 1) in vec2 inUV;
layout(location = 2) in vec4 inColor;

layout(location = 0) out vec2 vUV;
layout(location = 1) out vec4 vColor;

void main()
{
    vUV = inUV;
    vColor = inColor;
    gl_Position = vec4(inPos, 0.0, 1.0);
}
