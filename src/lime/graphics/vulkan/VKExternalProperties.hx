package lime.graphics.vulkan;

/**
	External-handle capabilities reported for buffers, fences or semaphores.

	Produced by `VKPhysicalDevice.getExternalBufferProperties()`,
	`getExternalFenceProperties()` and `getExternalSemaphoreProperties()`.

	This is how you find out whether a buffer or semaphore can be shared with
	another API (D3D, CUDA, a video decoder, …) and through which handle type.
**/
class VKExternalProperties
{
	/**
		Handle types this object can be exported to.
	**/
	public var compatibleHandleTypes(default, null):Int;

	/**
		Handle types that may be used to import an existing object of this kind.
	**/
	public var exportFromImportedHandleTypes(default, null):Int;

	/**
		Feature bits specific to the queried object kind:

		- buffer  → `VkExternalMemoryFeatureFlags`
		- fence   → `VkExternalFenceFeatureFlags`
		- semaphore → `VkExternalSemaphoreFeatureFlags`
	**/
	public var externalFeatures(default, null):Int;

	public function new(externalFeatures:Int, exportFromImportedHandleTypes:Int, compatibleHandleTypes:Int)
	{
		this.externalFeatures = externalFeatures;
		this.exportFromImportedHandleTypes = exportFromImportedHandleTypes;
		this.compatibleHandleTypes = compatibleHandleTypes;
	}

	public static function fromDynamic(data:Dynamic):VKExternalProperties
	{
		if (data == null)
		{
			return null;
		}

		return new VKExternalProperties(data.externalFeatures, data.exportFromImportedHandleTypes, data.compatibleHandleTypes);
	}
}
