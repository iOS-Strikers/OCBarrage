//
//  OCBarrageBackgroundColorTextCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageGradientBackgroundColorCell.h"

@implementation OCBarrageGradientBackgroundColorCell

- (void)updateSubviewsData {
    [self updateTextlayerContentAndBounds];
    [self addGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textlayer.frame = _gradientLayer.frame;
}

- (void)addGradientLayer {
    if (!self.gradientDescriptor.gradientColor) {
        return;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[self.gradientDescriptor.gradientColor colorWithAlphaComponent:0.8].CGColor, (__bridge id)[self.gradientDescriptor.gradientColor colorWithAlphaComponent:0.0].CGColor];
    gradientLayer.locations = @[@0.2, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = CGRectMake(0.0, 0.0, _textlayer.frame.size.width + 20.0, _textlayer.frame.size.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:gradientLayer.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:gradientLayer.bounds.size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = gradientLayer.bounds;
    maskLayer.path = maskPath.CGPath;
    gradientLayer.mask = maskLayer;
    _gradientLayer = gradientLayer;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    [self convertContentToImageWithSize:gradientLayer.frame.size];
    _gradientLayer = nil;
    _textlayer = nil;
}



- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gradientDescriptor = (OCBarrageGradientBackgroundColorDescriptor *)barrageDescriptor;
}

@end
