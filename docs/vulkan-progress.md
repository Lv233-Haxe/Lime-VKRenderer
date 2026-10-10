# Lime Vulkan 后端：进展与覆盖率

> 进展记录：批次演进、Vulkan 1.0–1.4 覆盖率、smoke test 验证状态（截至 2026-09-18）。
> 架构要点、CFFI 绑定约束与运行期排查见 [vulkan-dev-notes.md](vulkan-dev-notes.md)。

---

## 0. 速览

| 指标 | 数值 |
|---|---|
**559**（手写 238 + 扩展 300 + 1.4 core 19 + 2 个 1.3 属性查询；扩展命令由 `vk.xml` 生成） |
| Vulkan 1.0 / 1.1 / 1.2 Core 覆盖 | **137/137、165/165、178/178 = 100%** |
| Vulkan 1.4 Core 覆盖 | **234/234 = 100%**（19–22 批补入全部 19 条 1.4 独有命令） |
| Vulkan 1.3 覆盖 | **215/215 = 100%**（16 批补齐；20 批补 feature 面：Inline Uniform Blocks + Subgroup Size Control） |
| Haxe 封装类 | **80**（新增 `VKToolProperties` / `VKPrivateDataSlot` / `VKObjectType`）+ `VKCommandBuffer` 14 个动态状态方法（12批） |
| 设备特性开启 | ✅ `createDeviceWithFeatures` / `allocateMemoryEx`；id 覆盖 **1.0 / 1.1 / 1.2 / 1.3**（1–55） |
| 表面查询（KHR 扩展，不计入 core） | ✅ capabilities / formats / present modes 已暴露 |
| `VkStructureType` 常量 | **1251**（全量生成） |
| `VK.FORMAT_*` 常量 | **370**（由 `vk_gen_format_constants.py` 从 `vulkan_core.h` 全量生成） |
| 特性结构体表（C++） | **267**（全量 `*Features*`，纯 `VkBool32`） |
| **smoke test（真机 GTX 750 Ti / Vulkan 1.4.357）** | **✅ 全绿：28 PASS + 1 SKIP（externalProperties 平台限制），0 FAIL** |
| Haxe 编译期错误 | **0**（9批清掉 90+；14 批又遇 2 类：`Int64` 与 null 误用、HL helper 命名，均已加静态检查） |
| C++ 源文件编码 | ✅ 3 个含非 ASCII 文件已加 **UTF-8 BOM**（10批） |
| neko/HL 双侧 API | ✅ 920 函数零混用（`vk_ffi_side_check` 常驻） |
| 静态校验 | **9 道全过** |
| 源文件规模 | `ExternalInterface.cpp` ~45k 行 / `NativeCFFI.hx` ~14k 行 / `VK.hx` ~1100 行 |

**结论：Vulkan 1.0 / 1.1 / 1.2 三级命令覆盖 100%，且已在真机通过全套 smoke test（含渲染一帧 + present）。**

---

## 1. smoke test 验证状态（tests/vulkan-smoke）

> **最新真机确认（2026-09-18，14 批之后）：GTX 750 Ti 上 28 PASS + 1 SKIP、0 FAIL。**
> 13 批（1.3 特性链）与 14 批（6 条新命令）均已在真机验证通过。

运行环境：GTX 750 Ti (Maxwell GM107) + NVIDIA 550 驱动（Vulkan 1.4.357 加载器）、Windows、cpp 目标。

特性请求实测：`[1,2,20,23,24,26,27,28,45,50,53]`（14 批那次；16 批起 `Main.hx` 追加请求
`DEVICE_FEATURE_MAINTENANCE4`(55)，20 批起再请求 `DEVICE_FEATURE_INLINE_UNIFORM_BLOCK`(42) 与
`DEVICE_FEATURE_SUBGROUP_SIZE_CONTROL`(48)），其中 **id 27（descriptorIndexing）被自动裁剪**
（`f12[20]` = `descriptorBindingUniformBufferUpdateAfterBind` 硬件不支持）—— 裁剪机制按预期工作。

### CloudSmoke（基础 API 抽查）

| 项 | 结果 |
|---|---|
| getFenceStatus / freeDescriptorSet / cmdCopyQueryPoolResults | ✅ PASS |
| dynamicRendering | ✅ PASS（13 批接入 1.3 特性链后转真实渲染测试，真机已确认） |
| bindSparse | ✅ PASS（sparseBinding 已开启） |

### ModernApiChecks（1.1/1.2 查询家族 20 项）

| 项 | 结果 | 备注 |
|---|---|---|
| loaderVersion | ✅ 1.4.357 | `vkEnumerateInstanceVersion` |
| instanceEnumeration | ✅ 16 extensions, 14 layers | |
| deviceGroups | ✅ 1 group, 1 device | |
| features2 | ✅ timelineSemaphore/BDA/runtimeDescriptorArray/samplerYcbcrConversion 全 true | 特性链查询正确 |
| properties2 | ✅ maxMemoryAllocationSize=4292870144（≈4GB） | maintenance3 正确填充 |
| propertyFamilies | ✅ driverID=4 'NVIDIA'，maxTimelineSemaphoreValueDifference=2147483647 | Int64 跨 CFFI 正确 |
| formatProperties2 | ✅ optimalTilingFeatures=0xDD83 | |
| imageFormatProperties2 | ✅ sampleCounts=0xF, maxMipLevels=15 | |
| memoryProperties2 | ✅ 12 types, 3 heaps | |
| queueFamilyProperties2 | ✅ 3 families | |
| sparseImageFormatProperties2 | ✅ 1 entry | |
| externalProperties | ⏭ SKIP（OPAQUE_WIN32 平台限制） | 预期 |
| surfaceQueries | ✅ 5 formats, 5 present modes, resolved extent | MAILBOX 优先 |
| memory2AndBind2 | ✅ requiresDedicated=false | |
| descriptorSetLayoutSupport | ✅ | |
| descriptorUpdateTemplate | ✅ 24-byte blob applied | |
| bufferDeviceAddress | ✅ 0x222CC0000 | **BDA 全链路真实工作** |
| sparseMemoryRequirements2 | ✅ 0 entries | |
| queue2AndPeerFeatures | ✅ | |
| trimCommandPool | ✅ | |
| extendedDynamicState | ✅ 14 setters | 12批 |
| toolProperties | ✅ PASS | 0 entr(ies)（无工具挂载，正常） |
| vertexBuffers2 | ✅ PASS | 1 binding, size=VK_WHOLE_SIZE, stride=12 |
| privateData | ✅ PASS | round-trip high=4660 low=22136（= 0x12345678，往返无误） |
| copyCommands2 | ⏳ 待真机跑 | 15批新增，无 feature bit，6 条录制 |
| timestamp2 | ⏳ 待真机跑 | 15批新增，需 `synchronization2`（已请求） |
| sync2Remainder | ⏳ 待真机跑 | 16批；submit2 + set/resetEvent2 真提交，waitEvents2 只录制 |
| maintenance4 | ⏳ 待真机跑 | 16批；与对象自身 `getMemoryRequirements()` 交叉核对 size（`Main.hx` 已请求 id 55） |
| extensionCommands | ⏳ 待真机跑 | 19批新增；**扩展命令首次获得运行期覆盖**（`VkRect2D` 数组 + `float` 位模式两条编码路径） |
| inlineUniformBlocks | ⏳ 待真机跑 | 20批新增；查询属性类 +（feature 开启时）用 `VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK` 建 layout |
| subgroupSizeControl | ⏳ 待真机跑 | 20批新增；查询属性类；quad 管线在 feature 开启时**真实 pin** `minSubgroupSize`（走 pNext） |

### 渲染主流程

设备创建（8 项特性请求，descriptorIndexing 复合请求自动裁剪）→ swapchain（MAILBOX）→
离屏/在屏 pass → `drawFrame()`（acquire → 渲染 → **present**）→ 清理 → 正常退出。

---

## 2. 各批次新增

计数演进：105 → … → 238 → 517 → 510 → 516 → **559**（17 批起从 vk.xml 自动生成；20 批重放时按**指针成员政策**剔除 14 条会传/写 NULL 的坏命令并 +5 条 1.4 core、+2 条 1.3 属性查询；21 批**字节缓冲区通道** +6；22 批**二级数组通道**补完 1.4 的 12 条；23 批同通道收割扩展 31 条）。

### 第 21 批（510 → 516）：**字节缓冲区通道 —— `const void*` 参数/成员走 Haxe `Bytes`**

生成器新通道（`vk_gen_from_xml.py` + `vk_gen.py`），两种形态：

- **函数参数级**：`const void* pData` 带 XML `len` 链接（如 `vkCmdUpdateBuffer` 的 `dataSize`）→
  长度参数**折叠**进 Bytes（`len_of_bytes` op：保留 call 实参槽位、退出 CFFI 签名）——
  指针与长度同源于一个 `Bytes`，不可能不一致。
- **结构体成员级**：`const void*` 成员（`VkPushConstantsInfo::pValues`、`VkDebugUtilsObjectTagInfoEXT::pTag`、
  `VkPipelineCacheCreateInfo::pInitialData`）→ 进 `struct_extras`，与字符串成员同机制：独立 `Bytes` 参数，
  C++ 侧把指针写进结构体，兄弟 size 成员照走扁平 int 列表（调用方保证一致）。

C++ 发射用**方言占位符**（`%%BDECL/%%BPDECL/%%BPTR/%%BLEN`，`vk_gen.py` 的 `BYTES_EXPR`）：
neko 侧 `Bytes data (bytes);` + `val_null` 防护解包出局部指针/长度；HL 侧 `Bytes*` 形参内联
`(p && p->b) ? ... : 0`。签名 `bytes→o`、HL 注册 `_TBYTES`、Haxe `Bytes` 类型（映射表本就在）。

- 入批 6 条：`vkCmdPushConstants2`、`vkCmdPushDescriptorSetWithTemplate2`（1.4 core，size 走扁平列表）、
  `vkCmdUpdateMemoryKHR`（1.4，`dataSize` 折叠）、`vkCreateValidationCacheEXT`、
  `vkDebugMarkerSetObjectTagEXT`、`vkSetDebugUtilsObjectTagEXT`（3 条 EXT；当时剔除的 14 条坏命令部分回锅）
- 拒绝（政策保守）：模板驱动无长度者（`vkCmdPushDescriptorSetWithTemplate`、`vkGetMemoryHostPointerPropertiesEXT`）、
  数组形态 per-element bytes（`vkCreateShadersEXT`）、输出方向 `void*` 写目标（政策不变）
- `vk_selfcheck` 升级：bytes 占位符中和、`VK_*` 标识白名单、数组返回双形态（int vector / `CreateVulkan*Array`）；
  顺手修了批 12/14/15/16 从未单独自检过的历史告警（7/7 PASS）
- **坑 58**：占位符发射必须 `.format`，`"%%x%%" % name` 的 `%` 格式化会把 `%%` 吃成单个 `%`，
  与展开端正则不一致 → selfcheck 的 stray-`%%` 检查抓到（门禁立功）

> `lime_vk_*` = **516**；1.0–1.3 = 100%，**1.4 = 94.9%（222/234）**，扩展独有 269/377 = 71.4%。

### 第 1–3 批（105 → 151）

| 批次 | 内容 |
|---|---|
| 第 1 批（→123） | `VKEvent`；Compute 管线与 dispatch；二级命令缓冲与 `executeCommands`；`cmdSetEvent/ResetEvent/WaitEvents`；7 项动态状态 |
| 第 2 批（→136） | `VKQueryPool`；Query begin/end/reset/writeTimestamp；`cmdCopyImage`/`cmdResolveImage`；`cmdUpdateBuffer`/`cmdFillBuffer`；多 fence 等待 |
| 第 3 批（→151） | Timeline Semaphore 全家；Dynamic Rendering；`cmdPipelineBarrier2`；稀疏资源；`getImageSubresourceLayout`；`getFenceStatus`；`freeDescriptorSet`；`cmdCopyQueryPoolResults`；描述符批量更新 |

### 第 4 批（151 → 160）：1.0 Core 收尾（62% → 100%，+18）

物理设备特性/格式/图像格式/内存/稀疏格式查询、`get_device_queue`、`get_device_memory_commitment`、`create/destroy_buffer_view`、`get_image_sparse_memory_requirements`、`merge_pipeline_caches`、`get_render_area_granularity`、`set/reset_event`、4 个实例/设备扩展与层枚举。
配套 12 类：`VKBufferView`、`VKPhysicalDeviceFeatures`(55 字段)、`VKFormatProperties`、`VKImageFormatProperties`、`VKPhysicalDeviceMemoryProperties`、`VKMemoryType`/`VKMemoryHeap`、`VKExtensionProperties`/`VKLayerProperties`、两个稀疏类、`VKExtent2D`/`VKExtent3D`。

### 第 5 批（160 → 176）：1.1/1.2 的 2D 核心

| 类别 | API | 2D 价值 |
|---|---|---|
| 版本/特性 | `enumerate_instance_version`、`get_physical_device_features2` | ★★★ 1.1/1.2 可选特性唯一入口 |
| 属性 | `get_descriptor_indexing_properties`、`get_vulkan12_properties` | ★★★ bindless 数组上限 |
| 内存 | `get/set_buffer/image_memory_requirements2`、`bind_buffer/image_memory2` | ★★ 含 dedicated 分配提示 |
| 描述符/队列 | `get_descriptor_set_layout_support`、`get_device_queue2`、`trim_command_pool` | ★★★ 创建前校验 bindless 布局 |
| BDA | `get_buffer_device_address`、两个 opaque capture address | ★★★ bindless 顶点/索引/UBO |
| GPU 驱动批处理 | `cmd_draw_indirect_count` / `cmd_draw_indexed_indirect_count` | ★★★ 绘制数由 GPU 写入，免 CPU 回读 |

**通用特性查询机制**：**全部 267 个 `*Features*` 结构体都是 `{ sType, pNext, VkBool32 ... }`**（脚本核对 267/267）。C++ 一张 `{sType, sizeof}` 表，回读成扁平 int 数组 `[sType, wordCount, w0..]`；Haxe 侧 `VKFeatureWords.decode` → `Map<sType, Array<Int>>` → 生成的类型化类 `fromWords` 成具名布尔字段。**字段顺序全由生成器从头文件推导。**

配套 15 类：`VKStructureType`(1251 常量)、`VKFeatureWords`、`VKApiVersion`、`VKDescriptorSetLayoutSupport`、`VKMemoryRequirements2`、`VKDescriptorIndexingProperties`、`VKVulkan12Properties` + 8 个特性访问类。

### 第 6 批（176 → 199）：1.1/1.2 收尾达成 100%（+23）

| 组 | API（`lime_vk_*`） |
|---|---|
| RenderPass2 全家 | `create_render_pass2`、`cmd_begin/next_subpass/end_render_pass2` |
| DescriptorUpdateTemplate | `create/destroy_descriptor_update_template`、`update_descriptor_set_with_template` |
| Properties2 家族 | `get_physical_device_properties2`、`get_physical_device_format/image_format/memory/queue_family/sparse_image_format_properties2` |
| 外部互操作 | `get_physical_device_external_buffer/fence/semaphore_properties` |
| YCbCr | `create/destroy_sampler_ycbcr_conversion` |
| Device Groups（3D/VR） | `enumerate_physical_device_groups`、`get_device_group_peer_memory_features`、`cmd_set_device_mask` |
| Compute/稀疏 | `cmd_dispatch_base`、`get_image_sparse_memory_requirements2` |

新增 8 类 + 5 处方法扩展；常量约 40 个（`DESCRIPTOR_UPDATE_TEMPLATE_TYPE_*`、`RESOLVE_MODE_*`、`PEER_MEMORY_FEATURE_*`、`EXTERNAL_*`、`SAMPLER_YCBCR_*`、`COMPONENT_SWIZZLE_*`、`CHROMA_LOCATION_*`）。

### 第 7 批（199 → 202）：表面查询 + `VulkanRenderContext` 修补

新增 surface 三查询（KHR 扩展，不计入 core 覆盖率）：`get_physical_device_surface_capabilities/formats/present_modes`，配 `VKSurfaceCapabilities`（`resolveExtent()`）+ `VKSurfaceFormat`。

`VulkanRenderContext` 三处修补：`createSurface` 类型死角修复、`version` 惰性 getter、新增 `getApiVersion()`/`createInstance()`。

### 第 8 批（202 → 204）：设备特性开启

`CreateManagedVulkanDevice` 全零特性 → 前 7 批大半 1.1/1.2 函数调用即无效。新增：

| API | 说明 |
|---|---|
| `lime_vk_create_device_with_features` | 接 `VK.DEVICE_FEATURE_*` id，经 features2 校验后写 `pEnabledFeatures` + 1.1/1.2 pNext 链 |
| `lime_vk_allocate_memory_ex` | 可链 `VkMemoryAllocateFlagsInfo`（BDA 必需） |

同步更新 `tests/vulkan-smoke`：新增 `ModernApiChecks.hx`（20 项）、`Main.hx` 特性探测驱动创建、swapchain 真实规则、RenderPass2 优先、`drawIndexedIndirectCount`、接上 `CloudSmoke` 死代码。

### 第 9–11 批（204±0）：编译期修复

| 批次 | 问题 | 修复 |
|---|---|---|
| 9（Haxe 编译期） | 生成器在 static 函数写裸字段名（86 处）、`VK.hx` 重复常量、测试调用点写错名 | 生成器补前缀 + 批量重写；`vk_haxecheck` 扩到 7 项 |
| 10（C++ 编译期） | 无 BOM + 中文注释 → MSVC 按 cp936 解码炸出 100+ 错误 | 3 个文件加 UTF-8 BOM；新增 `vk_encoding.py`（第 8 道校验） |
| 11（C++ 编译期） | neko/HL 双侧 API 混用（HL_PRIM 体内用 `alloc_*`） | 修 1 处；新增 `vk_ffi_side_check.py`（第 9 道校验） |

### 第 12–13 批（204±0）：运行期修复（详见 dev-notes §4）

- **12**：`vkCmdBeginRendering` 特性未开 + PFN 存在 → 驱动崩。`checkDynamicRendering`/`checkSparse` 加特性门控。
- **13**：instance 的 `apiVersion` 被三元表达式硬编码成 1.0 → 1.1+ pNext 链全 0。改为使用 `vkEnumerateInstanceVersion` 实际值；`features2` 查询改逐个结构体。

### 第 14–15 批（204±0）：探测/校验一致性与字段对账

- **14**：`VulkanFeatureBitsDisable` + 校验失败改为**裁剪并跳过**（不再中止设备创建）；`supportedState` 查询与 Haxe 探测对齐为逐个查询。
- **15**：`VKVulkan12Properties.__load` 的嵌套读 `data.conformanceVersion.major`（C++ 给的是平铺字段）→ hxcpp null 崩溃。Haxe 改平铺 + C++ 补 15 个缺失 `shader*` 字段。
- **结果**：smoke test 全绿（见 §1）。

### 第 12 批（204 → 218）：**Vulkan 1.3 Extended Dynamic State（14 条）**

**价值**：1.3 把 `VK_EXT_extended_dynamic_state` 提升为 core。这批命令让管线状态
（cull mode / front face / 深度模板开关与比较函数 / 图元拓扑 / 光栅化丢弃 /
viewport+scissor 带 count）在**命令缓冲录制期**改变，**免去为每种状态组合重建 VkPipeline**
—— 2D 批渲染切换混合/裁剪模式时是刚需。

**特性依赖：无**。这 14 条在 1.3 core 里没有 feature bit（EXT 形态也无门控），
1.3 设备上只要 PFN 拿得到就能用，不需要经 `createDeviceWithFeatures` 请求 ——
这与 Synchronization2 / PrivateData / Maintenance4 不同（那三组各有 feature bit，见 §5 优先级）。

| 分组 | 命令 |
|---|---|
| 标量状态（12） | `setCullMode` `setFrontFace` `setPrimitiveTopology` `setDepthTestEnable` `setDepthWriteEnable` `setDepthCompareOp` `setDepthBoundsTestEnable` `setStencilTestEnable` `setStencilOp` `setRasterizerDiscardEnable` `setDepthBiasEnable` `setPrimitiveRestartEnable` |
| 批量数组（2） | `setViewportWithCount`（6 float/视口）`setScissorWithCount`（4 int/矩形） |

- 实现：`vk_batch12.py` → `vk_gen.py` → `vk_splice.py`（8 锚点唯一性校验通过）→ 9 道校验全过。
- Haxe 侧：`VKCommandBuffer` 新增 14 个方法（`setStencilOp` 5 参；两个 WithCount 收扁平数组，上限 16 个）。
- 常量：补 `VK.STENCIL_FACE_{FRONT,BACK,FRONT_AND_BACK}`（值查自 `vulkan_core.h`）。
- smoke：`ModernApiChecks.checkExtendedDynamicState` 把 14 个 setter 录进一个命令缓冲验证 PFN 可用。

> **覆盖率 84.2% → 90.7%**（181/215 → 195/215）。

### 第 13 批（218±0）：**Vulkan 1.3 特性开启链接入（id 41–55）**

1.3 命令里有一批带特性位（`synchronization2` / `dynamicRendering` / `privateData` / `maintenance4` …），
在此之前 `DEVICE_FEATURE_*` 只到 1.2（id 40），所以这些命令即使实现也无法合法调用。
本批把整条 1.3 特性链补齐：

- `LimeVulkanFeatureState` 增加 `features13` + `uses13`
- `ApplyVulkanDeviceFeature` / `VulkanDeviceFeatureName` 增加 **id 41–55**（按 `vulkan_core.h`
  里 `VkPhysicalDeviceVulkan13Features` 的字段声明顺序，1:1 对应）
- 版本门控：请求 1.3 特性时要求设备 `apiVersion >= 1.3`（1.1/1.2 仍要求 >= 1.2）
- supportedState 查询 / `VulkanFeatureBitsSatisfied` 校验 / 裁剪 skip 路径 / enabledChain
  四处同步补上 features13
- Haxe：`VK.DEVICE_FEATURE_*` 增加 15 个常量（41–55）
- **neko/HL 两侧对齐**：HL 版此前仍是"串联 pNext 查询 + 校验失败即中止"，
  本批一并升级为与 neko 相同的**逐个结构体查询 + 裁剪跳过**策略

**效果**：`Main.hx` 的 `buildFeatureRequests()` 现在会探测并请求 `synchronization2` 与
`dynamicRendering`，`CloudSmoke.checkDynamicRendering` 从 SKIP 转为**真实渲染测试**
（录制 `beginRendering`/`endRendering` 并提交）。

> 顺带修掉一处死代码：neko 版 skip 块曾被重复插入（内外层 `if (!satisfied)` 各一套），
> 内层 `continue` 使外层那段永远不可达 —— 已清理为单份。

---

### 第 14 批（218 → 224）：**Vulkan 1.3 收尾第一批（6 条）**

从 1.3 剩余 20 条里挑**结构体负担最轻**的 6 条先做，降低混入错误的概率：

| 命令 | 依赖 | Haxe 入口 |
|---|---|---|
| `vkGetPhysicalDeviceToolProperties` | 无 | `VKPhysicalDevice.getToolProperties():Array<VKToolProperties>` |
| `vkCmdBindVertexBuffers2` | 无 | `VKCommandBuffer.bindVertexBuffers2(firstBinding, bindings)` |
| `vkCreate/DestroyPrivateDataSlot` | `privateData` (45) | `VKDevice.createPrivateDataSlot(flags)` / `VKPrivateDataSlot.dispose()` |
| `vkSet/GetPrivateData` | `privateData` | `VKPrivateDataSlot.setData/getData(objectType, objectHandle, data)` |

- **新类**：`VKToolProperties`（数据）、`VKPrivateDataSlot`（句柄 + 生命周期）、
  `VKObjectType`（60 个 `VkObjectType` 常量，**由 `vk_gen_object_type.py` 从 SDK 头文件提取**，
  不手抄数值）
- **常量**：`VK.TOOL_PURPOSE_*` 7 个（校验自 `VkToolPurposeFlagBits`）
- **编码**：64 位标量（`VkDeviceSize` / `uint64_t` / 非分派句柄）仍按 `high`/`low` 两个 Int
  拆传；`vkCmdBindVertexBuffers2` 四条平行数组压成一个扁平 Int 列表，**每条绑定 8 slot**
  （buffer 句柄、offset、size、stride 各占 high/low），与 12 批 viewport/scissor 一致
- **`VK_WHOLE_SIZE`**：size 取 `high == -1 && low == -1` 表示"到缓冲末尾"（查 khronos man
  page 确认，不是 0），已写进方法文档
- **smoke**：`ModernApiChecks` 新增 `toolProperties` / `vertexBuffers2` / `privateData`
  三项；`Main.buildFeatureRequests()` 追加请求 `VK.DEVICE_FEATURE_PRIVATE_DATA`
  （`VkPhysicalDeviceVulkan13Features` 第 4 个 `VkBool32` 字段，index 4）

> **覆盖率 90.7% → 93.5%**（195/215 → 201/215）。

---

### 第 15 批（224 → 231）：**Vulkan 1.3 收尾第二批（7 条）**

| 命令 | 依赖 | Haxe 入口 |
|---|---|---|
| `vkCmdCopyBuffer2` | **无 feature bit** | `VKCommandBuffer.copyBuffer2(src, dst, regions)` |
| `vkCmdCopyImage2` | 无 | `copyImage2(src, dst, srcLayout, dstLayout, regions)` |
| `vkCmdCopyBufferToImage2` | 无 | `copyBufferToImage2(buffer, image, dstLayout, regions)` |
| `vkCmdCopyImageToBuffer2` | 无 | `copyImageToBuffer2(image, buffer, srcLayout, regions)` |
| `vkCmdBlitImage2` | 无 | `blitImage2(src, dst, srcLayout, dstLayout, filter, regions)` |
| `vkCmdResolveImage2` | 无 | `resolveImage2(src, dst, srcLayout, dstLayout, regions)` |
| `vkCmdWriteTimestamp2` | `synchronization2` (50) | `writeTimestamp2(stage, pool, queryIndex)` |

**关键校正**：查 khronos man page 确认 —— **六条 `*2` 拷贝命令在 1.3 core 里没有 feature bit**
（只要求 1.3 设备或 `VK_KHR_copy_commands2`），此前进度文档把它们归到
"需 `synchronization2`" 是错的；真正需要 `synchronization2` 的只有
`QueueSubmit2` / `CmdSetEvent2` / `CmdResetEvent2` / `CmdWaitEvents2` / `CmdWriteTimestamp2`。

**编码**：region 数组一律压成扁平 Int 列表，每条 region 固定 slot 数 ——
`VkBufferCopy2`=6、`VkBufferImageCopy2`=14、`VkImageCopy2`/`VkImageResolve2`=17、
`VkImageBlit2`=20（含 `srcOffsets[2]` 与 `dstOffsets[2]`）。sType 数值全部取自头文件
（`COPY_BUFFER_INFO_2`=1000337000 … `IMAGE_RESOLVE_2`=1000337010）。

**遗留限制**：`VkPipelineStageFlags2` 是 64 位，`writeTimestamp2` 与既有
`pipelineBarrier2` 一样只能表达低 32 位。

**smoke**：`ModernApiChecks` 新增 `copyCommands2`（两条 buffer + 两张 image，
录制 6 条命令不提交）与 `timestamp2`（`synchronization2` 未开则 SKIP）；
`run()` 增加 `featureRequests` 参数，`Main.hx` 传入 `requests`。

> **覆盖率 93.5% → 96.7%**（201/215 → 208/215）。

---

### 第 16 批（231 → 238）：**Vulkan 1.3 收尾（7 条）→ 1.3 达成 100%**

| 命令 | 依赖 | Haxe 入口 |
|---|---|---|
| `vkQueueSubmit2` | `synchronization2` | `VKQueue.submit2(cb, fence)` / `submit2Ex(...)` |
| `vkCmdSetEvent2` | `synchronization2` | `VKCommandBuffer.setEvent2(event, dependency)` |
| `vkCmdResetEvent2` | `synchronization2` | `VKCommandBuffer.resetEvent2(event, stage:Int64)` |
| `vkCmdWaitEvents2` | `synchronization2` | `VKCommandBuffer.waitEvents2(events, dependency)` |
| `vkGetDeviceBufferMemoryRequirements` | `maintenance4` (55) | `VKDevice.getBufferMemoryRequirementsForCreateInfo(size, usage, flags)` |
| `vkGetDeviceImageMemoryRequirements` | `maintenance4` | `VKDevice.getImageMemoryRequirementsForCreateInfo(...)` |
| `vkGetDeviceImageSparseMemoryRequirements` | `maintenance4` | `VKDevice.getImageSparseMemoryRequirementsForCreateInfo(...)` |

**`VkDependencyInfo` 扁平编码**（C++ 侧 `BuildVulkanDependencyInfo` 解析，neko/HL 共用一份）：

    header 4 ints: dependencyFlags, memoryBarrierCount, bufferBarrierCount, imageBarrierCount
    VkMemoryBarrier2       (8)  = srcStageH,L srcAccessH,L dstStageH,L dstAccessH,L
    VkBufferMemoryBarrier2 (16) = 8 + srcQueue, dstQueue, bufferH,L, offsetH,L, sizeH,L
    VkImageMemoryBarrier2  (19) = 8 + oldLayout, newLayout, srcQueue, dstQueue, imageH,L,
                                  aspect, baseMip, levelCount, baseArrayLayer, layerCount

字段顺序按头文件（`VkMemoryBarrier2` 是 stage/access **交替**，不是两组分写 —— 这点抄错不会报错，
只会让屏障语义悄悄变错）。

**命名**：`maintenance4` 的三条查询不作用于已存在的对象，所以与 1.1 的 `getBufferMemoryRequirements2(buffer)` / `getImageMemoryRequirements2(image)` 重名冲突（Haxe 无重载）→ 统一用 `...ForCreateInfo` 后缀。

**Maintenance4**：`VkBuffer/VkImageCreateInfo` 以**扁平 int 列表**跨 FFI 传（图像 11 槽
= `width,height,depth,mipLevels,arrayLayers,format,imageType,tiling,usage,samples,createFlags`
+ 可选 `planeAspect`），槽序与 `lime_vk_create_image_ex` 对齐，避免撞 `DEFINE_PRIME16` 上限。

**smoke**：`sync2Remainder`（submit2 + set/resetEvent2 真提交并等 fence；`waitEvents2` 只录制 ——
同一命令缓冲 wait 自己 set 的 event 会死锁）与 `maintenance4`（把查询结果与
`buffer.getMemoryRequirements()` 的 size 交叉核对）。

> **覆盖率 96.7% → 100%**（208/215 → 215/215）。Vulkan 1.0 / 1.1 / 1.2 / 1.3 **四级全 100%**。

---

### 第 17 批（238 → 389）：**扩展体系首批 —— 由 `vk.xml` 自动生成 151 条**

覆盖 KHR / EXT / NV / AMD 里结构最规整的一批（无出参、无字符串、无浮点、无平台依赖）。
生成器：**`.workbuddy/scripts/vk_gen_from_xml.py`** 读 `vk.xml` 产出 `vk_batchN.py`，
再走 `vk_gen → vk_splice → 11 面校验` 流水线。

**编码规则**（机器执行手写批次定下的约定）：

| vk.xml 类型 | CFFI 表示 |
|---|---|
| 分派/非分派句柄、`uint64_t`/`VkDeviceSize`/`VkDeviceAddress` | `(high, low)` 两个 int |
| `uint32_t`/`bool`/枚举/flags | 一个 int |
| `const T*`（结构体） | `value` 扁平 int 列表，**按成员递归展开**（`pNext` 跳过、`sType` 取自 XML） |
| `VkResult`/`void` | `bool`；返回句柄或 64 位标量 → obj |

参数顺序严格照 Vulkan 原型；数组长度一律 `xxxCountClamped = min(调用方传入, 列表长度 / 每元素槽位)`。

---

### 第 18 批（389 → 517）：**扩展命令收尾 128 条 —— 出参、字符串、浮点全部机器化**

| 新增能力 | 表示方式 | 解锁 |
|---|---|---|
| **出参**（`T*`、`T*+count`、`uint32_t*`） | 返回**一个扁平 int 列表**（见下方契约） | ~85 |
| 实例作用域（只有 `VkInstance`） | 新 `hdr="instance"`，走 `vkGetInstanceProcAddr` | 6 |
| `VkBool32` / 标量返回 | `bool` / 单元素 int 列表 | 7 |
| `size_t`/`HANDLE`/`VkSampleMask`/`int` | 2 / 2 / 1 / 1 槽 | ~12 |
| by-value 数组 `combinerOps[2]` | 聚合成一个本地数组，**只传一个实参** | 2 |
| 结构体**字符串成员** | 额外一个 `HxString` 参数，声明提升到结构体循环之前 | ~15（含 debug_utils 标签/命名） |
| **`float`**（成员与参数） | int 列表里放 **4 字节原始位模式**（`memcpy` 进、`VulkanFloatBits` 出） | 3 |
| **`VkAllocationCallbacks*`** | **直接丢弃**，调用处传 `0`（与手写批次既有约定一致） | ~40 |

**出参契约**（Haxe 侧统一返回 `Array<Int>`）：

    [按参数声明顺序，每个出参展开]
    标量出参   → 1 或 2 个 int（64 位拆 high/low，低字在前）
    结构体出参 → struct_slots 个 int（成员顺序同 expand_struct）
    数组出参   → 先 1 个 int（驱动回填的元素个数），再 N × 元素槽位

数组出参的**容量 = 调用方传入的扁平列表长度 / 每元素槽位**；驱动回填的 count 更小则以它为准，
只查询数量就传空列表。

#### 被排除的扩展（不是遗漏，是编译期根本不存在）

`platform="win32"|"xlib"|"xcb"|…` 的扩展把命令声明在 `#ifdef VK_USE_PLATFORM_*_KHR` 内，
`provisional="true"` 的（beta）声明在 `#ifdef VK_ENABLE_BETA_EXTENSIONS` 内。两个宏都没开，
`PFN_vkXxx` 与相关结构体根本不存在 → **C2065 / C2923**。这两个宏本构建不启用
（Lime 的 surface 走 SDL），所以生成器直接跳过这类扩展（共 **67** 条命令）。

#### 仍然拒绝的 98 条

| 原因 | 条数 |
|---|---|
| 结构体成员是指针（二级数组，长度藏在结构体内部） | 73 |
| `const void*` 参数（字节块） | 20 |
| 参数超过 `DEFINE_PRIME16` | 3 |
| 无实例/设备作用域 | 1 |
| 成员类型不支持 | 1 |

> **覆盖率**：可生成的扩展独有命令 **279/377 = 74%**（另有 67 条平台/测试版命令不适用）；
> `lime_vk_*` 总数 238 → **517**；Vulkan 1.0–1.3 仍为 100%，1.4 = 91.9%（215/234，缺的是 1.4 新增 core 命令）。

#### 首次编译暴露并修掉的 8 个真实错误（全部已加静态检查）

| # | 症状 | 根因 | 现在由谁拦 |
|---|---|---|---|
| 1 | `PFN_vkXxx 未声明` × 4 族 | 平台/测试版扩展的 `PFN_*` 不存在 | 生成器跳过这类扩展 |
| 2 | `C2440 value → vdynamic*` × 9 | 第 17 批的旧生成器把失败返回硬编码成 neko 的 `alloc_null ()`，HL 半边也照抄 | `vk_ffi_side_check`（它一直在报，是我阅卷方式错了，见下） |
| 3 | `C2197 参数太多` × 12 | 结构体字符串成员被当成 Vulkan 实参追加；by-value 数组被拆成 2 个实参 | `vk_selfcheck` 新增的**实参个数 == 原型参数个数**检查 |
| 4 | `val_array_set_i` 无法转换 | hxcpp 的数组存装箱值，整数要 `alloc_int` | 已修（`CreateVulkanIntVectorValue`） |
| 5 | 整批重复定义 ×154 | 18 批按"扩展全集"生成，含 17 批已有的命令 | `vk_validate` 第 11 面 + 生成器 `--exclude` |
| 6 | `out_array` 从未生成 | 非 const 结构体指针一律按单个结构体处理（驱动会写爆 1 元素缓冲） | 生成器修正 + 出参契约 |
| 7 | 多数组共用 count 时 `uint32_t xClamped` 重复声明 | 每个数组各声明一次 | `vk_selfcheck`（同名只允许一次声明） |
| 8 | `float color[4]` 少算 3 槽 | `vk.xml` 里名字是 `color`、`[4]` 在尾文本 | 生成器同时从 raw 文本抓下标 |

**阅卷方式的教训**：`vk_ffi_side_check.py` 的问题行原本不带 `!!` 前缀，而收尾脚本用
`grep -c "^!!"` 统计"问题数"，于是**它报了 9 处 C2440 风险，却被读成 0**。
现在所有校验脚本统一：问题行以 `!!` 开头，并且门禁一律用**进程退出码**。

---

### 第 19 批（函数数不变，**修正生成器**）：指针参数、helper 重复、可执行门禁

第一次真机编译暴露的问题，全部落在"生成器把不该省的省了"这一类上：

| 症状 | 根因 | 处理 |
|---|---|---|
| `C2664: 无法将参数 3 从 VkSampleMask 转换为 const VkSampleMask *` ×2 | 指针参数**没有兄弟 count 时被判成按值标量**（`kind="scalar_array" if count else "scalar"`）。`VkSampleMask` 加进 `SCALAR32` 后，从"明确拒绝"变成了"静默传错" | 指针一律走数组路径；`len`/`altlen` 可求值（`(samples + 31) / 32`）时按表达式定长度 |
| helper 被调用 194 次、**定义 0 个**（C3861） | 重放工具 `vk_regen_batch.py` 把 `EXTRA_HELPERS` 写死成 `""`；splice 片段因此不含 helper，而 batch 的调用点全在 | 重放保留/恢复 helper 文本；splice 前先检查"目标里是否已有" |
| helper 出现 **2 份定义**（C2084） | helper 文本随**每个**批次走，而两次 splice 是两次独立生成器运行，生成器内部去重看不到跨运行重复 | 生成器内按名去重 + 插入前过滤已存在定义 |

**新增静态面**：`vk_validate.py` 第 12 面"指针形状参数不得声明为 int"（965 个生成定义中零反例）；
`vk_selfcheck.py` 同名规则；`vk_validate.py` 退出码补齐（此前**重复定义 / void 当值用 / helper 缺失**三面都在报，却被 `return 1 if (problems or pfn_issues)` 忽略 → 假绿）。

> 覆盖率不变：1.0–1.3 全 100%，1.4 = 215/234；`lime_vk_*` = **517**。

#### 同批收尾：warning C4311（结构体成员的宏下标数组）

6 处 `warning C4311: 从"uint32_t *"/"uint8_t *"到"int"的指针截断`，根因是**成员数组的下标是宏**：
`presentMask[VK_MAX_DEVICE_GROUP_SIZE]`、`key[VK_MAX_PIPELINE_BINARY_KEY_SIZE_KHR]`、
`identifier[VK_MAX_SHADER_MODULE_IDENTIFIER_SIZE_EXT]`。解析只认数字下标 → 三个成员被当标量 →
编码方向生成 `outData.push_back ((int)value.presentMask);`（**数组名退化成指针**）。只是 warning，
所以编译能过、但**这几个结构体的回读数据是错的**。

- cpp：6 处改为 `for (int i = 0; i < (int)VK_MAX_*; ++i) { outData.push_back ((int)v.m[i]); }`
- 生成器：成员解析接受宏下标；新增 `macro_value()` 从 `vulkan_core.h` 读 `#define` 表；
  `encode_struct` 对宏数组循环展开；`expand_struct`（输入方向）明确拒绝（需运行时递增下标）
- 核对：重生成两批后 **15174 行渲染全部命中 cpp**（生成器输出与手改逐行一致，无需重插）、
  截断式残留 0、BOM 保持、九道门禁全 0

---

### 4.x 扩展命令的烟雾覆盖：为什么此前一条都测不到（第 19 批补上）

新增 279 条扩展命令后，烟雾测试**一条都没跑过**，原因有两个，都不在测试代码里：

1. **设备创建时没启用任何扩展** —— `createDeviceWithFeatures(queueFamily, null, requests)`
   的第二个参数是 `null`，实际只启用 `VK_KHR_swapchain`。扩展命令只有在创建逻辑设备时
   启用对应扩展才合法，所以哪怕拿到函数指针也不能调。
2. **扩展命令没有公开的 Haxe 封装** —— 生成的 279 条只有 `NativeCFFI` 里的 private `@:cffi`
   入口，而烟雾测试走的是公开封装类（`VKCommandBuffer` 等），根本够不到。

**现在**：`Main.buildDeviceExtensions()` 把候选扩展与设备实际上报的扩展求交集后传给
`createDeviceWithFeatures`；`ModernApiChecks.checkExtensionCommands()` 用
`@:access(lime._internal.backend.native.NativeCFFI)` 直接调 CFFI（**仅测试用**的耦合，
否则这 279 条永远没有运行期覆盖）。

**可测范围（按 vk.xml 实测，20 批重放后的 265 条）**：

| 分类 | 数量 | 能否真机调用 |
|---|---|---|
| 只需启用扩展名（无特性结构体） | **106** | ✅ 可以（已启用 `VK_EXT_discard_rectangles` / `VK_NV_clip_space_w_scaling`） |
| 需要扩展自身的 `VkPhysicalDevice*Features*` | **159** | ❌ 阻塞：特性链目前只支持 core 的 `DEVICE_FEATURE_*`（1–55），没有 EXT 特性结构体 |

> ⚠️ **`vkCmdSetSampleMaskEXT`（第 19 批修的那条）属于后 164 条** —— 它需要
> `extendedDynamicState3SampleMask`。也就是说**"派生长度数组"这条编码路径至今没有真机验证**，
> 测试里会明确打印 `SKIP sampleMaskExt (EXT feature structs are not chainable yet)`。
> 要真正验证它，得先做扩展特性链（见下一步）。


### 第 20 批（517 → 510，**净 -7**）：指针成员政策重放 + 1.4 收尾 5 条 + 1.3 feature 面补完

**审查发现一个静默数据损坏**：结构体成员解析没记录 `const`，`member_skip` 把
`const void* pData`（`VkPushConstantsInfoKHR::pValues`、`VkDebugUtilsObjectTagInfoEXT::pTag`…）
当成"可安全留 NULL 的 pUserData"，**已经插入的 14 条命令在运行期会把 NULL 当数据指针交给驱动，
或让驱动往 NULL 写**（`VkCheckpointDataNV::pCheckpointMarker`、`VkHostAddressRangeEXT::address` 是
out 方向的写目标，非 const 也一样）。这类错误编译器不报（void* 本来就是指针），只有验证层/崩溃才会暴露。

**指针成员新政策（生成器强制）**：

| 方向 | 允许留 NULL 的指针成员 | 其余指针成员 |
|---|---|---|
| 输入 | `pNext`、字面量 `pUserData` | **拒绝**（需要字节缓冲区通道，见下一步 2） |
| 输出 | `pNext` | **拒绝**（全是驱动写目标） |

按此政策重放扩展批次（17/18 两批合并为 265 条，剔除 14 条坏命令），
新单批插入器在写入前还会检查"每个被调用的 helper 都有定义"。

**同批新增**：

| 项 | 内容 |
|---|---|
| 1.4 core 5 条（19 批） | `vkCmdBindIndexBuffer2`、`vkCmdSetLineStipple`、`vkTransitionImageLayout`、`vkUnmapMemory2`、`vkGetImageSubresourceLayout2` —— 生成器新增 `--commands` 点名模式（core 晋升缺口不在扩展 todo 集里） |
| Inline Uniform Blocks | `VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK`(1000138000) 常量 + `VKInlineUniformBlockProperties` 访问类（5 个上限字段）+ `VKPhysicalDevice.getInlineUniformBlockProperties()` |
| Subgroup Size Control | `VKSubgroupSizeControlProperties` 访问类（4 字段）+ `VKPhysicalDevice.getSubgroupSizeControlProperties()` |
| **管线 pNext** | graphics：`VKGraphicsPipelineInfo.vertex/fragmentRequiredSubgroupSize` → state 尾部可选 2 int → C++ 给两个 stage 各挂 `VkPipelineShaderStageRequiredSubgroupSizeCreateInfo`；compute：`createComputePipeline(..., requiredSubgroupSize)`（CFFI 加 1 int，13 段同步） |
| smoke | `checkInlineUniformBlocks`（查询 + feature 开启时用新常量建 layout，descriptorCount=块字节数的特殊语义）、`checkSubgroupSizeControl`（范围断言）；quad 管线在 feature 开启时把顶点 stage **真实 pin** 到 `minSubgroupSize` |
| 特性请求 | `Main.buildFeatureRequests()` 追加 word 1（inlineUniformBlock→42）与 word 7（subgroupSizeControl→48） |

**验证**：7 道门禁（退出码）全 0 —— `vk_callsites`/`vk_haxecheck` 首次**零告警**
（过期副本 `vulkan - 副本/` 与 `VulkanRenderContext - 副本.hx` 已按既定方案移入 `.workbuddy/backup/stale-copies/`）。

> `lime_vk_*` = **559**；1.0–1.4 = **全部 100%**，扩展独有 300/377 = 79.6%。

---

## 3. 当前实现进度 vs 各 Vulkan 正式版

> 口径：可调用函数面（559 CFFI）+ 对象封装（82 类）。✅=已可调用、🟡=部分、❌=未做。

### 3.1 Vulkan 1.0（Core）—— 100%（137/137）

以 `vk.xml` 的 `VK_VERSION_1_0` 特性块（解析 `depends` 链）为基准。所有大类全 ✅：Instance/Device/Queue/物理设备、窗口面与 Swapchain、一二级命令缓冲、RenderPass/Subpass、图形与计算管线、Buffer/BufferView/Image/ImageView/Sampler、内存与上传环、同步全家、Query Pool、Copy/Resolve/Update/Fill、动态状态、间接绘制、稀疏资源、扩展与层枚举、描述符池。

**3 条命令并入更大封装不单建入口**：`vkEnumeratePhysicalDevices`→`lime_vk_get_physical_devices`；`vkGetPhysicalDeviceProperties`/`vkGetPhysicalDeviceQueueFamilyProperties`→`VKPhysicalDevice` 字段；`vkGetInstanceProcAddr`/`vkGetDeviceProcAddr` 由 window 层承接。

### 3.2 Vulkan 1.1 —— 100%（165/165）

| 功能 | 状态 |
|---|---|
| Features2/Properties2/MemoryProperties2/QueueFamilyProperties2/FormatProperties2/ImageFormatProperties2/SparseImageFormatProperties2 | ✅ |
| BindBufferMemory2/ImageMemory2、GetBuffer/ImageMemoryRequirements2、GetImageSparseMemoryRequirements2 | ✅ |
| GetDeviceQueue2、GetDescriptorSetLayoutSupport、TrimCommandPool、CmdDispatchBase | ✅ |
| GetPhysicalDeviceExternalBuffer/Fence/SemaphoreProperties | ✅ |
| Create/DestroySamplerYcbcrConversion | ✅ |
| Create/DestroyDescriptorUpdateTemplate、UpdateDescriptorSetWithTemplate | ✅ |
| EnumerateInstanceVersion | ✅ |
| Device Groups | ✅ |
| Protected Memory / Multi-View / Subgroups | 🟡 feature 层可经 Features2 查询；专用创建路径未做 |
| Maintenance1 | ✅ | `trimCommandPool`（1.1 core），真机已 PASS |
| Maintenance2 | n/a | 无新命令，仅输入附件行为约定 |
| Maintenance3 | ✅ | `getDescriptorSetLayoutSupport` + `VKMaintenance3Properties`（maxPerSetDescriptors / maxMemoryAllocationSize） |

### 3.3 Vulkan 1.2 —— 100%（178/178）

| 功能 | 状态 |
|---|---|
| Timeline Semaphore | ✅ 命令 + 属性 |
| Buffer Device Address | ✅ `getBufferDeviceAddress` + opaque capture + feature 查询 |
| Draw Indirect Count | ✅ `cmdDrawIndirectCount` / `cmdDrawIndexedIndirectCount` |
| Descriptor Indexing | ✅ feature 查询 + 上限查询 + 布局预校验（variable count / update-after-bind 便捷封装仍可加） |
| Host Query Reset | ✅ |
| RenderPass2 家族 | ✅ |
| Imageless Framebuffer | 🟡 feature 可查；创建路径仍走 1.0 |
| Separate Depth/Stencil Layouts | 🟡 feature 可查 + 布局常量已加；创建路径走 1.0 |
| 1.2 属性全覆盖 | ✅ `getVulkan12Properties` 55 字段 |

### 3.4 Vulkan 1.3 —— **100%（215/215）**

| 功能 | 状态 | 说明 |
|---|---|---|
| Dynamic Rendering | ✅ | vkCmdBeginRendering/EndRendering |
| Synchronization2 | ✅ | barrier2 + `WriteTimestamp2` + `QueueSubmit2` / `Set/Reset/WaitEvents2` 全部到位（16批） |
| Copy/Blit/Resolve Image2 家族 | ✅ | 六条 `*2` 拷贝全通（15批，**无 feature bit**） |
| Extended Dynamic State 1 | ✅ | 14 条 setter（12批）；EDS 2/3 仍缺 |
| Private Data | ✅ | `vkCreate/DestroyPrivateDataSlot`、`vkSet/GetPrivateData`（需 `privateData`，14批） |
| Tool Properties | ✅ | `vkGetPhysicalDeviceToolProperties`（14批，无特性依赖） |
| BindVertexBuffers2 | ✅ | `vkCmdBindVertexBuffers2`（14批，`VK_WHOLE_SIZE` 语义） |
| Maintenance4 | ✅ | `vkGetDevice{Buffer,Image,ImageSparse}MemoryRequirements`（16批，需 `maintenance4`） |
| Inline Uniform Blocks | ✅ | `VK.DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK` 常量 + `VKInlineUniformBlockProperties` 访问类（20 批）；smoke 建 layout 验证 |
| Demote-to-Helper / Shader Terminate | ✅ | 纯 feature（46/47），可查询 + 可请求 |
| Subgroup Size Control | ✅ | `VKSubgroupSizeControlProperties` 访问类 + 管线 `pNext` 挂载（graphics `info.vertex/fragmentRequiredSubgroupSize`、compute `createComputePipeline(..., requiredSubgroupSize)`，20 批）；smoke 在 quad 管线上真实 pin |
| 4444 / YCbCr 2plane444 / ASTC HDR 格式位 | ✅ | `VkFormat` **全量暴露：370 个 `VK.FORMAT_*`**（`vk_gen_format_constants.py` 从头文件生成，含 ASTC 269 族与各 `*_EXT` 别名） |

### 3.5 Vulkan 1.4 及扩展体系（口径：`vk.xml` 实测，2026-09-18）

**1.4 core：234/234 = 100%**（19–22 批补入全部 19 条 1.4 独有命令；22 批的**二级数组通道**吃掉最后 12 条：
push descriptor 家族、host image copy 3 条、`vkMapMemory2`、`vkCmdBindDescriptorSets2`、rendering attachment /
input-attachment indices、`vkGetDeviceImageSubresourceLayout`、`vkGetRenderingAreaGranularity`）。
另需接 **1.4 特性链**（`VkPhysicalDeviceVulkan14Features`，`DEVICE_FEATURE_*` 需从 56 起续）才能合法调用需特性位的命令。

**扩展体系**（generic 口径，排除冷门厂商）：扩展独有命令 **377** 条，已实现 **300 = 79.6%**（21 批 `const void*` +4、23 批二级数组 +31），
主动拒绝 **77** 条（54 嵌套结构体成员 / 17 `void*` 写目标 / 4 参数超限 / 2 其它）。

| 梯队 | 扩展独有命令 |
|---|---|
| A 调试（debug_utils / debug_marker / device_fault） | 6 |
| B Extended Dynamic State 2/3 + shader_object | 39 |
| B descriptor_buffer / descriptor_heap / inline_uniform / mutable_descriptor | 21 |
| C ray tracing + opacity_micromap | 37 |
| C mesh shader | 6 |
| C video（queue/decode/encode/maintenance） | 16 |
| C transform_feedback + device_generated_commands | 21 |
| C maintenance6/7 | 2 |
| **其余（厂商专有 NV/ARM/AMD/… + 小众 KHR）** | **287** |
| **合计** | **435** |

按现有流水线（7–15 条/批）估算：A+B+C ≈ **148 条 → 约 12–18 批**；
全量 435 条约 35–45 批，且厂商专有那 287 条大多**无硬件可验证**、收益低。

---

## 4. 结论与优先级建议

| 版本 | 现状 | 定位 |
|---|---|---|
| **1.0 / 1.1 / 1.2** | **✅ 全部 100% + 真机 smoke test 全绿** | **达成目标** |
| **1.3** | **✅ 100%（215/215）** | **与 1.0/1.1/1.2 同级达成** |
| 1.4 | 🟡 94.0%（220/234） | 差 14 条（需字节通道/二级数组） |
| 扩展独有命令 | 🟡 265/377 = 70.3% | 已含 debug_utils / RT / mesh 等 |

**下一步建议顺序**：

1. **扩展特性链（解锁 159 条）**：`createDeviceWithFeatures` 只能请求 core 特性
   （`DEVICE_FEATURE_*` 1–55）。加"按 sType 请求任意 `Vk*Features*` 结构体"的能力后，
   159 条需特性位的扩展命令（含 `vkCmdSetSampleMaskEXT` 的真机验证）才能合法调用。
2. **扩展命令剩 108 条**：87 条"结构体里的二级数组"（长度在结构体内部）、
   16 条字节缓冲区（无长度链接 / 数组形态 / 输出方向，21 批通道后剩余）、3 条参数超限、2 条其它。
3. **1.4 收尾 12 条**：与上面两条规则同源（push descriptor 余 2 / host image copy 4 / `vkMapMemory2` 等），
   另需接 `VkPhysicalDeviceVulkan14Features` 特性链（id 56 起）。
4. **真机验证待跑项**：批 21 的 6 条新命令（建议 smoke 加 `byteBuffers` 检查：
   `vkSetDebugUtilsObjectTagEXT` 打个 tag + `vkCmdPushConstants2` 与既有 push constants 对照）。
5. **EDS 2/3 + Shader Object**（B 梯队 39 条）：动态状态的另一半。
6. **`pipelineBarrier2` 等的 64 位掩码**：现用 `Int` 只能表达低 32 位；改 `Int64` 需动 CFFI 签名。

**2D 渲染落地推荐路径**：

```haxe
// 1. 探测能力
var features = physicalDevice.getFeatures2 ([
    VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES,
    VKStructureType.PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES,
    VKStructureType.PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES,
]);
var indexing = VKPhysicalDeviceDescriptorIndexingFeatures.fromWords (
    features.get (VKStructureType.PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES));

// 2. 查上限，创建前先校验
var limits = physicalDevice.getDescriptorIndexingProperties ();
var support = device.isDescriptorSetLayoutSupported (bindlessBindings, 0);

// 3. 拿 GPU 地址做 bindless
var address = device.getBufferDeviceAddress (vertexBuffer);

// 4. GPU 侧决定画多少
commandBuffer.drawIndexedIndirectCount (drawBuffer, Int64.ofInt(0), countBuffer, Int64.ofInt(0), maxDraws, 20);
```

---

*参考：Lime 8.4.0-preview 源码（`VK.hx` / `VK*.hx` / `NativeCFFI.hx` / `ExternalInterface.cpp` / `VKRenderer.cpp`）、`C:\VulkanSDK\1.4.357.0\share\vulkan\registry\vk.xml`（权威函数清单）、`vulkan_core.h`（结构体与常量权威来源）。*

### 第 22 批（516 → 528）：**二级数组通道 —— 1.4 补至 100%**

`_structs` 此前根本没解析成员 `len` 属性（所有二级数组命令因此被拒）。补上后新通道：

- **结构体成员的 const 指针数组**（`pRegions`/`pDescriptorSets`/`pDynamicOffsets`/`pColorAttachmentLocations`…，
  `len` 指向兄弟 count 成员）→ 独立 flat-list CFFI 参数，C++ 解码进 `std::vector`、把成员指过去、
  并把 count 成员**推导覆写**（Haxe 无需传它）。
- **元素内的指针数组**（`VkWriteDescriptorSet::pImageInfo` 等，len 指向元素自身 count）→ 一个共享参数，
  元素循环里按 `descriptorCount` **逐元素切分**（`split_by`）。
- **元素内的 `void*` 成员**（`VkMemoryToImageCopy::pHostPointer`，输入与输出方向都支持）→ 扁平列表里
  2 槽**字节偏移** + 一个基址 `Bytes` 参数，C++ 填 `base + offset`（驱动直接读写 Haxe 的 Bytes 内存）。
- **`void**` 输出地址**（`vkMapMemory2`）→ 复用 out_scalar slots=2：局部 `void*` 接住、outData 拆 64 位返回。
- **模板驱动 `const void*`**（`vkCmdPushDescriptorSetWithTemplate`，无长度链接）→ 只传指针，读取范围由
  descriptorUpdateTemplate 布局决定（与既有手写绑定同用法）。

入批 12 条 = 1.4 剩余全部：BindDescriptorSets2、PushDescriptorSet（15 参数顶格）、PushDescriptorSet2、
PushDescriptorSetWithTemplate、SetRenderingAttachmentLocations、SetRenderingInputAttachmentIndices、
CopyImageToImage、CopyImageToMemory、CopyMemoryToImage、GetDeviceImageSubresourceLayout、
GetRenderingAreaGranularity、MapMemory2。

防御两处：① 命令参数形态的结构体数组若元素含"无法参数化"的成员 → 仍拒绝（防静默 NULL，14 条坏命令同源）；
② SDK 1.4.357 的 vk.xml 把 `vkCreateSwapchainKHR`/`vkCreateSharedSwapchainsKHR` 的 `pCreateInfo`/`pCreateInfos`
**参数重复了两次**（上游笔误，规范为单份）—— 解析层按参数名去重保首，否则 CFFI 签名重名。

### 第 23 批（528 → 559）：**二级数组通道收割扩展 31 条**

同一通道对扩展独有命令生效：swapchain 创建 2 条、descriptor set 更新族、tooling/query 族等 31 条入批
（`vkCreateSwapchainKHR`/`vkCreateSharedSwapchainsKHR` 首次可生成）。剩 77 条拒因：54 嵌套结构体成员
（如 acceleration structure build 几何族）、17 `void*` 输出写目标、4 参数超限、2 其它。

> `lime_vk_*` = **559**；1.0–1.4 = **全部 100%**，扩展独有 300/377 = 79.6%。
> 真机：`mapMemory2` PASS（void** 输出通道）；`swapchainCreate` 通道验证通过 —— 驱动返回
> `VK_ERROR_NATIVE_WINDOW_IN_USE_KHR`（引擎 swapchain 占用窗口，Windows WSI 同 HWND 单 swapchain 限制），
> 创建请求以良好格式到达驱动层 = flat-list / 二级数组 / out 句柄三通道端到端可用。批 22/23 其余命令待专项 smoke。

### 2026-09-22：smoke 全绿（Validation Error 10 → 0）+ 画面动起来

**原生层**
- `lime_vk_upload_memory` / `lime_vk_download_memory`：改为**整块映射**（`vkMapMemory(..., 0, VK_WHOLE_SIZE, ...)`），
  memcpy 自己加调用者 offset；flush/invalidate 的 `VkMappedMemoryRange` 用 `offset=0 / size=VK_WHOLE_SIZE`
  —— 「`VK_WHOLE_SIZE` 的终点是当前映射末尾」这条规范语义是 01390/01389 的根因。
  映射整块后失去隐式边界检查，改在 Haxe 侧 `VKDeviceMemory.upload/download` 按 `size` 校验。
  （`vkGetDeviceMemoryCommitment` 只对 lazily allocated 内存合法，不能拿来做这件事。）
- `lime_vk_set_debug_utils_object_tag_ext`：flat list 由 **5 槽/结构体 → 7 槽**，补上从未赋值的
  `VkDebugUtilsObjectTagInfoEXT::tagSize`（此前恒为 0，`byteBuffers` 是"假 PASS"）。
- **特性表第 56 号**：`DEVICE_FEATURE_SPARSE_RESIDENCY_IMAGE_2D`（`VK.hx` 常量 +
  `VulkanDeviceFeatureName` + `ApplyVulkanDeviceFeature` 三处同步）；设备不支持时不请求。

**smoke**
- present 信号量改为 **per-swapchain-image 数组**（单一信号量在连续帧下触发
  `VUID-vkQueueSubmit-pSignalSemaphores-00067`）。
- `render()` 连续渲染 **180 帧**后才 finished（原来首帧就退，旋转看不出），deviceAlive 探针 gate 到首帧。
- 修掉测试数据：discard rect 负偏移、`pSizes=VK_WHOLE_SIZE`（需 maintenance5）→ 传真实 size、
  descriptor pool 补 `FREE_DESCRIPTOR_SET_BIT`、tag size 按 high/low 写；`bindSparse` 在
  未启用 `sparseResidencyImage2D` 的设备上**诚实 SKIP**。

**结果**：`Validation Error = 0`，FAIL 0，PASS 37；`render-to-image` PASS（clear 色 + quad 采样像素），
gpuProbe/isoFill 证明 GPU 真实执行。构建：`lime rebuild windows -64` → `ndll/Windows64/`（x64 LIB）。

### 2026-09-22（续）：smoke 加严 —— 时长压力 + resize 往返 + 退出码门禁

- smoke 由"180 帧动画"改为**时长驱动**（默认 60s；`LIME_VK_SMOKE_SECONDS` / `LIME_VK_SMOKE_QUICK=1` 可覆盖），
  期间每 2s 切换窗口尺寸（320x240 … 1600x900，共 **20 次**），强制 swapchain 反复重建。
- 新增运行期设备存活检查（每 30 帧一次空提交 + fence），设备丢失立刻失败，不再被帧循环掩盖。
- 结束输出一行可 grep 的 summary；新增门禁脚本 `.workbuddy/scripts/vk_smoke_gate.py`
  （判 Validation Error=0 / 无 FAIL / PASS≥30 / render-to-image / summary / resizes 与 recreations），**退出码即结论**。
- 探针从"每帧"降频到"每 30 帧"后，帧率由 ~2.5fps 回到 **~60fps**，时长门禁才有意义。

**基准结果**：`seconds=60 frames=3591 resizes=20 recreations=40 runtimeProbeFailures=0`，
**Validation Error = 0 / FAIL = 0 / PASS = 37 / GATE: PASS**。
