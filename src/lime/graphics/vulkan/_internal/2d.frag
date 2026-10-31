#version 450

// Vulkan2DRenderer batched quad fragment shader.

layout(binding = 1) uniform sampler2D tex0;

layout(location = 0) in vec2 vUV;
layout(location = 1) in vec4 vColor;

layout(location = 0) out vec4 outColor;

void main()
{
    outColor = texture(tex0, vUV) * vColor;
}
