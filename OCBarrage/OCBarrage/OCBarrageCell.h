//
//  OCBarrageCell.h
//  TestApp
//
//  Created by QMTV on 2017/8/21.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CALayer+OCBarrage.h"
#import "OCBarrageDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OCBarrageCellDelegate;

@interface OCBarrageCell : UIView
@property (nonatomic, assign, getter=isIdle) BOOL idle;//是否是空闲状态
@property (nonatomic, assign) NSTimeInterval idleTime;//开始闲置的时间, 闲置超过5秒的, 自动回收内存
@property (nonatomic, strong, nullable) OCBarrageDescriptor *barrageDescriptor;
@property (nonatomic, strong, readonly, nullable) CAAnimation *barrageAnimation;
@property (nonatomic, assign) int trackIndex;

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate;
- (void)prepareForReuse;
- (void)clearContents;

- (void)updateSubviewsData;
- (void)layoutContentSubviews;
- (void)convertContentToImage;
- (void)sizeToFit;//设置好数据之后调用一下自动计算bounds
- (void)removeSubViewsAndSublayers;//默认删除所有的subview和sublayer; 如果需要选择性的删除可以重写这个方法.
- (void)addBorderAttributes;

@end

@protocol OCBarrageCellDelegate <NSObject, CAAnimationDelegate>

@optional

@end

NS_ASSUME_NONNULL_END
