package lime.graphics.vulkan;

import haxe.Int64;
import haxe.io.Bytes;
#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

@:access(lime.graphics.VulkanRenderContext)
@:access(lime._internal.backend.native.NativeCFFI)
/**
	A logical Vulkan device created from a `VKPhysicalDevice`.
**/
class VKDevice
{
	public var extensions(default, null):Array<String>;
	public var graphicsQueue(default, null):VKQueue;
	public var handle(default, null):Int64;
	public var instance(default, null):VKInstance;
	public var physicalDevice(default, null):VKPhysicalDevice;
	public var queueFamily(default, null):VKQueueFamilyInfo;

	@:allow(lime.graphics.vulkan.VKPhysicalDevice)
	private function new(physicalDevice:VKPhysicalDevice, queueFamily:VKQueueFamilyInfo, extensions:Array<String>, data:Dynamic)
	{
		this.physicalDevice = physicalDevice;
		this.instance = physicalDevice.instance;
		this.queueFamily = queueFamily;
		this.extensions = extensions.copy();
		handle = VK.__makeHandle(data.handle);
		graphicsQueue = new VKQueue(this, VK.__makeHandle(data.queue), data.queueFamilyIndex, 0);
	}

	public function createCommandPool(queueFamily:VKQueueFamilyInfo = null, flags:Int = VK.COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT):VKCommandPool
	{
		if (queueFamily == null)
		{
			queueFamily = this.queueFamily;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && queueFamily != null)
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_command_pool(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, queueFamily.index, flags);
			var commandPoolHandle = VK.__makeHandle(data);
			if (!VK.__isZero(commandPoolHandle))
			{
				return new VKCommandPool(this, queueFamily.index, commandPoolHandle);
			}
		}
		#end

		return null;
	}

	public function createFence(signaled:Bool = false):VKFence
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var flags = signaled ? VK.FENCE_CREATE_SIGNALED_BIT : 0;
			var data:Dynamic = NativeCFFI.lime_vk_create_fence(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, flags);
			var fenceHandle = VK.__makeHandle(data);
			if (!VK.__isZero(fenceHandle))
			{
				return new VKFence(this, fenceHandle);
			}
		}
		#end

		return null;
	}

	public function createEvent(flags:Int = 0):VKEvent
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_event(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, flags);
			var eventHandle = VK.__makeHandle(data);
			if (!VK.__isZero(eventHandle))
			{
				return new VKEvent(this, eventHandle);
			}
		}
		#end

		return null;
	}

	public function createQueryPool(queryType:Int, queryCount:Int):VKQueryPool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_query_pool(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, queryType, queryCount);
			var poolHandle = VK.__makeHandle(data);
			if (!VK.__isZero(poolHandle))
			{
				return new VKQueryPool(this, poolHandle, queryType, queryCount);
			}
		}
		#end

		return null;
	}

	/**
		Creates a private data slot (Vulkan 1.3).

		Requires the `privateData` feature - request it through
		`VKPhysicalDevice.createDeviceWithFeatures` with
		`VK.DEVICE_FEATURE_PRIVATE_DATA`; otherwise this returns `null`.
	**/
	public function createPrivateDataSlot(flags:Int = 0):VKPrivateDataSlot
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_private_data_slot(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, flags);
			var slotHandle = VK.__makeHandle(data);
			if (!VK.__isZero(slotHandle))
			{
				return new VKPrivateDataSlot(this, slotHandle);
			}
		}
		#end

		return null;
	}

	/**
		Asks the driver for the memory requirements of a buffer described by a
		create-info, without creating it (Vulkan 1.3, `maintenance4`).

		Mirrors `createBuffer`'s parameters; `flags` maps to
		`VkBufferCreateInfo::flags`.
	**/
	public function getBufferMemoryRequirementsForCreateInfo(size:Int64, usage:Int, flags:Int = 0):VKMemoryRequirements2
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			return VKMemoryRequirements2.fromDynamic(NativeCFFI.lime_vk_get_device_buffer_memory_requirements(
				instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high, handle.low,
				[size.high, size.low, usage, flags]));
		}
		#end

		return null;
	}

	/**
		Memory requirements for an image that does not exist yet (Vulkan 1.3,
		`maintenance4`). Parameter order mirrors `createImage`, with `createFlags`
		and `planeAspect` appended.
	**/
	public function getImageMemoryRequirementsForCreateInfo(width:Int, height:Int, format:Int, usage:Int, depth:Int = 1, mipLevels:Int = 1,
			arrayLayers:Int = 1, imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL,
			samples:Int = VK.SAMPLE_COUNT_1_BIT, createFlags:Int = 0, planeAspect:Int = 0):VKMemoryRequirements2
	{
		var createInfo = __buildImageCreateInfo(width, height, format, usage, depth, mipLevels, arrayLayers, imageType, tiling, samples,
			createFlags, planeAspect);

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			return VKMemoryRequirements2.fromDynamic(NativeCFFI.lime_vk_get_device_image_memory_requirements(
				instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high, handle.low, createInfo));
		}
		#end

		return null;
	}

	/**
		Sparse memory requirements for an image that does not exist yet (Vulkan 1.3,
		`maintenance4`). Non-sparse descriptions return an empty array.
	**/
	public function getImageSparseMemoryRequirementsForCreateInfo(width:Int, height:Int, format:Int, usage:Int, depth:Int = 1, mipLevels:Int = 1,
			arrayLayers:Int = 1, imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL,
			samples:Int = VK.SAMPLE_COUNT_1_BIT, createFlags:Int = 0, planeAspect:Int = 0):Array<VKSparseImageMemoryRequirements>
	{
		var sparseRequirements = new Array<VKSparseImageMemoryRequirements>();
		var createInfo = __buildImageCreateInfo(width, height, format, usage, depth, mipLevels, arrayLayers, imageType, tiling, samples,
			createFlags, planeAspect);

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var result:Dynamic = NativeCFFI.lime_vk_get_device_image_sparse_memory_requirements(instance.context.__windowHandle,
				instance.handle.high, instance.handle.low, handle.high, handle.low, createInfo);
			if (result != null)
			{
				var length:Int = untyped result.length;
				for (i in 0...length)
				{
					sparseRequirements.push(VKSparseImageMemoryRequirements.fromDynamic(untyped result[i]));
				}
			}
		}
		#end

		return sparseRequirements;
	}

	// flat VkImageCreateInfo shared by the two maintenance4 image queries; the
	// slot order is fixed on the C++ side (see lime_vk_get_device_image_memory_requirements)
	private inline function __buildImageCreateInfo(width:Int, height:Int, format:Int, usage:Int, depth:Int, mipLevels:Int,
			arrayLayers:Int, imageType:Int, tiling:Int, samples:Int, createFlags:Int, planeAspect:Int):Array<Int>
	{
		return [width, height, depth, mipLevels, arrayLayers, format, imageType, tiling, usage, samples, createFlags, planeAspect];
	}

	public function waitForFences(fences:Array<VKFence>, waitAll:Bool = true, timeout:Int64 = null):Bool
	{
		if (fences == null || fences.length == 0)
		{
			return false;
		}
		if (timeout == null)
		{
			timeout = Int64.make(-1, -1);
		}

		var state = [waitAll ? 1 : 0];
		for (fence in fences)
		{
			if (fence == null || !fence.isValid())
			{
				return false;
			}
			state.push(fence.handle.high);
			state.push(fence.handle.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			return NativeCFFI.lime_vk_wait_for_fences(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, state, timeout.high, timeout.low);
		}
		#end

		return false;
	}

	public function allocateMemory(requirements:VKMemoryRequirements, properties:Int):VKDeviceMemory
	{
		if (requirements == null)
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_allocate_memory(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				physicalDevice.handle.high, physicalDevice.handle.low, handle.high, handle.low, requirements.size.high, requirements.size.low,
				requirements.memoryTypeBits, properties);
			var memoryHandle = VK.__makeHandle(data != null ? data.handle : null);
			if (!VK.__isZero(memoryHandle))
			{
				return new VKDeviceMemory(this, memoryHandle, requirements.size, data.memoryTypeIndex, properties);
			}
		}
		#end

		return null;
	}

	public function createBuffer(size:Int64, usage:Int):VKBuffer
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_buffer(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, size.high, size.low, usage);
			var bufferHandle = VK.__makeHandle(data);
			if (!VK.__isZero(bufferHandle))
			{
				return new VKBuffer(this, bufferHandle, size, usage);
			}
		}
		#end

		return null;
	}

	public function createBufferWithMemory(size:Int64, usage:Int, properties:Int, bytes:Bytes = null):VKBuffer
	{
		var buffer = createBuffer(size, usage);
		if (buffer == null)
		{
			return null;
		}

		var memory = buffer.allocateMemory(properties);
		if (memory == null)
		{
			buffer.dispose();
			return null;
		}

		if (bytes != null && !buffer.upload(bytes))
		{
			buffer.dispose(true);
			return null;
		}

		return buffer;
	}

	public inline function createIndexBuffer(size:Int64, properties:Int, bytes:Bytes = null):VKBuffer
	{
		return createBufferWithMemory(size, VK.BUFFER_USAGE_INDEX_BUFFER_BIT, properties, bytes);
	}

	public inline function createStagingBuffer(size:Int64, bytes:Bytes = null):VKBuffer
	{
		return createBufferWithMemory(size, VK.BUFFER_USAGE_TRANSFER_SRC_BIT, VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT,
			bytes);
	}

	public inline function createUploadRing(byteCapacity:Int, usage:Int = VK.BUFFER_USAGE_TRANSFER_SRC_BIT,
			properties:Int = VK.MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK.MEMORY_PROPERTY_HOST_COHERENT_BIT):VKUploadRing
	{
		return new VKUploadRing(this, byteCapacity, usage, properties);
	}

	public inline function createStorageBuffer(size:Int64, properties:Int, bytes:Bytes = null):VKBuffer
	{
		return createBufferWithMemory(size, VK.BUFFER_USAGE_STORAGE_BUFFER_BIT, properties, bytes);
	}

	public inline function createUniformBuffer(size:Int64, properties:Int, bytes:Bytes = null):VKBuffer
	{
		return createBufferWithMemory(size, VK.BUFFER_USAGE_UNIFORM_BUFFER_BIT, properties, bytes);
	}

	public inline function createVertexBuffer(size:Int64, properties:Int, bytes:Bytes = null):VKBuffer
	{
		return createBufferWithMemory(size, VK.BUFFER_USAGE_VERTEX_BUFFER_BIT, properties, bytes);
	}

	public function createDescriptorPool(maxSets:Int, poolSizes:Array<VKDescriptorPoolSize>, flags:Int = 0):VKDescriptorPool
	{
		var packed = [flags, maxSets, poolSizes != null ? poolSizes.length : 0];
		if (poolSizes != null)
		{
			for (poolSize in poolSizes)
			{
				packed.push(poolSize.descriptorType);
				packed.push(poolSize.descriptorCount);
			}
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_descriptor_pool(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, packed);
			var descriptorPoolHandle = VK.__makeHandle(data);
			if (!VK.__isZero(descriptorPoolHandle))
			{
				return new VKDescriptorPool(this, descriptorPoolHandle);
			}
		}
		#end

		return null;
	}

	public function createDescriptorSetLayout(bindings:Array<VKDescriptorSetLayoutBinding>, flags:Int = 0):VKDescriptorSetLayout
	{
		var packed = [flags, bindings != null ? bindings.length : 0];
		if (bindings != null)
		{
			for (binding in bindings)
			{
				packed.push(binding.binding);
				packed.push(binding.descriptorType);
				packed.push(binding.descriptorCount);
				packed.push(binding.stageFlags);
			}
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_descriptor_set_layout(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, packed);
			var descriptorSetLayoutHandle = VK.__makeHandle(data);
			if (!VK.__isZero(descriptorSetLayoutHandle))
			{
				return new VKDescriptorSetLayout(this, descriptorSetLayoutHandle);
			}
		}
		#end

		return null;
	}

	public function updateDescriptorSets(writes:Array<VKDescriptorWrite>):Bool
	{
		if (writes == null || writes.length == 0)
		{
			return true;
		}

		var packed = [writes.length];
		for (write in writes)
		{
			if (write == null || !write.pack(packed))
			{
				return false;
			}
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			return NativeCFFI.lime_vk_update_descriptor_sets(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, packed);
		}
		#end

		return false;
	}

	public function createFramebuffer(renderPass:VKRenderPass, attachments:Array<VKImageView>, width:Int, height:Int, layers:Int = 1):VKFramebuffer
	{
		if (renderPass == null || !renderPass.isValid() || attachments == null || attachments.length == 0)
		{
			return null;
		}

		var packed = [attachments.length];
		for (attachment in attachments)
		{
			if (attachment == null || !attachment.isValid())
			{
				return null;
			}
			packed.push(attachment.handle.high);
			packed.push(attachment.handle.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_framebuffer(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, renderPass.handle.high, renderPass.handle.low, packed, width, height, layers);
			var framebufferHandle = VK.__makeHandle(data);
			if (!VK.__isZero(framebufferHandle))
			{
				return new VKFramebuffer(this, renderPass, framebufferHandle, width, height);
			}
		}
		#end

		return null;
	}

	public function createGraphicsPipeline(renderPass:VKRenderPass, layout:VKPipelineLayout, vertexShader:VKShaderModule, fragmentShader:VKShaderModule,
			info:VKGraphicsPipelineInfo, cache:VKPipelineCache = null):VKPipeline
	{
		if (renderPass == null || layout == null || vertexShader == null || fragmentShader == null)
		{
			return null;
		}
		if (info == null)
		{
			info = new VKGraphicsPipelineInfo();
		}

		var cacheHandle = cache != null && cache.isValid() ? cache.handle : Int64.ofInt(0);

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && renderPass.isValid() && layout.isValid() && vertexShader.isValid() && fragmentShader.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_graphics_pipeline(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, renderPass.handle.high, renderPass.handle.low, layout.handle.high, layout.handle.low, vertexShader.handle.high,
				vertexShader.handle.low, fragmentShader.handle.high, fragmentShader.handle.low, info.pack(cacheHandle));
			var pipelineHandle = VK.__makeHandle(data);
			if (!VK.__isZero(pipelineHandle))
			{
				return new VKPipeline(this, layout, pipelineHandle);
			}
		}
		#end

		return null;
	}

	public function createComputePipeline(layout:VKPipelineLayout, shader:VKShaderModule, cache:VKPipelineCache = null,
			requiredSubgroupSize:Int = 0):VKPipeline
	{
		if (layout == null || shader == null)
		{
			return null;
		}

		var cacheHandle = cache != null && cache.isValid() ? cache.handle : Int64.ofInt(0);

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && layout.isValid() && shader.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_compute_pipeline(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, layout.handle.high, layout.handle.low, shader.handle.high, shader.handle.low, cacheHandle.high, cacheHandle.low, 0,
				requiredSubgroupSize);
			var pipelineHandle = VK.__makeHandle(data);
			if (!VK.__isZero(pipelineHandle))
			{
				return new VKPipeline(this, layout, pipelineHandle);
			}
		}
		#end

		return null;
	}

	public function createImage(width:Int, height:Int, format:Int, usage:Int, depth:Int = 1, mipLevels:Int = 1, arrayLayers:Int = 1,
			imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL, samples:Int = VK.SAMPLE_COUNT_1_BIT):VKImage
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_image(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, width, height, depth, mipLevels, arrayLayers, format, imageType, tiling, usage, samples);
			var imageHandle = VK.__makeHandle(data);
			if (!VK.__isZero(imageHandle))
			{
				return VKImage.createOwned(this, imageHandle, width, height, format);
			}
		}
		#end

		return null;
	}

	public function createImageEx(width:Int, height:Int, format:Int, usage:Int, createFlags:Int = 0, depth:Int = 1, mipLevels:Int = 1,
			arrayLayers:Int = 1, imageType:Int = VK.IMAGE_TYPE_2D, tiling:Int = VK.IMAGE_TILING_OPTIMAL, samples:Int = VK.SAMPLE_COUNT_1_BIT):VKImage
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_image_ex(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, width, height, depth, mipLevels, arrayLayers, format, imageType, tiling, usage, samples, createFlags);
			var imageHandle = VK.__makeHandle(data);
			if (!VK.__isZero(imageHandle))
			{
				return VKImage.createOwned(this, imageHandle, width, height, format);
			}
		}
		#end

		return null;
	}

	public function createPipelineCache(bytes:Bytes = null, byteOffset:Int = 0, byteLength:Int = -1):VKPipelineCache
	{
		if (byteLength < 0 && bytes != null)
		{
			byteLength = bytes.length - byteOffset;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_pipeline_cache(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, bytes, byteOffset, byteLength);
			var pipelineCacheHandle = VK.__makeHandle(data);
			if (!VK.__isZero(pipelineCacheHandle))
			{
				return new VKPipelineCache(this, pipelineCacheHandle);
			}
		}
		#end

		return null;
	}

	public function createPipelineLayout(descriptorSetLayouts:Array<VKDescriptorSetLayout> = null, pushConstantStages:Int = 0,
			pushConstantSize:Int = 0):VKPipelineLayout
	{
		var packed = [descriptorSetLayouts != null ? descriptorSetLayouts.length : 0];
		if (descriptorSetLayouts != null)
		{
			for (layout in descriptorSetLayouts)
			{
				if (layout == null || !layout.isValid())
				{
					return null;
				}
				packed.push(layout.handle.high);
				packed.push(layout.handle.low);
			}
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_pipeline_layout(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, packed, pushConstantStages, pushConstantSize);
			var pipelineLayoutHandle = VK.__makeHandle(data);
			if (!VK.__isZero(pipelineLayoutHandle))
			{
				return new VKPipelineLayout(this, pipelineLayoutHandle);
			}
		}
		#end

		return null;
	}

	public function createRenderPass(colorFormat:Int, depthStencilFormat:Int = VK.FORMAT_UNDEFINED, samples:Int = VK.SAMPLE_COUNT_1_BIT,
			colorLoadOp:Int = VK.ATTACHMENT_LOAD_OP_CLEAR, colorStoreOp:Int = VK.ATTACHMENT_STORE_OP_STORE,
			colorInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, colorFinalLayout:Int = VK.IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
			depthInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, depthFinalLayout:Int = VK.IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
			depthLoadOp:Int = VK.ATTACHMENT_LOAD_OP_CLEAR, depthStoreOp:Int = VK.ATTACHMENT_STORE_OP_DONT_CARE, resolveFormat:Int = VK.FORMAT_UNDEFINED,
			resolveLoadOp:Int = VK.ATTACHMENT_LOAD_OP_DONT_CARE, resolveStoreOp:Int = VK.ATTACHMENT_STORE_OP_STORE,
			resolveInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, resolveFinalLayout:Int = VK.IMAGE_LAYOUT_PRESENT_SRC_KHR):VKRenderPass
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var state = [
				colorFormat,
				depthStencilFormat,
				samples,
				colorLoadOp,
				colorStoreOp,
				colorInitialLayout,
				colorFinalLayout,
				depthInitialLayout,
				depthFinalLayout,
				depthLoadOp,
				depthStoreOp,
				resolveFormat,
				resolveLoadOp,
				resolveStoreOp,
				resolveInitialLayout,
				resolveFinalLayout
			];
			var data:Dynamic = NativeCFFI.lime_vk_create_render_pass(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, state);
			var renderPassHandle = VK.__makeHandle(data);
			if (!VK.__isZero(renderPassHandle))
			{
				return new VKRenderPass(this, renderPassHandle, colorFormat, depthStencilFormat, samples, resolveFormat);
			}
		}
		#end

		return null;
	}

	public function createSampler(filter:Int = VK.FILTER_LINEAR, addressMode:Int = VK.SAMPLER_ADDRESS_MODE_REPEAT,
			mipmapMode:Int = VK.SAMPLER_MIPMAP_MODE_LINEAR, anisotropyEnable:Bool = false, maxAnisotropy:Float = 1, compareOp:Int = -1, minLod:Float = 0,
			maxLod:Float = 0):VKSampler
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_sampler(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, filter, addressMode, mipmapMode, anisotropyEnable, maxAnisotropy, compareOp, minLod, maxLod);
			var samplerHandle = VK.__makeHandle(data);
			if (!VK.__isZero(samplerHandle))
			{
				return new VKSampler(this, samplerHandle);
			}
		}
		#end

		return null;
	}

	public function createSemaphore():VKSemaphore
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_semaphore(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low);
			var semaphoreHandle = VK.__makeHandle(data);
			if (!VK.__isZero(semaphoreHandle))
			{
				return new VKSemaphore(this, semaphoreHandle);
			}
		}
		#end

		return null;
	}

	public function createTimelineSemaphore(initialValue:Int64 = null):VKSemaphore
	{
		if (initialValue == null)
		{
			initialValue = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_timeline_semaphore(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, initialValue.high, initialValue.low);
			var semaphoreHandle = VK.__makeHandle(data);
			if (!VK.__isZero(semaphoreHandle))
			{
				return new VKSemaphore(this, semaphoreHandle);
			}
		}
		#end

		return null;
	}

	public function createShaderModule(bytes:Bytes, byteOffset:Int = 0, byteLength:Int = -1):VKShaderModule
	{
		if (bytes == null)
		{
			return null;
		}
		if (byteLength < 0)
		{
			byteLength = bytes.length - byteOffset;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_shader_module(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, bytes, byteOffset, byteLength);
			var shaderModuleHandle = VK.__makeHandle(data);
			if (!VK.__isZero(shaderModuleHandle))
			{
				return new VKShaderModule(this, shaderModuleHandle);
			}
		}
		#end

		return null;
	}

	/**
		Creates a swapchain for a window surface. Pass an existing swapchain as
		`oldSwapchain` when recreating resources after a resize.
	**/
	public function createSwapchain(surface:VKSurface, width:Int = 0, height:Int = 0, presentMode:Int = VK.PRESENT_MODE_FIFO_KHR,
			oldSwapchain:VKSwapchain = null):VKSwapchain
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && surface != null && surface.isValid() && queueFamily != null)
		{
			var oldSwapchainHandle = (oldSwapchain != null && oldSwapchain.isValid()) ? oldSwapchain.handle : Int64.ofInt(0);
			var data:Dynamic = NativeCFFI.lime_vk_create_swapchain(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				physicalDevice.handle.high, physicalDevice.handle.low, handle.high, handle.low, surface.high, surface.low, queueFamily.index, width, height,
				presentMode, oldSwapchainHandle.high, oldSwapchainHandle.low);
			var swapchainHandle = VK.__makeHandle(data != null ? data.handle : null);
			if (!VK.__isZero(swapchainHandle))
			{
				return new VKSwapchain(this, surface, data);
			}
		}
		#end

		return null;
	}

	/**
		Destroys the logical device. All resources created from the device should
		be destroyed before calling this method.
	**/
	public function dispose():Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			NativeCFFI.lime_vk_destroy_device(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high, handle.low);
			handle = Int64.ofInt(0);
			graphicsQueue = null;
		}
		#end
	}

	/**
		Retrieves a queue from this device by queue family index and by index
		within that family. The queue created by `VKPhysicalDevice.createDevice`
		is at index 0 of the family it was created from.
	**/
	public function getQueue(queueFamilyIndex:Int = -1, queueIndex:Int = 0):VKQueue
	{
		if (queueFamilyIndex < 0 && queueFamily != null)
		{
			queueFamilyIndex = queueFamily.index;
		}

		if (queueFamilyIndex < 0)
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_device_queue(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, queueFamilyIndex, queueIndex);
			if (data != null)
			{
				var queueHandle = VK.__makeHandle(data.handle);
				if (!VK.__isZero(queueHandle))
				{
					return new VKQueue(this, queueHandle, data.queueFamilyIndex, data.queueIndex);
				}
			}
		}
		#end

		return null;
	}

	/**
		Returns how much of a lazily allocated memory object is currently committed.

		This is only meaningful for memory allocated with
		`VK.MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT`.
	**/
	public function getMemoryCommitment(memory:VKDeviceMemory):Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && memory != null && memory.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_device_memory_commitment(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, memory.handle.high, memory.handle.low);
			return VK.__makeHandle(data);
		}
		#end

		return Int64.ofInt(0);
	}

	/**
		Queries buffer memory requirements through the Vulkan 1.1 path.

		Unlike `VKBuffer.getMemoryRequirements()` this also reports the dedicated
		allocation hints, which matter for large textures and for drivers that
		require a dedicated allocation.
	**/
	public function getBufferMemoryRequirements2(buffer:VKBuffer):VKMemoryRequirements2
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && buffer != null && buffer.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_buffer_memory_requirements2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low);
			return VKMemoryRequirements2.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Queries image memory requirements through the Vulkan 1.1 path.
	**/
	public function getImageMemoryRequirements2(image:VKImage):VKMemoryRequirements2
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && image != null && image.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_image_memory_requirements2(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, image.handle.high, image.handle.low);
			return VKMemoryRequirements2.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Binds device memory to a buffer through the Vulkan 1.1 path.

		Equivalent to `VKBuffer.bindMemory`, but this is the form required when the
		buffer came from a dedicated allocation, and it is the entry point future
		device-group support builds on.
	**/
	public function bindBufferMemory2(buffer:VKBuffer, memory:VKDeviceMemory, offset:Int64 = null):Bool
	{
		if (offset == null)
		{
			offset = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && buffer != null && buffer.isValid() && memory != null && memory.isValid())
		{
			var result = NativeCFFI.lime_vk_bind_buffer_memory2(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, buffer.handle.high, buffer.handle.low, memory.handle.high, memory.handle.low, offset.high, offset.low);
			if (result)
			{
				buffer.__setMemory(memory);
			}
			return result;
		}
		#end

		return false;
	}

	/**
		Binds device memory to an image through the Vulkan 1.1 path.
	**/
	public function bindImageMemory2(image:VKImage, memory:VKDeviceMemory, offset:Int64 = null):Bool
	{
		if (offset == null)
		{
			offset = Int64.ofInt(0);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && image != null && image.isValid() && memory != null && memory.isValid())
		{
			var result = NativeCFFI.lime_vk_bind_image_memory2(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, image.handle.high, image.handle.low, memory.handle.high, memory.handle.low, offset.high, offset.low);
			if (result)
			{
				image.__setMemory(memory);
			}
			return result;
		}
		#end

		return false;
	}

	/**
		Retrieves a queue through the Vulkan 1.1 path, which additionally accepts
		queue-create flags (used for protected queues).
	**/
	public function getQueue2(flags:Int = 0, queueFamilyIndex:Int = -1, queueIndex:Int = 0):VKQueue
	{
		if (queueFamilyIndex < 0 && queueFamily != null)
		{
			queueFamilyIndex = queueFamily.index;
		}

		if (queueFamilyIndex < 0)
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_device_queue2(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, flags, queueFamilyIndex, queueIndex);
			if (data != null)
			{
				var queueHandle = VK.__makeHandle(data.handle);
				if (!VK.__isZero(queueHandle))
				{
					return new VKQueue(this, queueHandle, data.queueFamilyIndex, data.queueIndex);
				}
			}
		}
		#end

		return null;
	}

	/**
		Checks whether a descriptor set layout can actually be created.

		This is the cheap way to validate a bindless (`UPDATE_AFTER_BIND`) layout
		before creating it, instead of discovering the driver's refusal later.
		`bindings` uses the same packing as `createDescriptorSetLayout`.
	**/
	public function isDescriptorSetLayoutSupported(bindings:Array<VKDescriptorSetLayoutBinding>, flags:Int = 0):VKDescriptorSetLayoutSupport
	{
		var packed = [flags, bindings != null ? bindings.length : 0];

		if (bindings != null)
		{
			for (binding in bindings)
			{
				packed.push(binding.binding);
				packed.push(binding.descriptorType);
				packed.push(binding.descriptorCount);
				packed.push(binding.stageFlags);
			}
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_descriptor_set_layout_support(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, packed);
			return VKDescriptorSetLayoutSupport.fromDynamic(data);
		}
		#end

		return null;
	}

	/**
		Returns the device address of a buffer created with
		`VK.BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT`.

		Buffer device address is the Vulkan 1.2 feature that makes bindless
		vertex/index/uniform data practical: a shader can reach any buffer through
		a plain 64-bit address instead of a bound descriptor.
	**/
	public function getBufferDeviceAddress(buffer:VKBuffer):Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && buffer != null && buffer.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_buffer_device_address(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low);
			return VK.__makeHandle(data);
		}
		#end

		return Int64.ofInt(0);
	}

	/**
		Returns the opaque capture address of a buffer, for use with
		`VK.MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT`.
	**/
	public function getBufferOpaqueCaptureAddress(buffer:VKBuffer):Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && buffer != null && buffer.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_buffer_opaque_capture_address(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, buffer.handle.high, buffer.handle.low);
			return VK.__makeHandle(data);
		}
		#end

		return Int64.ofInt(0);
	}

	/**
		Returns the opaque capture address of a memory allocation.
	**/
	public function getDeviceMemoryOpaqueCaptureAddress(memory:VKDeviceMemory):Int64
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && memory != null && memory.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_device_memory_opaque_capture_address(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, memory.handle.high, memory.handle.low);
			return VK.__makeHandle(data);
		}
		#end

		return Int64.ofInt(0);
	}

	/**
		Releases a command pool's unused internal resources back to the driver.

		Worth calling after a burst of command-buffer allocation, e.g. once a level
		finishes loading.
	**/
	public function trimCommandPool(commandPool:VKCommandPool, flags:Int = 0):Void
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && commandPool != null && commandPool.isValid())
		{
			NativeCFFI.lime_vk_trim_command_pool(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, commandPool.handle.high, commandPool.handle.low, flags);
		}
		#end
	}

	/**
		Creates a render pass through the Vulkan 1.2 path.

		Same shape as `createRenderPass`, with two additions:

		- `depthResolveMode` / `stencilResolveMode` (Vulkan 1.2 depth/stencil
		  resolve, chained through `VkSubpassDescriptionDepthStencilResolve`);
		- `depthStencilResolveAttachment`, the attachment index the resolved
		  depth/stencil is written to. Pass `-1` (the default) for no resolve.

		Depth/stencil resolve requires a multisampled depth/stencil attachment and
		a single-sampled resolve target, so the attachment must already exist in
		the pass — supply its index here.
	**/
	public function createRenderPass2(colorFormat:Int, depthStencilFormat:Int = VK.FORMAT_UNDEFINED, samples:Int = VK.SAMPLE_COUNT_1_BIT,
			colorLoadOp:Int = VK.ATTACHMENT_LOAD_OP_CLEAR, colorStoreOp:Int = VK.ATTACHMENT_STORE_OP_STORE,
			colorInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, colorFinalLayout:Int = VK.IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
			depthInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, depthFinalLayout:Int = VK.IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
			depthLoadOp:Int = VK.ATTACHMENT_LOAD_OP_CLEAR, depthStoreOp:Int = VK.ATTACHMENT_STORE_OP_DONT_CARE, resolveFormat:Int = VK.FORMAT_UNDEFINED,
			resolveLoadOp:Int = VK.ATTACHMENT_LOAD_OP_DONT_CARE, resolveStoreOp:Int = VK.ATTACHMENT_STORE_OP_STORE,
			resolveInitialLayout:Int = VK.IMAGE_LAYOUT_UNDEFINED, resolveFinalLayout:Int = VK.IMAGE_LAYOUT_PRESENT_SRC_KHR,
			depthResolveMode:Int = VK.RESOLVE_MODE_NONE, stencilResolveMode:Int = VK.RESOLVE_MODE_NONE,
			depthStencilResolveAttachment:Int = -1):VKRenderPass
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var state = [
				colorFormat,
				depthStencilFormat,
				samples,
				colorLoadOp,
				colorStoreOp,
				colorInitialLayout,
				colorFinalLayout,
				depthInitialLayout,
				depthFinalLayout,
				depthLoadOp,
				depthStoreOp,
				resolveFormat,
				resolveLoadOp,
				resolveStoreOp,
				resolveInitialLayout,
				resolveFinalLayout,
				depthResolveMode,
				stencilResolveMode,
				depthStencilResolveAttachment
			];
			var data:Dynamic = NativeCFFI.lime_vk_create_render_pass2(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high,
				handle.low, state);
			var renderPassHandle = VK.__makeHandle(data);
			if (!VK.__isZero(renderPassHandle))
			{
				return new VKRenderPass(this, renderPassHandle, colorFormat, depthStencilFormat, samples, resolveFormat);
			}
		}
		#end

		return null;
	}

	/**
		Creates a descriptor update template (Vulkan 1.1).

		The template records how a plain data blob maps onto descriptor set
		bindings, so a whole set can later be refreshed with a single
		`updateDescriptorSetWithTemplate()` call.
	**/
	public function createDescriptorUpdateTemplate(descriptorSetLayout:VKDescriptorSetLayout, entries:Array<VKDescriptorUpdateTemplateEntry>,
			flags:Int = 0, templateType:Int = VK.DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET,
			pipelineBindPoint:Int = VK.PIPELINE_BIND_POINT_GRAPHICS, pipelineLayout:VKPipelineLayout = null, set:Int = 0):VKDescriptorUpdateTemplate
	{
		if (entries == null || entries.length == 0)
		{
			return null;
		}

		var state = [
			flags,
			templateType,
			descriptorSetLayout != null ? descriptorSetLayout.handle.high : 0,
			descriptorSetLayout != null ? descriptorSetLayout.handle.low : 0,
			pipelineBindPoint,
			pipelineLayout != null ? pipelineLayout.handle.high : 0,
			pipelineLayout != null ? pipelineLayout.handle.low : 0,
			set,
			entries.length
		];

		for (entry in entries)
		{
			state.push(entry.dstBinding);
			state.push(entry.dstArrayElement);
			state.push(entry.descriptorCount);
			state.push(entry.descriptorType);
			state.push(entry.offset.high);
			state.push(entry.offset.low);
			state.push(entry.stride.high);
			state.push(entry.stride.low);
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_descriptor_update_template(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, state);
			var templateHandle = VK.__makeHandle(data);
			if (!VK.__isZero(templateHandle))
			{
				return new VKDescriptorUpdateTemplate(this, templateHandle);
			}
		}
		#end

		return null;
	}

	/**
		Rewrites a descriptor set from a raw data blob, using a template.

		`bytes` must be laid out exactly as the template's entries describe. This
		is the cheap path when a renderer rebuilds per-draw descriptors every
		frame: one call and no `VkWriteDescriptorSet` array.
	**/
	public function updateDescriptorSetWithTemplate(descriptorSet:VKDescriptorSet, updateTemplate:VKDescriptorUpdateTemplate, bytes:Bytes, byteOffset:Int = 0,
			byteLength:Int = -1):Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid() && descriptorSet != null && descriptorSet.isValid() && updateTemplate != null
			&& updateTemplate.isValid())
		{
			return NativeCFFI.lime_vk_update_descriptor_set_with_template(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				handle.high, handle.low, descriptorSet.handle.high, descriptorSet.handle.low, updateTemplate.handle.high, updateTemplate.handle.low, bytes,
				byteOffset, byteLength);
		}
		#end

		return false;
	}

	/**
		Creates a YCbCr conversion (Vulkan 1.1).

		Attach the result to a sampler to sample subsampled (video) formats. All
		enum arguments take the `VK.SAMPLER_YCBCR_*`, `VK.COMPONENT_SWIZZLE_*`
		and `VK.CHROMA_LOCATION_*` constants.
	**/
	public function createSamplerYcbcrConversion(format:Int, ycbcrModel:Int = VK.SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709,
			ycbcrRange:Int = VK.SAMPLER_YCBCR_RANGE_ITU_NARROW, rSwizzle:Int = VK.COMPONENT_SWIZZLE_IDENTITY,
			gSwizzle:Int = VK.COMPONENT_SWIZZLE_IDENTITY, bSwizzle:Int = VK.COMPONENT_SWIZZLE_IDENTITY,
			aSwizzle:Int = VK.COMPONENT_SWIZZLE_IDENTITY, xChromaOffset:Int = VK.CHROMA_LOCATION_MIDPOINT,
			yChromaOffset:Int = VK.CHROMA_LOCATION_MIDPOINT, chromaFilter:Int = VK.FILTER_LINEAR,
			forceExplicitReconstruction:Bool = false):VKSamplerYcbcrConversion
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_create_sampler_ycbcr_conversion(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, format, ycbcrModel, ycbcrRange, rSwizzle, gSwizzle, bSwizzle, aSwizzle, xChromaOffset,
				yChromaOffset, chromaFilter, forceExplicitReconstruction ? 1 : 0);
			var conversionHandle = VK.__makeHandle(data);
			if (!VK.__isZero(conversionHandle))
			{
				return new VKSamplerYcbcrConversion(this, conversionHandle);
			}
		}
		#end

		return null;
	}

	/**
		Returns which peer-memory operations are legal between two devices of a
		device group (Vulkan 1.1). Result is a `VK.PEER_MEMORY_FEATURE_*` mask.
	**/
	public function getDeviceGroupPeerMemoryFeatures(memoryTypeIndex:Int, localDeviceIndex:Int, remoteDeviceIndex:Int):Int
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid() && instance != null && instance.isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_get_device_group_peer_memory_features(instance.context.__windowHandle, instance.handle.high,
				instance.handle.low, handle.high, handle.low, memoryTypeIndex, localDeviceIndex, remoteDeviceIndex);
			return VK.__makeHandle(data).low;
		}
		#end

		return 0;
	}

	/**
		Allocates device memory with explicit `VkMemoryAllocateFlags` (Vulkan 1.1).

		`allocateMemory()` cannot set allocate flags, which makes it unusable for
		buffer device address: a buffer created with
		`VK.BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT` must have its memory allocated
		with `VK.MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT`. This variant exists for that.

		`properties` selects the memory type (`VK.MEMORY_PROPERTY_*`);
		`allocateFlags` is chained through a `VkMemoryAllocateFlagsInfo`
		(`VK.MEMORY_ALLOCATE_*`) and is omitted entirely when zero.
	**/
	public function allocateMemoryEx(requirements:VKMemoryRequirements, properties:Int, allocateFlags:Int = 0):VKDeviceMemory
	{
		if (requirements == null)
		{
			return null;
		}

		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			var data:Dynamic = NativeCFFI.lime_vk_allocate_memory_ex(instance.context.__windowHandle, instance.handle.high, instance.handle.low,
				physicalDevice.handle.high, physicalDevice.handle.low, handle.high, handle.low, requirements.size.high, requirements.size.low,
				requirements.memoryTypeBits, properties, allocateFlags);
			var memoryHandle = VK.__makeHandle(data != null ? data.handle : null);
			if (!VK.__isZero(memoryHandle))
			{
				return new VKDeviceMemory(this, memoryHandle, requirements.size, data.memoryTypeIndex, properties);
			}
		}
		#end

		return null;
	}

	public inline function get():Int64
	{
		return handle;
	}

	public inline function isValid():Bool
	{
		return !VK.__isZero(handle);
	}

	/**
		Blocks until the logical device has completed all submitted work.
	**/
	public function waitIdle():Bool
	{
		#if (!macro && lime_cffi && lime_vulkan)
		if (isValid())
		{
			return NativeCFFI.lime_vk_device_wait_idle(instance.context.__windowHandle, instance.handle.high, instance.handle.low, handle.high, handle.low);
		}
		#end

		return false;
	}
}
