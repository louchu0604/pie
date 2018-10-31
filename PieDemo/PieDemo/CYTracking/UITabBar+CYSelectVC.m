//
//  UITabBar+CYSelectVC.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/20.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "UITabBar+CYSelectVC.h"
#import <objc/runtime.h>
@implementation UITabBar (CYSelectVC)
+(void)load
{
    {
        Method originMethod = class_getInstanceMethod([self class], @selector(tabBar:didSelectItem:));
        Method newMethod = class_getInstanceMethod([self class], @selector(p_cy_tabBar:didSelectItem:));
        method_exchangeImplementations(originMethod,newMethod);
    }
}
- (void)_p_cytabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"%@",item.title);
}

@end
