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
    {
        //    query config.json, if need log,priority:background
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
////            向nodeManager查阅是否为需要追踪的事件 依据为：方法名+路径（hasPreFix）
//        });
//          CYTrackingManager *m = [CYTrackingManager sharedTrackingManager];
//        [m addEvent:action from:sender];
        if ([sender isKindOfClass:[UIButton class]]) {
            NSLog(@"是按钮哦");
            NSString *strtitle = ((UIButton *)sender).currentTitle;
          
            if (strtitle) {
                NSLog(@"strtitle : %@",strtitle);
            }
            NSString *imagename = ((UIButton *)sender).imageView.image.accessibilityIdentifier;
            if ((imagename)) {
                NSLog(@"imagename : %@",imagename);
            }
        }
//        NSLog(@"action:%@ to:%@ from:%@ for:%@",NSStringFromSelector(action),NSStringFromClass([target class]) ,NSStringFromClass([sender class]) ,event);
//        
//        NSLog(@"\r action:%@ \r to:%@ \r from:%@ \r for:%@",NSStringFromSelector(action),NSStringFromClass([target class]) ,sender,event);

        
    }
    return [self p_cy_sendAction:action to:target from:sender forEvent:event];
}

@end
