# Swift 迁移指南

当前分支为待发布的 Swift 全量迁移，podspec 版本为 2.0.0；没有发布 tag、Release 或 Pod。原 Objective-C 实现可从 Git 历史读取。

## 支持范围

- Swift 6 语言模式；Swift 6.2+ 编译器；最低 iOS 15。
- 核心 SPM / Pod 仅含 UIKit 弹幕库；Demo 和测试也使用 Swift。
- YYKit 为 Demo 第三方依赖，保持既有源码和许可证；Demo 与宿主测试共用一个桥接头。核心无需 YYKit。
- 本次不提供 Objective-C 源码/二进制兼容，也不提供 SwiftUI 页面。

## API 对照

| Objective-C | Swift |
| --- | --- |
| `[[OCBarrageManager alloc] init]` | `OCBarrageManager()` |
| `renderBarrageDescriptor:` | `renderBarrageDescriptor(_:)` |
| `dequeueReusableCellWithClass:` | `dequeueReusableCell(withClass:)` |
| `addBarrageAnimationWithDelegate:` | `addBarrageAnimation(delegate:)` |
| `convertContentToImageWithSize:` | `CALayer.convertContentToImage(size:)` |
| `OCBarrageRenderStoped/Started/Paused` | `OCBarrageRenderStatus.stopped/started/paused` |
| `OCBarragePositionLow/Middle/High/VeryHigh` | `OCBarragePositionPriority.low/middle/high/veryHigh` |
| `OCBarrageRenderPositionRandomTracks/Random/Increase` | `OCBarrageRenderPositionStyle.randomTracks/random/increase` |
| 任意 `Class` 的 `barrageCellClass` | `OCBarrageCell.Type?`，例如 `OCBarrageTextCell.self` |
| 可变 `NSMutableArray` 活动/闲置列表 | 只读 `[OCBarrageCell]` 快照；调用者不可直接增删引擎成员 |
| 主线程约定＋内部信号量 | `@MainActor` 隔离，同步 UI 操作与回调 |
| 描述符 / cell 子类初始化 | `required init()`；外部子类必须使用可访问初始化器 |
| `setBarrageDescriptor:` 内缓存文字描述符 | `textDescriptor` 为由 `barrageDescriptor` 计算的只读类型视图 |
| `textFont/textColor/shadowColor` 可空 | 非空默认值：17 pt 系统字体、白色、黑色；用明确值复位 |
| `OCBarrageTrackInfo` | 预约数据改为渲染器私有实现，不再作为公开配置对象 |
| `touchAction` 旧回调 | 保留；优先使用 `cellTouchedAction`，参数为非空描述符和 cell |

UI API、描述符和扩展点均在主 actor 上使用。从后台任务进入时应切换到 `MainActor`。动画 delegate 使用带运行时隔离检查的旧 Objective-C 协议适配，UI 图层动画回调应在主线程交付；不将动画对象跨 actor 发送。

## 保留的参数和行为

`renderRange.location` 仍为 Y 下界，`renderRange.length` 仍为 Y 上界，零范围表示整个容器。`fixedSpeed` 仍使用 `UIScreen.main.scale × 2 × fixedSpeed` 换算为 pt/s，上限 100。此迁移不改变这些历史单位。

默认水平线性动画继续按同类 cell 的相交垂直带预约入场，约束入口间距和追尾；自定义非线性/竖向/多段/祖先变速动画保留原时序。不同类型或自定义效果可能重叠。

暂停冻结位移并同步预约时间，继续不重发；停止清理活动/闲置 cell、预约、描述符和图层时钟。自然动画完成后复用，闲置超过五秒周期性清理。manager 释放自动停止渲染器；动画代理弱引用 renderer，清理任务和 Demo 发送任务不延长所属对象生命周期。

回调同步执行，支持 pause/stop/发送重入。闭包捕获 manager/控制器时仍应避免强引用环；渲染器会在回调前保存本次命中的描述符和两个回调，第一回调停止后第二回调仍能接收本次命中对象。

## 验证

验证结果与限制在本次实施记录中更新。编译、自动测试、视觉证据和固定准备负载分别检查，不以模拟器耗时代替真机帧率。

2026-11-14 验证结果：

- Xcode 27.2 / Swift 6.4.2 / iPhone 17 Pro（iOS 26.5）完整构建通过，无部署版本命令行覆盖。
- 27 项单元测试和 1 项 UI 测试全部通过；原 25 项逐项映射，新增 2 项释放/动画回收测试。验收脚本 `command_status` 和 `acceptance_status` 均为 PASS。
- 独立 `ExternalConsumer` 本地 SPM 工程在 iOS Simulator 构建通过，验证描述符、文字描述符和 cell 的跨模块继承与初始化。
- 固定 30 轮 GIF＋图文准备负载，独立三轮为 34.896 / 22.193 / 21.675 ms，中位数 22.193 ms。完整测试运行另测得 21.741 ms；迁移前同设备 Debug 基线为 21.094 ms。墙钟耗时受冷启动和负载影响，没有观察到稳定显著退化，不能解释为帧率。
- 自有 49 个 Objective-C 文件已替换；只保留 YYKit 桥接头，第三方目录相对基线 `4c3d3fa` diff 为零。

首次运行新增释放测试时，移除视图后立即检查弱引用失败；等待 UIKit 当前事务排空 50 ms 后释放通过。测试修正了检查时机，未放宽实际释放断言，核心释放实现未因此修改。

未验证真机帧率、iOS 15 真机运行和完整设备矩阵；Pod 仅完成 Ruby 语法检查，未发布或进行远程安装验证。YYKit 既有弃用/可空性警告仍保留。
