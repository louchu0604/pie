//
//  UITabBarController+CYPush.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/19.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UITabBarController+CYPush.h"
#import <objc/runtime.h>
#import "CYTrackingManager.h"

@implementation UITabBarController (CYPush)
+(void)load
{
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(tabBarController:didSelectViewController:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_tabBarController:didSelectViewController:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(setSelectedIndex:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_setSelectedIndex:));
        method_exchangeImplementations(originMethod,newMethod);
    }
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(_tabBarItemClicked:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_tabBarItemClicked:));
        method_exchangeImplementations(originMethod,newMethod);
    }
}
- (void)p_cy_tabBarItemClicked:(UIBarButtonItem *)item
{
    NSLog(@"user select:%@",item.title);
    
    [[CYTrackingManager sharedTrackingManager] currentIndex:item.title];
    [self p_cy_tabBarItemClicked:item];
}
- (void)p_cy_setSelectedIndex:(NSUInteger)selectedIndex
{
     [[CYTrackingManager sharedTrackingManager] currentIndex:[NSString stringWithFormat:@"%d",(unsigned long)selectedIndex]];
    [self p_cy_setSelectedIndex:selectedIndex];
}
- (void)p_cy_tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    [self p_cy_tabBarController:tabBarController didSelectViewController:viewController];
    
}

@end
