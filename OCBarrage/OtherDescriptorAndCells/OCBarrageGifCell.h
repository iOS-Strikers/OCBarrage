//
//  OCBarrageGifCell.h
//  OCBarrage
//
//  Created by QMTV on 2017/8/31.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageCell.h"
#import "YYAnimatedImageView.h"
#import "OCBarrageGifDescriptor.h"

@interface OCBarrageGifCell : OCBarrageCell

@property (nonatomic, strong) OCBarrageGifDescriptor *gifDescriptor;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@end
