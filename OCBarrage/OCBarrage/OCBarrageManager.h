//
//  OCBarrageView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBarrageRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageManager : NSObject {
    @protected
    OCBarrageRenderView *_renderView;
    NSMutableDictionary *_barrageCellStyleClass;
    NSDate *_startTime; //如果是nil,表示弹幕渲染不在运行中; 否则,表示开始的时间
    NSTimeInterval _pausedDuration; // 暂停持续时间
    NSDate * _pausedTime; // 上次暂停时间; 如果为nil, 说明当前没有暂停
}

@property (nonatomic, strong, readonly) OCBarrageRenderView *renderView;

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withStyle:(OCBarrageStyleType)barrageStyle;

- (void)start;
- (void)puase;
- (void)resume;
- (void)stop;

- (void)addBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor;


@end

NS_ASSUME_NONNULL_END
