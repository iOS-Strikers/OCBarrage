//
//  OCBarrageWalkBannerCell.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextCell.h"
#import "OCBarrageWalkBannerDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageWalkBannerCell : OCBarrageTextCell {
    CGRect _contentRect;
}

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *middleImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) OCBarrageWalkBannerDescriptor *walkBannerDescriptor;

@end

NS_ASSUME_NONNULL_END
