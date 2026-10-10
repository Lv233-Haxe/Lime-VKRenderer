package lime.graphics.vulkan;


/**
	`VkPhysicalDeviceBufferDeviceAddressFeatures` — 3 boolean features.

	Obtained by asking `VK.getPhysicalDeviceFeatures2` for
	`VKStructureType.PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES` and decoding the returned word array.
**/
class VKPhysicalDeviceBufferDeviceAddressFeatures
{
	public var bufferDeviceAddress(default, null):Bool;
	public var bufferDeviceAddressCaptureReplay(default, null):Bool;
	public var bufferDeviceAddressMultiDevice(default, null):Bool;

	public function new()
	{
	}

	public static function fromWords(words:Array<Int>):VKPhysicalDeviceBufferDeviceAddressFeatures
	{
		if (words == null)
		{
			return null;
		}

		var vKPhysicalDeviceBufferDeviceAddressFeatures = new VKPhysicalDeviceBufferDeviceAddressFeatures();
		vKPhysicalDeviceBufferDeviceAddressFeatures.bufferDeviceAddress = VKFeatureWords.flag (words, 0);
		vKPhysicalDeviceBufferDeviceAddressFeatures.bufferDeviceAddressCaptureReplay = VKFeatureWords.flag (words, 1);
		vKPhysicalDeviceBufferDeviceAddressFeatures.bufferDeviceAddressMultiDevice = VKFeatureWords.flag (words, 2);
		return vKPhysicalDeviceBufferDeviceAddressFeatures;
	}

	public static inline function structType():Int
	{
		return VKStructureType.PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES;
	}
}

