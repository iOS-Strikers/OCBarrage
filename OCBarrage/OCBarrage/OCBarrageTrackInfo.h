//
//  OCBarrageTrackInfo.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCBarrageTrackInfo : NSObject

@property (nonatomic, assign) int trackIndex;
@property (nonatomic, copy) NSString *trackIdentifier;
@property (nonatomic, assign) CFTimeInterval nextAvailableTime;//下次可用的时间
@property (nonatomic, assign) NSInteger barrageCount;//下次可用的时间

@end
