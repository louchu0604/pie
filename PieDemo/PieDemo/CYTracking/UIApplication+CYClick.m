//
//  UIApplication+CYClick.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UIApplication+CYClick.h"
#import <objc/runtime.h>
#import "CYTrackingManager.h"
@implementation UIApplication (CYClick)
+ (void)load
{
    {
    //    get original method
    
        Method originMethod = class_getInstanceMethod([self class], @selector(sendAction:to:from:forEvent:));
    //    get new method
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_sendAction:to:from:forEvent:));
    
    //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }
}
- (BOOL)p_cy_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event
{
   [[CYTrackingManager sharedTrackingManager] addAction:action from:sender to:target];

    return [self p_cy_sendAction:action to:target from:sender forEvent:event];
}

@end
