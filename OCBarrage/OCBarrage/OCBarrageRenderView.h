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

typedef NS_ENUM(NSInteger, OCBarrageRenderStatus) {
    OCBarrageRenderStoped = 0,
    OCBarrageRenderStarted,
    OCBarrageRenderPaused
};

@interface OCBarrageRenderView : UIView <CAAnimationDelegate> {
    @protected
    NSMutableDictionary *_barrageCellStyleClass;
    NSMutableArray<OCBarrageCell *> *_animatingCells;
    NSMutableArray<OCBarrageCell *> *_idleCells;
    dispatch_semaphore_t _animatingCellsLock;
    dispatch_semaphore_t _idleCellsLock;
    OCBarrageCell *_lastestCell;
    UIView *_lowPositionView;
    UIView *_heightPositionView;
    BOOL _autoClear;
    OCBarrageRenderStatus _renderStatus;
}

@property (nonatomic, strong, readonly) NSMutableArray<OCBarrageCell *> *animatingCells;
@property (nonatomic, strong, readonly) NSMutableArray<OCBarrageCell *> *idleCells;
@property (nonatomic, assign) OCBarrageRenderPositionStyle renderPositionStyle;
@property (nonatomic, assign, readonly) OCBarrageRenderStatus renderStatus;

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withBarrageIndentifier:(NSString *)barrageIndentifier;
- (nullable OCBarrageCell *)cellWithBarrageIndentifier:(NSString *)barrageIndentifier;
- (void)fireBarrageCell:(OCBarrageCell *)barrageCell;

- (void)start;
- (void)puase;
- (void)resume;
- (void)stop;


@end

NS_ASSUME_NONNULL_END
