//
//  OCBarrageContentView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageRenderView.h"

@implementation OCBarrageRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
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

- (nullable OCBarrageCell *)cellWithStyle:(OCBarrageStyleType)barrageStyle {
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
    }
    dispatch_semaphore_signal(_idleCellsLock);
    
    return barrageCell;
}

- (void)fireBarrageCell:(OCBarrageCell *)barrageCell {
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
    
    switch (barrageCell.barrageDescriptor.positionPriority) {
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
    
    CGRect cellFrame = barrageCell.bounds;
    cellFrame.origin.x = CGRectGetMaxX(self.frame);
    if (barrageCell.barrageDescriptor.bindingOriginY >= 0.0) {
        cellFrame.origin.y = barrageCell.barrageDescriptor.bindingOriginY;
    } else {
        switch (self.renderPositionStyle) {
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
                CGFloat maxY = CGRectGetHeight(self.bounds) - CGRectGetHeight(cellFrame);
                NSInteger originY = floorl(maxY);
                cellFrame.origin.y = arc4random()%originY;
            }
                break;
        }
    }
    
    if (CGRectGetMaxY(cellFrame) > CGRectGetMaxY(self.superview.bounds)) {
        cellFrame.origin.y = 0.0; //超过底部, 回到顶部
    } else if (cellFrame.origin.y  < 0) {
        cellFrame.origin.y = 0.0;
    }
    
    barrageCell.frame = cellFrame;
    
    [barrageCell addBarrageAnimationWithDelegate:self];
    _lastestCell = barrageCell;
}

#pragma mark ----- CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
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
    [self.idleCells addObject:animationedCell];
    dispatch_semaphore_signal(_idleCellsLock);
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

@end


