//
//  OCBarrageBecomeNobleCell.h
//  QuanMinTV
//
//  Created by QMTV on 2017/8/31.
//  Copyright © 2017年 QMTV. All rights reserved.
//

#import "OCBarrageTextCell.h"
#import "OCBarrageBecomeNobleDescriptor.h"

@interface OCBarrageBecomeNobleCell : OCBarrageTextCell

@property (nonatomic, strong) OCBarrageBecomeNobleDescriptor *nobleDescriptor;
@property (nonatomic, strong) CALayer *backgroundImageLayer;

@end
