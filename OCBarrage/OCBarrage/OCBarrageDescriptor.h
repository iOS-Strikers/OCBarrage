//
//  OCBarrageDescriptor.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OCBarrageHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageDescriptor : NSObject

@property (nonatomic, assign) Class barrageCellClass;
@property (nonatomic, assign) OCBarragePositionPriority positionPriority;//显示位置normal型的渲染在low型的上面, height型的渲染在normal上面
@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, copy, nullable) OCBarrageTouchAction touchAction;

@property (nonatomic, assign) CGFloat bindingOriginY;//在固定的某个Y坐标上显示

@end

NS_ASSUME_NONNULL_END
