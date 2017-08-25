//
//  OCBarrageCell.h
//  TestApp
//
//  Created by QMTV on 2017/8/21.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBarrageDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OCBarrageCellDelegate;

@interface OCBarrageCell : UIView {
    NSString *_barrageIndentifier;
}

@property (nonatomic, assign, getter=isIdle) BOOL idle;//是否是空闲状态
@property (nonatomic, assign) NSTimeInterval idleTime;//开始闲置的时间, 闲置超过5秒的, 自动回收内存
@property (nonatomic, copy, readonly) NSString *barrageIndentifier;
@property (nonatomic, strong, nullable) OCBarrageDescriptor *barrageDescriptor;
@property (nonatomic, strong, readonly) CAAnimation *barrageAnimation;
@property (nonatomic, assign) int trackIndex;

- (instancetype)initWithBarrageIndentifier:(NSString *)barrageIndentifier;
- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate;
- (void)updateSubviewsData;
- (void)sizeToFit;//设置好数据之后调用一下自动计算bounds
- (void)prepareForReuse;

@end

@protocol OCBarrageCellDelegate <NSObject, CAAnimationDelegate>

@optional

@end

NS_ASSUME_NONNULL_END
