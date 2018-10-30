//
//  ViewController.m
//  PieDemo
//
//  Created by louchu on 2018/10/29.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "ViewController.h"
#import "CYPieView.h"
#import "CYButton.h"
#import <objc/runtime.h>
#import "TestObj.h"

#define kbaseKey 10000
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sendMsg];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)sendMsg
{
//    发送hello (并没有实现该方法)
    [self performSelector:@selector(hello)];
}

#pragma mark -② forwardingTargetForSelector
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *clsStr = NSStringFromSelector(aSelector);
    if ([clsStr isEqualToString:@"hello"]) {
//        return  @"hhhh";
//        return [TestObj new];
    }
    return nil;
}
#pragma mark -③ forwardInvocation 

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *clsStr = NSStringFromSelector(anInvocation.selector);

    if ([clsStr isEqualToString:@"hello"])
    {
        [anInvocation invokeWithTarget:[TestObj new]];
    }
}
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (! signature) {
        //生成方法签名
        signature = [[TestObj new] methodSignatureForSelector:selector];
    }
    return signature;
}
#pragma mark - 事件响应
- (void)setThreeView
{
    UIButton *buttonA = [UIButton new];
    [self.view addSubview:buttonA];
    buttonA.tag = kbaseKey+1;
    buttonA.frame = CGRectMake(0, 0, scale_device_value(750), scale_device_value(1000));
    [buttonA setBackgroundColor:[UIColor redColor]];
    [buttonA addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonA setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

//    CYButton *buttonB = [CYButton new];
    UIButton *buttonB = [UIButton new];

    [buttonA addSubview:buttonB];
    buttonB.tag = kbaseKey+2;
    buttonB.frame = CGRectMake(SCREEN_WIDTH*0.5-scale_device_value(250), scale_device_value(100), scale_device_value(500), scale_device_value(500));
    [buttonB setBackgroundColor:[UIColor yellowColor]];
    [buttonB addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIButton *buttonC = [UIButton new];
    [buttonB addSubview:buttonC];
    buttonC.tag = kbaseKey+3;
    buttonC.frame = CGRectMake(scale_device_value(25), scale_device_value(300), scale_device_value(550), scale_device_value(300));
    [buttonC setBackgroundColor:[UIColor greenColor]];
    [buttonC addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonC setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
}

- (void)btnclick:(UIButton *)btn
{
    switch (btn.tag) {
        case kbaseKey+1:
        {
            NSLog(@"buttonA clicked");
            
        }
            break;
        case kbaseKey+2:
        {
            NSLog(@"buttonB clicked");
        }
            break;
        case kbaseKey+3:
        {
            NSLog(@"buttonC clicked");
        }
            break;
        default:
            break;
    }
}
- (void)setPieView
{
    CYPieView *pie = [CYPieView new];
    pie.frame = self.view.frame;
    [self.view addSubview:pie];
    [pie setPieData:@[@10.0,@20.0,@30.0,@11.2,@10.7,@18.1] firstCircle:scale_device_value(120) secondCircle:scale_device_value(200) thirdCircle:scale_device_value(260) labelCircle:scale_device_value(265)];
    
}
@end
