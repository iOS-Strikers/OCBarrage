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
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}

- (void)updateSubviewsData {
    [super updateSubviewsData];
    
    [self addGradientLayer];
    _textlayer.backgroundColor = [UIColor blackColor].CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textlayer.frame = _gradientLayer.frame;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [_textlayer removeFromSuperlayer];
    [_gradientLayer removeFromSuperlayer];
    _textlayer = nil;
    _gradientLayer = nil;
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
    
    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, 0.0, [UIScreen mainScreen].scale);
    //self为需要截屏的UI控件 即通过改变此参数可以截取特定的UI控件
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.layer setContents:(id)image.CGImage];
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gradientDescriptor = (OCBarrageGradientBackgroundColorDescriptor *)barrageDescriptor;
}

@end
