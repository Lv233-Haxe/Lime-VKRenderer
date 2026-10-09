[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/Lv233/Lime-VKRenderer.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/Lime-VKRenderer) [![Build Status](https://img.shields.io/github/actions/workflow/status/Lv233/Lime-VKRenderer/main.yml?branch=develop)](https://github.com/Lv233/Lime-VKRenderer/actions) [![Community](https://img.shields.io/discourse/posts?color=24afc4&server=https%3A%2F%2Fcommunity.openfl.org&label=community)](https://community.openfl.org/c/lime/19) [![Discord Server](https://img.shields.io/discord/415681294446493696.svg?color=7289da)](https://discordapp.com/invite/tDgq8EE)

Lime-VKRenderer
====
Lime-VKRenderer is a personal enhanced fork of Lime, the flexible, lightweight layer for Haxe cross-platform developers.
This fork replaces SDL2 with SDL3, adds fully validated native Vulkan 1.4 rendering backend, alongside all upstream Lime functionality.

Lime supports native, Flash and HTML5 targets with unified support for:
 * Windowing
 * Input
 * Events
 * Audio
 * Render contexts
 * Network access
 * Assets

Lime does not include a renderer, but exposes the current context:
 * Cairo
 * Canvas
 * DOM
 * Flash
 * GL
 * Vulkan 1.4 (Added in this fork)

The GL context is based upon the WebGL standard, implemented for both OpenGL and OpenGL ES as needed.

### Vulkan & SDL3 Features
- SDL2 replaced with SDL3, utilizing SDL3's new window, input and event subsystem features
- Native Vulkan 1.4 backend with fully validated implementation
- Built-in window/swapchain integration, resource management and command buffer primitives for custom renderers
- Vulkan support is available for Windows and Linux C++ native builds. Apple targets require explicit Vulkan-enabled builds with MoltenVK packaging.

To request a Vulkan window, use the standard RenderContextType.VULKAN context selection or set <window renderer="vulkan" /> in project XML.
The in-repo tests/vulkan-smoke project is used as the current Vulkan CI smoke test application.

Lime provides a unified audio API, but also provides access to OpenAL for advanced audio on native targets.

> ⚠️ Note: This is an independent fork. SDL3 migration and Vulkan 1.4 implementation are not merged into upstream OpenFL/Lime. For official upstream Lime, see https://github.com/openfl/lime.

License
=======
Lime is free, open-source software under the MIT license (LICENSE.md).
All additions in this fork (SDL3 port, Vulkan 1.4 backend) are also MIT licensed, consistent with upstream.

Installation
============
First, install the latest version of Haxe (http://www.haxe.org/download).

Install lime from Haxelib and run Lime's setup command:
haxelib install lime
haxelib run lime setup

Development Builds
==================
To install a development build, use the haxelib local command:
haxelib local Lime-VKRenderer-haxelib.zip

Building from Source
====================
1. Clone this Lime-VKRenderer repository, including submodules:
haxelib git Lime-VKRenderer https://github.com/Lv233/Lime-VKRenderer

2. Install required dependencies:
haxelib install format
haxelib install hxp

3. Copy the ndll directory from the latest Haxelib release (https://lib.haxe.org/p/Lime-VKRenderer/), or see project/README.md for details about building native binaries.

4. After any changes to the tools or lime/tools/src/lime/tools directories, rebuild from source:
Lime-VKRenderer rebuild tools

5. To switch away from a source build:
haxelib set Lime-VKRenderer [version number]

Sample
======
You can build a sample Lime project with the following commands:
lime create HelloWorld
cd HelloWorld
lime test neko

You can also list other projects that are available using:
lime create

> Enable Vulkan 1.4 rendering in your project XML:
<window renderer="vulkan" />

Targets
=======
Lime-VKRenderer currently supports the following targets:
lime test windows
lime test mac
lime test linux
lime test android
lime test ios
lime test html5
lime test flash
lime test air
lime test neko
lime test hl

Desktop builds are currently designed to be built on the same host OS.

Join the Community
==================
Have a question? Want a new place to hang out?
 * OpenFL Forums: https://community.openfl.org/c/lime/19
 * OpenFL Discord: https://discordapp.com/invite/tDgq8EE
