//
//  UIImage+SaveImageName.m
//  SmartSleep
//
//  Created by louchu on 2018/10/31.
//  Copyright © 2018年 Ben. All rights reserved.
//

#import "UIImage+SaveImageName.h"
#import <objc/runtime.h>
@implementation UIImage (SaveImageName)
+ (void)load
{
    //    present
    {
        //    get original method
        
        Method originMethod = class_getClassMethod([self class], @selector(imageNamed:));
        //    get new method
        Method newMethod = class_getClassMethod([self class], @selector(p_cy_imageNamed:));
        
        //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }

}
+ (nullable UIImage *)p_cy_imageNamed:(NSString *)name
{
    UIImage *image = [self p_cy_imageNamed:name];
//    NSLog(@"图片的名字是%@",name);
    [image setAccessibilityIdentifier:name];
    return image;
}
@end
