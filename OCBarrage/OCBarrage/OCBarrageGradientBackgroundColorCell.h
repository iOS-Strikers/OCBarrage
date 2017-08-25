//
//  OCBarrageBackgroundColorTextCell.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextCell.h"
#import "OCBarrageGradientBackgroundColorDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageGradientBackgroundColorCell : OCBarrageTextCell {
    CAGradientLayer *_gradientLayer;
}

@property (nonatomic, strong, nullable) OCBarrageGradientBackgroundColorDescriptor *gradientDescriptor;

@end

NS_ASSUME_NONNULL_END
