//
//  OCBarrageTrackInfo.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageTrackInfo : NSObject

@property (nonatomic, assign) int trackIndex;
@property (nonatomic, copy, nullable) NSString *trackIdentifier;
@property (nonatomic, assign) CFTimeInterval nextAvailableTime;//下次可用的时间
@property (nonatomic, assign) NSInteger barrageCount;//当前行的弹幕数量
@property (nonatomic, assign) CGFloat trackHeight;//轨道高度

@end

NS_ASSUME_NONNULL_END
