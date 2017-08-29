//
//  OCBarrageWalkBannerDescriptor.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageWalkBannerDescriptor : OCBarrageTextDescriptor

@property (nonatomic, copy) NSString *bannerLeftImageSrc;
@property (nonatomic, strong) UIColor *bannerMiddleColor;
@property (nonatomic, copy) NSString *bannerRightImageSrc;

@end

NS_ASSUME_NONNULL_END
