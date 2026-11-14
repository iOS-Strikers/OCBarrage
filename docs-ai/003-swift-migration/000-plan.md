# Swift 全量迁移方案

状态：Approved；版本：v2；基线：4c3d3fa（2026-11-14）。

## Background / Research

用户已选择：弹幕核心＋Demo＋测试全部 Swift，YYKit 作为第三方依赖保留。
当前自有 Objective-C 文件 49 个（含头文件），第三方目录 164 个；公开实现位于 OCBarrage/OCBarrage，六类扩展位于 OtherDescriptorAndCells。Demo 由 main.m、AppDelegate、Storyboard 的 RootViewController 和 ViewController 启动。核心依赖 UIKit/Core Animation，YYKit 仅供 Demo 图文、GIF 和竖排使用。
基线已执行 25 项单元测试＋1 项 UI 测试。现有 podspec 为 1.0.5、来源为旧仓库，源码匹配 .h/.m、声明 iOS 8；当前 Xcode 27.2 不再支持该部署版本。机器实际工具链为 Swift 6.4.2，之前验证使用 iOS 15 编译下限、iOS 26.5 模拟器。
分类：架构/语言迁移，full flow。此文件只记录方案，批准前不修改生产代码。

## Goals / Non-goals

- 将核心、全部自定义描述符/cell、App 入口/控制器、单元/UI 测试迁移为 Swift；删除被替代的自有 .h/.m，不保留平行 OC 引擎。
- YYKit 及已修复的竖排实现原样保留在 ThirdPartyLibraries，保留许可证和资源；只允许 Demo 和宿主单元测试共用桥接头导入 YYKit，核心不依赖桥接或 YYKit。
- 保持三种 Demo 模式、七种综合效果、控制逻辑、奇偶速度、调度边界及已完成性能优化。
- 不新增 SwiftUI 版本、不重写 YYKit、不发布 Pod/Release，不自动提交/推送本次迁移。此前逐次提交授权不扩大到该重大迁移。
- 不承诺 Objective-C 源码/二进制兼容；历史版本通过 Git 历史保留，不复制一套旧核心到主代码。

## Design / Approach

### 兼容与公开 API（需确认）

- Swift 6 语言模式，核心和 Demo 最低 iOS 15。README、podspec、Package.swift、Xcode 构建配置一致；iOS 8 支持随此次重大迁移结束。
- 保留 OCBarrageManager、OCBarrageRenderView、OCBarrageCell、OCBarrageTextDescriptor 等主要类型名及职责，枚举使用 Swift case 命名；不以本次迁移为由重命名整套 API。
- 维持现有 renderRange 的 NSRange 下界/上界语义、fixedSpeed 的 scale×2 换算和上限。用迁移表明确新 Swift 调用方式，不偷偷改变参数单位。
- 描述符因子类扩展保留 class，OCBarrageDescriptor / OCBarrageTextDescriptor 为 open，供外部继承的初始化器为 public/required（按类型构造约束确定）；可继承 cell 和生命周期扩展点使用 open，动态构造 cell 使用受约束的 OCBarrageCell.Type 和 required 初始化器，拒绝任意 AnyClass。
- 活动/闲置数组向调用方只读，不再暴露可直接改变引擎状态的 NSMutableArray。生命周期和动画 UI API 归属 @MainActor；不能靠 @unchecked Sendable 或关闭 Swift 6 检查掩盖问题。
- 将仅保护主线程状态的信号量替换为主 actor 隔离；回调捕获目标后执行，支持同步 stop/pause/发送重入。Core Animation 代理与主 actor 的边界使用实际 SDK 声明验证，保留动画身份识别及取消回调行为。

### 模块与工程

- proposed：OCBarrage/OCBarrage/*.swift，保持核心目录独立；新增 Package.swift 仅发布核心 OCBarrage library，不包含 Demo/YYKit。
- proposed：AppDelegate.swift、RootViewController.swift、ViewController.swift，以及 OtherDescriptorAndCells/*.swift。沿用现有 UIKit 页面和布局；App 用 Swift @main 启动，Storyboard 模块/类名正确关联，避免双入口。
- proposed：OCBarrage/OCBarrage-Bridging-Header.h，仅导入 YYKit，由 Demo 与需要直接验证 YYKit 的宿主单元测试共用；允许其作为非业务 Objective-C 声明胶水存在。
- 修改 project.pbxproj，移除旧自有 Objective-C 编译项，增加 Swift 文件和共享 scheme，保留 YYKit 编译项与资源。
- podspec source_files 改为 Swift，声明 swift_versions 和新的部署下限；同步仓库主页和来源。不要让尚未发布的 Swift 内容冒充已有 1.0.5；使用 2.0.0 的待发布版本定义，明确 tag/Pod 尚未发布。
- proposed：OCBarrageTests/*.swift 与 OCBarrageUITests/*.swift，测试行为一一迁移。使用 Swift XCTest 保持现有宿主、截图附件、UI 测试链路；不同时更换测试框架。
- README 更新 Swift 接入、迁移兼容表、模块依赖边界及验证结果。

### 实施顺序

1. 在当前干净工作区创建 codex/swift-migration 分支，保留 master 基线。
2. 保存现有测试逐项映射和必要基线记录；先迁移核心数据模型/cell，再 renderer/manager。
3. 迁移六类扩展和 Demo，完成 YYKit Swift 桥接及工程入口。
4. 全量迁移测试，维持原断言意图；不删除失败用例来满足数量。
5. 修正包定义、接入文档，完成全部验证和独立代码审查。

## Acceptance criteria / Verification plan

全部必需：
- AC1：git 文件和编译项检查，自有 .m 全部移除；业务 .h 被 Swift 替代，仅 Demo YYKit 桥接头可保留。ThirdPartyLibraries 源码与基线 diff 为零。
- AC2：无需最低版本命令行覆盖，Xcode scheme 在指定 iPhone 17 Pro 模拟器构建成功；Swift 6 检查启用；SPM 核心在 iOS Simulator 编译成功（UIKit 包不以 macOS swift build 成功作为验收）。
- AC3：旧 25 项单元测试与 1 项 UI 测试按名称/行为逐项映射为 Swift 版本并全部通过；编译失败不计作行为红灯。涉及锁可用性等实现断言改成同步回调可完成的外部行为验证，保留原覆盖目的。
- AC4：在独立 Swift 导入调用方验证 public/open API、descriptor 与 cell 的跨模块子类扩展及初始化、包导入；覆盖主 actor 调用和取消/释放，无崩溃或明显引用环。
- AC5：实际启动 Demo 验证轨道、竖排、综合模式（包含 GIF 换帧和图文附件），开始/暂停/继续/停止/切换/后台暂停；截图及短录屏可检查。轨道 60/110 pt/s、0.65 秒发送；综合每回调最多一种效果；所有七种效果保留。
- AC6：固定 30 轮 GIF＋图文准备负载复测并报告，不把墙钟耗时当帧率；检查 PNG/GIF 对象复用和 UILabel 复用，显著退化必须定位。随机/冷启动差异用相同设备与配置、多次重复排除。
- AC7：现有停止再启动清理、边框阴影复位、无效几何、速度追赶、范围/行高变化、容器坐标、非线性自定义动画不被改写、组合字符、竖排空/窄容器等回归覆盖均保留。
- AC8：迁移文档与本次实际通过项一致，至少两轮独立代码审查、最后一轮 clean；必需验收完成才报告全量迁移完成。

非必需且明确不宣称：真机帧率、iOS 15 真机验收、完整多设备矩阵、Pod 发布及 Objective-C 调用兼容。

## Risks / Open questions

- 重大兼容变更：iOS 15 下限、Swift-only API、只读数组、受约束 metatype、主 actor 隔离；需要用户确认此具体方案。
- YYKit 的可空性/宏/C 函数及富文本附件从 Swift 调用的实际导入名须编译验证；不把语法替换当迁移完成。
- CALayer 时间基准、CAAnimation 代理生命周期和 Swift 析构隔离须专项验证。
- podspec 版本为待发布定义，不创建 2.0.0 tag 或声称 CocoaPods 可安装该版本。

## Spec Review / Human approval

独立 Reviewer：/root/swift_spec_review。第一轮发现描述符跨模块继承访问级别遗漏，AC4 未明确其编译验证；ACCEPT，v2 已补充 open 描述符和可访问初始化器、外部模块子类验证。另 ACCEPT 宿主测试需要共用 YYKit 桥接头的构建澄清。Reviewer 第二轮复核 v2：clean，无新增阻断项。用户于 2026-11-14 回复“确认”，批准当前 v2（Swift 6、最低 iOS 15、不保证旧 Objective-C 源码兼容）及全部验收范围。批准前方案审查两轮，最新 clean。
