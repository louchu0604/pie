//
//  UIViewController+addMethod.m
//  PieDemo
//
//  Created by louchu on 2018/10/31.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "UIViewController+addMethod.h"
#import <objc/runtime.h>
@implementation UIViewController (addMethod)
#pragma mark -① resolveInstanceMethod
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
//    NSString *clsStr = NSStringFromSelector(sel);
//    if ([clsStr isEqualToString:@"hello"]) {
//        NSLog(@"it is hello method");
//        class_addMethod([self class], sel, (IMP)mymethod, "v@:@");
//        return YES;
//    }
    return [super resolveInstanceMethod:sel];
}



void mymethod(id self, SEL _cmd){
     NSLog(@"hello method added");
}
@end
