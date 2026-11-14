# 测试迁移映射

原 25 个单元测试同名保留；Objective-C 名称不带括号，Swift XCTest 报告使用 `()`。

| 原用例 / Swift 同名用例 | 迁移处理 |
| --- | --- |
| `testCleanupIsScheduledAgainAfterStopAndRestart()` | 由拦截延迟 selector 改为等待真实清理 Task，验证 stop/restart 两轮均回收。 |
| `testReusedCellAppliesZeroAndNilBorderAttributes()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testReuseMatchesExactClassAndRemovesOnlySelectedCell()` | 通过发送与完成动画建立只读 idle 列表，不直接修改引擎数组。 |
| `testTouchCallbacksCanPauseAndStopSynchronously()` | 删除信号量可用性断言，保留同步 pause/stop 和回调顺序断言。 |
| `testTouchMissAndFirstHitPreserveDispatchBehavior()` | 复用确定性展示层；直接调用共享触摸分发函数验证 miss / 首次命中。 |
| `testTextHitTestingKeepsComposedCharacterBoundaries()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testTrackFramesUseBoundsAndRejectUnusableGeometry()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testTracksIgnoreStaleIndicesAfterResize()` | 不直接修改内部预约；构造真实十行预约后缩容，验证索引和可见边界。 |
| `testTracksUseFreeRowsDespiteOtherClassRecords()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testBurstIsStaggeredAndFastFollowingCellDoesNotCatchSlowCell()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testRangeAndHeightChangesKeepOverlappingTrackOccupancy()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testPauseMovesTrackDeadlinesAndReuseResetsLayerClock()` | 改为验证真实图层全局起始时间平移与后车不追尾，保持重复 resume、二次 pause、复用时钟和重启无旧预约覆盖。 |
| `testCustomAnimationTimingRemainsUntouched()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testDefaultVerticalLayoutMatchesExplicitInsetPath()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testTooNarrowVerticalContainerHasNoVisibleText()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testNonUnitAncestorClockDoesNotEnterTrackScheduler()` | 保留非单位祖先速度下动画 beginTime 不被调度改写的断言。 |
| `testRealEmptyTextAndInvalidRasterSizesAreRejected()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testVisibleTracksStayStaggeredAcrossPauseAndResume()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testDemoStartPauseRestartAndStopAreConsistent()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testDemoButtonsStayInsideSafeAreaAndModesCancelPlayback()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testDemoFeedsOneLaneAtATimeWithAlternatingSpeeds()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testTextCellReusesLabelAndResetsShadow()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testDemoReusesDecodedGif()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testPerformanceRepeatedDemoPreparation()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |
| `testMixedDemoPreparesAtMostOneCellPerTick()` | 保留原行为与关键断言，使用 Swift 类型安全 API。 |

新增：`testManagerReleaseStopsExternallyRetainedRenderer()`、`testAnimationCompletionRecyclesAndRendererCanDeallocate()`。

UI：`OCBarrageUITests/testDemoPlaybackControlsAndModeSwitching()` 同名保留。
