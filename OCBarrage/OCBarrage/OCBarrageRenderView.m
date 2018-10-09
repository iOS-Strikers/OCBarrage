//
//  OCBarrageContentView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#define kNextAvailableTimeKey(identifier, index) [NSString stringWithFormat:@"%@_%d", identifier, index]

#import "OCBarrageRenderView.h"
#import "OCBarrageTrackInfo.h"

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
        if ([NSStringFromClass([cell class]) isEqualToString:NSStringFromClass(barrageCellClass)]) {
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
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *enumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *cell = nil;
    while (cell = [enumerator nextObject]){
        CFTimeInterval pausedTime = [cell.layer convertTime:CACurrentMediaTime() fromLayer:nil];
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
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *enumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *cell = nil;
    while (cell = [enumerator nextObject]){
        CFTimeInterval pausedTime = cell.layer.timeOffset;
        cell.layer.speed = 1.0;
        cell.layer.timeOffset = 0.0;
        cell.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [cell.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        cell.layer.beginTime = timeSincePause;
    }
    dispatch_semaphore_signal(_animatingCellsLock);
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
    }
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    NSEnumerator *animatingEnumerator = [self.animatingCells reverseObjectEnumerator];
    OCBarrageCell *animatingCell = nil;
    while (animatingCell = [animatingEnumerator nextObject]){
        CFTimeInterval pausedTime = [animatingCell.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        animatingCell.layer.speed = 0.0;
        animatingCell.layer.timeOffset = pausedTime;
        [animatingCell.layer removeAllAnimations];
        [animatingCell removeFromSuperview];
    }
    [self.animatingCells removeAllObjects];
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
    [self.animatingCells addObject:barrageCell];
    barrageCell.idle = NO;
    dispatch_semaphore_signal(_animatingCellsLock);
    
    [self addBarrageCell:barrageCell WithPositionPriority:barrageCell.barrageDescriptor.positionPriority];
    CGRect cellFrame = [self calculationBarrageCellFrame:barrageCell];
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
    CGRect cellFrame = barrageCell.bounds;
    cellFrame.origin.x = CGRectGetMaxX(self.frame);
    
    if (![[NSValue valueWithRange:barrageCell.barrageDescriptor.renderRange] isEqualToValue:[NSValue valueWithRange:NSMakeRange(0, 0)]]) {
        CGFloat cellHeight = CGRectGetHeight(barrageCell.bounds);
        CGFloat minOriginY = barrageCell.barrageDescriptor.renderRange.location;
        CGFloat maxOriginY = barrageCell.barrageDescriptor.renderRange.length;
        if (maxOriginY > CGRectGetHeight(self.bounds)) {
            maxOriginY = CGRectGetHeight(self.bounds);
        }
        if (minOriginY < 0) {
            minOriginY = 0;
        }
        CGFloat renderHeight = maxOriginY - minOriginY;
        if (renderHeight < 0) {
            renderHeight = cellHeight;
        }

        int trackCount = floorf(renderHeight/cellHeight);
        int trackIndex = arc4random_uniform(trackCount);//用户改变行高(比如弹幕文字大小不会引起显示bug, 因为虽然是同一个类, 但是trackCount变小了, 所以不会出现trackIndex*cellHeight超出屏幕边界的情况)
        
        dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
        OCBarrageTrackInfo *trackInfo = [_trackNextAvailableTime objectForKey:kNextAvailableTimeKey(NSStringFromClass([barrageCell class]), trackIndex)];
        if (trackInfo && trackInfo.nextAvailableTime > CACurrentMediaTime()) {//当前行暂不可用
            
            NSMutableArray *availableTrackInfos = [NSMutableArray array];
            for (OCBarrageTrackInfo *info in _trackNextAvailableTime.allValues) {
                if (CACurrentMediaTime() > info.nextAvailableTime && [info.trackIdentifier containsString:NSStringFromClass([barrageCell class])]) {//只在同类弹幕中判断是否有可用的轨道
                    [availableTrackInfos addObject:info];
                }
            }
            if (availableTrackInfos.count > 0) {
                OCBarrageTrackInfo *randomInfo = [availableTrackInfos objectAtIndex:arc4random_uniform((int)availableTrackInfos.count)];
                trackIndex = randomInfo.trackIndex;
            } else {
                if (_trackNextAvailableTime.count < trackCount) {//刚开始不是每一条轨道都跑过弹幕, 还有空轨道
                    NSMutableArray *numberArray = [NSMutableArray array];
                    for (int index = 0; index < trackCount; index++) {
                        OCBarrageTrackInfo *emptyTrackInfo = [_trackNextAvailableTime objectForKey:kNextAvailableTimeKey(NSStringFromClass([barrageCell class]), index)];
                        if (!emptyTrackInfo) {
                            [numberArray addObject:[NSNumber numberWithInt:index]];
                        }
                    }
                    if (numberArray.count > 0) {
                        trackIndex = [[numberArray objectAtIndex:arc4random_uniform((int)numberArray.count)] intValue];
                    }
                }
                //真的是没有可用的轨道了
            }
        }
        dispatch_semaphore_signal(_trackInfoLock);
        
        barrageCell.trackIndex = trackIndex;
        cellFrame.origin.y = trackIndex*cellHeight+minOriginY;
    } else {
        switch (self.renderPositionStyle) {
            case OCBarrageRenderPositionRandom: {
                CGFloat maxY = CGRectGetHeight(self.bounds) - CGRectGetHeight(cellFrame);
                int originY = floorl(maxY);
                cellFrame.origin.y = arc4random_uniform(originY);
            }
                break;
            case OCBarrageRenderPositionIncrease: {
                if (_lastestCell) {
                    CGRect lastestFrame = _lastestCell.frame;
                    cellFrame.origin.y = CGRectGetMaxY(lastestFrame);
                } else {
                    cellFrame.origin.y = 0.0;
                }
            }
                break;
            default: {
                CGFloat renderViewHeight = CGRectGetHeight(self.bounds);
                CGFloat cellHeight = CGRectGetHeight(barrageCell.bounds);
                int trackCount = floorf(renderViewHeight/cellHeight);
                int trackIndex = arc4random_uniform(trackCount);//用户改变行高(比如弹幕文字大小不会引起显示bug, 因为虽然是同一个类, 但是trackCount变小了, 所以不会出现trackIndex*cellHeight超出屏幕边界的情况)
                
                dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
                OCBarrageTrackInfo *trackInfo = [_trackNextAvailableTime objectForKey:kNextAvailableTimeKey(NSStringFromClass([barrageCell class]), trackIndex)];
                if (trackInfo && trackInfo.nextAvailableTime > CACurrentMediaTime()) {//当前行暂不可用
                    NSMutableArray *availableTrackInfos = [NSMutableArray array];
                    for (OCBarrageTrackInfo *info in _trackNextAvailableTime.allValues) {
                        if (CACurrentMediaTime() > info.nextAvailableTime && [info.trackIdentifier containsString:NSStringFromClass([barrageCell class])]) {//只在同类弹幕中判断是否有可用的轨道
                            [availableTrackInfos addObject:info];
                        }
                    }
                    if (availableTrackInfos.count > 0) {
                        OCBarrageTrackInfo *randomInfo = [availableTrackInfos objectAtIndex:arc4random_uniform((int)availableTrackInfos.count)];
                        trackIndex = randomInfo.trackIndex;
                    } else {
                        if (_trackNextAvailableTime.count < trackCount) {//刚开始不是每一条轨道都跑过弹幕, 还有空轨道
                            NSMutableArray *numberArray = [NSMutableArray array];
                            for (int index = 0; index < trackCount; index++) {
                                OCBarrageTrackInfo *emptyTrackInfo = [_trackNextAvailableTime objectForKey:kNextAvailableTimeKey(NSStringFromClass([barrageCell class]), index)];
                                if (!emptyTrackInfo) {
                                    [numberArray addObject:[NSNumber numberWithInt:index]];
                                }
                            }
                            if (numberArray.count > 0) {
                                trackIndex = [[numberArray objectAtIndex:arc4random_uniform((int)numberArray.count)] intValue];
                            }
                        }
                        //真的是没有可用的轨道了
                    }
                }
                dispatch_semaphore_signal(_trackInfoLock);
                
                barrageCell.trackIndex = trackIndex;
                cellFrame.origin.y = trackIndex*cellHeight;
            }
                break;
        }
    }
    
    if (CGRectGetMaxY(cellFrame) > CGRectGetHeight(self.bounds)) {
        cellFrame.origin.y = 0.0; //超过底部, 回到顶部
    } else if (cellFrame.origin.y  < 0) {
        cellFrame.origin.y = 0.0;
    }
    
    return cellFrame;
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

- (void)recordTrackInfoWithBarrageCell:(OCBarrageCell *)barrageCell {
    NSString *nextAvalibleTimeKey = kNextAvailableTimeKey(NSStringFromClass([barrageCell class]), barrageCell.trackIndex);
    CFTimeInterval duration = barrageCell.barrageAnimation.duration;
    NSValue *fromValue = nil;
    NSValue *toValue = nil;
    if ([barrageCell.barrageAnimation isKindOfClass:[CABasicAnimation class]]) {
        fromValue = [(CABasicAnimation *)barrageCell.barrageAnimation fromValue];
        toValue = [(CABasicAnimation *)barrageCell.barrageAnimation toValue];
    } else if ([barrageCell.barrageAnimation isKindOfClass:[CAKeyframeAnimation class]]) {
        fromValue = [[(CAKeyframeAnimation *)barrageCell.barrageAnimation values] firstObject];
        toValue = [[(CAKeyframeAnimation *)barrageCell.barrageAnimation values] lastObject];
    } else {
        
    }
    const char *fromeValueType = [fromValue objCType];
    const char *toValueType = [toValue objCType];
    if (!fromeValueType || !toValueType) {
        return;
    }
    NSString *fromeValueTypeString = [NSString stringWithCString:fromeValueType encoding:NSUTF8StringEncoding];
    NSString *toValueTypeString = [NSString stringWithCString:toValueType encoding:NSUTF8StringEncoding];
    if (![fromeValueTypeString isEqualToString:toValueTypeString]) {
        return;
    }
    if ([fromeValueTypeString containsString:@"CGPoint"]) {
        CGPoint fromPoint = [fromValue CGPointValue];
        CGPoint toPoint = [toValue CGPointValue];
        
        dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
        OCBarrageTrackInfo *trackInfo = [_trackNextAvailableTime objectForKey:nextAvalibleTimeKey];
        if (!trackInfo) {
            trackInfo = [[OCBarrageTrackInfo alloc] init];
            trackInfo.trackIdentifier = nextAvalibleTimeKey;
            trackInfo.trackIndex = barrageCell.trackIndex;
        }
        trackInfo.barrageCount++;
        
        trackInfo.nextAvailableTime = CGRectGetWidth(barrageCell.bounds);
        CGFloat distanceX = fabs(toPoint.x - fromPoint.x);
        CGFloat distanceY = fabs(toPoint.y - fromPoint.y);
        CGFloat distance = MAX(distanceX, distanceY);
        CGFloat speed = distance/duration;
        if (distanceX == distance) {
            CFTimeInterval time = CGRectGetWidth(barrageCell.bounds)/speed;
            trackInfo.nextAvailableTime = CACurrentMediaTime() + time + 0.1;//多加一点时间
            [_trackNextAvailableTime setValue:trackInfo forKey:nextAvalibleTimeKey];
        } else if (distanceY == distance) {
            //            CFTimeInterval time = CGRectGetHeight(barrageCell.bounds)/speed;
            
        } else {
            
        }
        dispatch_semaphore_signal(_trackInfoLock);
        return;
    } else if ([fromeValueTypeString containsString:@"CGVector"]) {
        
        return;
    } else if ([fromeValueTypeString containsString:@"CGSize"]) {
        
        return;
    } else if ([fromeValueTypeString containsString:@"CGRect"]) {
        
        return;
    } else if ([fromeValueTypeString containsString:@"CGAffineTransform"]) {
        
        return;
    } else if ([fromeValueTypeString containsString:@"UIEdgeInsets"]) {
        
        return;
    } else if ([fromeValueTypeString containsString:@"UIOffset"]) {
        
        return;
    }
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
    
    dispatch_semaphore_wait(_trackInfoLock, DISPATCH_TIME_FOREVER);
    OCBarrageTrackInfo *trackInfo = [_trackNextAvailableTime objectForKey:kNextAvailableTimeKey(NSStringFromClass([animationedCell class]), animationedCell.trackIndex)];
    if (trackInfo) {
        trackInfo.barrageCount--;
    }
    dispatch_semaphore_signal(_trackInfoLock);
    
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
        
        dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
        NSInteger count = self.animatingCells.count;
        for (int i = 0; i < count; i++) {
            OCBarrageCell *barrageCell = [self.animatingCells objectAtIndex:i];
            if ([barrageCell.layer.presentationLayer hitTest:touchPoint]) {
                if (barrageCell.barrageDescriptor.touchAction) {
                    barrageCell.barrageDescriptor.touchAction(barrageCell.barrageDescriptor);
                }
                if (barrageCell.barrageDescriptor.cellTouchedAction) {
                    barrageCell.barrageDescriptor.cellTouchedAction(barrageCell.barrageDescriptor, barrageCell);
                }
                break;
            }
        }
        dispatch_semaphore_signal(_animatingCellsLock);
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


