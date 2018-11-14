//
//  CYFPSLabel.h
//  PieDemo
//
//  Created by louchu on 2018/11/2.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//写成了单例
@interface CYFPSLabel : UILabel
+ (instancetype)sharedFPSLabel;
- (void)showFPS;
- (void)hideFPS;
- (void)setM:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
