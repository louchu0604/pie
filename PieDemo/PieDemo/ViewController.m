//
//  ViewController.m
//  PieDemo
//
//  Created by louchu on 2018/10/29.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "ViewController.h"
#import "CYPieView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CYPieView *pie = [CYPieView new];
    pie.frame = self.view.frame;
    [self.view addSubview:pie];
    [pie setPieData:@[@10.0,@20.0,@30.0,@11.2,@10.7,@18.1] firstCircle:scale_device_value(120) secondCircle:scale_device_value(200) thirdCircle:scale_device_value(260) labelCircle:scale_device_value(265)];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
