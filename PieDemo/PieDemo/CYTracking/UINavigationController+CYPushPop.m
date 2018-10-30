//
//  UINavigationController+CYPushPop.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UINavigationController+CYPushPop.h"
#import <objc/runtime.h>
#import "CYTrackingManager.h"

@implementation UINavigationController (CYPushPop)
+ (void)load
{
//    push(see present case in CYViewPush)
   
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_pushViewController:animated:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(initWithRootViewController:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_initWithRootViewController:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(showViewController:sender:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_showViewController:sender:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    
//    pop
    
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_popViewControllerAnimated:));
        method_exchangeImplementations(originMethod,newMethod);        
    }
   
    
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(popToViewController:animated:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_popToViewController:animated:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(popToRootViewControllerAnimated:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_popToRootViewControllerAnimated:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(setViewControllers:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_setViewControllers:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    
}

- (void)p_cy_showViewController:(UIViewController *)vc sender:(id)sender
{
    [self p_cy_showViewController:vc sender:sender];
}
- (void)p_cy_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    [self p_cy_setViewControllers:viewControllers];
}
- (NSArray<UIViewController *> *)p_cy_popToRootViewControllerAnimated:(BOOL)animated
{
    return  [self p_cy_popToRootViewControllerAnimated:animated];
}
- (NSArray<UIViewController *> *)p_cy_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    return  [self p_cy_popToViewController:viewController animated:animated];
}
- (instancetype)p_cy_initWithRootViewController:(UIViewController *)rootViewController{
    NSLog(@"nav:%@",rootViewController);

    return  [self p_cy_initWithRootViewController:rootViewController];
}

- (void)p_cy_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"nav:%@",viewController);
    [self p_cy_pushViewController:viewController animated:animated];
}
- (nullable UIViewController *)p_cy_popViewControllerAnimated:(BOOL)animated{
  return  [self p_cy_popViewControllerAnimated:animated];
}

@end
