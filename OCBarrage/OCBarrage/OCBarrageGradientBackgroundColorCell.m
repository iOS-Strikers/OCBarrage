//
//  OCBarrageBackgroundColorTextCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageGradientBackgroundColorCell.h"

@implementation OCBarrageGradientBackgroundColorCell

- (instancetype)initWithBarrageIndentifier:(NSString *)barrageIndentifier {
    self = [super initWithBarrageIndentifier:barrageIndentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setGradientColor:(UIColor *)gradientColor {
    _gradientColor = gradientColor;
    if (!self.gradientColor) {
        return;
    }
    
    if (_gradientLayer) {
        [_gradientLayer removeFromSuperlayer];
    }
    
    [self addGradientLayer];
}

- (void)updateSubviewsData {
    [super updateSubviewsData];
    self.gradientColor = self.gradientDescriptor.gradientColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _gradientLayer.frame = CGRectMake(0.0, 0.0, _textlayer.frame.size.width + 20.0, _textlayer.frame.size.height);
}

- (void)addGradientLayer {
    if (!self.gradientColor) {
        return;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[self.gradientColor colorWithAlphaComponent:0.8].CGColor, (__bridge id)[self.gradientColor colorWithAlphaComponent:0.0].CGColor];
    gradientLayer.locations = @[@0.2, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = CGRectMake(0.0, 0.0, _textlayer.frame.size.width + 20.0, _textlayer.frame.size.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:gradientLayer.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:gradientLayer.bounds.size];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = gradientLayer.bounds;
    maskLayer.path = maskPath.CGPath;
    gradientLayer.mask = maskLayer;
    [self.layer insertSublayer:gradientLayer below:_textlayer];
    _gradientLayer = gradientLayer;
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gradientDescriptor = (OCBarrageGradientBackgroundColorDescriptor *)barrageDescriptor;
}

@end
