//
//  OCBarrageBackgroundColorTextCell.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextCell.h"
#import "OCBarrageGradientBackgroundColorDescriptor.h"

@interface OCBarrageGradientBackgroundColorCell : OCBarrageTextCell {
    CAGradientLayer *_gradientLayer;
}

@property (nonatomic, strong, nullable) OCBarrageGradientBackgroundColorDescriptor *gradientDescriptor;
@property (nonatomic, strong, nullable) UIColor *gradientColor;

@end
