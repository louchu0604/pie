//
//  UIViewController+CYViewPush.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/11.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UIViewController+CYViewPush.h"
#import <objc/runtime.h>
#import "CYTrackingManager.h"
@implementation UIViewController (CYViewPush)
+ (void)load
{
//    present
    {
        //    get original method
        
        Method originMethod = class_getInstanceMethod([self class], @selector(presentViewController:animated:completion:));
        //    get new method
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_presentViewController:animated:completion:));
        
        //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }
//    dismissview
    {
        //    get original method
        
        Method originMethod = class_getInstanceMethod([self class], @selector(dismissViewControllerAnimated:completion:));
        //    get new method
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_dismissViewControllerAnimated:completion:));
        
        //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }
}
- (void)p_cy_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    
    [self p_cy_dismissViewControllerAnimated:flag completion:completion];
}
- (void)p_cy_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    CYTrackingManager *m = [CYTrackingManager sharedTrackingManager];
    [m currentVC:viewControllerToPresent event:0];
    [self p_cy_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end
