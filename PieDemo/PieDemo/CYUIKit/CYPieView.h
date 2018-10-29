//
//  CYPieView.h
//  PieDemo
//
//  Created by louchu on 2018/10/29.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CYPieView : UIView
/**
 

 @param pieDataArray
 */

/**
 设置饼图

 @param pieDataArray 饼图数据(数组)
 @param firstCircle 饼图里层半径
 @param secondCircle 饼图外层半径
 @param thirdCircle 饼图放大半径
 @param labelCircle 外围tip起始半径
 */
- (void)setPieData:(NSArray <NSNumber *>*)pieDataArray
       firstCircle:(float)firstCircle
      secondCircle:(float)secondCircle
       thirdCircle:(float)thirdCircle
       labelCircle:(float)labelCircle;

/**
 放大效果

 @param active 是否设置放大效果
 */
- (void)setScaleAnimation:(BOOL)active;
@end

NS_ASSUME_NONNULL_END
