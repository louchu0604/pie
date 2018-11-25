//
//  CollectionViewCell.m
//  PieDemo
//
//  Created by louchu on 2018/11/15.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "CollectionViewCell.h"
@interface CollectionViewCell ()
@property (nonatomic, strong) UILabel *label;
@end
@implementation CollectionViewCell
- (void)freshDate:(NSString *)dateString
{
    self.backgroundColor = [UIColor whiteColor];
    if(_label==nil)
    {
        _label = [UILabel new];
        _label.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _label.backgroundColor = RGB(210, 160, 233);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = systemFont(28);
        _label.textColor = RGB(0, 0, 0);
        [self addSubview:_label];
    }
    
    _label.text = dateString;
}
@end
