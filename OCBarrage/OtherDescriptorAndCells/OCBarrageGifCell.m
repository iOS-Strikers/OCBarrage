//
//  OCBarrageGifCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/31.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageGifCell.h"

@implementation OCBarrageGifCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    
    return self;
}

- (void)addSubviews {
    [self addSubview:self.imageView];
}

- (void)updateSubviewsData {
    self.imageView.image = self.gifDescriptor.image;
}

- (void)layoutContentSubviews {
    self.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
    CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(1.0)];
    walkAnimation.duration = self.barrageDescriptor.animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    walkAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

- (void)removeSubViewsAndSublayers {

}

#pragma mark ---- setter
- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.gifDescriptor = (OCBarrageGifDescriptor *)barrageDescriptor;
}

#pragma mark ---- getter

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.autoPlayAnimatedImage = YES;
    }
    
    return _imageView;
}

@end
