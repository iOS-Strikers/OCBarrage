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
@class OCBarrageCell;

typedef void(^OCBarrageTouchAction)(__weak OCBarrageDescriptor *descriptor);
typedef void(^OCBarrageCellTouchedAction)(__weak OCBarrageDescriptor *descriptor, __weak OCBarrageCell *cell);

typedef NS_ENUM(NSInteger, OCBarragePositionPriority) {
    OCBarragePositionLow = 0,
    OCBarragePositionMiddle,
    OCBarragePositionHigh,
    OCBarragePositionVeryHigh
};

typedef NS_ENUM(NSInteger, OCBarrageRenderPositionStyle) {//新加的cell的y坐标的类型
    OCBarrageRenderPositionRandomTracks = 0, //将OCBarrageRenderView分成几条轨道, 随机选一条展示
    OCBarrageRenderPositionRandom, // y坐标随机
    OCBarrageRenderPositionIncrease, //y坐标递增, 循环
};

#endif /* OCBarrageHeader_h */
