//
//  OCBarrageWalkBannerCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//
#define ImageWidth 89.0
#define ImageHeight 57.0

#import "OCBarrageWalkBannerCell.h"

@implementation OCBarrageWalkBannerCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    //因为在点击的时候被改为了红色, 所以在重用的时候, 要重置一下颜色
    self.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)addSubviews {
    [self addSubview:self.leftImageView];
    [self addSubview:self.middleImageView];
    [self addSubview:self.rightImageView];
}

- (void)updateSubviewsData {
    [super updateSubviewsData];
    
    [self.leftImageView setImage:[UIImage imageNamed:@"chaoren_left"]];
    [self.middleImageView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.83 blue:0.26 alpha:1.00]];
    [self.rightImageView setImage:[UIImage imageNamed:@"chaoren_right"]];
}

- (void)layoutContentSubviews {
    [super layoutContentSubviews];
    
    CGFloat leftImageViewX = 0.0;
    CGFloat leftImageViewY = 0.0;
    CGFloat leftImageViewW = ImageWidth;
    CGFloat leftImageViewH = ImageHeight;
    self.leftImageView.frame = CGRectMake(leftImageViewX, leftImageViewY, leftImageViewW, leftImageViewH);
    
    CGFloat middleImageViewW = CGRectGetWidth(self.textLabel.bounds);
    CGFloat middleImageViewH = 19;
    CGFloat middleImageViewX = CGRectGetMaxX(self.leftImageView.bounds) - 1.0;
    CGFloat middleImageViewY = (leftImageViewH - middleImageViewH)/2;
    self.middleImageView.frame = CGRectMake(middleImageViewX, middleImageViewY, middleImageViewW, middleImageViewH);
    self.textLabel.center = self.middleImageView.center;
    
    CGFloat rightImageViewX = CGRectGetMaxX(self.textLabel.frame) - 1.0;
    CGFloat rightImageViewY = leftImageViewY;
    CGFloat rightImageViewW = CGRectGetWidth(self.rightImageView.frame) > 2?CGRectGetWidth(self.rightImageView.frame):22.0;
    CGFloat rightImageViewH = ImageHeight;
    self.rightImageView.frame = CGRectMake(rightImageViewX, rightImageViewY, rightImageViewW, rightImageViewH);
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:CGSizeMake(CGRectGetMaxX(self.rightImageView.frame), CGRectGetMaxY(self.rightImageView.frame))];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    //如果不要删除leftImageView, middleImageView, rightImageView, textLabel, 只需重写这个方法并留空就可以了.
    //比如: 你想在这个cell被点击的时候, 修改文本颜色
}

#pragma mark ---- setter
- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.walkBannerDescriptor = (OCBarrageWalkBannerDescriptor *)barrageDescriptor;
}

#pragma mark ---- getter
- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftImageView;
}

- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _middleImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _rightImageView;
}

@end
