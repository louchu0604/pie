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
      NSLog(@"add p_cy_showViewController");
      [[CYTrackingManager sharedTrackingManager] addVC:@{@"name":NSStringFromClass([vc class]),@"add":[NSString stringWithFormat:@"%p",vc]}];
    
    [self p_cy_showViewController:vc sender:sender];
}
- (void)p_cy_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
      NSLog(@"reset p_cy_setViewControllers");
    NSMutableArray *infoarray = [NSMutableArray new];
    for (UIViewController *vc in viewControllers) {
        NSDictionary *dic =@{@"name":NSStringFromClass([vc class]),@"add":[NSString stringWithFormat:@"%p",vc]};
        [infoarray addObject:dic];
    }
    [[CYTrackingManager sharedTrackingManager] resetVCArray:infoarray];
    [self p_cy_setViewControllers:viewControllers];
}
- (instancetype)p_cy_initWithRootViewController:(UIViewController *)rootViewController{
//     NSLog(@"add p_cy_initWithRootViewController");
//      [[CYTrackingManager sharedTrackingManager] addVC:@{@"name":NSStringFromClass([rootViewController class]),@"add":[NSString stringWithFormat:@"%p",rootViewController]}];
    
    return  [self p_cy_initWithRootViewController:rootViewController];
}

- (void)p_cy_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
      NSLog(@"add p_cy_pushViewController");
    
    [[CYTrackingManager sharedTrackingManager] addVC:@{@"name":NSStringFromClass([viewController class]),@"add":[NSString stringWithFormat:@"%p",viewController]}];
    
    [self p_cy_pushViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)p_cy_popToRootViewControllerAnimated:(BOOL)animated
{
    NSLog(@"reset p_cy_popToRootViewControllerAnimated");

    NSArray *viewControllers =[self p_cy_popToRootViewControllerAnimated:animated];
    NSMutableArray *infoarray = [NSMutableArray new];
    for (UIViewController *vc in viewControllers) {
        NSDictionary *dic =@{@"name":NSStringFromClass([vc class]),@"add":[NSString stringWithFormat:@"%p",vc]};
        [infoarray addObject:dic];
    }
    [[CYTrackingManager sharedTrackingManager] resetVCArray:infoarray];
    
    return viewControllers;
}
- (NSArray<UIViewController *> *)p_cy_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
     NSLog(@"reset p_cy_popToViewController");
    NSArray *viewControllers =[self p_cy_popToViewController:viewController animated:animated];
    NSMutableArray *infoarray = [NSMutableArray new];
    for (UIViewController *vc in viewControllers) {
        NSDictionary *dic =@{@"name":NSStringFromClass([vc class]),@"add":[NSString stringWithFormat:@"%p",vc]};
        [infoarray addObject:dic];
    }
    [[CYTrackingManager sharedTrackingManager] resetVCArray:infoarray];
    
    return viewControllers;
}

- (nullable UIViewController *)p_cy_popViewControllerAnimated:(BOOL)animated{
     NSLog(@"remove p_cy_popViewControllerAnimated");
    
    UIViewController *viewController =  [self p_cy_popViewControllerAnimated:animated];
    
      [[CYTrackingManager sharedTrackingManager]
       removeVC:@{@"name":NSStringFromClass([viewController class]),
                  @"add":[NSString stringWithFormat:@"%p",viewController]}];
  return  viewController;
}

@end
