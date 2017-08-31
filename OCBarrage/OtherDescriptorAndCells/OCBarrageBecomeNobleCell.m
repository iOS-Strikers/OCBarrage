//
//  OCBarrageBecomeNobleCell.m
//  QuanMinTV
//
//  Created by QMTV on 2017/8/31.
//  Copyright © 2017年 QMTV. All rights reserved.
//

#import "OCBarrageBecomeNobleCell.h"

@implementation OCBarrageBecomeNobleCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addsublayers];
    }
    
    return self;
}

- (void)addsublayers {
    [self.layer insertSublayer:self.backgroundImageLayer atIndex:0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self addsublayers];
}

- (void)updateSubviewsData {
    [super updateSubviewsData];
    
    [self.backgroundImageLayer setContents:(__bridge id)self.nobleDescriptor.backgroundImage.CGImage];
}

- (void)layoutContentSubviews {
    [super layoutContentSubviews];
 
    self.backgroundImageLayer.frame = CGRectMake(0.0, 0.0, self.nobleDescriptor.backgroundImage.size.width, self.nobleDescriptor.backgroundImage.size.height);
    CGPoint center = self.backgroundImageLayer.position;
    center.y += 17.0;
    self.textLabel.center = center;
}

- (void)convertContentToImage {
    UIImage *image = [self.layer convertContentToImageWithSize:CGSizeMake(self.nobleDescriptor.backgroundImage.size.width, self.nobleDescriptor.backgroundImage.size.height)];
    [self.layer setContents:(__bridge id)image.CGImage];
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
    CGPoint stopCenter = CGPointMake(CGRectGetMidX(self.superview.bounds), self.center.y);
    CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:stopCenter], [NSValue valueWithCGPoint:stopCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(0.25), @(0.75), @(1.0)];
    walkAnimation.duration = self.barrageDescriptor.animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    walkAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

#pragma mark ---- setter
- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.nobleDescriptor = (OCBarrageBecomeNobleDescriptor *)barrageDescriptor;
}

#pragma mark ---- getter
- (CALayer *)backgroundImageLayer {
    if (!_backgroundImageLayer) {
        _backgroundImageLayer = [[CALayer alloc] init];
    }
    
    return _backgroundImageLayer;
}

@end
