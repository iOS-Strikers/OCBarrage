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
    if (!_textLabel) {
        [self addSubview:self.textLabel];
    }
    if (self.textDescriptor.textShadowOpened) {
        self.textLabel.layer.shadowColor = self.textDescriptor.shadowColor.CGColor;
        self.textLabel.layer.shadowOffset = self.textDescriptor.shadowOffset;
        self.textLabel.layer.shadowRadius = self.textDescriptor.shadowRadius;
        self.textLabel.layer.shadowOpacity = self.textDescriptor.shadowOpacity;
    }
    
    [self.textLabel setAttributedText:self.textDescriptor.attributedText];
}

- (void)layoutContentSubviews {
    CGRect textFrame = [self.textDescriptor.attributedText.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[self.textDescriptor.attributedText attributesAtIndex:0 effectiveRange:NULL] context:nil];
    self.textLabel.frame = textFrame;
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:_textLabel.frame.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
    _textLabel = nil;
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
    CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
    
    CGFloat animationDuration = self.barrageDescriptor.animationDuration;
    if (self.barrageDescriptor.fixedSpeed > 0.0) {//如果是固定速度那就用固定速度
        if (self.barrageDescriptor.fixedSpeed > 100.0) {
            self.barrageDescriptor.fixedSpeed = 100.0;
        }
        animationDuration = (startCenter.x - endCenter.x)/([UIScreen mainScreen].scale*2)/self.barrageDescriptor.fixedSpeed;
    }
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(1.0)];
    walkAnimation.duration = animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    walkAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _textLabel;
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.textDescriptor = (OCBarrageTextDescriptor *)barrageDescriptor;
}

@end
