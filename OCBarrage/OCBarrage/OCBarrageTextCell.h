//
//  OCBarrageTextCell.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageTextCell : OCBarrageCell {
    @protected
    CATextLayer *_textlayer;
    BOOL _textShadowOpen;
}

- (void)openTextShadow;
- (void)closeTextShadow;

@end

NS_ASSUME_NONNULL_END
