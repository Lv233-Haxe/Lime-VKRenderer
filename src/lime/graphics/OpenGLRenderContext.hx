package lime.graphics;

#if (!lime_doc_gen || lime_opengl)
#if (lime_doc_gen || (sys && lime_cffi && !doc_gen))
import lime._internal.backend.native.NativeOpenGLRenderContext;
import lime.utils.ArrayBufferView;
import lime.utils.BytePointer;
import lime.utils.DataPointer;

/**
	The `OpenGLRenderContext` allows access to OpenGL features when OpenGL is the render
	context type of the `Window`. Historically, Lime was designed for WebGL render support
	on all platforms, and support has expanded to provide additional OpenGL ES native APIs.

	Support for desktop OpenGL-specific features is currently sparse, but the
	`OpenGLRenderContext` provides the platform for us to add additional desktop specific
	features.

	The `OpenGLRenderContext` is not compatible with mobile or web targets, but it can be
	converted to an OpenGL ES or a WebGL-style context for cross-platform development.

	You can convert from `lime.graphics.RenderContext` or `lime.graphics.opengl.GL`, and
	can convert to `lime.graphics.OpenGLES3RenderContext`,
	`lime.graphics.OpenGLES2RenderContext`, `lime.graphics.WebGL2RenderContext`, or
	`lime.graphics.WebGLRenderContext` directly if desired:

	```haxe
	var gl:OpenGLRenderContext = window.context;
	var gl:OpenGLRenderContext = GL;

	var gles3:OpenGLES3RenderContext = gl;
	var gles2:OpenGLES2RenderContext = gl;
	var webgl2:WebGL2RenderContext = gl;
	var webgl:WebGLRenderContext = gl;
	```
**/
@:access(lime.graphics.RenderContext)
@:forward()
@:transitive
abstract OpenGLRenderContext(Dynamic) from Dynamic to Dynamic
{
	@:from private static function fromRenderContext(context:RenderContext):OpenGLRenderContext
	{
		return context.gl;
	}

	// -------------------------------------------------------------
	// GLVK fix: typed forwarding for pointer-taking GL calls.
	//
	// This abstract is `over Dynamic` (the lime fork made it so a
	// `GLVKContext` -- a plain class, not a `NativeOpenGLRenderContext` --
	// can be installed as `GL.context` via `GL.__setGLContext`). With
	// `@:forward` on a `Dynamic` abstract, every GL call degrades to
	// `this->__Field("name", paccDynamic)(args)` dynamic dispatch, which
	// SKIPS the compile-time `BytePointer -> DataPointer` (address)
	// conversion. In OpenGL mode the wrapped object is a real
	// `NativeOpenGLRenderContext`; its native entry then receives
	// `(GLfloat*)0` and SEH-crashes (e.g. `uniformMatrix4fv`).
	//
	// These explicit methods restore the conversion for the native path
	// while leaving the `GLVKContext` (Vulkan) path byte-for-byte intact:
	// when `this` is a `GLVKContext` we still dynamic-dispatch, so it
	// receives the original object (which `GLVKData.toBytes` knows how to
	// read). When `this` is a real native context we forward to
	// `NativeOpenGLRenderContext`'s typed methods.
	//
	// IMPORTANT: the conversion CANNOT be moved to the call site (i.e. by
	// typing these parameters as `DataPointer`). The two backends need
	// *different* values for the same argument: native GL needs the
	// ADDRESS (a Float), GLVK needs the wrapper OBJECT (`GLVKData.toBytes`
	// only reads Bytes/BytePointer/ArrayBufferView objects and cannot
	// recover a `Bytes` from a bare address). So the parameters stay
	// `Dynamic` and the conversion is done here, per backend, via
	// `__toDataPointer`.
	// -------------------------------------------------------------

	@:noCompletion private static function __isNative(o:Dynamic):Bool
	{
		return Std.isOfType(o, NativeOpenGLRenderContext);
	}

	/**
		Restore the `BytePointer -> DataPointer` conversion that dynamic dispatch skips.

		`DataPointer` is a Float holding the *address*. Its `@:from` converters
		(`fromBytesPointer`, `fromArrayBufferView`, `fromBytes`, ...) compute that
		address from the wrapper object. But when the value arrives as `Dynamic`,
		Haxe emits an unchecked `(Float)v` cast -- on a `BytePointer` object that
		yields 0/garbage and the native side dereferences `(GLfloat*)0` => SEH.
		So dispatch on the runtime type and call the right converter.
	**/
	// Note: `BytePointer`, `ArrayBuffer` and `lime.utils.Bytes` are all ABSTRACTS
	// and cannot be used as values in `Std.isOfType`, so match on their runtime
	// representations instead: `BytePointerData` (a class declared alongside
	// `BytePointer`) and `haxe.io.Bytes`. An `ArrayBuffer` is an abstract over
	// `Bytes`, so the `Bytes` branch covers it too (and `fromArrayBuffer` just
	// delegates to `fromBytes`). `ArrayBufferView` is a real class.
	@:noCompletion private static function __toDataPointer(v:Dynamic):DataPointer
	{
		if (v == null) return 0;
		if (Std.isOfType(v, BytePointerData)) return DataPointer.fromBytesPointer(v);
		if (Std.isOfType(v, ArrayBufferView)) return DataPointer.fromArrayBufferView(v);
		if (Std.isOfType(v, haxe.io.Bytes)) return DataPointer.fromBytes(v);
		return v; // already an address (Float/Int) or a DataPointer
	}

	// -- uniform float/int/uint vectors (native: loc,count,v ; webgl: loc,v) --
	public function uniform1fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1fv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform1fv(location, a, b, c);
	}
	public function uniform2fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2fv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform2fv(location, a, b, c);
	}
	public function uniform3fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3fv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform3fv(location, a, b, c);
	}
	public function uniform4fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4fv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform4fv(location, a, b, c);
	}
	public function uniform1iv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1iv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform1iv(location, a, b, c);
	}
	public function uniform2iv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2iv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform2iv(location, a, b, c);
	}
	public function uniform3iv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3iv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform3iv(location, a, b, c);
	}
	public function uniform4iv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4iv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform4iv(location, a, b, c);
	}
	public function uniform1uiv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1uiv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform1uiv(location, a, b, c);
	}
	public function uniform2uiv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2uiv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform2uiv(location, a, b, c);
	}
	public function uniform3uiv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3uiv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform3uiv(location, a, b, c);
	}
	public function uniform4uiv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4uiv(location, (b == null) ? 1 : a, __toDataPointer((b == null) ? a : b));
		else (cast this:Dynamic).uniform4uiv(location, a, b, c);
	}

	// -- matrix vectors (native: loc,count,transpose,v ; webgl: loc,transpose,v) --
	public function uniformMatrix2fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix2fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix2fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix2fv(location, a, b, c);
	}
	public function uniformMatrix3fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix3fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix3fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix3fv(location, a, b, c);
	}
	public function uniformMatrix4fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix4fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix4fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix4fv(location, a, b, c);
	}
	public function uniformMatrix2x3fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix2x3fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix2x3fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix2x3fv(location, a, b, c);
	}
	public function uniformMatrix2x4fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix2x4fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix2x4fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix2x4fv(location, a, b, c);
	}
	public function uniformMatrix3x2fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix3x2fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix3x2fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix3x2fv(location, a, b, c);
	}
	public function uniformMatrix3x4fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix3x4fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix3x4fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix3x4fv(location, a, b, c);
	}
	public function uniformMatrix4x2fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix4x2fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix4x2fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix4x2fv(location, a, b, c);
	}
	public function uniformMatrix4x3fv(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).uniformMatrix4x3fv(location, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).uniformMatrix4x3fv(location, 1, a, __toDataPointer(b)); }
		else (cast this:Dynamic).uniformMatrix4x3fv(location, a, b, c);
	}

	// -- buffer uploads --
	// GLVKContext.bufferData takes (target,a,?b,?c): c==null => webgl form
	// (target, srcData, usage); c!=null => native form (target, size, srcData, usage).
	// Native is always (target, size, srcData, usage), so the 3-arg webgl form
	// is mapped with a size=0 placeholder (dead path in native mode, where
	// foxlite always passes the 4-arg native form).
	public function bufferData(target:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).bufferData(target, a, __toDataPointer(b), c); else (cast this:NativeOpenGLRenderContext).bufferData(target, 0, __toDataPointer(a), b); }
		else (cast this:Dynamic).bufferData(target, a, b, c);
	}
	public function bufferSubData(target:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) { if (c != null) (cast this:NativeOpenGLRenderContext).bufferSubData(target, a, b, __toDataPointer(c)); else (cast this:NativeOpenGLRenderContext).bufferSubData(target, a, 0, __toDataPointer(b)); }
		else (cast this:Dynamic).bufferSubData(target, a, b, c);
	}

	// -- vertex attribs --
	public function vertexAttribPointer(index:Dynamic, size:Dynamic, type:Dynamic, normalized:Dynamic, stride:Dynamic, offset:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttribPointer(index, size, type, normalized, stride, __toDataPointer(offset));
		else (cast this:Dynamic).vertexAttribPointer(index, size, type, normalized, stride, offset);
	}
	// Integer-attrib form: (index, size, type, stride, offset) -- NO `normalized`.
	// WebGL2RenderContext / OpenGLES3RenderContext / GL all call it with 5 args.
	public function vertexAttribIPointer(index:Dynamic, size:Dynamic, type:Dynamic, stride:Dynamic, offset:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttribIPointer(index, size, type, stride, __toDataPointer(offset));
		else (cast this:Dynamic).vertexAttribIPointer(index, size, type, stride, offset);
	}

	// -- indexed draws --
	public function drawElements(mode:Dynamic, count:Dynamic, type:Dynamic, offset:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).drawElements(mode, count, type, __toDataPointer(offset));
		else (cast this:Dynamic).drawElements(mode, count, type, offset);
	}
	public function drawElementsInstanced(mode:Dynamic, count:Dynamic, type:Dynamic, offset:Dynamic, instanceCount:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).drawElementsInstanced(mode, count, type, __toDataPointer(offset), instanceCount);
		else (cast this:Dynamic).drawElementsInstanced(mode, count, type, offset, instanceCount);
	}
	// native drawRangeElements is (mode, start, end, count, type, offset) -- `mode` FIRST.
	public function drawRangeElements(mode:Dynamic, start:Dynamic, end:Dynamic, count:Dynamic, type:Dynamic, offset:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).drawRangeElements(mode, start, end, count, type, __toDataPointer(offset));
		else (cast this:Dynamic).drawRangeElements(mode, start, end, count, type, offset);
	}

	// -- texture uploads --
	public function texImage2D(target:Dynamic, level:Dynamic, internalformat:Dynamic, width:Dynamic, height:Dynamic, border:Dynamic, format:Dynamic, type:Dynamic, srcData:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).texImage2D(target, level, internalformat, width, height, border, format, type, __toDataPointer(srcData));
		else (cast this:Dynamic).texImage2D(target, level, internalformat, width, height, border, format, type, srcData);
	}
	public function texSubImage2D(target:Dynamic, level:Dynamic, xoffset:Dynamic, yoffset:Dynamic, width:Dynamic, height:Dynamic, format:Dynamic, type:Dynamic, srcData:Dynamic, ?srcOffset:Dynamic):Void
	{
		// native texSubImage2D takes 9 args (srcOffset has no native counterpart)
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, __toDataPointer(srcData));
		else (cast this:Dynamic).texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, srcData, srcOffset);
	}

	// -- readback --
	public function readPixels(x:Dynamic, y:Dynamic, width:Dynamic, height:Dynamic, format:Dynamic, type:Dynamic, pixels:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).readPixels(x, y, width, height, format, type, __toDataPointer(pixels));
		else (cast this:Dynamic).readPixels(x, y, width, height, format, type, pixels);
	}

	// -- WEBGL-named variants foxlite reaches through `GL.*` (no native *WEBGL
	//    counterpart exists, so map to the native method with count = 1) --
	public function uniform1fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1fv(location, 1, __toDataPointer(a));
		else (cast this:Dynamic).uniform1fvWEBGL(location, a, b, c);
	}
	public function uniform2fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2fv(location, 1, __toDataPointer(a));
		else (cast this:Dynamic).uniform2fvWEBGL(location, a, b, c);
	}
	public function uniform3fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3fv(location, 1, __toDataPointer(a));
		else (cast this:Dynamic).uniform3fvWEBGL(location, a, b, c);
	}
	public function uniform4fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4fv(location, 1, __toDataPointer(a));
		else (cast this:Dynamic).uniform4fvWEBGL(location, a, b, c);
	}
	public function uniformMatrix2fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniformMatrix2fv(location, 1, a, __toDataPointer(b));
		else (cast this:Dynamic).uniformMatrix2fvWEBGL(location, a, b, c);
	}
	public function uniformMatrix3fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniformMatrix3fv(location, 1, a, __toDataPointer(b));
		else (cast this:Dynamic).uniformMatrix3fvWEBGL(location, a, b, c);
	}
	public function uniformMatrix4fvWEBGL(location:Dynamic, a:Dynamic, ?b:Dynamic, ?c:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniformMatrix4fv(location, 1, a, __toDataPointer(b));
		else (cast this:Dynamic).uniformMatrix4fvWEBGL(location, a, b, c);
	}

	// -------------------------------------------------------------
	// GLVK perf: typed fast paths for the primitive-argument hot list.
	//
	// With this abstract over Dynamic, EVERY GL call degrades to
	// `__Field(name, paccDynamic)` + a Dynamic call with boxed arguments;
	// the openfl/flixel renderers issue thousands of those per frame. For
	// the native backend the underlying object is a real
	// `NativeOpenGLRenderContext`, so after one cheap runtime type check the
	// call becomes a plain static C++ method invocation. GLVK keeps the
	// Dynamic path byte-for-byte.
	// -------------------------------------------------------------

	// -- state & resources --
	public function activeTexture(texture:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).activeTexture(texture);
		else (cast this:Dynamic).activeTexture(texture);
	}
	public function bindBuffer(target:Dynamic, buffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).bindBuffer(target, buffer);
		else (cast this:Dynamic).bindBuffer(target, buffer);
	}
	public function bindFramebuffer(target:Dynamic, framebuffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).bindFramebuffer(target, framebuffer);
		else (cast this:Dynamic).bindFramebuffer(target, framebuffer);
	}
	public function bindRenderbuffer(target:Dynamic, renderbuffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).bindRenderbuffer(target, renderbuffer);
		else (cast this:Dynamic).bindRenderbuffer(target, renderbuffer);
	}
	public function bindTexture(target:Dynamic, texture:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).bindTexture(target, texture);
		else (cast this:Dynamic).bindTexture(target, texture);
	}
	public function blendColor(red:Dynamic, green:Dynamic, blue:Dynamic, alpha:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).blendColor(red, green, blue, alpha);
		else (cast this:Dynamic).blendColor(red, green, blue, alpha);
	}
	public function blendEquation(mode:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).blendEquation(mode);
		else (cast this:Dynamic).blendEquation(mode);
	}
	public function blendEquationSeparate(modeRGB:Dynamic, modeAlpha:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).blendEquationSeparate(modeRGB, modeAlpha);
		else (cast this:Dynamic).blendEquationSeparate(modeRGB, modeAlpha);
	}
	public function blendFunc(sfactor:Dynamic, dfactor:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).blendFunc(sfactor, dfactor);
		else (cast this:Dynamic).blendFunc(sfactor, dfactor);
	}
	public function blendFuncSeparate(srcRGB:Dynamic, dstRGB:Dynamic, srcAlpha:Dynamic, dstAlpha:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
		else (cast this:Dynamic).blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
	}
	public function clear(mask:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).clear(mask);
		else (cast this:Dynamic).clear(mask);
	}
	public function clearColor(red:Dynamic, green:Dynamic, blue:Dynamic, alpha:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).clearColor(red, green, blue, alpha);
		else (cast this:Dynamic).clearColor(red, green, blue, alpha);
	}
	public function clearDepth(depth:Dynamic):Void
	{
		// the native GLES-style entry is clearDepthf
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).clearDepthf(depth);
		else (cast this:Dynamic).clearDepth(depth);
	}
	public function clearStencil(s:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).clearStencil(s);
		else (cast this:Dynamic).clearStencil(s);
	}
	public function colorMask(red:Dynamic, green:Dynamic, blue:Dynamic, alpha:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).colorMask(red, green, blue, alpha);
		else (cast this:Dynamic).colorMask(red, green, blue, alpha);
	}
	public function cullFace(mode:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).cullFace(mode);
		else (cast this:Dynamic).cullFace(mode);
	}
	public function depthFunc(func:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).depthFunc(func);
		else (cast this:Dynamic).depthFunc(func);
	}
	public function depthMask(flag:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).depthMask(flag);
		else (cast this:Dynamic).depthMask(flag);
	}
	public function depthRange(nearVal:Dynamic, farVal:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).depthRangef(nearVal, farVal);
		else (cast this:Dynamic).depthRange(nearVal, farVal);
	}
	public function disable(cap:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).disable(cap);
		else (cast this:Dynamic).disable(cap);
	}
	public function disableVertexAttribArray(index:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).disableVertexAttribArray(index);
		else (cast this:Dynamic).disableVertexAttribArray(index);
	}
	public function drawArrays(mode:Dynamic, first:Dynamic, count:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).drawArrays(mode, first, count);
		else (cast this:Dynamic).drawArrays(mode, first, count);
	}
	public function drawArraysInstanced(mode:Dynamic, first:Dynamic, count:Dynamic, instanceCount:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).drawArraysInstanced(mode, first, count, instanceCount);
		else (cast this:Dynamic).drawArraysInstanced(mode, first, count, instanceCount);
	}
	public function enable(cap:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).enable(cap);
		else (cast this:Dynamic).enable(cap);
	}
	public function enableVertexAttribArray(index:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).enableVertexAttribArray(index);
		else (cast this:Dynamic).enableVertexAttribArray(index);
	}
	public function frontFace(mode:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).frontFace(mode);
		else (cast this:Dynamic).frontFace(mode);
	}
	public function lineWidth(width:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).lineWidth(width);
		else (cast this:Dynamic).lineWidth(width);
	}
	public function pixelStorei(pname:Dynamic, param:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).pixelStorei(pname, param);
		else (cast this:Dynamic).pixelStorei(pname, param);
	}
	public function polygonOffset(factor:Dynamic, units:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).polygonOffset(factor, units);
		else (cast this:Dynamic).polygonOffset(factor, units);
	}
	public function sampleCoverage(value:Dynamic, invert:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).sampleCoverage(value, invert);
		else (cast this:Dynamic).sampleCoverage(value, invert);
	}
	public function scissor(x:Dynamic, y:Dynamic, width:Dynamic, height:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).scissor(x, y, width, height);
		else (cast this:Dynamic).scissor(x, y, width, height);
	}
	public function stencilFunc(func:Dynamic, ref:Dynamic, mask:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilFunc(func, ref, mask);
		else (cast this:Dynamic).stencilFunc(func, ref, mask);
	}
	public function stencilFuncSeparate(face:Dynamic, func:Dynamic, ref:Dynamic, mask:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilFuncSeparate(face, func, ref, mask);
		else (cast this:Dynamic).stencilFuncSeparate(face, func, ref, mask);
	}
	public function stencilMask(mask:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilMask(mask);
		else (cast this:Dynamic).stencilMask(mask);
	}
	public function stencilMaskSeparate(face:Dynamic, mask:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilMaskSeparate(face, mask);
		else (cast this:Dynamic).stencilMaskSeparate(face, mask);
	}
	public function stencilOp(fail:Dynamic, zfail:Dynamic, zpass:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilOp(fail, zfail, zpass);
		else (cast this:Dynamic).stencilOp(fail, zfail, zpass);
	}
	public function stencilOpSeparate(face:Dynamic, fail:Dynamic, zfail:Dynamic, zpass:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).stencilOpSeparate(face, fail, zfail, zpass);
		else (cast this:Dynamic).stencilOpSeparate(face, fail, zfail, zpass);
	}
	public function texParameterf(target:Dynamic, pname:Dynamic, param:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).texParameterf(target, pname, param);
		else (cast this:Dynamic).texParameterf(target, pname, param);
	}
	public function texParameteri(target:Dynamic, pname:Dynamic, param:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).texParameteri(target, pname, param);
		else (cast this:Dynamic).texParameteri(target, pname, param);
	}
	public function uniform1f(location:Dynamic, x:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1f(location, x);
		else (cast this:Dynamic).uniform1f(location, x);
	}
	public function uniform1i(location:Dynamic, x:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform1i(location, x);
		else (cast this:Dynamic).uniform1i(location, x);
	}
	public function uniform2f(location:Dynamic, x:Dynamic, y:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2f(location, x, y);
		else (cast this:Dynamic).uniform2f(location, x, y);
	}
	public function uniform2i(location:Dynamic, x:Dynamic, y:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform2i(location, x, y);
		else (cast this:Dynamic).uniform2i(location, x, y);
	}
	public function uniform3f(location:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3f(location, x, y, z);
		else (cast this:Dynamic).uniform3f(location, x, y, z);
	}
	public function uniform3i(location:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform3i(location, x, y, z);
		else (cast this:Dynamic).uniform3i(location, x, y, z);
	}
	public function uniform4f(location:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic, w:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4f(location, x, y, z, w);
		else (cast this:Dynamic).uniform4f(location, x, y, z, w);
	}
	public function uniform4i(location:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic, w:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).uniform4i(location, x, y, z, w);
		else (cast this:Dynamic).uniform4i(location, x, y, z, w);
	}
	public function useProgram(program:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).useProgram(program);
		else (cast this:Dynamic).useProgram(program);
	}
	public function validateProgram(program:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).validateProgram(program);
		else (cast this:Dynamic).validateProgram(program);
	}
	public function vertexAttrib1f(indx:Dynamic, x:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttrib1f(indx, x);
		else (cast this:Dynamic).vertexAttrib1f(indx, x);
	}
	public function vertexAttrib2f(indx:Dynamic, x:Dynamic, y:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttrib2f(indx, x, y);
		else (cast this:Dynamic).vertexAttrib2f(indx, x, y);
	}
	public function vertexAttrib3f(indx:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttrib3f(indx, x, y, z);
		else (cast this:Dynamic).vertexAttrib3f(indx, x, y, z);
	}
	public function vertexAttrib4f(indx:Dynamic, x:Dynamic, y:Dynamic, z:Dynamic, w:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).vertexAttrib4f(indx, x, y, z, w);
		else (cast this:Dynamic).vertexAttrib4f(indx, x, y, z, w);
	}
	public function viewport(x:Dynamic, y:Dynamic, width:Dynamic, height:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).viewport(x, y, width, height);
		else (cast this:Dynamic).viewport(x, y, width, height);
	}

	// -- draws --
	public function finish():Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).finish();
		else (cast this:Dynamic).finish();
	}
	public function flush():Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).flush();
		else (cast this:Dynamic).flush();
	}
	public function generateMipmap(target:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).generateMipmap(target);
		else (cast this:Dynamic).generateMipmap(target);
	}
	public function framebufferRenderbuffer(target:Dynamic, attachment:Dynamic, renderbuffertarget:Dynamic, renderbuffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
		else (cast this:Dynamic).framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	}
	public function framebufferTexture2D(target:Dynamic, attachment:Dynamic, textarget:Dynamic, texture:Dynamic, level:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).framebufferTexture2D(target, attachment, textarget, texture, level);
		else (cast this:Dynamic).framebufferTexture2D(target, attachment, textarget, texture, level);
	}
	public function copyTexImage2D(target:Dynamic, level:Dynamic, internalformat:Dynamic, x:Dynamic, y:Dynamic, width:Dynamic, height:Dynamic, border:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).copyTexImage2D(target, level, internalformat, x, y, width, height, border);
		else (cast this:Dynamic).copyTexImage2D(target, level, internalformat, x, y, width, height, border);
	}
	public function copyTexSubImage2D(target:Dynamic, level:Dynamic, xoffset:Dynamic, yoffset:Dynamic, x:Dynamic, y:Dynamic, width:Dynamic, height:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).copyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
		else (cast this:Dynamic).copyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
	}

	// -- object lifecycle (allocation-time, still worth skipping __Field) --
	public function attachShader(program:Dynamic, shader:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).attachShader(program, shader);
		else (cast this:Dynamic).attachShader(program, shader);
	}
	public function bindAttribLocation(program:Dynamic, index:Dynamic, name:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).bindAttribLocation(program, index, name);
		else (cast this:Dynamic).bindAttribLocation(program, index, name);
	}
	public function compileShader(shader:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).compileShader(shader);
		else (cast this:Dynamic).compileShader(shader);
	}
	public function createBuffer():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createBuffer();
		return (cast this:Dynamic).createBuffer();
	}
	public function createFramebuffer():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createFramebuffer();
		return (cast this:Dynamic).createFramebuffer();
	}
	public function createProgram():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createProgram();
		return (cast this:Dynamic).createProgram();
	}
	public function createRenderbuffer():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createRenderbuffer();
		return (cast this:Dynamic).createRenderbuffer();
	}
	public function createShader(type:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createShader(type);
		return (cast this:Dynamic).createShader(type);
	}
	public function createTexture():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).createTexture();
		return (cast this:Dynamic).createTexture();
	}
	public function deleteBuffer(buffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteBuffer(buffer);
		else (cast this:Dynamic).deleteBuffer(buffer);
	}
	public function deleteFramebuffer(framebuffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteFramebuffer(framebuffer);
		else (cast this:Dynamic).deleteFramebuffer(framebuffer);
	}
	public function deleteProgram(program:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteProgram(program);
		else (cast this:Dynamic).deleteProgram(program);
	}
	public function deleteRenderbuffer(renderbuffer:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteRenderbuffer(renderbuffer);
		else (cast this:Dynamic).deleteRenderbuffer(renderbuffer);
	}
	public function deleteShader(shader:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteShader(shader);
		else (cast this:Dynamic).deleteShader(shader);
	}
	public function deleteTexture(texture:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).deleteTexture(texture);
		else (cast this:Dynamic).deleteTexture(texture);
	}
	public function detachShader(program:Dynamic, shader:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).detachShader(program, shader);
		else (cast this:Dynamic).detachShader(program, shader);
	}
	public function linkProgram(program:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).linkProgram(program);
		else (cast this:Dynamic).linkProgram(program);
	}
	public function shaderSource(shader:Dynamic, source:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).shaderSource(shader, source);
		else (cast this:Dynamic).shaderSource(shader, source);
	}

	// -- queries --
	public function checkFramebufferStatus(target:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).checkFramebufferStatus(target);
		return (cast this:Dynamic).checkFramebufferStatus(target);
	}
	public function getError():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getError();
		return (cast this:Dynamic).getError();
	}
	public function getActiveAttrib(program:Dynamic, index:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getActiveAttrib(program, index);
		return (cast this:Dynamic).getActiveAttrib(program, index);
	}
	public function getActiveUniform(program:Dynamic, index:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getActiveUniform(program, index);
		return (cast this:Dynamic).getActiveUniform(program, index);
	}
	public function getAttribLocation(program:Dynamic, name:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getAttribLocation(program, name);
		return (cast this:Dynamic).getAttribLocation(program, name);
	}
	public function getUniformLocation(program:Dynamic, name:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getUniformLocation(program, name);
		return (cast this:Dynamic).getUniformLocation(program, name);
	}
	public function getParameter(pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getParameter(pname);
		return (cast this:Dynamic).getParameter(pname);
	}
	public function getProgramParameter(program:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getProgramParameter(program, pname);
		return (cast this:Dynamic).getProgramParameter(program, pname);
	}
	public function getProgramInfoLog(program:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getProgramInfoLog(program);
		return (cast this:Dynamic).getProgramInfoLog(program);
	}
	public function getShaderParameter(shader:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getShaderParameter(shader, pname);
		return (cast this:Dynamic).getShaderParameter(shader, pname);
	}
	public function getShaderInfoLog(shader:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getShaderInfoLog(shader);
		return (cast this:Dynamic).getShaderInfoLog(shader);
	}
	public function getShaderSource(shader:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getShaderSource(shader);
		return (cast this:Dynamic).getShaderSource(shader);
	}
	public function getShaderPrecisionFormat(shadertype:Dynamic, precisiontype:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getShaderPrecisionFormat(shadertype, precisiontype);
		return (cast this:Dynamic).getShaderPrecisionFormat(shadertype, precisiontype);
	}
	public function getSupportedExtensions():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getSupportedExtensions();
		return (cast this:Dynamic).getSupportedExtensions();
	}
	public function getExtension(name:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getExtension(name);
		return (cast this:Dynamic).getExtension(name);
	}
	public function getFramebufferAttachmentParameter(target:Dynamic, attachment:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getFramebufferAttachmentParameter(target, attachment, pname);
		return (cast this:Dynamic).getFramebufferAttachmentParameter(target, attachment, pname);
	}
	public function getBufferParameter(target:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getBufferParameter(target, pname);
		return (cast this:Dynamic).getBufferParameter(target, pname);
	}
	public function getRenderbufferParameter(target:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getRenderbufferParameter(target, pname);
		return (cast this:Dynamic).getRenderbufferParameter(target, pname);
	}
	public function getTexParameter(target:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getTexParameter(target, pname);
		return (cast this:Dynamic).getTexParameter(target, pname);
	}
	public function getUniform(program:Dynamic, location:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getUniform(program, location);
		return (cast this:Dynamic).getUniform(program, location);
	}
	public function getVertexAttrib(index:Dynamic, pname:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).getVertexAttrib(index, pname);
		return (cast this:Dynamic).getVertexAttrib(index, pname);
	}
	public function hint(target:Dynamic, mode:Dynamic):Void
	{
		if (__isNative(this)) (cast this:NativeOpenGLRenderContext).hint(target, mode);
		else (cast this:Dynamic).hint(target, mode);
	}
	public function isBuffer(buffer:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isBuffer(buffer);
		return (cast this:Dynamic).isBuffer(buffer);
	}
	public function isContextLost():Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isContextLost();
		return (cast this:Dynamic).isContextLost();
	}
	public function isEnabled(cap:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isEnabled(cap);
		return (cast this:Dynamic).isEnabled(cap);
	}
	public function isFramebuffer(framebuffer:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isFramebuffer(framebuffer);
		return (cast this:Dynamic).isFramebuffer(framebuffer);
	}
	public function isProgram(program:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isProgram(program);
		return (cast this:Dynamic).isProgram(program);
	}
	public function isRenderbuffer(renderbuffer:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isRenderbuffer(renderbuffer);
		return (cast this:Dynamic).isRenderbuffer(renderbuffer);
	}
	public function isShader(shader:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isShader(shader);
		return (cast this:Dynamic).isShader(shader);
	}
	public function isTexture(texture:Dynamic):Dynamic
	{
		if (__isNative(this)) return (cast this:NativeOpenGLRenderContext).isTexture(texture);
		return (cast this:Dynamic).isTexture(texture);
	}
}
#else
@:forward()
@:transitive
abstract OpenGLRenderContext(Dynamic) from Dynamic to Dynamic
{
	@:from private static function fromRenderContext(context:RenderContext):OpenGLRenderContext
	{
		return null;
	}
}
#end
#end
