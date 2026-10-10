package lime.graphics.vulkan;

/**
	Decoding helpers for the packed word array returned by
	`VK.getPhysicalDeviceFeatures2` and friends.

	The reply is framed per requested struct as
	`[sType, wordCount, word0, word1, ...]`, where every word is a `VkBool32`
	normalised to `0` or `1`. Every Vulkan `*Features` struct is
	`{ sType, pNext, VkBool32 ... }`, so this representation is exact.
**/
class VKFeatureWords
{
	/**
		Reads one flag out of a single struct's word slice.
	**/
	public static inline function flag(words:Array<Int>, index:Int):Bool
	{
		return words != null && index >= 0 && index < words.length && words[index] != 0;
	}

	/**
		Reads one 32-bit integer out of a single struct's word slice.
	**/
	public static inline function uint(words:Array<Int>, index:Int):Int
	{
		return (words != null && index >= 0 && index < words.length) ? words[index] : 0;
	}

	/**
		Rebuilds the `sType -> words` mapping from a packed reply.

		Returns `null` for a `null` reply so callers can distinguish
		"query failed" from "queried, nothing present".
	**/
	public static function decode(packed:Array<Int>):Map<Int, Array<Int>>
	{
		if (packed == null)
		{
			return null;
		}

		var result = new Map<Int, Array<Int>>();
		var i = 0;

		while (i + 1 < packed.length)
		{
			var sType = packed[i];
			var count = packed[i + 1];
			var words = new Array<Int>();

			for (w in 0...count)
			{
				if (i + 2 + w >= packed.length)
				{
					break;
				}
				words.push(packed[i + 2 + w]);
			}

			result.set(sType, words);
			i += 2 + count;
		}

		return result;
	}
}
