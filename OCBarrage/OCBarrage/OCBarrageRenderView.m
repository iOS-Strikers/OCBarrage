//
//  OCBarrageContentView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageRenderView.h"
#import "OCBarrageTrackInfo.h"

// 同一垂直带与入口／出口几何只保留最后一条预约；不同几何的活动记录并存。
@interface OCBarrageScheduledTrackInfo : OCBarrageTrackInfo
@property (nonatomic, assign) Class cellClass;
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) CGFloat tailStartX;
@property (nonatomic, assign) CGFloat tailEndX;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval endTime;
@end
@implementation OCBarrageScheduledTrackInfo
@end

@interface OCBarrageRenderView ()
@property (nonatomic, assign) CFTimeInterval trackPauseTime;
@end

static BOOL OCBarrageTimingIsLinear(CAMediaTimingFunction *timing) {
    if (!timing) return YES;
    float first[2], second[2];
    [timing getControlPointAtIndex:1 values:first];
    [timing getControlPointAtIndex:2 values:second];
    return first[0] == first[1] && second[0] == second[1];
}

static BOOL OCBarrageTracksOverlap(OCBarrageScheduledTrackInfo *info, OCBarrageCell *cell, CGFloat originY) {
    return info.cellClass == [cell class] &&
        info.originY < originY + CGRectGetHeight(cell.bounds) &&
        originY < info.originY + info.trackHeight;
}

@implementation OCBarrageRenderView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _animatingCellsLock = dispatch_semaphore_create(1);
        _idleCellsLock = dispatch_semaphore_create(1);
        _trackInfoLock = dispatch_semaphore_create(1);
        _lowPositionView = [[UIView alloc] init];
        [self addSubview:_lowPositionView];
        _middlePositionView = [[UIView alloc] init];
        [self addSubview:_middlePositionView];
        _highPositionView = [[UIView alloc] init];
        [self addSubview:_highPositionView];
        _veryHighPositionView = [[UIView alloc] init];
        [self addSubview:_veryHighPositionView];
        self.layer.masksToBounds = YES;
        _trackNextAvailableTime = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (nullable OCBarrageCell *)dequeueReusableCellWithClass:(Class)barrageCellClass {
    OCBarrageCell *barrageCell = nil;
    
    dispatch_semaphore_wait(_idleCellsLock, DISPATCH_TIME_FOREVER);
    for (OCBarrageCell *cell in self.idleCells) {
        if ([cell class] == barrageCellClass) {
            barrageCell = cell;
            break;
        }
    }
    if (barrageCell) {
        [self.idleCells removeObject:barrageCell];
        barrageCell.idleTime = 0.0;
    } else {
        barrageCell = [self newCellWithClass:barrageCellClass];
    }
    dispatch_semaphore_signal(_idleCellsLock);
    if (![barrageCell isKindOfClass:[OCBarrageCell class]]) {
        return nil;
    }
    
    return barrageCell;
}

- (OCBarrageCell *)newCellWithClass:(Class)barrageCellClass {
    OCBarrageCell *barrageCell = [[barrageCellClass alloc] init];
    if (![barrageCell isKindOfClass:[OCBarrageCell class]]) {
        return nil;
    }
    
    return barrageCell;
}

- (void)start {
    switch (self.renderStatus) {
        case OCBarrageRenderStarted: {
            return;
        }
            break;
        case OCBarrageRenderPaused: {
            [self resume];
            return;
        }
            break;
        default: {
            _renderStatus = OCBarrageRenderStarted;
        }
            break;
    }
}

- (void)pause {
    switch (self.renderStatus) {
        case OCBarrageRenderStarted: {
            _renderStatus = OCBarrageRenderPaused;
        }
            break;
        case OCBarrageRenderPaused: {
            return;
        }
            break;
        default: {
            return;
        }
            break;
    }
    
    self.trackPauseTime = CACurrentMediaTime();
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *enumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *cell = nil;
    while (cell = [enumerator nextObject]){
        CFTimeInterval pausedTime = [cell.layer convertTime:self.trackPauseTime fromLayer:nil];
        cell.layer.speed = 0.0;
        cell.layer.timeOffset = pausedTime;
    }
    dispatch_semaphore_signal(_animatingCellsLock);
}

- (void)resume {
    switch (self.renderStatus) {
        case OCBarrageRenderStarted: {
            return;
        }
            break;
        case OCBarrageRenderPaused: {
            _renderStatus = OCBarrageRenderStarted;
        }
            break;
        default: {
            return;
        }
            break;
    }
    
    CFTimeInterval now = CACurrentMediaTime();
    CFTimeInterval pauseDuration = MAX(0.0, now - self.trackPauseTime);
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *enumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *cell = nil;
    while (cell = [enumerator nextObject]){
        CFTimeInterval pausedTime = cell.layer.timeOffset;
        cell.layer.speed = 1.0;
        cell.layer.timeOffset = 0.0;
        cell.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [cell.layer convertTime:now fromLayer:nil] - pausedTime;
        cell.layer.beginTime = timeSincePause;
    }
    dispatch_semaphore_signal(_animatingCellsLock);
    dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
    for (OCBarrageScheduledTrackInfo *info in _trackNextAvailableTime.allValues) {
        if (info.endTime > self.trackPauseTime) {
            info.startTime += pauseDuration;
            info.endTime += pauseDuration;
            info.nextAvailableTime += pauseDuration;
        }
    }
    dispatch_semaphore_signal(_trackInfoLock);
    self.trackPauseTime = 0;
}

- (void)stop {
    switch (self.renderStatus) {
        case OCBarrageRenderStarted: {
            _renderStatus = OCBarrageRenderStoped;
        }
            break;
        case OCBarrageRenderPaused: {
            _renderStatus = OCBarrageRenderStoped;
        }
            break;
        default: {
            return;
        }
            break;
    }
    
    if (_autoClear) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearIdleCells) object:nil];
        _autoClear = NO;
    }
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *animatingEnumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *animatingCell = nil;
    while (animatingCell = [animatingEnumerator nextObject]){
        [animatingCell.layer removeAllAnimations];
        animatingCell.layer.speed = 1.0;
        animatingCell.layer.timeOffset = 0.0;
        animatingCell.layer.beginTime = 0.0;
        [animatingCell removeFromSuperview];
    }
    [self.animatingCells removeAllObjects];
    _lastestCell = nil;
    self.trackPauseTime = 0;
    dispatch_semaphore_signal(_animatingCellsLock);
    
    dispatch_semaphore_wait(_idleCellsLock, DISPATCH_TIME_FOREVER);
    [self.idleCells removeAllObjects];
    dispatch_semaphore_signal(_idleCellsLock);
    
    dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
    [_trackNextAvailableTime removeAllObjects];
    dispatch_semaphore_signal(_trackInfoLock);
}

- (void)fireBarrageCell:(OCBarrageCell *)barrageCell {
    switch (self.renderStatus) {
        case OCBarrageRenderStarted: {
            
        }
            break;
        case OCBarrageRenderPaused: {
            
            return;
        }
            break;
        default:
            return;
            break;
    }
    if (!barrageCell) {
        return;
    }
    if (![barrageCell isKindOfClass:[OCBarrageCell class]]) {
        return;
    }
    [barrageCell clearContents];
    [barrageCell updateSubviewsData];
    [barrageCell layoutContentSubviews];
    [barrageCell convertContentToImage];
    [barrageCell sizeToFit];
    [barrageCell removeSubViewsAndSublayers];
    [barrageCell addBorderAttributes];
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    _lastestCell = [self.animatingCells lastObject];
    dispatch_semaphore_signal(_animatingCellsLock);
    CGRect cellFrame = [self calculationBarrageCellFrame:barrageCell];
    if (CGRectIsNull(cellFrame)) {
        return;
    }
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    [self.animatingCells addObject:barrageCell];
    barrageCell.idle = NO;
    dispatch_semaphore_signal(_animatingCellsLock);
    
    [self addBarrageCell:barrageCell WithPositionPriority:barrageCell.barrageDescriptor.positionPriority];
    barrageCell.frame = cellFrame;
    [barrageCell addBarrageAnimationWithDelegate:self];
    [self recordTrackInfoWithBarrageCell:barrageCell];
    
    _lastestCell = barrageCell;
}

- (void)addBarrageCell:(OCBarrageCell *)barrageCell WithPositionPriority:(OCBarragePositionPriority)positionPriority {
    switch (positionPriority) {
        case OCBarragePositionMiddle: {
            [self insertSubview:barrageCell aboveSubview:_middlePositionView];
        }
            break;
        case OCBarragePositionHigh: {
            [self insertSubview:barrageCell belowSubview:_highPositionView];
        }
            break;
        case OCBarragePositionVeryHigh: {
            [self insertSubview:barrageCell belowSubview:_veryHighPositionView];
        }
            break;
        default: {
            [self insertSubview:barrageCell belowSubview:_lowPositionView];
        }
            break;
    }
}

- (CGRect)calculationBarrageCellFrame:(OCBarrageCell *)barrageCell {
    barrageCell.trackIndex = -1;
    CGFloat height = CGRectGetHeight(barrageCell.bounds);
    CGFloat width = CGRectGetWidth(barrageCell.bounds);
    CGRect bounds = self.bounds;
    if (!isfinite(height) || !isfinite(width) || height <= 0 || width <= 0 ||
        !isfinite(bounds.origin.x) || !isfinite(bounds.origin.y) ||
        !isfinite(bounds.size.width) || !isfinite(bounds.size.height) ||
        bounds.size.width <= 0 || bounds.size.height <= 0) {
        return CGRectNull;
    }

    CGFloat minY = CGRectGetMinY(bounds), maxY = CGRectGetMaxY(bounds);
    NSRange range = barrageCell.barrageDescriptor.renderRange;
    BOOL hasRange = !NSEqualRanges(range, NSMakeRange(0, 0));
    if (hasRange) {
        // 历史 API 的 length 表示上界，而不是 NSRange 的区间长度。
        minY = MAX(minY, (CGFloat)range.location);
        maxY = MIN(maxY, (CGFloat)range.length);
    }
    CGFloat availableHeight = maxY - minY;
    if (availableHeight < height) return CGRectNull;
    CGRect frame = CGRectMake(CGRectGetMaxX(bounds), minY, width, height);
    if (!hasRange && self.renderPositionStyle == OCBarrageRenderPositionRandom) {
        frame.origin.y += (availableHeight - height) * ((double)arc4random() / UINT32_MAX);
        return frame;
    }
    if (!hasRange && self.renderPositionStyle == OCBarrageRenderPositionIncrease) {
        CGFloat nextY = _lastestCell ? MAX(minY, CGRectGetMaxY(_lastestCell.frame)) : minY;
        frame.origin.y = nextY + height <= maxY ? nextY : minY;
        return frame;
    }

    double count = floor(availableHeight / height);
    if (!isfinite(count) || count < 1 || count > INT_MAX) return CGRectNull;
    int trackCount = (int)count, selected = 0;
    uint32_t ties = 0;
    CFTimeInterval now = CACurrentMediaTime(), earliest = DBL_MAX;
    dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
    NSArray *infos = _trackNextAvailableTime.allValues;
    for (int index = 0; index < trackCount; index++) {
        CGFloat y = minY + index * height;
        CFTimeInterval available = now;
        for (OCBarrageScheduledTrackInfo *info in infos) {
            if (info.endTime > now && OCBarrageTracksOverlap(info, barrageCell, y)) {
                available = MAX(available, info.nextAvailableTime);
            }
        }
        if (available < earliest) {
            earliest = available;
            selected = index;
            ties = 1;
        } else if (available == earliest && arc4random_uniform(++ties) == 0) {
            selected = index;
        }
    }
    dispatch_semaphore_signal(_trackInfoLock);
    barrageCell.trackIndex = selected;
    frame.origin.y = minY + selected * height;
    return frame;
}

- (void)clearIdleCells {
    dispatch_semaphore_wait(_idleCellsLock, DISPATCH_TIME_FOREVER);
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSEnumerator *enumerator = [self.idleCells reverseObjectEnumerator];
    OCBarrageCell *cell;
    while (cell = [enumerator nextObject]){
        CGFloat time = timeInterval - cell.idleTime;
        if (time > 5.0 && cell.idleTime > 0) {
            [self.idleCells removeObject:cell];
        }
    }
    
    if (self.idleCells.count == 0) {
        _autoClear = NO;
    } else {
        [self performSelector:@selector(clearIdleCells) withObject:nil afterDelay:5.0];
    }
    dispatch_semaphore_signal(_idleCellsLock);
}

- (void)recordTrackInfoWithBarrageCell:(OCBarrageCell *)cell {
    CAAnimation *animation = [cell.barrageAnimation copy];
    if (!CGPointEqualToPoint(cell.layer.anchorPoint, CGPointMake(0.5, 0.5)) ||
        !CATransform3DIsIdentity(cell.layer.transform)) return;
    // 轨道期限以全局秒为单位；自定义祖先速率保留其原始动画时序。
    for (CALayer *layer = cell.layer; layer; layer = layer.superlayer) {
        if (layer.speed != 1) return;
    }
    if (cell.trackIndex < 0 || ![animation isKindOfClass:[CAPropertyAnimation class]] ||
        !isfinite(animation.duration) || animation.duration <= 0 ||
        animation.beginTime != 0 || animation.timeOffset != 0 || animation.speed != 1 ||
        animation.autoreverses || animation.repeatDuration != 0 ||
        (animation.repeatCount != 0 && animation.repeatCount != 1) ||
        !OCBarrageTimingIsLinear(animation.timingFunction) ||
        cell.layer.speed != 1 || cell.layer.timeOffset != 0) return;
    CAPropertyAnimation *propertyAnimation = (CAPropertyAnimation *)animation;
    if (![propertyAnimation.keyPath isEqualToString:@"position"] ||
        propertyAnimation.additive || propertyAnimation.cumulative || propertyAnimation.valueFunction) return;

    NSValue *fromValue, *toValue;
    if ([animation isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *basic = (CABasicAnimation *)animation;
        if (basic.byValue) return;
        fromValue = basic.fromValue;
        toValue = basic.toValue;
    } else if ([animation isKindOfClass:[CAKeyframeAnimation class]]) {
        CAKeyframeAnimation *keyframe = (CAKeyframeAnimation *)animation;
        if (keyframe.path || keyframe.values.count != 2 || keyframe.rotationMode ||
            ![keyframe.calculationMode isEqualToString:kCAAnimationLinear]) return;
        if (keyframe.keyTimes && (keyframe.keyTimes.count != 2 ||
            [keyframe.keyTimes.firstObject doubleValue] != 0 || [keyframe.keyTimes.lastObject doubleValue] != 1)) return;
        if (keyframe.timingFunctions.count > 1 || !OCBarrageTimingIsLinear(keyframe.timingFunctions.firstObject)) return;
        fromValue = keyframe.values.firstObject;
        toValue = keyframe.values.lastObject;
    } else {
        return;
    }
    if (![fromValue isKindOfClass:[NSValue class]] || ![toValue isKindOfClass:[NSValue class]] ||
        strcmp(fromValue.objCType, @encode(CGPoint)) || strcmp(toValue.objCType, @encode(CGPoint))) return;
    CGPoint from = fromValue.CGPointValue, to = toValue.CGPointValue;
    CGFloat width = CGRectGetWidth(cell.bounds);
    CGFloat entryX = from.x - width / 2, exitX = to.x + width / 2;
    if (!isfinite(from.x) || !isfinite(from.y) || !isfinite(to.x) || !isfinite(to.y) ||
        from.x <= to.x || fabs(from.y - to.y) > 0.001 ||
        fabs(from.y - cell.layer.position.y) > 0.001 ||
        fabs(entryX - CGRectGetMaxX(self.bounds)) > 0.001 ||
        fabs(exitX - CGRectGetMinX(self.bounds)) > 0.001) return;
    CGFloat speed = (from.x - to.x) / animation.duration;
    if (!isfinite(speed) || speed <= 0) return;

    CGFloat originY = CGRectGetMinY(cell.frame), height = CGRectGetHeight(cell.bounds);
    CFTimeInterval now = CACurrentMediaTime(), start = now;
    dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
    for (NSString *key in _trackNextAvailableTime.allKeys) {
        OCBarrageScheduledTrackInfo *info = _trackNextAvailableTime[key];
        if (info.endTime <= now) {
            [_trackNextAvailableTime removeObjectForKey:key];
            continue;
        }
        if (!OCBarrageTracksOverlap(info, cell, originY)) continue;
        // 同时约束入口间距和前车离屏时的间距，避免快弹幕追上慢弹幕。
        CFTimeInterval clearsEntry = info.startTime + (info.tailStartX - entryX) / info.speed;
        CFTimeInterval avoidsCatch = info.endTime - (entryX - info.tailEndX) / speed;
        CFTimeInterval available = MIN(info.endTime, MAX(info.startTime, MAX(clearsEntry, avoidsCatch))) + 0.1;
        start = MAX(start, available);
    }
    // 分档打乱行顺序，再加小抖动；同批相邻轨道不会整列齐发。
    start += 0.05 + ((cell.trackIndex % 8) * 5 % 8) * 0.08 + arc4random_uniform(20001) / 1000000.0;
    NSString *identifier = [NSString stringWithFormat:@"%@_%.17g_%.17g_%.17g_%.17g",
                            NSStringFromClass([cell class]), (double)originY, (double)height, (double)entryX, (double)exitX];
    OCBarrageScheduledTrackInfo *info = [[OCBarrageScheduledTrackInfo alloc] init];
    info.cellClass = [cell class];
    info.trackIdentifier = identifier;
    info.trackIndex = cell.trackIndex;
    info.originY = originY;
    info.trackHeight = height;
    info.tailStartX = from.x + width / 2;
    info.tailEndX = exitX;
    info.speed = speed;
    info.startTime = start;
    info.endTime = start + animation.duration;
    info.nextAvailableTime = start + width / speed + 0.1;
    _trackNextAvailableTime[identifier] = info;
    dispatch_semaphore_signal(_trackInfoLock);

    animation.beginTime = [cell.layer convertTime:start fromLayer:nil];
    [cell.layer addAnimation:animation forKey:kBarrageAnimation];
}


#pragma mark ----- CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
    
    if (self.renderStatus == OCBarrageRenderStoped) {
        return;
    }
    OCBarrageCell *animationedCell = nil;
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    for (OCBarrageCell *cell in self.animatingCells) {
        CAAnimation *barrageAnimation = [cell barrageAnimation];
        if (barrageAnimation == anim) {
            animationedCell = cell;
            [self.animatingCells removeObject:cell];
            break;
        }
    }
    dispatch_semaphore_signal(_animatingCellsLock);
    
    if (!animationedCell) {
        return;
    }
    
    [animationedCell removeFromSuperview];
    [animationedCell prepareForReuse];
    
    dispatch_semaphore_wait(_idleCellsLock, DISPATCH_TIME_FOREVER);
    animationedCell.idleTime = [[NSDate date] timeIntervalSince1970];
    [self.idleCells addObject:animationedCell];
    dispatch_semaphore_signal(_idleCellsLock);
    
    if (!_autoClear) {
        [self performSelector:@selector(clearIdleCells) withObject:nil afterDelay:5.0];
        _autoClear = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [touches.allObjects firstObject];
        CGPoint touchPoint = [touch locationInView:self];
        OCBarrageCell *touchedCell = nil;

        dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
        NSInteger count = self.animatingCells.count;
        for (NSInteger i = 0; i < count; i++) {
            OCBarrageCell *barrageCell = [self.animatingCells objectAtIndex:i];
            if ([barrageCell.layer.presentationLayer hitTest:touchPoint]) {
                touchedCell = barrageCell;
                break;
            }
        }
        dispatch_semaphore_signal(_animatingCellsLock);

        // 回调可能调用 pause、stop 或发送新弹幕，必须在释放活动列表锁后执行。
        if (touchedCell.barrageDescriptor.touchAction) {
            touchedCell.barrageDescriptor.touchAction(touchedCell.barrageDescriptor);
        }
        if (touchedCell.barrageDescriptor.cellTouchedAction) {
            touchedCell.barrageDescriptor.cellTouchedAction(touchedCell.barrageDescriptor, touchedCell);
        }
    }
}

#pragma mark ----- getter
- (NSMutableArray<OCBarrageCell *> *)animatingCells {
    if (!_animatingCells) {
        _animatingCells = [[NSMutableArray alloc] init];
    }
    
    return _animatingCells;
}

- (NSMutableArray<OCBarrageCell *> *)idleCells {
    if (!_idleCells) {
        _idleCells = [[NSMutableArray alloc] init];
    }
    
    return _idleCells;
}

- (OCBarrageRenderStatus)renderStatus {
    return _renderStatus;
}

@end


