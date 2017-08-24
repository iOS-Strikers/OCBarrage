//
//  OCBarrageContentView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageRenderView.h"

@implementation OCBarrageRenderView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _barrageCellStyleClass = [NSMutableDictionary dictionary];
        _animatingCellsLock = dispatch_semaphore_create(1);
        _idleCellsLock = dispatch_semaphore_create(1);
        _lowPositionView = [[UIView alloc] init];
        [self addSubview:_lowPositionView];
        _heightPositionView = [[UIView alloc] init];
        [self addSubview:_heightPositionView];
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withStyle:(OCBarrageStyleType)barrageStyle {
    [_barrageCellStyleClass setValue:barrageCellClass forKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:barrageStyle]]];
}

- (OCBarrageCell *)cellWithStyle:(OCBarrageStyleType)barrageStyle {
    OCBarrageCell *barrageCell = nil;
    
    dispatch_semaphore_wait(_idleCellsLock, DISPATCH_TIME_FOREVER);
    for (OCBarrageCell *cell in self.idleCells) {
        if (cell.cellStyle == barrageStyle) {
            barrageCell = cell;
            break;
        }
    }
    if (barrageCell) {
        [self.idleCells removeObject:barrageCell];
    } else {
        barrageCell = [self cellWithBarrageStyle:barrageStyle];
    }
    dispatch_semaphore_signal(_idleCellsLock);
    barrageCell.idleTime = 0.0;
    
    return barrageCell;
}

- (OCBarrageCell *)cellWithBarrageStyle:(OCBarrageStyleType)barrageStyle {
    Class barrageCellClass = [_barrageCellStyleClass valueForKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:barrageStyle]]];
    if (barrageCellClass == nil || barrageCellClass == NULL) {
        barrageCellClass = [OCBarrageCell class];
    }
    OCBarrageCell *barrageCell = [(OCBarrageCell *)[barrageCellClass alloc] initWithStyle:barrageStyle];
    
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

- (void)puase {
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
    
    [barrageCell updateSubviewsData];
    [barrageCell sizeToFit];
    
    dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
    _lastestCell = [self.animatingCells lastObject];
    [self.animatingCells addObject:barrageCell];
    barrageCell.idle = NO;
    dispatch_semaphore_signal(_animatingCellsLock);
    
    [self addBarrageCell:barrageCell WithPositionPriority:barrageCell.barrageDescriptor.positionPriority];
    barrageCell.frame = [self calculationBarrageCellFrame:barrageCell];
    
    [barrageCell addBarrageAnimationWithDelegate:self];
    _lastestCell = barrageCell;
}

- (void)addBarrageCell:(OCBarrageCell *)barrageCell WithPositionPriority:(OCBarragePositionPriority)positionPriority {
    switch (positionPriority) {
        case OCBarragePositionMiddle: {
            [self insertSubview:barrageCell aboveSubview:_lowPositionView];
        }
            break;
        case OCBarragePositionHeight: {
            [self insertSubview:barrageCell belowSubview:_heightPositionView];
        }
            break;
        case OCBarragePositionVeryHeight: {
            [self insertSubview:barrageCell aboveSubview:_heightPositionView];
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
    if (barrageCell.barrageDescriptor.bindingOriginY >= 0.0) {
        cellFrame.origin.y = barrageCell.barrageDescriptor.bindingOriginY;
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
                int trackNumber = floorf(renderViewHeight/cellHeight);
                cellFrame.origin.y = (arc4random()%(trackNumber+1))*cellHeight;
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

#pragma mark ----- CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
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

        dispatch_semaphore_wait(_animatingCellsLock, DISPATCH_TIME_FOREVER);
        NSInteger count = self.animatingCells.count;
        for (int i = 0; i < count; i++) {
            OCBarrageCell *barrageCell = [self.animatingCells objectAtIndex:i];
            if ([barrageCell.layer.presentationLayer hitTest:touchPoint]) {
                if (barrageCell.barrageDescriptor.touchAction) {
                    barrageCell.barrageDescriptor.touchAction(barrageCell.barrageDescriptor);
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


