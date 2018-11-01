//
//  UIGestureRecognizer+CYGesture.m
//  SmartSleep
//
//  Created by louchu on 2018/11/1.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UIGestureRecognizer+CYGesture.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (CYGesture)
+ (void)load
{
    //    present
    {
        //    get original method
        
        Method originMethod = class_getInstanceMethod([self class], @selector(_updateGestureWithEvent:buttonEvent:));
        //    get new method
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_updateGestureWithEvent:buttonEvent:));
        
        //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }
  
}
- (void)p_cy_updateGestureWithEvent:(nullable UIEvent *)event buttonEvent:(nullable UIEvent *)buttonevent
{
    [self p_cy_updateGestureWithEvent:event buttonEvent:buttonevent];
}

@end
