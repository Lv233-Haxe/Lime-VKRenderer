# Lime Vulkan 后端：开发细节与注意项

> 架构要点、CFFI 绑定约束、校验工具链与运行期排查要点。**改代码前先读本文。**
> 批次进展与覆盖率见 [vulkan-progress.md](vulkan-progress.md)。

---

## 1. 后端架构

### 1.1 四区段 CFFI 绑定（`NativeCFFI.hx`）

多目标分段文件，每个 Vulkan 函数必须**四段齐全**才在对应目标生效：

| 区段 | 守卫 | 适用目标 |
|---|---|---|
| `@:cffi` 签名区 | `#if lime_vulkan` | 文档/工具链（纯声明） |
| `cpp.Callable` 段 | `#if cpp` | **cpp（Win/Linux/Android）** —— 实际生效的那个 |
| `CFFI.load` 段 | `#if neko` | neko |
| `hlNative` 段 | `#if hl` | HashLink |

`ExternalInterface.cpp` 对应三处：

| 区段 | 说明 |
|---|---|
| 真实实现区 | 每函数一对（neko `value` 版 + `HL_PRIM hl_vk_xxx` 版） |
| 兜底桩区 | `#else` 内用 `LimeVulkanUnavailableValue/Void/Bool/Array()` |
| 注册区 | `DEFINE_PRIME*n` + `DEFINE_HL_PRIM (...)` |

- **教训**：只改 `@:cffi` 段在 cpp 构建下完全不生效（报 `has no field`）。必须四段同步补齐。
- **注册区不受 `#ifdef LIME_VULKAN` 保护**，且实现与桩二选一 → **新增函数必须同时写实现和桩**，否则关 Vulkan 的构建会链接失败。
- **平台门控**：`#ifdef LIME_VULKAN → #else → #endif` 包住整批新式实现+桩；其前的函数是逐函数守卫（旧式）。新增走新式。

### 1.2 `cpp.Callable` 签名串规则

`cpp.Prime._loadPrime("lime", name, "<sig>")` 的签名串与 C++ neko 风格函数
（`bool/value/void/int lime_vk_xxx(value window, <params>)`）一一对应；**运行期按串做 `CheckSig`，任一字符不符即 `does not have signature` 并返回空指针。**

**签名串 = 按参数顺序各字符 + 返回字符。** 不要假定首字符必为 `o`（`o` 对应每个 `value` 参数：window / state 数组 / bytes / 句柄）。

| 逻辑类型 | C++ 形参（neko / HL） | 字符 | Haxe 类型 |
|---|---|---|---|
| `value`（数组） | `value` / `hl_varray*` | `o` | `Array<Dynamic>` |
| `bytes` | `value` / `Bytes*` | `o` | `Bytes` |
| `int` | `int` / `int` | `i` | `Int` |
| `bool` | `bool` / `bool` | `b` | `Bool` |
| `double` | `double` / `double` | `d` | `Float` |
| `HxString` | `HxString` / `hl_vstring*` | `s` | `String` |
| 返回 `value` | `value` / `vdynamic*` | `o` | `Dynamic` |
| 返回 `bool` | `bool` | `b` | `Bool` |
| 返回 `void` | `void` | `v` | `Void` |
| 返回 `int` | `int` | `i` | `Int` |

- 签名串须与 `cpp.Callable` 泛型**逐项一致**（`cpp.Object→o、Int→i、String→s、Float→d、Void→''、Bool→b`）。
- **参数上限 16**：`DEFINE_PRIME` 只定义到 `DEFINE_PRIME16`。超出须把一组 `Int` 打包成 `value state` 数组（沿用 `cmd_copy_buffer_to_image_region` / `cmd_wait_events` / `create_render_pass` 风格）。
- **四类高频笔误（勿人工数 `i`，用脚本校验）**：
  1. 返回类型不一致：C++ 声明 `value` 但签名串返回位写 `b`。
  2. `i` 个数错。
  3. 数组 `o` 位置错。
  4. HL 返回类型错配：返回 `hl_varray*` 的桩若写 `HLLimeVulkanUnavailableValue ()`，因 `vdynamic*→hl_varray*` 无法隐式转换而编译失败，数组返回须用 `HLLimeVulkanUnavailableArray ()`。

### 1.3 C++ 原生侧与关键约束

- **动态加载**：全部 PFN 经 `GetManagedVulkanDeviceProc(window, instance, device, "vkXxx")`（设备级）或 `vkGetInstanceProcAddr(instance, "vkXxx")`（实例级）从 SDL_vulkan 取，**不静态链 libvulkan**。
- **实例级函数的 `vkGetInstanceProcAddr` 由公共头部统一声明**，函数体内不要再写（重复声明=编译错）；设备级（`hdr="dev"`）不需要。生成器已在 `build_header` 加 scope 分支。

**⚠️ 可选设备特性默认全部关闭**：`CreateManagedVulkanDevice` 的 `pEnabledFeatures` 指向全零 `VkPhysicalDeviceFeatures` 且 `pNext` 从不设置 → `samplerAnisotropy`、`sparseBinding`、`timelineSemaphore`、`bufferDeviceAddress`、`drawIndirectCount`、`descriptorIndexing`、`hostQueryReset`、`samplerYcbcrConversion` 等**全部不生效**。对应 API 要么返回 `VK_ERROR_FEATURE_NOT_PRESENT`，要么无效使用。所以 `createTimelineSemaphore` / `getBufferDeviceAddress` / `cmdDrawIndirectCount` / `bindSparse` 等 **必须先经 `VKPhysicalDevice.createDeviceWithFeatures` 显式开启**。

- `createDevice(queueFamily, extensions)` 保持原语义（不开可选特性）。
- `createDeviceWithFeatures(queueFamily, extensions, features)` 接 `VK.DEVICE_FEATURE_*` id 列表，先经 `vkGetPhysicalDeviceFeatures2` 校验；**不支持的项会被裁剪并跳过（不中止设备创建）**，见 §4.4。
- id 17–40 需 1.2 设备（`Vulkan11/12Features` 是 1.2 promoted 结构体）；**id 41–55 是 1.3 特性**（`VkPhysicalDeviceVulkan13Features`），需 1.3 设备。
  各段 id 段按结构体的 `VkBool32` 声明顺序编号（1.0→1–16、1.1→17–22、1.2→23–40、1.3→41–55），
  加新特性时**照着 `vulkan_core.h` 的字段顺序往下排**即可。
- `allocateMemory` 无法设 `VkMemoryAllocateFlags` → **BDA 必须用 `allocateMemoryEx`**（带 `VK.MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT`）。

**⚠️ 不静态链 libvulkan → 每个函数体须先声明局部 PFN 变量**，否则裸调用解析到 `vulkan_core.h` 全局符号，链接期报未解析外部符号：

```
error LNK2019: 无法解析的外部符号 _vkGetInstanceProcAddr@8
fatal error LNK1120: 1 个无法解析的外部命令
```

🔴 **`LNK1120` 数字是未解析符号的"种数"非引用者数**：别只修报错点名的函数——用 `vk_validate.py` 第 8 项一次找全。

**HL 侧对象构造约定**：

| 场景 | neko | HashLink |
|---|---|---|
| 建空对象 | `alloc_empty_object ()` | `(vdynamic*)hl_alloc_dynobj ()` |
| 写 int 字段 | `alloc_field (o, val_id ("k"), alloc_int (v))` | `hl_dyn_seti (o, hl_hash_utf8 ("k"), &hlt_i32, v)` |
| 写 bool 字段 | `alloc_field (o, val_id ("k"), alloc_bool (v))` | `hl_dyn_seti (o, hl_hash_utf8 ("k"), &hlt_bool, v)` |
| 写嵌套对象 | `alloc_field (o, val_id ("k"), child)` | `hl_dyn_setp (o, id, &hlt_dynobj, child)` |
| 写字符串 | `alloc_string (s)` | `hl_dyn_setp (o, id, &hlt_bytes, hl_copy_bytes ((const vbyte*)s, (int)std::strlen (s) + 1))` |
| 建数组 | `alloc_array (n)` + `val_array_set_i` | `(hl_varray*)hl_alloc_array (&hlt_dynobj, n)` + `hl_aptr (a, vdynamic*)` |
| 建 int 数组 | `alloc_array (n)` + `alloc_int` | `(hl_varray*)hl_alloc_array (&hlt_i32, n)` + `hl_aptr (a, int)` |
| 写数组字段 | `alloc_field (o, val_id ("k"), arr)` | `hl_dyn_setp (o, id, &hlt_array, arr)` |
| 读句柄字段 | `val_int (val_field (e, val_id ("high")))` | `hl_dyn_geti (e, hl_hash_utf8 ("high"), &hlt_i32)` |

**可复用读数组 helper**：`Get%%H%%VulkanIntVector`（`Array<Int>`→`vector<int>`，`%%H%%`=neko 空/HL`"HL"`）、`GetVulkanDoubleVector`、`%%H%%GetVulkanBytesLength`/`%%H%%GetVulkanBytesPointer`。

**⚠️ hxcpp 的 NEKO_COMPATIBLE CFFI 没有 `alloc_double` / `alloc_float`**（`hx/CFFI.h` 仅 `alloc_int/bool/string/null/field/array/empty_object`）。浮点传出用 `VulkanFloatCString (double)` 转十进制文本，Haxe 侧 `Std.parseFloat` 还原。**不要 `alloc_double`，也不要退化成整数。**

### 1.4 平台门控

- 原生 `LIME_VULKAN` = `windows || linux || android`（`project/Build.xml`）。
- Haxe `lime-vulkan` define 仅 `cpp windows / cpp linux`（`include.xml`）→ **Android 上对象 API 默认失效**，macOS 未纳入构建。
- 需 Vulkan SDK：`VULKAN_SDK` 指向 `<SDK>\Include`；本机实测 `C:\VulkanSDK\1.4.357.0`。

---

## 2. 校验脚本工具链

不编译也能验证绑定正确性。脚本位于 `.workbuddy/scripts/`（纯 stdlib，用托管 Python）：
```bash
PY="C:/Users/Administrator/.workbuddy/binaries/python/versions/3.13.12/python.exe"
```

| # | 脚本 | 校验内容 |
|---|---|---|
| 1 | `vk_validate.py` | 四区段 + C++ 三处完整性、签名串一致性、链接安全、helper 名存在性、void 命令不可当值用、重复定义、**指针形状参数不得按值传**（**12 个检查面**，全部计入退出码） |
| 2 | `vk_gap.py` | Vulkan 1.0/1.1/1.2/1.3 覆盖率（读 SDK 的 `vk.xml` 作权威清单） |
| 3 | `vk_callsites.py` | Haxe 调用点 ↔ `@:cffi` 声明参数个数一致性 |
| 4 | `vk_fieldcheck.py` | C++ 返回对象 key ↔ Haxe 类字段名交叉校验 |
| 5 | `vk_haxecheck.py` | Haxe 编译期错误静态检查（**8 项**：含 `Int64` 与 null 误用） |
| 6 | `vk_fix_static_field_access.py` | static 函数内裸实例字段访问，作用域感知（`--apply` 可重写，`--dirs` 含 tests） |
| 7 | `pp_structure.py` | `ExternalInterface.cpp` 预处理嵌套结构 |
| 8 | `vk_encoding.py` | C/C++ 源文件编码：含非 ASCII 字节者必须有 UTF-8 BOM |
| 9 | `vk_ffi_side_check.py` | neko/HL 双侧 API 混用 |
| — | `vk_gen_features.py` / `vk_gen_properties.py` | 从头文件重新生成 sType 常量 / 特性结构体表 / 特性访问类 |
| — | `vk_gen_object_type.py` / `vk_gen_format_constants.py` | 从 `vulkan_core.h` 全量导出 `VKObjectType` / `VkFormat` 常量（**枚举数值一律脚本抽，不手抄**） |
| — | `vk_selfcheck.py` | **插入前**对生成的 `vk_batchN.py` 做结构自检（占位符、括号、声明顺序、实参作用域、参数类型/数量、`kind=array` 返回路径） |
| — | `vk_restore_presplice.py` | 从 `vk_splice.py` 自动写出的 `.workbuddy/backup/pre-splice/` 快照回滚两个目标文件（比从生成文本反推可靠） |
| — | `vk_fix_count_clamp.py` / `vk_fix_batch17_module.py` | 就地修复"多个数组共用 count 导致重复声明"，cpp 与批次模块各一份 |
| — | `vk_splice_batch.py` | **只插一个批次**（把其它批次临时改名 + 清空内置 FUNCS/HELPERS 的生成器副本）；剥离重复桩 helper、**跳过目标里已有的 helper 定义**、插入前检查『每个被调用的 helper 都有定义』、给 impl 段打标签 |
| — | `vk_drop_functions.py` | 按名从两个目标删掉一批函数（impl 段按 offset 整块删，其余七段按名 + 语句边界删），**并校验六段计数仍然一致** |
| — | `vk_regen_batch.py` | 用当前生成器重放既有批次模块（自动剔除不再适用的命令），**并保留批次自带的 helper 文本**；文本丢失时从生成器恢复并告警 |

**`vk_validate.py` 的 12 个检查面**（退出码 = 任一面有问题即非 0）：① `@:cffi` 声明存在 ② `_loadPrime`/`cpp.Callable` 存在 ③ `@:hlNative` 占位存在 ④ C++ neko 实现存在 ⑤ C++ `HL_PRIM` 实现存在 ⑥ `DEFINE_PRIME*n` 注册存在且**参数个数与 C++ 形参一致** ⑦ `DEFINE_HL_PRIM` 注册存在 ⑧ **链接安全**：函数体内每个 `vkXxx(...)` 都能解析到局部 `PFN_vkXxx vkXxx = ...` 变量。
⑨ **helper 存在性**：函数体内调用的 Lime helper（`(HL)?(Create|Get|Read|Fill|Combine|Normalize|Encode|Decode|Copy|Alloc)*`）
必须在 cpp 里找得到定义 —— 拦截 `CreateHLVulkanXxx` 这类命名笔误（MSVC C3861）。
helper 命名**不对称**：`GetHLVulkan*Vector`（HL 中缀）vs `HLCreateVulkan*Value`（HL 前缀）。
⑩ **PFN 返回值用法**：从 `vulkan_core.h` 的 `typedef <ret> (VKAPI_PTR *PFN_vkXxx)` 抽返回类型，
凡 `void` 命令被当值用（`= vkXxx(` / `return vkXxx(` / `!vkXxx(`）即报 **C2440** 风险。
784 个 PFN 里 480 个返回 void —— 靠记忆分辨不了（`vkEnumerate*` 是 `VkResult`，
maintenance4 的 `vkGetDevice*MemoryRequirements` 是 `void`）。头文件缺失时报 SKIP，不假绿。

⑫ **指针形状参数**：CFFI 参数里类型为 `int` 而名字形如 `p[A-Z]`（`pSampleMask`）即报 `C2664` 风险。
   指针被按值传的指纹 —— 965 个生成定义中**零合法反例**，所以这条命名约定可安全强制。
   第 19 批 `vkCmdSetSampleMaskEXT` 就是靠它（事后）定位的。

⑪ **重复定义**：同名字 + 同形参 + **同预处理分支路径**出现两次即报 `C2084`。
   用分支路径而不是只比名字，才能同时容许 `#ifdef LIME_VULKAN` / `#else` 成对重名与
   C++ 重载（`LogVulkanNativeBootstrap`）。加这一面的原因是第 17 批曾把
   `HLLimeVulkanUnavailableArray` 留了两份在同一个 `#else` 区里 —— 直到编译才会发现。

**追加新函数推荐流程**：

```bash
$PY .workbuddy/scripts/vk_restore_baseline.py        # 0) 留批前回滚点（精确移除本批 8 个块）
# 1) 新建 vk_batchN.py（导出 FUNCS + EXTRA_HELPERS），再：
$PY .workbuddy/scripts/vk_gen.py                     #    生成 8 个待插入片段（vk_gen 自动加载所有 vk_batch*.py）
$PY .workbuddy/scripts/vk_splice.py                  #    先校验 8 锚点唯一，再落盘
# 2) 九道校验全过（见上表 #1–#9）
```

> 生成器输出**全部**批次片段，故改了任一既有批次内容后，必须 `vk_restore_baseline.py` → 回滚 → 一次性重放，否则重复插入。

#### 基线无法回滚时的替身流程（`vk_restore_baseline.py` 报 MISS）

impl 片段被后续批次手工改过 → 与配套 needle 不再一致 ⇒ 无法精确移除。此时：

```bash
# 1) 把已插入的批次模块改名为 .py.spliced，脱离 vk_gen 的 vk_batch*.py glob
# 2) 复制生成器，并把内置 FUNCS 与 HELPERS 一起清空（只清 FUNCS → helper 段重复插入，编译报几十条重定义）
$PY - <<'PY'   # 示例：vk_gen_b14.py
src = open('vk_gen.py', encoding='utf-8').read()
start, end = src.index('FUNCS = ['), src.index('# optional extra batches')
src = src[:start] + 'FUNCS = []' + src[src.rindex(']', start, end)+1:]
hs = src.index('HELPERS = r"""'); src = src[:hs] + 'HELPERS = ""' + src[src.index('"""', hs+13)+3:]
open('vk_gen_b14.py','w',encoding='utf-8',newline='\n').write(src)
PY
$PY vk_gen_b14.py        # 只输出新批次片段
# 3) 删掉 cpp_stub.txt 开头自带的 HLLimeVulkanUnavailableArray 定义（cpp 里已存在一份，
#    不剥离就会编译报重定义）；同理 cpp_impl.txt 里的 helper 段若已存在也别再插一次
$PY vk_splice.py
# 4) 恢复批次模块名、删掉生成器副本
```


#### 用 vk.xml 生成扩展批次的两条纪律（第 18 批教训）

**① 新批次必须排除既有批次已覆盖的命令。** 生成器按"扩展全集"筛选，很容易把上一批
已经插入的命令再生成一遍 —— 结果是一次性多出 154 处重名定义，`NativeCFFI.hx` 与
cpp 的八个区段全部重复。生成时显式带上上一批：

```bash
python vk_gen_from_xml.py --extensions generic --exclude vk_batch17.py \
       --out vk_batch18.py --helpers
```

`--exclude` 会把该模块的函数名映射回 Vulkan 命令名后从待做集合里剔除。第 11 面检查
（重复定义）是这条纪律的兜底。

**② 出参命令统一返回扁平 int 列表。** 出参不再逐个造对象：

    [按参数声明顺序] 标量 1–2 int · 结构体 struct_slots int · 数组 = 1 int 长度 + N×槽位

数组容量取"调用方传入的扁平列表长度 / 每元素槽位"，驱动程序回填的 count 更小则以它为
准；只问数量就传空列表。四个由 `%%H%%` 分派的返回辅助：
`(HL)CreateVulkanIntVectorValue`（int 列表）、`VulkanIntFloat` / `VulkanFloatBits`
（float 位模式）、`(HL)GetVulkanString`（HxString → const char*）。

**③ 生成后先跑 `vk_selfcheck.py` 再 splice。** 生成器如今会输出结构体展开、数组循环、
出参回填这些带声明顺序依赖的代码，"文件生成了"不等于"能编译"。自检覆盖的六类错误
（count 重复声明、实参重复追加、`outData` 声明过晚、`index` 未声明、固定长度成员漏槽、
`kind=array` 未走 int 列表返回）都真实发生过。


#### 阅卷方式：门禁只用退出码，别用 `grep "^!!"`

第 18 批首次编译暴露了 9 处 `C2440 value → vdynamic*`，而 `vk_ffi_side_check.py` **当时就在报这 9 处** ——
收尾脚本却用 `grep -c "^!!"` 统计"问题数"，而那个脚本的问题行当时不带 `!!` 前缀，于是全部被读成 0。
"全绿"是假的，而且假了整整一轮编译。

两条规矩：

1. 所有校验脚本的问题行统一以 `!!` 开头；门禁一律 `python vk_x.py >/dev/null; echo $?`。
2. 加/改校验脚本后，**必须拿一个已知坏样本证明它会报**（负控）。第 11 面加完就是这么发现
   口径过宽（名字比对）→ 改成"名字 + 形参 + 预处理分支路径"的。

#### 平台 / 测试版扩展：编译期根本不存在，必须跳过

```python
# 平台扩展的命令声明在 #ifdef VK_USE_PLATFORM_<X>_KHR 内，
# provisional（beta）扩展的在 #ifdef VK_ENABLE_BETA_EXTENSIONS 内
if e.get("platform"):                                   continue
if (e.get("provisional") or "").lower() == "true":      continue
```

只按 `supported="vulkan"` 过滤是不够的：`VK_EXT_full_screen_exclusive`、
`VK_NV_acquire_winrt_display`、`VK_NV_cuda_kernel_launch` 都是 `supported=vulkan`，
但它们的 `PFN_vkXxx` 与结构体在本构建里**不存在** → C2065 / C2923。
本仓库共 67 条这样的命令。

#### by-value 数组（`combinerOps[2]`）是**一个**实参

展开成 N 个 CFFI int 参数是对的（调用方按元素传），但**调用时只能传一个**：
C 里数组会退化成指针。生成一个本地数组再传：

```cpp
VkFragmentShadingRateCombinerOpKHR combinerOpsValues[2] = { (…)combinerOps0, (…)combinerOps1 };
vkCmdSetFragmentShadingRateKHR (commandBuffer, sizeData.data (), combinerOpsValues);
```

#### 结构体字符串成员：是参数，但不是**实参**

`const char* pLabelName` 需要一个额外的 `HxString` 参数，但它已经写进结构体了，
**不能**出现在 Vulkan 调用里（否则 C2197 "参数太多"）。生成器里这两件事必须分开记。

#### 撤销一批已经插进去的代码

`vk_splice.py` 每次把"插入前"的两个目标写进 `.workbuddy/backup/pre-splice/`，但那只回滚到**上一次**
插入前。要撤掉更早的批次，用 `vk_drop_functions.py`：

* impl 段（banner 注释 → `#else` 锚点之间的连续块）**按 offset 整块删**；
* 其余七段按名字 + 语句边界删（`cpp.Callable` 两行、`@:hlNative` 一行或四行）；
* 删完**必须**校验六个"每函数一段"的计数彼此相等 —— 这一步抓到过一次真实的过度删除：
  某函数的参数名里带 `Callable`，而我用 `"Callable" in line` 判断分支，于是它被当成
  `cpp.Callable` 条目，"吃到 `));` 为止"的循环吞掉了后面 460 行（含锚点）。

**通用教训**：判断"这行属于哪一类"要用**匹配到的模式**，不要用行内子串。
`"Callable" in line` 与 `re.match(CALLABLE_PATTERN, line)` 在正常输入上等价，
在 `pCallableShaderBindingTable` 上不等价。

#### `vk_gap.py` 的数据源

gap 读的是 `vk-inventory.json` **快照**，不是实时扫描源码 —— 新批次插完后必须刷新一次，
否则覆盖率数字停在插入之前：

```bash
$PY vk_validate.py --json vk-inventory.json && $PY vk_gap.py --version VK_VERSION_1_3
```

---

## 3. 结构体 / 常量取值必须以头文件为准

**不要凭记忆写字段名与枚举值**，已踩过：

- 1.0 稀疏结构体叫 `VkSparseImageFormatProperties`（**非** `VkPhysicalDeviceSparseImageFormatProperties`），字段 `aspectMask`，**无** `format`。
- 1.0 的 `vkGetImageSparseMemoryRequirements` 直接收 `VkImage`，**无** `VkImageSparseMemoryRequirementsInfo`（那是 1.1 的 `...2`）。
- `VkPhysicalDeviceExternalImageFormatProperties` 已从 1.4 头文件移除（仅 NV 变体）；1.1 external 能力改经 `vkGetPhysicalDeviceExternalBufferProperties` 查询。
- 权威来源：`C:\VulkanSDK\<ver>\Include\vulkan\vulkan_core.h`。
- 查询特性位序时同样查头文件：`VkPhysicalDeviceVulkan12Features` 的 `descriptorIndexing` 是 **word 9**、`VkPhysicalDeviceVulkan13Features` 的 `dynamicRendering` 是 **word 12**。

`vk_gen_features.py` 用「去下划线归一化」匹配 sType 枚举名，避免 `16BitStorage`/`8BitStorage`/`RGBA10X6`/`Image2DViewOf3D` 数字边界猜错（规则推导 16 个失败 → 归一化查表 267/267 全中）。

---

## 4. 运行期排查要点（实战浓缩）

编译通过 ≠ 能跑。以下每条都是真机上炸过之后总结的。

### 4.1 instance 的 `apiVersion` 决定 pNext 链填不填

```cpp
// 错：三元表达式恒取 1.0，条件那一支不可达
applicationInfo.apiVersion = instanceVersion >= VK_API_VERSION_1_0 ? VK_API_VERSION_1_0 : instanceVersion;
// 对：驱动会自行 clamp 到它支持的版本
applicationInfo.apiVersion = instanceVersion;      // 来自 vkEnumerateInstanceVersion
```

instance 以 Vulkan 1.0 创建时，驱动**只填 1.0 部分**，`vkGetPhysicalDeviceFeatures2` / `Properties2`
的 pNext 链上所有 1.1+ 结构体**静默保持 memset 的 0**（不报错）。

**症状**：core 部分正确（设备名、limits、1.0 特性），但 `timelineSemaphore=false`、
`maxMemoryAllocationSize=0`——**即使在支持 1.3/1.4 的显卡上**。

### 4.2 "PFN 拿得到" ≠ "特性已开启"

1.3+ 驱动对 core 函数（如 `vkCmdBeginRendering`）**一律发 PFN**，但特性未开启时调用是
**未定义行为**——直接崩，不是返回错误。**显卡越新越容易中招。**

所有 smoke 检查必须先门控"该特性在设备创建时被请求过"，而不是"探测到支持"。

### 4.3 逐个查询优于串联 pNext 链

`vkGetPhysicalDeviceFeatures2` 一次挂多个结构体的串联写法，在部分驱动上会让
**链上后面的结构体读回全 0**。改为**每个结构体单独查询**（一次只挂一个 pNext）后正常。

### 4.4 探测与校验必须走同一条查询路径

`createDeviceWithFeatures` 内部会二次校验（`VulkanFeatureBitsSatisfied` 按 Bool32 字比对）。
若校验侧用串联、探测侧用逐个，就会出现"Haxe 说支持、C++ 说不支持"的矛盾。

**当前策略**：校验失败**不再中止设备创建**，而是
`VulkanFeatureBitsDisable` 裁剪掉不支持的位 + 打印
`feature skipped: id=N (name) unsupported words: f12[N]` + 继续。
理由：开启不支持的位是未定义行为（会崩），但因探测分歧而整个失败会让调用方**连设备都拿不到**。

**复合请求**（如 `DEVICE_FEATURE_DESCRIPTOR_INDEXING` 一次开 20 个子项位）依赖此机制：
设备不支持的子项被裁掉，其余照常启用。实测 GTX 750 Ti (Maxwell GM107) 的
`descriptorBindingUniformBufferUpdateAfterBind`（f12 word 20）就是这样被裁掉的。

### 4.5 C++ 与 Haxe 的字段粒度必须对账

**症状**：查询函数一调用就崩，连日志都没有。

**根因示例**：`VKVulkan12Properties.__load` 读嵌套的 `data.conformanceVersion.major`，
而 C++ 工厂给的是**平铺**的 `conformanceVersionMajor/Minor/Subminor/Patch`
→ `data.conformanceVersion` 为 null → **hxcpp 下访问 null 字段直接崩**。

**对账方法**：对每个 `VK*Properties` 类，交叉比对 `__load` 的 `data.X` 读取集合
vs C++ 工厂 `val_id("X")` 集合：

- 嵌套读 `data.X.Y` 必须有 C++ 提供的子对象 X（如 `limits`、`{high,low}` 句柄包装）
- 平铺读缺失 → 字段永远是 false/0（不崩但数据错）

内容：C++ 若是平铺，Haxe 也必须平铺读（或反之，两侧改一致）。
`vk_fieldcheck.py` 只查 C++ key ↔ Haxe **声明**，不查 `__load` 的**读取**，需手工或脚本对账。

### 4.6 源文件编码：含非 ASCII 必须有 UTF-8 BOM

`ExternalInterface.cpp` 无 BOM 却有中文注释时，MSVC 按系统代码页（zh-CN=936/GBK）解码，
GBK 贪心配对把 UTF-8 序列重切 → **行边界失同步**，下一行的函数签名不再被当成代码。

**识别指纹**：报错行号比真实行号**恒差固定值**（吞行导致）。

**修法**：加 UTF-8 BOM（3 字节，正文不动）。**BOM 是承重的**：

- **不要**把 `vk_splice.py` 读写改成 `utf-8-sig`（现用 `utf-8` 会保留 BOM 字符；
  改成 `utf-8-sig` 会在下次 splice 静默删 BOM，错误复发）
- 只读脚本用 `utf-8-sig`（`pp_structure.py` / `vk_validate.py` / `vk_fieldcheck.py`）
- `.hx` 不需要 BOM（Haxe 默认 UTF-8）

### 4.7 neko / HL 双侧 API 不能混用

一个入口有两套实现，收尾块最容易从另一侧粘贴。**指纹**：`C2664`（要 `value` 给了 `vdynamic*`）
+ `C2440`（反过来）同时出现。用 `vk_ffi_side_check.py` 兜底。

### 4.8 脚本编辑 C++ 用花括号计数定位函数边界

用"从签名行往下找第一个 `\t}`"定位函数结尾会命中 for/if 的闭合括号，把新函数插进函数体内部
（`C2267` 具有块范围的静态函数非法 / `C2601` 本地函数定义非法）。**改完立刻验证全文件 `{` 与 `}`
数量相等**，再跑九道校验。

---

## 5. 详细坑清单

本项目累计 33 条已踩坑记录（含每条的症状、根因、修法与通用教训），维护在：

```
~/.workbuddy/skills/lime-native-cffi-binding/references/pitfalls.md
```

同目录还有 `vk-recipes.md`（可复制的片段模板：桩、HL 对象构造、锚点用法）与
全套校验脚本副本 —— 该 skill 是本文档的可执行版本，新会话恢复上下文时优先装它。

**几条最通用的**：

- `Cannot find identifier` **批量**出现 → 先确认那个标识符是否真的不存在。成片"找不到"几乎
  总是**上下文崩坏**（编码、宏、`#if` 分支、括号错配），而不是真的缺失。
- 生成器写 `static function` 时，模板里每个实例字段赋值都要带对象前缀（`o.field = ...`）；
  裸写只在实例方法里合法。
- **门禁只看退出码**，别用 `grep -c "^!!"` 去数问题行：口径一旦不匹配，
  报告里明明写着 172 个问题的检查会被读成 0（第 19 批就这样白绿了一轮编译）。
  同理校验脚本自己也会漏：`return 1 if (problems or pfn_issues)` 曾把重复定义、
  void 当值用、helper 缺失三面排除在退出码之外。
- 生成器产物"结构校验全绿"≠"能编译/能运行"——四区段、签名串、覆盖率这些查的是绑定完整性，
  与语言层面是否成立正交。
- **常量/枚举数值一律用脚本从头文件抽**（`vk_gen_object_type.py` 就是模板：直接 parse
  `vulkan_core.h` 生成 `VKObjectType.hx`）。手写数值必错，且 `*_MAX_ENUM` / `*_RANGE` 别名
  会让朴素正则抽到重复值（`0x7FFFFFFF` 被切出一个假的 `0`）。

---

*参考：Lime 8.4.0-preview 源码（`VK.hx` / `VK*.hx` / `NativeCFFI.hx` / `ExternalInterface.cpp` / `VKRenderer.cpp`）、`vk.xml`（权威函数清单）、`vulkan_core.h`（结构体与常量权威来源）。*
