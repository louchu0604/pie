//
//  CYButton.m
//  PieDemo
//
//  Created by louchu on 2018/10/30.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "CYButton.h"

@implementation CYButton
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    /*
     层级关系:A->B->C
     A:CGRectMake(0, 0, scale_device_value(750), scale_device_value(1000));
     B:CGRectMake(SCREEN_WIDTH*0.5-scale_device_value(250), scale_device_value(100), scale_device_value(500), scale_device_value(500));
     C:CGRectMake(scale_device_value(25), scale_device_value(300), scale_device_value(550), scale_device_value(300));
     
     */
    
 //    1.将事件传递给B
//    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height),point)) {
//        return self;
//    }
//    2.点击C超出B部分的视图时,还是会将事件传递给C
/*     2.1 扩大B的响应范围
     原来（0,0,scale_device_value(500), scale_device_value(500)）
    扩大后（0,0,scale_device_value(575), scale_device_value(600)）
 */

    if (CGRectContainsPoint(CGRectMake(0, 0,scale_device_value(575), scale_device_value(600)),point)) {
//        2.2 判断是否在C范围内
        float xValue = point.x;
        float yValue = point.y;
        BOOL rightPart = false;
        BOOL bottomPart = false;
        if (xValue>=scale_device_value(25)&&xValue<=scale_device_value(575)
            &&yValue>=scale_device_value(500)&&yValue<=scale_device_value(600))
        {
            bottomPart = YES;
        }
        if (xValue>=scale_device_value(500)&&xValue<=scale_device_value(575)
            &&yValue>=scale_device_value(300)&&yValue<=scale_device_value(600))
        {
            rightPart = YES;
        }
        
        if(bottomPart||rightPart)//点击了C超出B的范围
        {
            for (UIView *subview in self.subviews) {
                if (subview.tag ==10000+3 ) {//找到C
                    return subview;
                }
            }
        }
    }
    
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
