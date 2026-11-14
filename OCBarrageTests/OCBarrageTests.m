//
//  OCBarrageTests.m
//  OCBarrageTests
//

#import <XCTest/XCTest.h>
#import "../OCBarrage/OtherDescriptorAndCells/OCBarrageGifCell.h"
#import "../OCBarrage/ViewController.h"
#import "../OCBarrage/OCBarrage/OCBarrageManager.h"

@interface ViewController (DemoRegression)
- (void)startBarrage;
- (void)pasueBarrage;
- (void)stopBarrage;
- (void)addGifBarrage;
- (void)emitDemoBarrage;
- (void)addMixedImageAndTextBarrage;
@end
#import "../OCBarrage/OCBarrage/OCBarrageRenderView.h"
#import "../OCBarrage/OCBarrage/OCBarrageTextCell.h"
#import "../OCBarrage/OCBarrage/OCBarrageTrackInfo.h"
#import "../OCBarrage/ThirdPartyLibraries/YYKit/Text/Component/YYTextLayout.h"

@interface OCBarrageRenderView (RegressionAccess)
- (CGRect)calculationBarrageCellFrame:(OCBarrageCell *)cell;
@end

// 拦截延迟清理，避免测试依赖真实计时器。
@interface OCBarrageTestRenderView : OCBarrageRenderView
@property (nonatomic, assign) NSUInteger cleanupRequests;
- (BOOL)animatingLockIsAvailable;
- (NSArray<OCBarrageTrackInfo *> *)trackInfos;
@end

@implementation OCBarrageTestRenderView
- (NSArray<OCBarrageTrackInfo *> *)trackInfos { return _trackNextAvailableTime.allValues; }
- (BOOL)animatingLockIsAvailable {
    if (dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_NOW) != 0) {
        return NO;
    }
    dispatch_semaphore_signal(_animatingCellsLock);
    return YES;
}
- (void)performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay {
    if (selector == NSSelectorFromString(@"clearIdleCells")) {
        self.cleanupRequests++;
        return;
    }
    [super performSelector:selector withObject:object afterDelay:delay];
}
@end

@interface OCBarrageTestCell : OCBarrageCell
@property (nonatomic, strong) CAAnimation *testAnimation;
@end

@implementation OCBarrageTestCell
- (CAAnimation *)barrageAnimation {
    return self.testAnimation;
}
@end

// 固定内容尺寸，但仍使用生产 TextCell 的动画与生产 renderer 调度。
@interface OCBarrageSizedTextCell : OCBarrageTextCell
@end
@implementation OCBarrageSizedTextCell
- (void)updateSubviewsData {}
- (void)layoutContentSubviews {}
- (void)convertContentToImage {}
- (void)sizeToFit {}
- (void)removeSubViewsAndSublayers {}
@end
@interface OtherOCBarrageSizedTextCell : OCBarrageSizedTextCell
@end
@implementation OtherOCBarrageSizedTextCell
@end

@interface OCBarrageCustomTimingCell : OCBarrageSizedTextCell
@property NSInteger timingVariant;
@property CFTimeInterval originalBeginTime;
@end
@implementation OCBarrageCustomTimingCell
- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)delegate {
    [super addBarrageAnimationWithDelegate:delegate];
    CAKeyframeAnimation *animation = (CAKeyframeAnimation *)[self.barrageAnimation copy];
    switch (self.timingVariant) {
        case 0: animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; break;
        case 1: animation.autoreverses = YES; break;
        case 2: animation.repeatCount = 2; break;
        case 3: animation.beginTime = CACurrentMediaTime() + 10; break;
        case 4: animation.keyTimes = @[@0.2, @0.8]; break;
        case 5: animation.speed = 0.5; break;
        case 6: {
            CGPoint from = [animation.values.firstObject CGPointValue];
            CGPoint to = [animation.values.lastObject CGPointValue];
            from.y += 15; to.y += 15;
            animation.values = @[[NSValue valueWithCGPoint:from], [NSValue valueWithCGPoint:to]];
            break;
        }
        case 7: self.layer.anchorPoint = CGPointMake(0, 0.5); break;
        default: self.layer.transform = CATransform3DMakeRotation(M_PI / 12, 0, 0, 1); break;
    }
    self.originalBeginTime = animation.beginTime;
    [self.layer addAnimation:animation forKey:kBarrageAnimation];
}
@end

// 使用确定的展示层与触摸替身，避免依赖动画提交时机或合成系统触摸。
@interface OCBarrageHitTestLayer : CALayer
@end
@implementation OCBarrageHitTestLayer
- (CALayer *)presentationLayer { return self; }
@end

@interface OCBarrageTouchableCell : OCBarrageCell
@end
@implementation OCBarrageTouchableCell
+ (Class)layerClass { return [OCBarrageHitTestLayer class]; }
@end

@interface OCBarrageTestTouch : NSObject
@property (nonatomic, assign) CGPoint point;
- (CGPoint)locationInView:(UIView *)view;
@end
@implementation OCBarrageTestTouch
- (CGPoint)locationInView:(UIView *)view { return self.point; }
@end

@interface OCBarrageTestEvent : NSObject
@property (nonatomic, assign) UIEventType type;
@end
@implementation OCBarrageTestEvent
@end

@interface OCBarrageTests : XCTestCase
@end

@implementation OCBarrageTests

- (void)finishCellInRenderView:(OCBarrageRenderView *)renderView {
    OCBarrageTestCell *cell = [[OCBarrageTestCell alloc] init];
    cell.testAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [renderView.animatingCells addObject:cell];
    [renderView animationDidStop:cell.testAnimation finished:YES];
}

- (void)testCleanupIsScheduledAgainAfterStopAndRestart {
    OCBarrageTestRenderView *renderView = [[OCBarrageTestRenderView alloc] init];
    [renderView start];
    [self finishCellInRenderView:renderView];
    XCTAssertEqual(renderView.cleanupRequests, (NSUInteger)1);
    XCTAssertEqual(renderView.idleCells.count, (NSUInteger)1);
    [self finishCellInRenderView:renderView];
    XCTAssertEqual(renderView.cleanupRequests, (NSUInteger)1);

    [renderView stop];
    XCTAssertEqual(renderView.idleCells.count, (NSUInteger)0);
    [renderView start];
    [self finishCellInRenderView:renderView];
    XCTAssertEqual(renderView.cleanupRequests, (NSUInteger)2);
    [renderView stop];
}

- (void)testReusedCellAppliesZeroAndNilBorderAttributes {
    OCBarrageCell *cell = [[OCBarrageCell alloc] init];
    OCBarrageDescriptor *decorated = [[OCBarrageDescriptor alloc] init];
    decorated.borderColor = [UIColor redColor];
    decorated.borderWidth = 3.0;
    decorated.cornerRadius = 12.0;
    cell.barrageDescriptor = decorated;
    [cell addBorderAttributes];
    XCTAssertTrue(CGColorEqualToColor(cell.layer.borderColor, decorated.borderColor.CGColor));
    XCTAssertEqualWithAccuracy(cell.layer.borderWidth, 3.0, 0.001);
    XCTAssertEqualWithAccuracy(cell.layer.cornerRadius, 12.0, 0.001);

    [cell prepareForReuse];
    OCBarrageDescriptor *plain = [[OCBarrageDescriptor alloc] init];
    plain.borderColor = nil;
    plain.borderWidth = 0.0;
    plain.cornerRadius = 0.0;
    cell.barrageDescriptor = plain;
    [cell addBorderAttributes];
    XCTAssertTrue(cell.layer.borderColor == NULL);
    XCTAssertEqualWithAccuracy(cell.layer.borderWidth, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(cell.layer.cornerRadius, 0.0, 0.001);
}

- (void)testReuseMatchesExactClassAndRemovesOnlySelectedCell {
    OCBarrageRenderView *renderView = [[OCBarrageRenderView alloc] init];
    OCBarrageTestCell *subclassCell = [[OCBarrageTestCell alloc] init];
    OCBarrageCell *baseCell = [[OCBarrageCell alloc] init];
    baseCell.idleTime = 123.0;
    [renderView.idleCells addObjectsFromArray:@[subclassCell, baseCell]];

    XCTAssertEqual([renderView dequeueReusableCellWithClass:[OCBarrageCell class]], baseCell);
    XCTAssertEqualWithAccuracy(baseCell.idleTime, 0.0, 0.001);
    XCTAssertEqualObjects(renderView.idleCells, (@[subclassCell]));
    XCTAssertEqual([renderView dequeueReusableCellWithClass:[OCBarrageTestCell class]], subclassCell);
    XCTAssertEqual(renderView.idleCells.count, (NSUInteger)0);
    OCBarrageCell *newCell = [renderView dequeueReusableCellWithClass:[OCBarrageCell class]];
    XCTAssertNotNil(newCell);
    XCTAssertTrue(newCell != baseCell);
    XCTAssertEqual([newCell class], [OCBarrageCell class]);
}

- (void)sendTouchAtPoint:(CGPoint)point toRenderView:(OCBarrageRenderView *)renderView {
    OCBarrageTestTouch *touch = [[OCBarrageTestTouch alloc] init];
    touch.point = point;
    OCBarrageTestEvent *event = [[OCBarrageTestEvent alloc] init];
    event.type = UIEventTypeTouches;
    [renderView touchesEnded:[NSSet setWithObject:(UITouch *)touch] withEvent:(UIEvent *)event];
}

- (void)testTouchCallbacksCanPauseAndStopSynchronously {
    OCBarrageTestRenderView *renderView = [[OCBarrageTestRenderView alloc] init];
    [renderView start];
    OCBarrageTouchableCell *cell = [[OCBarrageTouchableCell alloc] init];
    cell.frame = CGRectMake(0, 0, 100, 40);
    cell.barrageDescriptor = [[OCBarrageDescriptor alloc] init];
    [renderView.animatingCells addObject:cell];
    [renderView addSubview:cell];
    NSMutableArray *calls = [NSMutableArray array];
    __weak OCBarrageTestRenderView *weakRenderView = renderView;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    cell.barrageDescriptor.touchAction = ^(OCBarrageDescriptor *descriptor) {
        [calls addObject:@"legacy"];
        // 旧实现应失败并返回，而不是让整个测试进程挂死。
        BOOL unlocked = [weakRenderView animatingLockIsAvailable];
        XCTAssertTrue(unlocked);
        if (!unlocked) { return; }
        [weakRenderView pause];
        XCTAssertEqual(weakRenderView.renderStatus, OCBarrageRenderPaused);
    };
#pragma clang diagnostic pop
    cell.barrageDescriptor.cellTouchedAction = ^(OCBarrageDescriptor *descriptor, OCBarrageCell *touchedCell) {
        [calls addObject:@"cell"];
        XCTAssertNotNil(touchedCell);
        XCTAssertEqual(descriptor, touchedCell.barrageDescriptor);
        BOOL unlocked = [weakRenderView animatingLockIsAvailable];
        XCTAssertTrue(unlocked);
        if (!unlocked) { return; }
        [weakRenderView stop];
        XCTAssertEqual(weakRenderView.renderStatus, OCBarrageRenderStoped);
    };

    [self sendTouchAtPoint:CGPointMake(20, 20) toRenderView:renderView];
    XCTAssertEqualObjects(calls, (@[@"legacy", @"cell"]));
    XCTAssertEqual(renderView.renderStatus, OCBarrageRenderStoped);
    XCTAssertEqual(renderView.animatingCells.count, (NSUInteger)0);
    XCTAssertNil(cell.superview);
    [renderView stop];
}

- (void)testTouchMissAndFirstHitPreserveDispatchBehavior {
    OCBarrageTestRenderView *renderView = [[OCBarrageTestRenderView alloc] init];
    NSMutableArray *calls = [NSMutableArray array];
    for (NSUInteger index = 0; index < 2; index++) {
        OCBarrageTouchableCell *cell = [[OCBarrageTouchableCell alloc] init];
        cell.frame = CGRectMake(0, 0, 100, 40);
        cell.barrageDescriptor = [[OCBarrageDescriptor alloc] init];
        cell.barrageDescriptor.cellTouchedAction = ^(OCBarrageDescriptor *descriptor, OCBarrageCell *touchedCell) {
            [calls addObject:@(index)];
        };
        [renderView.animatingCells addObject:cell];
        [renderView addSubview:cell];
    }
    [self sendTouchAtPoint:CGPointMake(200, 200) toRenderView:renderView];
    XCTAssertEqual(calls.count, (NSUInteger)0);
    XCTAssertTrue([renderView animatingLockIsAvailable]);
    [self sendTouchAtPoint:CGPointMake(20, 20) toRenderView:renderView];
    XCTAssertEqualObjects(calls, (@[@0]));
}

- (void)testTextHitTestingKeepsComposedCharacterBoundaries {
    for (NSNumber *vertical in @[@NO, @YES]) {
        for (NSString *character in @[@"e\u0301", @"👨‍👩‍👧‍👦"]) {
            NSString *string = [NSString stringWithFormat:@"ABC%@XYZ", character];
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:string
                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:30.0]}];
            YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(400, 400)];
            container.verticalForm = vertical.boolValue;
            // 固定路径，隔离旧版 YYKit 的无限布局范围扩展逻辑。
            container.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 400, 400)];
            YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:text];
            XCTAssertNotNil(layout);
            XCTAssertGreaterThan(layout.lines.count, (NSUInteger)0);
            NSUInteger start = 3;
            NSUInteger end = start + character.length;
            CGRect startCaret = [layout caretRectForPosition:[YYTextPosition positionWithOffset:start]];
            CGRect endCaret = [layout caretRectForPosition:[YYTextPosition positionWithOffset:end]];
            XCTAssertFalse(CGRectIsNull(startCaret));
            XCTAssertFalse(CGRectIsNull(endCaret));
            for (NSNumber *fraction in @[@0.25, @0.75]) {
                CGPoint point = CGPointMake(CGRectGetMidX(startCaret), CGRectGetMidY(startCaret));
                if (vertical.boolValue) {
                    point.y += (CGRectGetMidY(endCaret) - point.y) * fraction.doubleValue;
                } else {
                    point.x += (CGRectGetMidX(endCaret) - point.x) * fraction.doubleValue;
                }
                YYTextPosition *position = [layout closestPositionToPoint:point];
                XCTAssertNotNil(position);
                XCTAssertTrue(position.offset == start || position.offset == end,
                              @"%@ vertical=%@ point=%@ offset=%ld", character, vertical,
                              NSStringFromCGPoint(point), (long)position.offset);
            }
        }
    }
}

- (OCBarrageSizedTextCell *)sizedCellOfClass:(Class)cellClass width:(CGFloat)width height:(CGFloat)height duration:(NSTimeInterval)duration {
    OCBarrageSizedTextCell *cell = [[cellClass alloc] init];
    cell.bounds = CGRectMake(0, 0, width, height);
    OCBarrageTextDescriptor *descriptor = [[OCBarrageTextDescriptor alloc] init];
    descriptor.animationDuration = duration;
    cell.barrageDescriptor = descriptor;
    return cell;
}

- (CFTimeInterval)globalStartForCell:(OCBarrageCell *)cell {
    return [cell.layer convertTime:cell.barrageAnimation.beginTime toLayer:nil];
}

- (void)assertCell:(OCBarrageCell *)following doesNotCatch:(OCBarrageCell *)leading {
    CAKeyframeAnimation *first = (CAKeyframeAnimation *)leading.barrageAnimation;
    CAKeyframeAnimation *second = (CAKeyframeAnimation *)following.barrageAnimation;
    CGFloat tailStart = [first.values.firstObject CGPointValue].x + leading.bounds.size.width / 2;
    CGFloat tailEnd = [first.values.lastObject CGPointValue].x + leading.bounds.size.width / 2;
    CGFloat headStart = [second.values.firstObject CGPointValue].x - following.bounds.size.width / 2;
    CGFloat headEnd = [second.values.lastObject CGPointValue].x - following.bounds.size.width / 2;
    CFTimeInterval startA = [self globalStartForCell:leading];
    CFTimeInterval startB = [self globalStartForCell:following];
    CGFloat speedA = (tailStart - tailEnd) / first.duration;
    CGFloat speedB = (headStart - headEnd) / second.duration;
    XCTAssertGreaterThanOrEqual(startB, startA);
    for (CFTimeInterval time = startB; time <= startA + first.duration; time += 0.02) {
        CGFloat tail = tailStart - speedA * (time - startA);
        CGFloat head = headStart - speedB * (time - startB);
        XCTAssertGreaterThanOrEqual(head - tail, -0.001);
        if (head < tail - 0.001) break;
    }
}

- (void)testTrackFramesUseBoundsAndRejectUnusableGeometry {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(80, 90, 320, 100);
    OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:80 height:20 duration:5];
    CGRect frame = [view calculationBarrageCellFrame:cell];
    XCTAssertEqualWithAccuracy(frame.origin.x, 320, 0.001);
    cell.barrageDescriptor.renderRange = NSMakeRange(30, 90);
    frame = [view calculationBarrageCellFrame:cell];
    XCTAssertGreaterThanOrEqual(frame.origin.y, 30);
    XCTAssertLessThanOrEqual(CGRectGetMaxY(frame), 90);
    for (NSValue *range in @[[NSValue valueWithRange:NSMakeRange(90, 80)],
                             [NSValue valueWithRange:NSMakeRange(90, 100)],
                             [NSValue valueWithRange:NSMakeRange(120, 150)]]) {
        cell.barrageDescriptor.renderRange = range.rangeValue;
        XCTAssertTrue(CGRectIsNull([view calculationBarrageCellFrame:cell]));
    }
    cell.barrageDescriptor.renderRange = NSMakeRange(0, 0);
    cell.bounds = CGRectMake(0, 0, 80, 0);
    XCTAssertTrue(CGRectIsNull([view calculationBarrageCellFrame:cell]));
    [view start];
    [view fireBarrageCell:cell];
    XCTAssertEqual(view.animatingCells.count, (NSUInteger)0);
    cell.bounds = CGRectMake(0, 0, 80, 120);
    XCTAssertTrue(CGRectIsNull([view calculationBarrageCellFrame:cell]));
    view.renderPositionStyle = OCBarrageRenderPositionRandom;
    XCTAssertTrue(CGRectIsNull([view calculationBarrageCellFrame:cell]));
    [view stop];
}

- (void)testTracksIgnoreStaleIndicesAfterResize {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 200);
    [view start];
    for (NSUInteger i = 0; i < 10; i++) {
        [view fireBarrageCell:[self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:10]];
    }
    for (OCBarrageTrackInfo *info in view.trackInfos) {
        if (info.trackIndex > 0) info.nextAvailableTime = CACurrentMediaTime() - 1;
    }
    view.frame = CGRectMake(0, 0, 320, 20);
    OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:10];
    CGRect frame = [view calculationBarrageCellFrame:cell];
    XCTAssertEqual(cell.trackIndex, 0);
    XCTAssertEqualWithAccuracy(frame.origin.y, 0, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMaxY(frame), 20, 0.001);
    [view stop];
}

- (void)testTracksUseFreeRowsDespiteOtherClassRecords {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 200);
    [view start];
    for (NSUInteger i = 0; i < 10; i++) {
        [view fireBarrageCell:[self sizedCellOfClass:[OtherOCBarrageSizedTextCell class] width:100 height:20 duration:10]];
    }
    NSMutableSet *rows = [NSMutableSet set];
    for (NSUInteger i = 0; i < 10; i++) {
        OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:10];
        [view fireBarrageCell:cell];
        [rows addObject:@(cell.trackIndex)];
    }
    XCTAssertEqual(rows.count, (NSUInteger)10);
    [view stop];
}

- (void)testBurstIsStaggeredAndFastFollowingCellDoesNotCatchSlowCell {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 80);
    [view start];
    CFTimeInterval now = CACurrentMediaTime();
    NSMutableArray<NSNumber *> *starts = [NSMutableArray array];
    for (NSUInteger i = 0; i < 4; i++) {
        OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:5];
        [view fireBarrageCell:cell];
        CFTimeInterval start = [self globalStartForCell:cell];
        XCTAssertGreaterThan(start, now);
        [starts addObject:@(start)];
    }
    [starts sortUsingSelector:@selector(compare:)];
    XCTAssertGreaterThan(starts.lastObject.doubleValue - starts.firstObject.doubleValue, 0.25);
    [view stop];
    view.frame = CGRectMake(0, 0, 320, 20);
    [view start];
    OCBarrageSizedTextCell *slow = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:200 height:20 duration:8];
    OCBarrageSizedTextCell *fast = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:50 height:20 duration:2];
    [view fireBarrageCell:slow];
    [view fireBarrageCell:fast];
    [self assertCell:fast doesNotCatch:slow];
    [view stop];
}

- (void)testRangeAndHeightChangesKeepOverlappingTrackOccupancy {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 120);
    [view start];
    OCBarrageSizedTextCell *first = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:180 height:20 duration:8];
    first.barrageDescriptor.renderRange = NSMakeRange(40, 60);
    [view fireBarrageCell:first];
    OCBarrageSizedTextCell *second = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:60 height:30 duration:3];
    second.barrageDescriptor.renderRange = NSMakeRange(50, 80);
    [view fireBarrageCell:second];
    [self assertCell:second doesNotCatch:first];
    view.frame = CGRectMake(0, 0, 240, 120);
    OCBarrageSizedTextCell *third = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:50 height:20 duration:2];
    third.barrageDescriptor.renderRange = NSMakeRange(45, 65);
    [view fireBarrageCell:third];
    [self assertCell:third doesNotCatch:first];
    [self assertCell:third doesNotCatch:second];
    [view stop];
}

- (void)testPauseMovesTrackDeadlinesAndReuseResetsLayerClock {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 20);
    [view start];
    OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:5];
    [view fireBarrageCell:cell];
    CFTimeInterval deadline = view.trackInfos.firstObject.nextAvailableTime;
    [view pause];
    [NSThread sleepForTimeInterval:0.03];
    [view resume];
    CFTimeInterval shifted = view.trackInfos.firstObject.nextAvailableTime;
    XCTAssertGreaterThanOrEqual(shifted - deadline, 0.025);
    [view resume];
    XCTAssertEqualWithAccuracy(view.trackInfos.firstObject.nextAvailableTime, shifted, 0.001);
    [view pause];
    [NSThread sleepForTimeInterval:0.02];
    [view resume];
    XCTAssertGreaterThanOrEqual(view.trackInfos.firstObject.nextAvailableTime - shifted, 0.015);
    [view animationDidStop:cell.barrageAnimation finished:YES];
    XCTAssertEqualWithAccuracy(cell.layer.speed, 1, 0.001);
    XCTAssertEqualWithAccuracy(cell.layer.beginTime, 0, 0.001);
    XCTAssertEqualWithAccuracy(cell.layer.timeOffset, 0, 0.001);
    XCTAssertEqual([view dequeueReusableCellWithClass:[OCBarrageSizedTextCell class]], cell);
    [view stop];
    XCTAssertEqual(view.trackInfos.count, (NSUInteger)0);
}

- (void)testCustomAnimationTimingRemainsUntouched {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 120);
    [view start];
    for (NSInteger variant = 0; variant < 9; variant++) {
        OCBarrageCustomTimingCell *cell = (id)[self sizedCellOfClass:[OCBarrageCustomTimingCell class] width:100 height:20 duration:5];
        cell.timingVariant = variant;
        [view fireBarrageCell:cell];
        XCTAssertEqualWithAccuracy(cell.barrageAnimation.beginTime, cell.originalBeginTime, 0.001);
    }
    [view stop];
}

- (void)testDefaultVerticalLayoutMatchesExplicitInsetPath {
    NSString *string = [@"竖排布局测试，组合字符e\u0301与家庭👨‍👩‍👧‍👦。" stringByPaddingToLength:240 withString:@"横竖布局回归。" startingAtIndex:0];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    for (NSNumber *maxRows in @[@0, @2]) {
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(140, 220) insets:UIEdgeInsetsMake(8, 11, 13, 17)];
        container.verticalForm = YES;
        container.maximumNumberOfRows = maxRows.unsignedIntegerValue;
        container.truncationType = YYTextTruncationTypeEnd;
        YYTextLayout *actual = [YYTextLayout layoutWithContainer:container text:text];
        YYTextContainer *reference = [container copy];
        reference.path = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(CGRectMake(0, 0, 140, 220), container.insets)];
        YYTextLayout *expected = [YYTextLayout layoutWithContainer:reference text:text];
        XCTAssertGreaterThan(actual.lines.count, (NSUInteger)0);
        XCTAssertEqual(actual.lines.count, expected.lines.count);
        XCTAssertTrue(NSEqualRanges(actual.visibleRange, expected.visibleRange));
        for (NSUInteger i = 0; i < MIN(actual.lines.count, expected.lines.count); i++) {
            YYTextLine *a = actual.lines[i], *b = expected.lines[i];
            XCTAssertTrue(NSEqualRanges(a.range, b.range));
            XCTAssertEqualWithAccuracy(a.bounds.origin.x, b.bounds.origin.x, 0.01);
            XCTAssertEqualWithAccuracy(a.bounds.origin.y, b.bounds.origin.y, 0.01);
            XCTAssertGreaterThanOrEqual(CGRectGetMinX(a.bounds), 11 - 0.01);
            XCTAssertLessThanOrEqual(CGRectGetMaxX(a.bounds), 123 + 0.01);
        }
        CGRect caret = [actual caretRectForPosition:[YYTextPosition positionWithOffset:3]];
        XCTAssertFalse(CGRectIsNull(caret));
        XCTAssertNotNil([actual closestPositionToPoint:CGPointMake(CGRectGetMidX(caret), CGRectGetMidY(caret))]);
        UIGraphicsBeginImageContextWithOptions(container.size, YES, 2);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, container.size.width, container.size.height));
        [actual drawInContext:UIGraphicsGetCurrentContext() size:container.size debug:nil];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        XCTAttachment *attachment = [XCTAttachment attachmentWithImage:image];
        attachment.name = [NSString stringWithFormat:@"vertical-default-%@", maxRows];
        attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:attachment];
    }
}

- (void)testTooNarrowVerticalContainerHasNoVisibleText {
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(1, 100)];
    container.verticalForm = YES;
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"竖排" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24]}];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:text];
    XCTAssertEqual(layout.lines.count, (NSUInteger)0);
    XCTAssertEqual(layout.visibleRange.length, (NSUInteger)0);
}

- (void)testNonUnitAncestorClockDoesNotEnterTrackScheduler {
    UIView *parent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    parent.layer.speed = 0.5;
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = parent.bounds;
    [parent addSubview:view];
    [view start];
    OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:100 height:20 duration:5];
    [view fireBarrageCell:cell];
    XCTAssertEqualWithAccuracy(cell.barrageAnimation.beginTime, 0, 0.001);
    XCTAssertEqual(view.trackInfos.count, (NSUInteger)0);
    [view stop];
}

- (void)testRealEmptyTextAndInvalidRasterSizesAreRejected {
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 100);
    [view start];
    for (NSUInteger i = 0; i < 2; i++) {
        OCBarrageTextCell *cell = [[OCBarrageTextCell alloc] init];
        OCBarrageTextDescriptor *descriptor = [[OCBarrageTextDescriptor alloc] init];
        descriptor.text = i == 0 ? @"" : nil;
        descriptor.animationDuration = 5;
        cell.barrageDescriptor = descriptor;
        XCTAssertNoThrow([view fireBarrageCell:cell]);
        XCTAssertNil(cell.superview);
        XCTAssertEqual(view.animatingCells.count, (NSUInteger)0);
    }
    CALayer *layer = [CALayer layer];
    for (NSValue *size in @[[NSValue valueWithCGSize:CGSizeZero],
                            [NSValue valueWithCGSize:CGSizeMake(-1, 10)],
                            [NSValue valueWithCGSize:CGSizeMake(INFINITY, 10)]]) {
        XCTAssertNoThrow([layer convertContentToImageWithSize:size.CGSizeValue]);
    }
    [view stop];
}

- (void)waitForAnimationTime:(NSTimeInterval)duration {
    XCTestExpectation *tick = [self expectationWithDescription:@"animation frame"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tick fulfill];
    });
    [self waitForExpectationsWithTimeout:duration + 5 handler:nil];
}

- (void)attachWindow:(UIWindow *)window name:(NSString *)name {
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, 1);
    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    XCTAttachment *attachment = [XCTAttachment attachmentWithImage:image];
    attachment.name = name;
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

- (void)testVisibleTracksStayStaggeredAcrossPauseAndResume {
    UIWindow *previousWindow = UIApplication.sharedApplication.keyWindow;
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *controller = [[UIViewController alloc] init];
    window.rootViewController = controller;
    controller.view.backgroundColor = [UIColor colorWithWhite:0.06 alpha:1];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, window.bounds.size.width - 40, 40)];
    title.text = @"轨道错峰 · 实际动画回归";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:22];
    [controller.view addSubview:title];
    OCBarrageTestRenderView *view = [[OCBarrageTestRenderView alloc] init];
    view.frame = CGRectMake(20, 130, window.bounds.size.width - 40, 8 * 36);
    [controller.view addSubview:view];
    [window makeKeyAndVisible];
    [view start];
    NSMutableArray<OCBarrageSizedTextCell *> *cells = [NSMutableArray array];
    for (NSUInteger i = 0; i < 8; i++) {
        OCBarrageSizedTextCell *cell = [self sizedCellOfClass:[OCBarrageSizedTextCell class] width:140 height:36 duration:5];
        cell.backgroundColor = [UIColor colorWithHue:i / 8.0 saturation:0.65 brightness:0.8 alpha:1];
        cell.barrageDescriptor.cornerRadius = 9;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 36)];
        label.text = [NSString stringWithFormat:@"弹幕 %02lu", (unsigned long)(i + 1)];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        [cell addSubview:label];
        [view fireBarrageCell:cell];
        [cells addObject:cell];
    }
    [self waitForAnimationTime:1.8];
    CGFloat minX = CGFLOAT_MAX, maxX = -CGFLOAT_MAX;
    for (OCBarrageCell *cell in cells) {
        CALayer *presentation = cell.layer.presentationLayer;
        XCTAssertNotNil(presentation);
        minX = MIN(minX, presentation.position.x);
        maxX = MAX(maxX, presentation.position.x);
    }
    XCTAssertGreaterThan(maxX - minX, 20);
    [self attachWindow:window name:@"tracks-staggered"];
    [view pause];
    [self waitForAnimationTime:0.05];
    NSMutableArray<NSNumber *> *pausedX = [NSMutableArray array];
    for (OCBarrageCell *cell in cells) [pausedX addObject:@(cell.layer.presentationLayer.position.x)];
    [self waitForAnimationTime:0.15];
    for (NSUInteger i = 0; i < cells.count; i++) {
        XCTAssertEqualWithAccuracy(cells[i].layer.presentationLayer.position.x, pausedX[i].doubleValue, 0.5);
    }
    [self attachWindow:window name:@"tracks-paused"];
    [view resume];
    [self waitForAnimationTime:0.2];
    for (NSUInteger i = 0; i < cells.count; i++) {
        XCTAssertLessThan(cells[i].layer.presentationLayer.position.x, pausedX[i].doubleValue - 5);
    }
    [self attachWindow:window name:@"tracks-resumed"];
    [view stop];
    window.hidden = YES;
    [previousWindow makeKeyAndVisible];
}

- (void)testDemoStartPauseRestartAndStopAreConsistent {
    ViewController *controller = [[ViewController alloc] init];
    UIWindow *previous = UIApplication.sharedApplication.keyWindow;
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    window.rootViewController = controller;
    [window makeKeyAndVisible];
    [controller.view layoutIfNeeded];
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    [controller startBarrage];
    NSUInteger initial = manager.renderView.animatingCells.count;
    XCTAssertGreaterThan(initial, (NSUInteger)0, @"开始应立即发送首批弹幕");
    [controller startBarrage];
    XCTAssertEqual(manager.renderView.animatingCells.count, initial);
    [controller pasueBarrage];
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderPaused);
    [self waitForAnimationTime:0.8];
    XCTAssertEqual(manager.renderView.animatingCells.count, initial);
    [controller startBarrage];
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderStarted);
    XCTAssertEqual(manager.renderView.animatingCells.count, initial, @"暂停后开始应恢复，不能另发一批");
    [controller stopBarrage];
    [self waitForAnimationTime:1.0];
    XCTAssertEqual(manager.renderView.animatingCells.count, (NSUInteger)0);
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderStoped);
    [controller startBarrage];
    XCTAssertGreaterThan(manager.renderView.animatingCells.count, (NSUInteger)0);
    [controller stopBarrage];
    window.hidden = YES;
    [previous makeKeyAndVisible];
}

- (void)testDemoButtonsStayInsideSafeAreaAndModesCancelPlayback {
    UIWindow *previous = UIApplication.sharedApplication.keyWindow;
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    ViewController *controller = [[ViewController alloc] init];
    window.rootViewController = controller;
    [window makeKeyAndVisible];
    [controller.view layoutIfNeeded];
    UIButton *start = [controller valueForKey:@"startButton"];
    UIButton *pause = [controller valueForKey:@"pauseButton"];
    UIButton *stop = [controller valueForKey:@"stopButton"];
    for (UIButton *button in @[start, pause, stop]) {
        XCTAssertGreaterThanOrEqual(button.bounds.size.height, 44);
        XCTAssertLessThanOrEqual(CGRectGetMaxY(button.frame), CGRectGetHeight(controller.view.bounds) - controller.view.safeAreaInsets.bottom);
    }
    CGPoint startCenter = start.center;
    XCTAssertEqual([controller.view hitTest:startCenter withEvent:nil], start);
    [start sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertFalse(start.enabled);
    XCTAssertTrue(pause.enabled);
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    [self waitForAnimationTime:0.8];
    [pause sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertTrue(start.enabled);
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderPaused);
    [self attachWindow:window name:@"demo-paused"];
    [start sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderStarted);
    UISegmentedControl *mode = [controller valueForKey:@"modeControl"];
    mode.selectedSegmentIndex = 1;
    [mode sendActionsForControlEvents:UIControlEventValueChanged];
    XCTAssertFalse(start.enabled);
    XCTAssertFalse(pause.enabled);
    XCTAssertFalse(stop.enabled);
    [self waitForAnimationTime:1.2];
    XCTAssertEqual(manager.renderView.animatingCells.count, (NSUInteger)0);
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderStoped);
    [self attachWindow:window name:@"demo-vertical"];
    mode.selectedSegmentIndex = 2;
    [mode sendActionsForControlEvents:UIControlEventValueChanged];
    [start sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertGreaterThan(manager.renderView.animatingCells.count, (NSUInteger)0);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderPaused);
    [controller viewDidDisappear:NO];
    [self waitForAnimationTime:1.2];
    XCTAssertEqual(manager.renderView.animatingCells.count, (NSUInteger)0);
    XCTAssertEqual(manager.renderView.renderStatus, OCBarrageRenderStoped);
    window.hidden = YES;
    [previous makeKeyAndVisible];
}

- (void)testDemoFeedsOneLaneAtATimeWithAlternatingSpeeds {
    UIWindow *previous = UIApplication.sharedApplication.keyWindow;
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    ViewController *controller = [[ViewController alloc] init];
    window.rootViewController = controller;
    [window makeKeyAndVisible];
    [controller.view layoutIfNeeded];
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    [controller startBarrage];
    XCTAssertEqual(manager.renderView.animatingCells.count, (NSUInteger)1, @"开始只能发送一条，不能整批齐发");
    [self waitForAnimationTime:0.8];
    [controller pasueBarrage];
    NSArray<OCBarrageCell *> *cells = [manager.renderView.animatingCells copy];
    XCTAssertEqual(cells.count, (NSUInteger)2);
    if (cells.count == 2) {
        XCTAssertEqualWithAccuracy(CGRectGetMinY(cells[0].frame), 0, 0.01);
        XCTAssertEqualWithAccuracy(CGRectGetMinY(cells[1].frame), 40, 0.01);
        CGFloat speeds[2];
        for (NSUInteger i = 0; i < 2; i++) {
            CAKeyframeAnimation *animation = (CAKeyframeAnimation *)cells[i].barrageAnimation;
            CGFloat distance = [animation.values.firstObject CGPointValue].x - [animation.values.lastObject CGPointValue].x;
            speeds[i] = distance / animation.duration;
        }
        XCTAssertEqualWithAccuracy(speeds[0], 60, 0.01);
        XCTAssertEqualWithAccuracy(speeds[1], 110, 0.01);
    }
    [self attachWindow:window name:@"demo-alternating-lanes"];
    [controller stopBarrage];
    window.hidden = YES;
    [previous makeKeyAndVisible];
}

- (void)testTextCellReusesLabelAndResetsShadow {
    OCBarrageTextCell *cell = [[OCBarrageTextCell alloc] init];
    OCBarrageTextDescriptor *first = [[OCBarrageTextDescriptor alloc] init];
    first.text = @"shadow";
    first.textShadowOpened = YES;
    cell.barrageDescriptor = first;
    [cell updateSubviewsData];
    UILabel *label = cell.textLabel;
    [cell layoutContentSubviews];
    [cell convertContentToImage];
    [cell removeSubViewsAndSublayers];
    XCTAssertNil(label.superview);
    [cell prepareForReuse];
    OCBarrageTextDescriptor *second = [[OCBarrageTextDescriptor alloc] init];
    second.text = @"plain";
    cell.barrageDescriptor = second;
    [cell updateSubviewsData];
    XCTAssertEqual(cell.textLabel, label, @"复用 cell 时不应重新创建 UILabel");
    XCTAssertEqual(cell.textLabel.superview, cell);
    XCTAssertEqual(cell.textLabel.layer.shadowOpacity, 0);
    XCTAssertEqualObjects(cell.textLabel.attributedText.string, @"plain");
}

- (void)testDemoReusesDecodedGif {
    ViewController *controller = [[ViewController alloc] init];
    [controller loadViewIfNeeded];
    [controller.view layoutIfNeeded];
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    manager.renderView.frame = CGRectMake(0, 0, 400, 600);
    [manager start];
    [controller addGifBarrage];
    OCBarrageGifCell *first = (id)manager.renderView.animatingCells.lastObject;
    [controller addGifBarrage];
    OCBarrageGifCell *second = (id)manager.renderView.animatingCells.lastObject;
    XCTAssertNotNil(first.gifDescriptor.image);
    XCTAssertEqual(first.gifDescriptor.image, second.gifDescriptor.image);
    [controller stopBarrage];
}

- (void)testPerformanceRepeatedDemoPreparation {
    ViewController *controller = [[ViewController alloc] init];
    [controller loadViewIfNeeded];
    [controller.view layoutIfNeeded];
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    manager.renderView.frame = CGRectMake(0, 0, 400, 600);
    [manager start];
    // 固定重复负载，包含首次加载；逐轮停止以排除动画数量差异。
    CFTimeInterval start = CACurrentMediaTime();
    for (NSUInteger i = 0; i < 30; i++) {
        @autoreleasepool {
            [controller addGifBarrage];
            [controller addMixedImageAndTextBarrage];
            [manager stop];
            [manager start];
        }
    }
    NSLog(@"PERF_DEMO_30_MS=%.3f", (CACurrentMediaTime() - start) * 1000);
    [controller stopBarrage];
}

- (void)testMixedDemoPreparesAtMostOneCellPerTick {
    ViewController *controller = [[ViewController alloc] init];
    [controller loadViewIfNeeded];
    [controller.view layoutIfNeeded];
    OCBarrageManager *manager = [controller valueForKey:@"barrageManager"];
    manager.renderView.frame = CGRectMake(0, 0, 400, 600);
    UISegmentedControl *mode = [controller valueForKey:@"modeControl"];
    mode.selectedSegmentIndex = 2;
    [manager start];
    for (NSUInteger tick = 0; tick < 7; tick++) {
        [controller setValue:@(tick) forKey:@"emissionTick"];
        NSUInteger before = manager.renderView.animatingCells.count;
        [controller emitDemoBarrage];
        XCTAssertEqual(manager.renderView.animatingCells.count, before + 1,
                       @"综合模式首轮应分七次发送，每次只准备一种效果");
    }
    [controller stopBarrage];
}

@end
