//
//  OCBarrageTextCell.m
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextCell.h"

@implementation OCBarrageTextCell

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)updateSubviewsData {
    if (!_textlayer) {
        [self.layer addSublayer:self.textlayer];
    }
    if (self.textDescriptor.textShadowOpened) {
        self.textlayer.shadowColor = self.textDescriptor.shadowColor.CGColor;
        self.textlayer.shadowOffset = self.textDescriptor.shadowOffset;
        self.textlayer.shadowRadius = self.textDescriptor.shadowRadius;
        self.textlayer.shadowOpacity = self.textDescriptor.shadowOpacity;
    }
    
    [self.textlayer setString:self.textDescriptor.attributedText];
}

- (void)layoutContentViews {
    self.textlayer.frame = CGRectMake(0.0, 0.0, [self.textDescriptor.attributedText size].width, [self.textDescriptor.attributedText size].height);
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:_textlayer.frame.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
    _textlayer = nil;
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

- (CATextLayer *)textlayer {
    if (!_textlayer) {
        _textlayer = [[CATextLayer alloc] init];
        _textlayer.contentsScale = [UIScreen mainScreen].scale;
        _textlayer.alignmentMode = @"center";
    }
    
    return _textlayer;
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.textDescriptor = (OCBarrageTextDescriptor *)barrageDescriptor;
}

@end
