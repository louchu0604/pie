//
//  UITableViewCell+CYSelCell.m
//  PieDemo
//
//  Created by louchu on 2018/11/9.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "UITableViewCell+CYSelCell.h"
#import <objc/runtime.h>

@implementation UITableViewCell (CYSelCell)
+ (void)load
{
    //    present
    {
        //    get original method
        
        Method originMethod = class_getClassMethod([self class], @selector(setSelected:animated:));
        //    get new method
        Method newMethod = class_getClassMethod([self class], @selector(p_cy_setSelected:animated:));
        
        //    if exist ,changed IMP
        method_exchangeImplementations(originMethod,newMethod);
    }
    
}
- (void)p_cy_setSelected:(BOOL)selected animated:(BOOL)animated {
    if(selected)
    {
        NSLog(@"cell select:%@",self);
    }
    [self p_cy_setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
