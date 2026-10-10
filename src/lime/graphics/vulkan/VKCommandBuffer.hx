package lime.graphics.vulkan;

import haxe.Int64;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A Vulkan command buffer allocated from a `VKCommandPool`.
**/
class VKCommandBuffer
{
	public var device(get, never):VKDevice;
	public var handle(default, null):Int64;
	public var level(default, null):Int;
	public var pool(default, null):VKCommandPool;

	@:allow(lime.graphics.vulkan.VKCommandPool)
	private function new(pool:VKCommandPool, handle:Int64, level:Int)
	{
		this.pool = pool;
		this.handle = handle;
		this.level = level;
	}

	public function begin(flags:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && pool != null && pool.device != null && pool.device.isValid())
		{
			return NativeCFFI.lime_vk_begin_command_buffer(pool.device.instance.context.__windowHandle, pool.device.instance.handle.high,
				pool.device.instance.handle.low, pool.device.handle.high, pool.device.handle.low, handle.high, handle.low, flags);
		}
		#end

		return false;
	}

	public function dispose():Void
	{
		if (pool != null)
		{
			pool.free(this);
		}
	}

	public function beginRenderPass(renderPass:VKRenderPass, framebuffer:VKFramebuffer, width:Int, height:Int, clearRed:Float = 0, clearGreen:Float = 0,
			clearBlue:Float = 0, clearAlpha:Float = 1, clearDepth:Float = 1, clearStencil:Int = 0, x:Int = 0, y:Int = 0):Bool
	{
		var clearValueCount = renderPass != null && renderPass.depthStencilFormat != VK.FORMAT_UNDEFINED ? 2 : 1;
		var state = [x, y, width, height, clearStencil, clearValueCount];
		var clear = [clearRed, clearGreen, clearBlue, clearAlpha, clearDepth];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && renderPass != null && renderPass.isValid() && framebuffer != null && framebuffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_begin_render_pass(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, renderPass.handle.high, renderPass.handle.low, framebuffer.handle.high,
				framebuffer.handle.low, state, clear);
		}
		#end

		return false;
	}

	public function bindDescriptorSet(layout:VKPipelineLayout, descriptorSet:VKDescriptorSet, firstSet:Int = 0,
			bindPoint:Int = VK.PIPELINE_BIND_POINT_GRAPHICS, dynamicOffsets:Array<Int> = null):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && layout != null && layout.isValid() && descriptorSet != null && descriptorSet.isValid())
		{
			if (dynamicOffsets != null && dynamicOffsets.length > 0)
			{
				var state = [bindPoint, firstSet, dynamicOffsets.length];
				for (offset in dynamicOffsets)
				{
					state.push(offset);
				}
				return NativeCFFI.lime_vk_cmd_bind_descriptor_set_ex(device.instance.context.__windowHandle, device.instance.handle.high,
					device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, layout.handle.high, layout.handle.low,
					descriptorSet.handle.high, descriptorSet.handle.low, state);
			}

			return NativeCFFI.lime_vk_cmd_bind_descriptor_set(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, layout.handle.high, layout.handle.low, descriptorSet.handle.high,
				descriptorSet.handle.low, bindPoint, firstSet);
		}
		#end

		return false;
	}

	public function bindDescriptorSetDynamicOffset(layout:VKPipelineLayout, descriptorSet:VKDescriptorSet, dynamicOffset:Int, firstSet:Int = 0,
			bindPoint:Int = VK.PIPELINE_BIND_POINT_GRAPHICS):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && layout != null && layout.isValid() && descriptorSet != null && descriptorSet.isValid())
		{
			return NativeCFFI.lime_vk_cmd_bind_descriptor_set_dynamic_offset(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, layout.handle.high, layout.handle.low,
				descriptorSet.handle.high, descriptorSet.handle.low, dynamicOffset, firstSet, bindPoint);
		}
		#end

		return false;
	}

	public function bindIndexBuffer(buffer:VKBuffer, offset:Int64 = null, indexType:Int = VK.INDEX_TYPE_UINT16):Bool
	{
		if (offset == null)
		{
			offset = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_bind_index_buffer(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, offset.high, offset.low, indexType);
		}
		#end

		return false;
	}

	public function bindPipeline(pipeline:VKPipeline, bindPoint:Int = VK.PIPELINE_BIND_POINT_GRAPHICS):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pipeline != null && pipeline.isValid())
		{
			return NativeCFFI.lime_vk_cmd_bind_pipeline(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, pipeline.handle.high, pipeline.handle.low, bindPoint);
		}
		#end

		return false;
	}

	public function bindVertexBuffer(buffer:VKBuffer, binding:Int = 0, offset:Int64 = null):Bool
	{
		if (offset == null)
		{
			offset = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_bind_vertex_buffer(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, binding, offset.high, offset.low);
		}
		#end

		return false;
	}

	public function blitImage(source:VKImage, destination:VKImage, width:Int, height:Int, sourceLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
			destinationLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, filter:Int = VK.FILTER_LINEAR):Bool
	{
		return blitImageRegion(source, destination, width, height, sourceLayout, destinationLayout, filter);
	}

	public function blitImageRegion(source:VKImage, destination:VKImage, sourceWidth:Int, sourceHeight:Int,
			sourceLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, destinationLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
			filter:Int = VK.FILTER_LINEAR, destinationWidth:Int = -1, destinationHeight:Int = -1, sourceX:Int = 0, sourceY:Int = 0, sourceZ:Int = 0,
			destinationX:Int = 0, destinationY:Int = 0, destinationZ:Int = 0, sourceDepth:Int = 1, destinationDepth:Int = 1, sourceMipLevel:Int = 0,
			destinationMipLevel:Int = 0, sourceBaseArrayLayer:Int = 0, destinationBaseArrayLayer:Int = 0, layerCount:Int = 1,
			aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		if (destinationWidth < 0) destinationWidth = sourceWidth;
		if (destinationHeight < 0) destinationHeight = sourceHeight;
		var state = [
			sourceX,
			sourceY,
			sourceZ,
			sourceX + sourceWidth,
			sourceY + sourceHeight,
			sourceZ + sourceDepth,
			destinationX,
			destinationY,
			destinationZ,
			destinationX + destinationWidth,
			destinationY + destinationHeight,
			destinationZ + destinationDepth,
			sourceLayout,
			destinationLayout,
			filter,
			sourceMipLevel,
			destinationMipLevel,
			sourceBaseArrayLayer,
			destinationBaseArrayLayer,
			layerCount,
			aspectMask
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null && destination.isValid())
		{
			return NativeCFFI.lime_vk_cmd_blit_image(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high, source.handle.low, destination.handle.high,
				destination.handle.low, state);
		}
		#end

		return false;
	}

	public function clearColorImage(image:VKImage, layout:Int, red:Float, green:Float, blue:Float, alpha:Float, aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid())
		{
			return NativeCFFI.lime_vk_cmd_clear_color_image(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low, layout, aspectMask,
				[red, green, blue, alpha]);
		}
		#end

		return false;
	}

	public function clearDepthStencilImage(image:VKImage, layout:Int, depth:Float = 1, stencil:Int = 0,
			aspectMask:Int = VK.IMAGE_ASPECT_DEPTH_BIT | VK.IMAGE_ASPECT_STENCIL_BIT, baseMipLevel:Int = 0, levelCount:Int = 1, baseArrayLayer:Int = 0,
			layerCount:Int = 1):Bool
	{
		var state = [
			layout,
			stencil,
			aspectMask,
			baseMipLevel,
			levelCount,
			baseArrayLayer,
			layerCount
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid())
		{
			return NativeCFFI.lime_vk_cmd_clear_depth_stencil_image(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low, state,
				[depth]);
		}
		#end

		return false;
	}

	public function clearAttachments(color:Bool, depth:Bool, stencil:Bool, x:Int, y:Int, width:Int, height:Int, red:Float = 0, green:Float = 0,
			blue:Float = 0, alpha:Float = 0, depthValue:Float = 1, stencilValue:Int = 0):Bool
	{
		var state = [color ? 1 : 0, depth ? 1 : 0, stencil ? 1 : 0, x, y, width, height, stencilValue];
		var clear = [red, green, blue, alpha, depthValue];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_clear_attachments(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, state, clear);
		}
		#end

		return false;
	}

	public function copyBuffer(source:VKBuffer, destination:VKBuffer, size:Int64, sourceOffset:Int64 = null, destinationOffset:Int64 = null):Bool
	{
		if (sourceOffset == null) sourceOffset = Int64.ofInt(0);
		if (destinationOffset == null) destinationOffset = Int64.ofInt(0);
		var state = [
			size.high,
			size.low,
			sourceOffset.high,
			sourceOffset.low,
			destinationOffset.high,
			destinationOffset.low
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null && destination.isValid())
		{
			return NativeCFFI.lime_vk_cmd_copy_buffer(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high, source.handle.low, destination.handle.high,
				destination.handle.low, state);
		}
		#end

		return false;
	}

	public function copyBufferToImage(buffer:VKBuffer, image:VKImage, width:Int, height:Int, layout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL):Bool
	{
		return copyBufferToImageRegion(buffer, image, width, height, layout);
	}

	public function copyBufferToImageRegion(buffer:VKBuffer, image:VKImage, width:Int, height:Int, layout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
			depth:Int = 1, bufferOffset:Int64 = null, bufferRowLength:Int = 0, bufferImageHeight:Int = 0, imageX:Int = 0, imageY:Int = 0, imageZ:Int = 0,
			mipLevel:Int = 0, baseArrayLayer:Int = 0, layerCount:Int = 1, aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		if (bufferOffset == null) bufferOffset = Int64.ofInt(0);
		var state = [
			width,
			height,
			depth,
			layout,
			bufferOffset.high,
			bufferOffset.low,
			bufferRowLength,
			bufferImageHeight,
			imageX,
			imageY,
			imageZ,
			mipLevel,
			baseArrayLayer,
			layerCount,
			aspectMask
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid()
			&& device != null
			&& device.isValid()
			&& buffer != null
			&& buffer.isValid()
			&& image != null
			&& image.isValid())
		{
			return NativeCFFI.lime_vk_cmd_copy_buffer_to_image_region(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low,
				image.handle.high, image.handle.low, state);
		}
		#end

		return false;
	}

	public function copyImageToBufferRegion(image:VKImage, buffer:VKBuffer, width:Int, height:Int, layout:Int = VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
			depth:Int = 1, bufferOffset:Int64 = null, bufferRowLength:Int = 0, bufferImageHeight:Int = 0, imageX:Int = 0, imageY:Int = 0, imageZ:Int = 0,
			mipLevel:Int = 0, baseArrayLayer:Int = 0, layerCount:Int = 1, aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		if (bufferOffset == null) bufferOffset = Int64.ofInt(0);
		var state = [
			width,
			height,
			depth,
			layout,
			bufferOffset.high,
			bufferOffset.low,
			bufferRowLength,
			bufferImageHeight,
			imageX,
			imageY,
			imageZ,
			mipLevel,
			baseArrayLayer,
			layerCount,
			aspectMask
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid()
			&& device != null
			&& device.isValid()
			&& image != null
			&& image.isValid()
			&& buffer != null
			&& buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_copy_image_to_buffer_region(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low,
				buffer.handle.high, buffer.handle.low, state);
		}
		#end

		return false;
	}

	public function draw(vertexCount:Int, instanceCount:Int = 1, firstVertex:Int = 0, firstInstance:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_draw(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, vertexCount, instanceCount, firstVertex, firstInstance);
		}
		#end

		return false;
	}

	public function drawIndexed(indexCount:Int, instanceCount:Int = 1, firstIndex:Int = 0, vertexOffset:Int = 0, firstInstance:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_draw_indexed(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance);
		}
		#end

		return false;
	}

	public function drawIndirect(buffer:VKBuffer, offset:Int64, drawCount:Int, stride:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_draw_indirect(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, offset.high, offset.low, drawCount,
				stride);
		}
		#end

		return false;
	}

	public function drawIndexedIndirect(buffer:VKBuffer, offset:Int64, drawCount:Int, stride:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_draw_indexed_indirect(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low,
				offset.high, offset.low, drawCount, stride);
		}
		#end

		return false;
	}

	/**
		Issues `drawCount` non-indexed draws, reading the actual draw count from
		`countBuffer` (Vulkan 1.2 `vkCmdDrawIndirectCount`).

		This is the GPU-driven batching primitive: the shader writes the surviving
		count into `countBuffer`, so the CPU never has to read it back. On a 2D
		renderer it removes the per-frame round trip that a plain `drawIndirect`
		with a CPU-side count would need.
	**/
	public function drawIndirectCount(buffer:VKBuffer, offset:Int64, countBuffer:VKBuffer, countBufferOffset:Int64, maxDrawCount:Int, stride:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid() && countBuffer != null && countBuffer.isValid())
		{
			var state = [
				buffer.handle.high, buffer.handle.low, offset.high, offset.low, countBuffer.handle.high, countBuffer.handle.low,
				countBufferOffset.high, countBufferOffset.low, maxDrawCount, stride
			];

			return NativeCFFI.lime_vk_cmd_draw_indirect_count(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, state);
		}
		#end

		return false;
	}

	/**
		Indexed equivalent of `drawIndirectCount` (Vulkan 1.2
		`vkCmdDrawIndexedIndirectCount`).
	**/
	public function drawIndexedIndirectCount(buffer:VKBuffer, offset:Int64, countBuffer:VKBuffer, countBufferOffset:Int64, maxDrawCount:Int,
			stride:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid() && countBuffer != null && countBuffer.isValid())
		{
			var state = [
				buffer.handle.high, buffer.handle.low, offset.high, offset.low, countBuffer.handle.high, countBuffer.handle.low,
				countBufferOffset.high, countBufferOffset.low, maxDrawCount, stride
			];

			return NativeCFFI.lime_vk_cmd_draw_indexed_indirect_count(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, state);
		}
		#end

		return false;
	}

	public function dispatch(x:Int, y:Int, z:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_dispatch(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, x, y, z);
		}
		#end

		return false;
	}

	public function dispatchIndirect(buffer:VKBuffer, offset:Int64):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_dispatch_indirect(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, offset.high, offset.low);
		}
		#end

		return false;
	}

	public function executeCommands(commandBuffers:Array<VKCommandBuffer>):Bool
	{
		if (commandBuffers == null || commandBuffers.length == 0)
		{
			return false;
		}

		var state = [];
		for (buffer in commandBuffers)
		{
			if (buffer == null || !buffer.isValid())
			{
				return false;
			}
			state.push(buffer.handle.high);
			state.push(buffer.handle.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_execute_commands(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, state);
		}
		#end

		return false;
	}

	public function nextSubpass(contents:Int = VK.SUBPASS_CONTENTS_INLINE):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_next_subpass(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, contents);
		}
		#end

		return false;
	}

	public function resetEvent(event:VKEvent, stageMask:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && event != null && event.isValid())
		{
			return NativeCFFI.lime_vk_cmd_reset_event(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, event.handle.high, event.handle.low, stageMask);
		}
		#end

		return false;
	}

	public function setBlendConstants(red:Float, green:Float, blue:Float, alpha:Float):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_blend_constants(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, red, green, blue, alpha);
		}
		#end

		return false;
	}

	public function setDepthBias(constantFactor:Float, slopeFactor:Float, clamp:Float):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_bias(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, constantFactor, slopeFactor, clamp);
		}
		#end

		return false;
	}

	public function setDepthBounds(minBounds:Float, maxBounds:Float):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_bounds(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, minBounds, maxBounds);
		}
		#end

		return false;
	}

	public function setEvent(event:VKEvent, stageMask:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && event != null && event.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_event(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, event.handle.high, event.handle.low, stageMask);
		}
		#end

		return false;
	}

	public function setLineWidth(width:Float):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_line_width(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, width);
		}
		#end

		return false;
	}

	public function setStencilCompareMask(faceMask:Int, compareMask:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_stencil_compare_mask(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, faceMask, compareMask);
		}
		#end

		return false;
	}

	public function setStencilReference(faceMask:Int, reference:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_stencil_reference(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, faceMask, reference);
		}
		#end

		return false;
	}

	public function setStencilWriteMask(faceMask:Int, writeMask:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_stencil_write_mask(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, faceMask, writeMask);
		}
		#end

		return false;
	}

	public function waitEvents(events:Array<VKEvent>, srcStageMask:Int, dstStageMask:Int):Bool
	{
		if (events == null || events.length == 0)
		{
			return false;
		}

		var state = [];
		for (event in events)
		{
			if (event == null || !event.isValid())
			{
				return false;
			}
			state.push(event.handle.high);
			state.push(event.handle.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_wait_events(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, srcStageMask, dstStageMask, state);
		}
		#end

		return false;
	}

	public function end():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && pool != null && pool.device != null && pool.device.isValid())
		{
			return NativeCFFI.lime_vk_end_command_buffer(pool.device.instance.context.__windowHandle, pool.device.instance.handle.high,
				pool.device.instance.handle.low, pool.device.handle.high, pool.device.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}

	public function endRenderPass():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_end_render_pass(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}

	/**
		Vulkan 1.2 form of `beginRenderPass`.

		Adds `contents`, which selects inline recording (the default) or execution
		of secondary command buffers. Everything else matches the 1.0 call.
	**/
	public function beginRenderPass2(renderPass:VKRenderPass, framebuffer:VKFramebuffer, width:Int, height:Int, clearRed:Float = 0, clearGreen:Float = 0,
			clearBlue:Float = 0, clearAlpha:Float = 1, clearDepth:Float = 1, clearStencil:Int = 0, x:Int = 0, y:Int = 0,
			contents:Int = VK.SUBPASS_CONTENTS_INLINE):Bool
	{
		var clearValueCount = renderPass != null && renderPass.depthStencilFormat != VK.FORMAT_UNDEFINED ? 2 : 1;
		var state = [x, y, width, height, clearStencil, clearValueCount, contents];
		var clear = [clearRed, clearGreen, clearBlue, clearAlpha, clearDepth];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && renderPass != null && renderPass.isValid() && framebuffer != null && framebuffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_begin_render_pass2(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, renderPass.handle.high, renderPass.handle.low, framebuffer.handle.high,
				framebuffer.handle.low, state, clear);
		}
		#end

		return false;
	}

	/**
		Vulkan 1.2 form of `nextSubpass`.
	**/
	public function nextSubpass2(contents:Int = VK.SUBPASS_CONTENTS_INLINE):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_next_subpass2(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, contents);
		}
		#end

		return false;
	}

	/**
		Vulkan 1.2 form of `endRenderPass`.
	**/
	public function endRenderPass2():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_end_render_pass2(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}

	/**
		Sets the device mask for subsequent commands (Vulkan 1.1 device groups).
	**/
	public function setDeviceMask(deviceMask:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_device_mask(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, deviceMask);
		}
		#end

		return false;
	}

	/**
		Dispatch with a base workgroup offset (Vulkan 1.1 device groups).

		With a single device `baseGroup*` is always zero and this is equivalent to
		`dispatch()`.
	**/
	public function dispatchBase(groupCountX:Int, groupCountY:Int, groupCountZ:Int, baseGroupX:Int = 0, baseGroupY:Int = 0, baseGroupZ:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_dispatch_base(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, groupCountX, groupCountY, groupCountZ, baseGroupX, baseGroupY, baseGroupZ);
		}
		#end

		return false;
	}

	public inline function get():Int64
	{
		return handle;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}

	public function reset(flags:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && pool != null && pool.device != null && pool.device.isValid())
		{
			return NativeCFFI.lime_vk_reset_command_buffer(pool.device.instance.context.__windowHandle, pool.device.instance.handle.high,
				pool.device.instance.handle.low, pool.device.handle.high, pool.device.handle.low, handle.high, handle.low, flags);
		}
		#end

		return false;
	}

	public function pipelineBarrierImage(image:VKImage, oldLayout:Int, newLayout:Int, srcStageMask:Int, dstStageMask:Int, srcAccessMask:Int,
			dstAccessMask:Int, aspectMask:Int, baseMipLevel:Int = 0, levelCount:Int = 1, baseArrayLayer:Int = 0, layerCount:Int = 1):Bool
	{
		var state = [
			oldLayout,
			newLayout,
			srcStageMask,
			dstStageMask,
			srcAccessMask,
			dstAccessMask,
			aspectMask,
			baseMipLevel,
			levelCount,
			baseArrayLayer,
			layerCount
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid())
		{
			return NativeCFFI.lime_vk_cmd_pipeline_barrier_image(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low, state);
		}
		#end

		return false;
	}

	/**
		Starts a dynamic rendering pass (Vulkan 1.3, needs `dynamicRendering`
		requested at device creation).

		`view` must be a **VkImageView** (`image.createView(...)`), not the image
		itself — `VkRenderingAttachmentInfo::imageView` rejects a raw image handle
		and most drivers crash instead of returning an error.
	**/
	public function beginRendering(view:VKImageView, x:Int, y:Int, width:Int, height:Int, loadOp:Int = VK.ATTACHMENT_LOAD_OP_CLEAR,
			storeOp:Int = VK.ATTACHMENT_STORE_OP_STORE, clearRed:Float = 0, clearGreen:Float = 0, clearBlue:Float = 0, clearAlpha:Float = 1,
			layerCount:Int = 1, imageLayout:Int = VK.IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL):Bool
	{
		var state = [x, y, width, height, layerCount, loadOp, storeOp, imageLayout];
		var clear = [clearRed, clearGreen, clearBlue, clearAlpha];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && view != null && view.isValid())
		{
			return NativeCFFI.lime_vk_cmd_begin_rendering(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, view.handle.high, view.handle.low, state,
				clear);
		}
		#end

		return false;
	}

	public function endRendering():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_end_rendering(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}

	public function pipelineBarrier2(srcStageMask:Int, srcAccessMask:Int, dstStageMask:Int, dstAccessMask:Int):Bool
	{
		var state = [srcStageMask, srcAccessMask, dstStageMask, dstAccessMask];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_pipeline_barrier2(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, state);
		}
		#end

		return false;
	}

	public function pipelineBarrierImage2(image:VKImage, oldLayout:Int, newLayout:Int, srcStageMask:Int, dstStageMask:Int, srcAccessMask:Int,
			dstAccessMask:Int, aspectMask:Int, baseMipLevel:Int = 0, levelCount:Int = 1, baseArrayLayer:Int = 0, layerCount:Int = 1):Bool
	{
		var state = [
			oldLayout,
			newLayout,
			srcStageMask,
			dstStageMask,
			srcAccessMask,
			dstAccessMask,
			aspectMask,
			baseMipLevel,
			levelCount,
			baseArrayLayer,
			layerCount
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid())
		{
			return NativeCFFI.lime_vk_cmd_pipeline_barrier_image2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high, image.handle.low, state);
		}
		#end

		return false;
	}

	public function copyQueryPoolResults(pool:VKQueryPool, buffer:VKBuffer, firstQuery:Int = 0, queryCount:Int = -1, dstOffset:Int64 = null,
			stride:Int64 = null, flags:Int = 0):Bool
	{
		if (queryCount < 0 && pool != null) queryCount = pool.queryCount;
		if (dstOffset == null) dstOffset = Int64.ofInt(0);
		if (stride == null) stride = Int64.ofInt(0);
		var state = [firstQuery, queryCount, dstOffset.high, dstOffset.low, stride.high, stride.low, flags];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_copy_query_pool_results(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, pool.handle.high, pool.handle.low,
				buffer.handle.high, buffer.handle.low, state);
		}
		#end

		return false;
	}

	public function pushConstants(layout:VKPipelineLayout, stageFlags:Int, bytes:haxe.io.Bytes, offset:Int = 0, byteOffset:Int = 0, byteLength:Int = -1):Bool
	{
		if (bytes == null || layout == null)
		{
			return false;
		}
		if (byteLength < 0)
		{
			byteLength = bytes.length - byteOffset;
		}
		var state = [stageFlags, offset, byteOffset, byteLength];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && layout.isValid())
		{
			return NativeCFFI.lime_vk_cmd_push_constants(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, layout.handle.high, layout.handle.low, state, bytes);
		}
		#end

		return false;
	}

	public function setScissor(x:Int, y:Int, width:Int, height:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_scissor(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, x, y, width, height);
		}
		#end

		return false;
	}

	public function setViewport(x:Float, y:Float, width:Float, height:Float, minDepth:Float = 0, maxDepth:Float = 1):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_viewport(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, x, y, width, height, minDepth, maxDepth);
		}
		#end

		return false;
	}

	// ------------------------------------------------------------------
	// Vulkan 1.3 extended dynamic state (promoted from
	// VK_EXT_extended_dynamic_state). These have no feature bit - they only
	// need a 1.3 device, so they return false (rather than failing) when the
	// PFN is unavailable on older hardware.
	// ------------------------------------------------------------------

	public function setCullMode(cullMode:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_cull_mode(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, cullMode);
		}
		#end

		return false;
	}

	public function setFrontFace(frontFace:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_front_face(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, frontFace);
		}
		#end

		return false;
	}

	public function setPrimitiveTopology(primitiveTopology:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_primitive_topology(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, primitiveTopology);
		}
		#end

		return false;
	}

	public function setDepthTestEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_test_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	public function setDepthWriteEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_write_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	public function setDepthCompareOp(depthCompareOp:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_compare_op(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, depthCompareOp);
		}
		#end

		return false;
	}

	public function setDepthBoundsTestEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_bounds_test_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	public function setStencilTestEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_stencil_test_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	/**
		Sets the stencil ops for the faces selected by `faceMask`.

		`faceMask` is `VK.STENCIL_FACE_FRONT_BIT` / `_BACK_BIT`; the remaining
		arguments are `VkStencilOp` / `VkCompareOp` values.
	**/
	public function setStencilOp(faceMask:Int, failOp:Int, passOp:Int, depthFailOp:Int, compareOp:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_stencil_op(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, faceMask, failOp, passOp, depthFailOp,
				compareOp);
		}
		#end

		return false;
	}

	public function setRasterizerDiscardEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_rasterizer_discard_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	public function setDepthBiasEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_depth_bias_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	public function setPrimitiveRestartEnable(enable:Bool):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid())
		{
			return NativeCFFI.lime_vk_cmd_set_primitive_restart_enable(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, enable ? 1 : 0);
		}
		#end

		return false;
	}

	/**
		Sets many viewports in one call (Vulkan 1.3).

		`viewports` is a flat list of 6 floats per viewport — `x, y, width,
		height, minDepth, maxDepth`, in order. Up to 16 viewports are consumed.
	**/
	public function setViewportWithCount(viewports:Array<Float>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && viewports != null && viewports.length >= 6)
		{
			return NativeCFFI.lime_vk_cmd_set_viewport_with_count(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, viewports);
		}
		#end

		return false;
	}

	/**
		Sets many scissor rectangles in one call (Vulkan 1.3).

		`scissors` is a flat list of 4 ints per rectangle — `offsetX, offsetY,
		width, height`, in order. Up to 16 rectangles are consumed.
	**/
	public function setScissorWithCount(scissors:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && scissors != null && scissors.length >= 4)
		{
			return NativeCFFI.lime_vk_cmd_set_scissor_with_count(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, scissors);
		}
		#end

		return false;
	}

	public function copyImage(source:VKImage, destination:VKImage, width:Int, height:Int, sourceLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
			destinationLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, sourceX:Int = 0, sourceY:Int = 0, sourceZ:Int = 0, destinationX:Int = 0,
			destinationY:Int = 0, destinationZ:Int = 0, sourceMipLevel:Int = 0, destinationMipLevel:Int = 0, layerCount:Int = 1, sourceDepth:Int = 1,
			aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		var state = [
			sourceX,
			sourceY,
			sourceZ,
			width,
			height,
			sourceDepth,
			sourceMipLevel,
			layerCount,
			destinationX,
			destinationY,
			destinationZ,
			destinationMipLevel,
			layerCount,
			sourceLayout,
			destinationLayout,
			aspectMask
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null && destination.isValid())
		{
			return NativeCFFI.lime_vk_cmd_copy_image(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high, source.handle.low, destination.handle.high,
				destination.handle.low, state);
		}
		#end

		return false;
	}

	public function resolveImage(source:VKImage, destination:VKImage, width:Int, height:Int, sourceLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
			destinationLayout:Int = VK.IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, sourceX:Int = 0, sourceY:Int = 0, sourceZ:Int = 0, destinationX:Int = 0,
			destinationY:Int = 0, destinationZ:Int = 0, layerCount:Int = 1, sourceDragMipLevel:Int = 0, destinationDragMipLevel:Int = 0,
			aspectMask:Int = VK.IMAGE_ASPECT_COLOR_BIT):Bool
	{
		var state = [
			sourceX,
			sourceY,
			sourceZ,
			width,
			height,
			1,
			sourceDragMipLevel,
			layerCount,
			destinationX,
			destinationY,
			destinationZ,
			destinationDragMipLevel,
			layerCount,
			sourceLayout,
			destinationLayout,
			aspectMask
		];

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null && destination.isValid())
		{
			return NativeCFFI.lime_vk_cmd_resolve_image(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high, source.handle.low, destination.handle.high,
				destination.handle.low, state);
		}
		#end

		return false;
	}

	public function fillBuffer(buffer:VKBuffer, offset:Int64, size:Int64, value:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid())
		{
			return NativeCFFI.lime_vk_cmd_fill_buffer(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, offset.high, offset.low,
				size.high, size.low, value);
		}
		#end

		return false;
	}

	public function updateBuffer(buffer:VKBuffer, bytes:haxe.io.Bytes, offset:Int64 = null):Bool
	{
		if (offset == null)
		{
			offset = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid() && bytes != null)
		{
			return NativeCFFI.lime_vk_cmd_update_buffer(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low, offset.high, offset.low, bytes);
		}
		#end

		return false;
	}

	public function beginQuery(pool:VKQueryPool, queryIndex:Int, flags:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid())
		{
			return NativeCFFI.lime_vk_cmd_begin_query(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, pool.handle.high, pool.handle.low, queryIndex, flags);
		}
		#end

		return false;
	}

	public function endQuery(pool:VKQueryPool, queryIndex:Int):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid())
		{
			return NativeCFFI.lime_vk_cmd_end_query(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, pool.handle.high, pool.handle.low, queryIndex);
		}
		#end

		return false;
	}

	public function resetQueryPool(pool:VKQueryPool, firstQuery:Int = 0, queryCount:Int = -1):Bool
	{
		if (queryCount < 0 && pool != null)
		{
			queryCount = pool.queryCount;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid())
		{
			return NativeCFFI.lime_vk_cmd_reset_query_pool(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, pool.handle.high, pool.handle.low, firstQuery, queryCount);
		}
		#end

		return false;
	}

	public function writeTimestamp(pool:VKQueryPool, queryIndex:Int, pipelineStage:Int = VK.PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid())
		{
			return NativeCFFI.lime_vk_cmd_write_timestamp(device.instance.context.__windowHandle, device.instance.handle.high, device.instance.handle.low,
				device.handle.high, device.handle.low, handle.high, handle.low, pipelineStage, pool.handle.high, pool.handle.low, queryIndex);
		}
		#end

		return false;
	}

	/**
		Binds several vertex buffers in one call, supplying an explicit size per
		binding (Vulkan 1.3).

		`bindings` is a flat int list - **8 entries per binding**, in this order:

		| slot | meaning |
		| --- | --- |
		| 0, 1 | buffer handle `high`, `low` |
		| 2, 3 | offset `high`, `low` (64-bit `VkDeviceSize`) |
		| 4, 5 | size `high`, `low` - the byte range actually used |
		| 6, 7 | stride `high`, `low` |

		A `size` of `VK_WHOLE_SIZE` (i.e. `high == -1 && low == -1`) binds from
		`offset` to the end of the buffer; any other value must satisfy
		`offset + size <= bufferSize`. `firstBinding + bindingCount` must stay
		within `maxVertexInputBindings`.
	**/
	public function bindVertexBuffers2(firstBinding:Int, bindings:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && bindings != null && bindings.length >= 8)
		{
			return NativeCFFI.lime_vk_cmd_bind_vertex_buffers_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, firstBinding, bindings);
		}
		#end

		return false;
	}

	/**
		Copies buffer regions using the Vulkan 1.3 `*2` family (no feature bit).

		`regions` is a flat int list - **6 entries per region**, in this order:

		| slot | meaning |
		| --- | --- |
		| 0, 1 | `srcOffset` `high`, `low` |
		| 2, 3 | `dstOffset` `high`, `low` |
		| 4, 5 | `size` `high`, `low` |
	**/
	public function copyBuffer2(source:VKBuffer, destination:VKBuffer, regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null
			&& destination.isValid() && regions != null && regions.length >= 6)
		{
			return NativeCFFI.lime_vk_cmd_copy_buffer_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high,
				source.handle.low, destination.handle.high, destination.handle.low, regions);
		}
		#end

		return false;
	}

	/**
		Copies image regions using the 1.3 `*2` family (no feature bit).

		`regions` is a flat int list - **17 entries per region**:
		`srcAspect, srcMip, srcBaseLayer, srcLayerCount, srcX, srcY, srcZ,
		dstAspect, dstMip, dstBaseLayer, dstLayerCount, dstX, dstY, dstZ,
		width, height, depth`
	**/
	public function copyImage2(source:VKImage, destination:VKImage, sourceLayout:Int, destinationLayout:Int, regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null
			&& destination.isValid() && regions != null && regions.length >= 17)
		{
			return NativeCFFI.lime_vk_cmd_copy_image_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high,
				source.handle.low, sourceLayout, destination.handle.high, destination.handle.low, destinationLayout, regions);
		}
		#end

		return false;
	}

	/**
		Copies buffer regions into an image using the 1.3 `*2` family.

		`regions` is a flat int list - **14 entries per region**:
		`bufferOffsetHigh, bufferOffsetLow, bufferRowLength, bufferImageHeight,
		aspect, mipLevel, baseArrayLayer, layerCount, imageX, imageY, imageZ,
		width, height, depth`
	**/
	public function copyBufferToImage2(buffer:VKBuffer, image:VKImage, destinationLayout:Int, regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && buffer != null && buffer.isValid() && image != null
			&& image.isValid() && regions != null && regions.length >= 14)
		{
			return NativeCFFI.lime_vk_cmd_copy_buffer_to_image_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, buffer.handle.high,
				buffer.handle.low, image.handle.high, image.handle.low, destinationLayout, regions);
		}
		#end

		return false;
	}

	/**
		Copies image regions into a buffer using the 1.3 `*2` family.

		Region layout is identical to `copyBufferToImage2` (14 ints per region).
	**/
	public function copyImageToBuffer2(image:VKImage, buffer:VKBuffer, sourceLayout:Int, regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && image != null && image.isValid() && buffer != null
			&& buffer.isValid() && regions != null && regions.length >= 14)
		{
			return NativeCFFI.lime_vk_cmd_copy_image_to_buffer_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, image.handle.high,
				image.handle.low, sourceLayout, buffer.handle.high, buffer.handle.low, regions);
		}
		#end

		return false;
	}

	/**
		Blits image regions using the 1.3 `*2` family (no feature bit).

		`regions` is a flat int list - **20 entries per region**:
		`srcAspect, srcMip, srcBaseLayer, srcLayerCount, srcOff0{x,y,z}, srcOff1{x,y,z},
		dstAspect, dstMip, dstBaseLayer, dstLayerCount, dstOff0{x,y,z}, dstOff1{x,y,z}`
	**/
	public function blitImage2(source:VKImage, destination:VKImage, sourceLayout:Int, destinationLayout:Int, filter:Int,
			regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null
			&& destination.isValid() && regions != null && regions.length >= 20)
		{
			return NativeCFFI.lime_vk_cmd_blit_image_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high,
				source.handle.low, sourceLayout, destination.handle.high, destination.handle.low, destinationLayout, filter, regions);
		}
		#end

		return false;
	}

	/**
		Resolves image regions using the 1.3 `*2` family (no feature bit).

		Region layout is identical to `copyImage2` (17 ints per region).
	**/
	public function resolveImage2(source:VKImage, destination:VKImage, sourceLayout:Int, destinationLayout:Int,
			regions:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && source != null && source.isValid() && destination != null
			&& destination.isValid() && regions != null && regions.length >= 17)
		{
			return NativeCFFI.lime_vk_cmd_resolve_image_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, source.handle.high,
				source.handle.low, sourceLayout, destination.handle.high, destination.handle.low, destinationLayout, regions);
		}
		#end

		return false;
	}

	/**
		Writes a timestamp with the 1.3 stage flags (needs `synchronization2`).

		Only the low 32 bits of `stage` reach the driver - the same limitation as
		the existing `pipelineBarrier2` path, because the FFI carries it as two
		Ints rather than a native 64-bit value.
	**/
	public function writeTimestamp2(stage:Int64, pool:VKQueryPool, queryIndex:Int = 0):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && pool != null && pool.isValid())
		{
			return NativeCFFI.lime_vk_cmd_write_timestamp_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, stage.high, stage.low,
				pool.handle.high, pool.handle.low, queryIndex);
		}
		#end

		return false;
	}

	/**
		Sets an event with 1.3 synchronization stage/access masks (needs `synchronization2`).

		`dependency` is a flat `VkDependencyInfo`: a 4-int header
		(`dependencyFlags, memoryCount, bufferCount, imageCount`) followed by
		memory (8 ints each), buffer (16) and image (19) barrier blocks.
	**/
	public function setEvent2(event:VKEvent, dependency:Array<Int>):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && event != null && event.isValid() && dependency != null)
		{
			return NativeCFFI.lime_vk_cmd_set_event_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, event.handle.high,
				event.handle.low, dependency);
		}
		#end

		return false;
	}

	/**
		Resets an event, waiting for `stage` first (1.3, needs `synchronization2`).

		`stage` is a 64-bit `VkPipelineStageFlags2`, passed whole through the FFI
		`high`/`low` pair.
	**/
	public function resetEvent2(event:VKEvent, stage:Int64):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && event != null && event.isValid())
		{
			return NativeCFFI.lime_vk_cmd_reset_event_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, event.handle.high,
				event.handle.low, stage.high, stage.low);
		}
		#end

		return false;
	}

	/**
		Waits for several events at once (1.3, needs `synchronization2`).

		`dependency` uses the same flat `VkDependencyInfo` encoding as `setEvent2`.
	**/
	public function waitEvents2(events:Array<VKEvent>, dependency:Array<Int>):Bool
	{
		if (events == null || events.length == 0)
		{
			return false;
		}

		var packed = new Array<Int>();
		for (event in events)
		{
			if (event == null || !event.isValid())
			{
				return false;
			}
			packed.push(event.handle.high);
			packed.push(event.handle.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && device != null && device.isValid() && dependency != null)
		{
			return NativeCFFI.lime_vk_cmd_wait_events_2(device.instance.context.__windowHandle, device.instance.handle.high,
				device.instance.handle.low, device.handle.high, device.handle.low, handle.high, handle.low, packed, dependency);
		}
		#end

		return false;
	}

	@:allow(lime.graphics.vulkan.VKCommandPool)
	private function __invalidate():Void
	{
		handle = Int64.ofInt(0);
	}

	private inline function get_device():VKDevice
	{
		return (pool != null) ? pool.device : null;
	}
}
