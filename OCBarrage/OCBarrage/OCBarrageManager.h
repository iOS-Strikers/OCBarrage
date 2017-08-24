//
//  OCBarrageView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBarrageRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageManager : NSObject {
    @protected
    OCBarrageRenderView *_renderView;
}

@property (nonatomic, strong, readonly) OCBarrageRenderView *renderView;
@property (nonatomic, assign, readonly) OCBarrageRenderStatus renderStatus;

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withBarrageIndentifier:(NSString *)barrageIndentifier;

- (void)start;
- (void)puase;
- (void)resume;
- (void)stop;

- (void)renderBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor;

@end

NS_ASSUME_NONNULL_END
