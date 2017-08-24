//
//  OCBarrageHeader.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#ifndef OCBarrageHeader_h
#define OCBarrageHeader_h

#define kBarrageAnimation @"kBarrageAnimation"
@class OCBarrageDescriptor;

typedef NS_ENUM(NSInteger, OCBarrageStyleType) {
    OCBarrageStyleText = 0,
    OCBarrageStyleTextAndBackgroundImage
};

typedef void(^OCBarrageTouchAction)(__weak OCBarrageDescriptor  *descriptor);

typedef NS_ENUM(NSInteger, OCBarragePositionPriority) {
    OCBarragePositionLow = 0,
    OCBarragePositionMiddle,
    OCBarragePositionHeight,
    OCBarragePositionVeryHeight
};

typedef NS_ENUM(NSInteger, OCBarrageRenderPositionStyle) {//新加的cell的y坐标的类型
    OCBarrageRenderPositionRandom = 0, // y坐标随机
    OCBarrageRenderPositionIncrease, //y坐标递增
    OCBarrageRenderPositionFollow // 不与前一条弹幕重叠的情况下渲染在同一行
};

#endif /* OCBarrageHeader_h */
