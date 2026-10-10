package lime.graphics.vulkan;

import haxe.Int64;

/**
	One slot description inside a `VKDescriptorUpdateTemplate`.

	The template maps a byte range of the update blob onto a descriptor set
	binding. `offset` is where this entry's data starts inside the blob, and
	`stride` is the distance between consecutive descriptors when
	`descriptorCount > 1` (use `0` for a single descriptor).
**/
class VKDescriptorUpdateTemplateEntry
{
	public var descriptorCount:Int;
	public var descriptorType:Int;

	/**
		First array element of the binding that this entry writes.
	**/
	public var dstArrayElement:Int;

	/**
		Binding number inside the descriptor set.
	**/
	public var dstBinding:Int;

	/**
		Byte offset of this entry's data inside the update blob.
	**/
	public var offset:Int64;

	/**
		Byte distance between consecutive descriptors, `0` when there is only one.
	**/
	public var stride:Int64;

	public function new(dstBinding:Int, descriptorType:Int, descriptorCount:Int, offset:Int64, stride:Int64, dstArrayElement:Int = 0)
	{
		this.dstBinding = dstBinding;
		this.descriptorType = descriptorType;
		this.descriptorCount = descriptorCount;
		this.offset = offset;
		this.stride = stride;
		this.dstArrayElement = dstArrayElement;
	}
}
