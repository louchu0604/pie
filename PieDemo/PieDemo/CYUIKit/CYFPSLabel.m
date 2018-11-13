//
//  CYFPSLabel.m
//  PieDemo
//
//  Created by louchu on 2018/11/2.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "CYFPSLabel.h"
static CYFPSLabel *fpsLabel;

@implementation CYFPSLabel
{
    CADisplayLink *_fpsLink;
    int _fpscount;
    NSTimeInterval _lastTime;
    
}
+ (instancetype)sharedFPSLabel
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        fpsLabel = [[self alloc] init];
        fpsLabel.frame = CGRectMake(0, 80, 40, 12);
        fpsLabel.font = [UIFont systemFontOfSize:10];
        fpsLabel.textAlignment = NSTextAlignmentCenter;
        fpsLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
        fpsLabel.textColor = [UIColor whiteColor];
        });
    return fpsLabel;
}
- (void)showFPS
{
    //    timer run view add

    _fpsLink = [CADisplayLink displayLinkWithTarget:self  selector:@selector(tick:)];
    [_fpsLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];//避免滚动的时候无法追踪
    UIWindow *window = [UIApplication sharedApplication].keyWindow ;
    [window addSubview:self];
    
}
- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _fpscount++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _fpscount / delta;
    _fpscount = 0;
    
    NSString *text1 = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
//    NSLog(@"%@", text1);

    self.text = text1;
}
- (void)hideFPS
{
//    timer invalid view remove
    [_fpsLink invalidate];
    _fpsLink = nil;
    [self removeFromSuperview];
    

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
