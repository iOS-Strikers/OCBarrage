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

- (void)updateSubviewsData {
    [super updateSubviewsData];
    self.gradientColor = self.gradientDescriptor.gradientColor;
    [self addGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textlayer.frame = _gradientLayer.frame;
}

- (void)addGradientLayer {
    if (!self.gradientColor) {
        return;
    }
    
    if (!_gradientLayer) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[self.gradientColor colorWithAlphaComponent:0.8].CGColor, (__bridge id)[self.gradientColor colorWithAlphaComponent:0.0].CGColor];
        gradientLayer.locations = @[@0.2, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1.0, 0);
        gradientLayer.frame = CGRectMake(0.0, 0.0, _textlayer.frame.size.width + 20.0, _textlayer.frame.size.height);
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:gradientLayer.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:gradientLayer.bounds.size];
        
        _gradientLayer = gradientLayer;
        [self.layer insertSublayer:gradientLayer atIndex:0];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = gradientLayer.bounds;
        maskLayer.path = maskPath.CGPath;
        gradientLayer.mask = maskLayer;
        
//        UIGraphicsBeginImageContext(gradientLayer.frame.size);
//        //self为需要截屏的UI控件 即通过改变此参数可以截取特定的UI控件
//        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        //至此已拿到image
//        UIImageView *imaView = [[UIImageView alloc] initWithImage:image];
//        imaView.frame = CGRectMake(0, 100, 100.0, 100.0);
//        [[UIApplication sharedApplication].keyWindow addSubview:imaView];
    }
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gradientDescriptor = (OCBarrageGradientBackgroundColorDescriptor *)barrageDescriptor;
}

@end
