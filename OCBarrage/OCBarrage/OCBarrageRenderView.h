//
//  OCBarrageContentView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBarrageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageRenderView : UIView <CAAnimationDelegate> {
    @protected
    NSMutableArray<OCBarrageCell *> *_animatingCells;
    NSMutableArray<OCBarrageCell *> *_idleCells;
    dispatch_semaphore_t _animatingCellsLock;
    dispatch_semaphore_t _idleCellsLock;
    OCBarrageCell *_lastestCell;
    UIView *_lowPositionView;
    UIView *_heightPositionView;
}
@property (nonatomic, strong, readonly) NSMutableArray<OCBarrageCell *> *animatingCells;
@property (nonatomic, strong, readonly) NSMutableArray<OCBarrageCell *> *idleCells;
@property (nonatomic, assign) OCBarrageRenderPositionStyle renderPositionStyle;
- (nullable OCBarrageCell *)cellWithStyle:(OCBarrageStyleType)barrageStyle;
- (void)fireBarrageCell:(OCBarrageCell *)barrageCell;

@end

NS_ASSUME_NONNULL_END
