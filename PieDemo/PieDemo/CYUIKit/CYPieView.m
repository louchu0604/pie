//
//  CYPieView.m
//  PieDemo
//
//  Created by louchu on 2018/10/29.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "CYPieView.h"
#define k_point @"pointvalue"
#define k_percent @"percentvalue"
#define k_showinfo @"k_showinfo"
#define k_text @"show_text"
#define k_color @"show_color"
#define k_minfloat 10
#define hasNotMoved -1

@interface CYPieView()
{
    CGPoint viewCenter;
     float _firstCircle;//内径
     float _secondCircle;//彩色的半径
     float _thirdCircle;//放大后的半径
     float _labelCircle;//提示问题的起始点半径
}
@property (nonatomic, strong)NSMutableArray *pieChartPercentArray;
@property (nonatomic, strong) NSMutableArray *layerArray;
@property (nonatomic, strong) NSMutableArray *maskLayerArray;
@property (nonatomic, strong) NSMutableArray *drawPointRightArray;
@property (nonatomic, strong) NSMutableArray *drawPointLeftArray;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) NSMutableArray *pointLabelArray;
@property (nonatomic, strong) NSMutableArray *colorGradeArray;
@property (nonatomic, strong) NSMutableArray *originalArray;
@property BOOL needFresh;
@property int previousIdx;
@property float oldPercent;
@end
@implementation CYPieView
-(void)setPieData:(NSArray<NSNumber *> *)pieDataArray firstCircle:(float)firstCircle secondCircle:(float)secondCircle thirdCircle:(float)thirdCircle labelCircle:(float)labelCircle
{
    assert(firstCircle>0);
    assert(secondCircle>firstCircle);
    assert(thirdCircle>secondCircle);
    assert(labelCircle>=thirdCircle);
    assert(labelCircle<=self.frame.size.height&&labelCircle<=self.frame.size.width);
    
    _firstCircle = firstCircle;
    _secondCircle = secondCircle;
    _thirdCircle = thirdCircle;
    _labelCircle = labelCircle;
    if(!_pieChartPercentArray)
    {
        _pieChartPercentArray = [NSMutableArray new];
    }else
    {
        [_pieChartPercentArray removeAllObjects];
    }
    if(!_colorGradeArray)
    {
        _colorGradeArray = [NSMutableArray new];
    }else
    {
        [_colorGradeArray removeAllObjects];
    }
    NSMutableArray *color = [NSMutableArray arrayWithObjects:
                             @{k_text:@"A",k_color:RGB(0x40, 0x9e, 0xfe)},
                             @{k_text:@"B",k_color:RGB(0xfa, 0xbd, 0x33)},
                             @{k_text:@"C",k_color:RGB(0xeb, 0x5b, 0x3b)},
                             @{k_text:@"D",k_color:RGB(0xfc, 0x9a, 0x4e)},
                             @{k_text:@"E",k_color:RGB(0x4a, 0xbf, 0xb3)},
                             @{k_text:@"F",k_color:RGB(0x6c, 0xb7, 0xfc)},
                             nil];
    
    int maxidx = 0;
    float maxValue = 0.0;
    float needAddValue = 0.0;
    float totalValue = 0.0;
    for (int i=0; i<pieDataArray.count; i++) {
        if([pieDataArray[i] floatValue]>0.0)
        {
            if([pieDataArray[i] floatValue]>1.0)
            {
                
                [_pieChartPercentArray addObject:pieDataArray[i]];
                [_colorGradeArray addObject:color[i]];
                
                if([pieDataArray[i] floatValue]>=maxValue)
                {
                    maxValue = [pieDataArray[i] floatValue];
                    maxidx = _pieChartPercentArray.count-1;
                }
                
            }else
            {
                needAddValue +=[pieDataArray[i] floatValue];
            }
            
        }else{
            NSString*name =@"data content error";
            
            NSString*reason =@"百分比不得为负";
            
            NSException*exception = [NSException exceptionWithName:name reason:reason userInfo:nil];
            
            @throw exception;
            
        }
        totalValue+=[pieDataArray[i] floatValue];
        
    }
    
    if (totalValue>100.0) {
        NSString*name =@"data content error";
        
        NSString*reason =@"百分比总和不得超过100";
        
        NSException*exception = [NSException exceptionWithName:name reason:reason userInfo:nil];
        
        @throw exception;
    }
    float oldValue = [_pieChartPercentArray[maxidx] floatValue];
    oldValue+= needAddValue;
    
    _pieChartPercentArray[maxidx]=[NSNumber numberWithFloat:oldValue] ;
    //   NSArray *layers =
    
    if (_lineArray) {
        for (CALayer *layer in _lineArray) {
            [layer removeFromSuperlayer];
        }
    }
    if (_layerArray) {
        for (CALayer *layer in _layerArray) {
            [layer removeFromSuperlayer];
            
        }
    }
    if (_pointLabelArray) {
        for (UIView *pview in _pointLabelArray) {
            [pview removeFromSuperview];
        }
    }
    _needFresh = YES;
    [self setNeedsDisplay];
    
}
#pragma mark - set parameters

- (void)setScaleAnimation:(BOOL)active
{
        self.userInteractionEnabled  = active;
}
- (void)drawRect:(CGRect)rect {
    if (_needFresh==YES) {
        [[UIColor whiteColor] setFill];
        UIRectFill(rect);
        viewCenter = self.center;
//        CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
        _previousIdx = hasNotMoved;
        [self mypieview];
    }
    // Drawing code
}
- (void)mypieview
{
    //    原始数组排序
    //   10月26日修改：改为两边扩散排序
    _pieChartPercentArray = [[self findLarger:_pieChartPercentArray] mutableCopy];
    
    _drawPointLeftArray = [NSMutableArray new];
    _drawPointRightArray = [NSMutableArray new];
    _lineArray = [NSMutableArray new];
    _pointLabelArray = [NSMutableArray new];
    float start = 0.0;
    float end = 0.0;
    float oldPercent = 0.0;
    _layerArray = [NSMutableArray new];
    _maskLayerArray = [NSMutableArray new];
    for (int i=0; i<self.pieChartPercentArray.count;i++) {
        
        float percent = [self.pieChartPercentArray[i] floatValue];
        end -=2*M_PI*percent*0.01;
        
        UIBezierPath *path = [self piePathWithRadius:_secondCircle startAngle:-2*M_PI*oldPercent*0.01 endAngle:-2*M_PI*(oldPercent+percent)*0.01];
        NSLog(@"%.f %.f",2*M_PI*oldPercent*0.01,-2*M_PI*(oldPercent+percent)*0.01);
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.strokeColor = ((UIColor *)[_colorGradeArray[i] valueForKey:k_color]).CGColor;
        layer.fillColor = ((UIColor *)[_colorGradeArray[i] valueForKey:k_color]).CGColor;
        layer.borderWidth = 20.0;
        layer.lineWidth = 0.1;
        
        [self.layer addSublayer:layer];
        [_layerArray addObject:layer];
        
        UIBezierPath *path2 = [self piePathWithRadius:_firstCircle startAngle:2*M_PI*oldPercent*0.01 endAngle:-2*M_PI*(oldPercent+percent)*0.01];
    
        CAShapeLayer *layer2 = [CAShapeLayer layer];
        layer2.path = path2.CGPath;
        layer2.strokeColor = [UIColor whiteColor].CGColor;
        layer2.fillColor = [UIColor whiteColor].CGColor;
        layer2.borderWidth = 20.0;
        layer2.lineWidth = 0.1;
        [_maskLayerArray addObject:layer2];
        //        计算出该段圆弧的中点
        //        判断左右 加入数组
        float angle =-2*M_PI*(oldPercent+percent*0.5)*0.01;
        float x= viewCenter.x+cos(angle)*_labelCircle;
        float y = viewCenter.y+sin(angle)*_labelCircle;
        
        if (x>=viewCenter.x) {
            [_drawPointRightArray addObject:@{k_point:[NSValue valueWithCGPoint:CGPointMake(x, y)],k_percent:self.pieChartPercentArray[i],k_showinfo:_colorGradeArray[i]}];
        }else
        {
            [_drawPointLeftArray addObject:@{k_point:[NSValue valueWithCGPoint:CGPointMake(x, y)],k_percent:self.pieChartPercentArray[i],k_showinfo:_colorGradeArray[i]}];
        }
        
        start = end;
        oldPercent+=percent;
        NSLog(@"oldPercent %f",oldPercent);
        
    }
    //    放大功能暂时先删除
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];

    
    {
        UIBezierPath *path2 = [self piePathWithRadius:_firstCircle startAngle:0 endAngle:-2*M_PI];
        
        CAShapeLayer *layer2 = [CAShapeLayer layer];
        layer2.path = path2.CGPath;
        layer2.strokeColor = [UIColor whiteColor].CGColor;
        layer2.fillColor = [UIColor whiteColor].CGColor;
        layer2.borderWidth = 20.0;
        layer2.lineWidth = 0.1;
        [self.layer addSublayer:layer2];
    }
    
    //    根据y值从上到下排序

    _drawPointLeftArray = [[self findHigher:_drawPointLeftArray] mutableCopy];
    
    _drawPointRightArray = [[self findHigher:_drawPointRightArray] mutableCopy];
    
    int rightDrawNumber = _drawPointRightArray.count;
    
    float rightNeedLength =  (rightDrawNumber-1)*scale_device_value(80);
    float rightFirstLength = viewCenter.y-rightNeedLength*0.5;
    float rightLastLength = viewCenter.y+rightNeedLength*0.5;

    int leftDrawNumber = _drawPointLeftArray.count;
    
    float leftNeedLength = (leftDrawNumber-1)*scale_device_value(80);
    float leftFirstLength = viewCenter.y-leftNeedLength*0.5;
    float leftLastLength = viewCenter.y+leftNeedLength*0.5;

    //    left 确定range
    
    NSMutableArray *rightHeightArray = [NSMutableArray new];
    NSMutableArray *lefttHeightArray = [NSMutableArray new];
    {
        float lasty = rightFirstLength-scale_device_value(40);
        for (int i=0; i<_drawPointRightArray.count; i++) {
            CGPoint t0 = [[_drawPointRightArray[i] valueForKey:k_point] CGPointValue];
            if(t0.y>=lasty+scale_device_value(80))
            {
                [rightHeightArray addObject:[NSNumber numberWithFloat:t0.y]];
                lasty = t0.y;
            }else
            {
                [rightHeightArray addObject:[NSNumber numberWithFloat:lasty+scale_device_value(80)]];
                lasty =lasty+scale_device_value(80);
            }
            
        }
        //     反过来
        float sslasty =rightLastLength +scale_device_value(40);
        for (int i=rightHeightArray.count-1; i>=0; i--) {
            float t0 = [rightHeightArray[i] floatValue];
            if(t0<=sslasty-scale_device_value(80))
            {
                NSLog(@"ok");
                break;
            }else
            {
                rightHeightArray[i] = [NSNumber numberWithFloat:sslasty-scale_device_value(80)];
                sslasty = sslasty-scale_device_value(80);
            }
            
        }
        
    }
    {
        float lasty = leftFirstLength-scale_device_value(40);
        for (int i=0; i<_drawPointLeftArray.count; i++) {
            CGPoint t0 = [[_drawPointLeftArray[i] valueForKey:k_point] CGPointValue];
            if(t0.y>=lasty+scale_device_value(80))
            {
                [lefttHeightArray addObject:[NSNumber numberWithFloat:t0.y]];
                lasty = t0.y;
            }else
            {
                [lefttHeightArray addObject:[NSNumber numberWithFloat:lasty+scale_device_value(80)]];
                lasty =lasty+scale_device_value(80);
            }
            
        }
        //     反过来
        float sslasty =leftLastLength +scale_device_value(40);
        for (int i=lefttHeightArray.count-1; i>=0; i--) {
            float t0 = [lefttHeightArray[i] floatValue];
            if(t0<=sslasty-scale_device_value(80))
            {
                NSLog(@"ok");
                break;
            }else
            {
                lefttHeightArray[i] = [NSNumber numberWithFloat:sslasty-scale_device_value(80)];
                sslasty = sslasty-scale_device_value(80);
            }
            
        }
        
    }
    float lastX = 0.0;
    
    for (int i=0; i<_drawPointRightArray.count; i++) {
        
        CGPoint t0 = [[_drawPointRightArray[i] valueForKey:k_point] CGPointValue];
        UIView *v = [UIView new];
        v.frame = CGRectMake(0, 0, scale_device_value(10), scale_device_value(10));
        v.center = t0;
        v.layer.masksToBounds = YES;
        v.layer.cornerRadius = scale_device_value(5);
        v.backgroundColor =  (UIColor *)[[_drawPointRightArray[i] valueForKey:k_showinfo] valueForKey:k_color];
        
        UIBezierPath *path = [UIBezierPath bezierPath]; // 创建路径
        [path moveToPoint:t0];
        
        float aimY = [rightHeightArray[i] floatValue];
        
        BOOL addonce = false;
        if (fabs(aimY-t0.y)<scale_device_value(10)) {
            addonce = true;
        }
        if(i==0)
        {
            if (_drawPointRightArray.count==1) {
                addonce = true;
            }else
            {
                float lastaimY = [rightHeightArray[i+1] floatValue];
                if (lastaimY-t0.y>=scale_device_value(75)) {
                    addonce = true;
                }
            }
        }else
        {
            if (_drawPointRightArray.count==i+1) {//最后一个
                float formeraimY = [rightHeightArray[i-1] floatValue];
                if (t0.y-formeraimY>=scale_device_value(75)) {
                    addonce = true;
                }
            }else
            {
                float formeraimY = [rightHeightArray[i-1] floatValue];
                float lastaimY = [rightHeightArray[i+1] floatValue];
                
                if (t0.y-formeraimY>=scale_device_value(75)&&lastaimY-t0.y>=scale_device_value(75)) {
                    addonce = true;
                }
            }
        }
        if (addonce) {
            aimY = t0.y;
            rightHeightArray[i] = [NSNumber numberWithFloat:aimY];
            
            lastX = t0.x;
        }else
        {
            if(t0.x<scale_device_value(520))
            {
                //                 [path addLineToPoint:CGPointMake(scale_device_value(550), t0.y)];
            }
            
            [path addLineToPoint:CGPointMake(scale_device_value(650), aimY)];
            
        }
        
        NSDictionary *dic0= @{NSFontAttributeName:systemFont(11),
                              NSForegroundColorAttributeName:[[_drawPointRightArray[i] valueForKey:k_showinfo] valueForKey:k_color]
                              };
        NSDictionary *dic1= @{NSFontAttributeName:systemFont(10),
                              NSForegroundColorAttributeName:[[_drawPointRightArray[i] valueForKey:k_showinfo] valueForKey:k_color]
                              };
        
        float showpercent = [[_drawPointRightArray[i] valueForKey:k_percent] floatValue];
        NSString *showString = [NSString stringWithFormat:@"%.2f %@",showpercent,@"%"];
        [showString drawAtPoint:CGPointMake(scale_device_value(660), aimY-scale_device_value(30)) withAttributes:dic0];
        
        [path addLineToPoint:CGPointMake(scale_device_value(717), aimY)];
        
        [[[_drawPointRightArray[i] valueForKey:k_showinfo] valueForKey:k_text] drawAtPoint:CGPointMake(scale_device_value(660), aimY+scale_device_value(8)) withAttributes:dic1];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = ((UIColor *)[[_drawPointRightArray[i] valueForKey:k_showinfo] valueForKey:k_color]).CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        
        shapeLayer.borderWidth = 1.0;
        //        if(showpercent>=k_minfloat)
        //        {
        [self.layer addSublayer:shapeLayer];
        [self addSubview:v];
        [_pointLabelArray addObject:v];
        [_lineArray addObject:shapeLayer];
        //        }
        
    }
    for (int i=0; i<_drawPointLeftArray.count; i++) {
        
        CGPoint t0 = [[_drawPointLeftArray[i] valueForKey:k_point] CGPointValue];
        UIView *v = [UIView new];
        v.frame = CGRectMake(0, 0, scale_device_value(10), scale_device_value(10));
        v.center = t0;
        v.layer.masksToBounds = YES;
        v.layer.cornerRadius = scale_device_value(5);
        v.backgroundColor = (UIColor *)[[_drawPointLeftArray[i] valueForKey:k_showinfo] valueForKey:k_color];
        
        UIBezierPath *path = [UIBezierPath bezierPath]; // 创建路径
        [path moveToPoint:t0];
        
        float aimY = [lefttHeightArray[i] floatValue];
        BOOL addonce = false;
        if (fabs(aimY-t0.y)<scale_device_value(10)) {
            addonce = true;
        }
        if(i==0)
        {
            if (_drawPointLeftArray.count==1) {
                addonce = true;
            }else
            {
                float lastaimY = [lefttHeightArray[i+1] floatValue];
                if (lastaimY-t0.y>=scale_device_value(75)) {
                    addonce = true;
                }
            }
        }else
        {
            if (_drawPointLeftArray.count==i+1) {//最后一个
                float formeraimY = [lefttHeightArray[i-1] floatValue];
                if (t0.y-formeraimY>=scale_device_value(75)) {
                    addonce = true;
                }
            }else
            {
                float formeraimY = [lefttHeightArray[i-1] floatValue];
                float lastaimY = [lefttHeightArray[i+1] floatValue];
                
                if (t0.y-formeraimY>=scale_device_value(75)&&lastaimY-t0.y>=scale_device_value(75)) {
                    addonce = true;
                }
            }
        }
        
        if (addonce) {
            aimY = t0.y;
            lefttHeightArray[i] = [NSNumber numberWithFloat:aimY];
        }
        else
        {
            if(t0.x>scale_device_value(210))
            {
                //                [path addLineToPoint:CGPointMake(scale_device_value(180), t0.y)];
            }
            [path addLineToPoint:CGPointMake(scale_device_value(80), aimY)];
            
        }
        NSDictionary *dic0= @{NSFontAttributeName:systemFont(11),
                              NSForegroundColorAttributeName:[[_drawPointLeftArray[i] valueForKey:k_showinfo] valueForKey:k_color]
                              };
        NSDictionary *dic1= @{NSFontAttributeName:systemFont(10),
                              NSForegroundColorAttributeName:[[_drawPointLeftArray[i] valueForKey:k_showinfo] valueForKey:k_color]
                              };
        float showpercent = [[_drawPointLeftArray[i] valueForKey:k_percent] floatValue];
        NSString *showString = [NSString stringWithFormat:@"%.2f %@",showpercent,@"%"];
        
        [showString drawAtPoint:CGPointMake(scale_device_value(30), aimY-scale_device_value(30)) withAttributes:dic0];
        
        [path addLineToPoint:CGPointMake(scale_device_value(33), aimY)];
        [[[_drawPointLeftArray[i] valueForKey:k_showinfo] valueForKey:k_text] drawAtPoint:CGPointMake(scale_device_value(30), aimY+scale_device_value(8)) withAttributes:dic1];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = ((UIColor *)[[_drawPointLeftArray[i] valueForKey:k_showinfo] valueForKey:k_color]).CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        
        shapeLayer.borderWidth = 1.0;
        //        if(showpercent>=k_minfloat)
        //        {
        [self.layer addSublayer:shapeLayer];
        [self addSubview:v];
        [_pointLabelArray addObject:v];
        [_lineArray addObject:shapeLayer];
        //        }
        
    }
}
- (NSMutableArray *)findLarger:(NSMutableArray *)array

{
    NSMutableArray *retArray = [NSMutableArray new];
    NSMutableArray *colornew = [NSMutableArray new];
    NSMutableArray *colorold = [_colorGradeArray mutableCopy];
   
    while (array.count>0) {
        int idx = 0;
        float maxV =100.0;
        //     10.26修改     找到最大的
        for (int i=0; i<array.count; i++) {
            float t0 = [array[i] floatValue];
            if (t0<=maxV) {
                maxV = t0;
                idx = i;
            }
        }
        int insertIdx= retArray.count*0.5;
        [retArray insertObject:array[idx] atIndex:insertIdx];
        [colornew insertObject:colorold[idx] atIndex:insertIdx];
        [array removeObjectAtIndex:idx];
        [colorold removeObjectAtIndex:idx];
        
    }
    _colorGradeArray = [colornew mutableCopy];
    
    return retArray;
    
}

- (NSMutableArray *)findHigher:(NSMutableArray *)array
{
    NSMutableArray *retArray = [NSMutableArray new];
   
    while (array.count>0) {
        int idx = 0;
        float minY = 1000;
        //      找到最小的
        for (int i=0; i<array.count; i++) {
            float t0 = [[array[i] valueForKey:k_point] CGPointValue].y;
            if (t0<=minY) {
                minY = t0;
                idx = i;
            }
        }
        [retArray addObject:array[idx]];
        [array removeObjectAtIndex:idx];
    }
    return retArray;
}


/**
 触摸事件逻辑
 1. 根据触摸坐标计算出目标饼
 2. 将之前放大的饼恢复&&放大目标饼

 @param recognizer 手势
 */
- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer locationInView:self];
    CGPoint endPoint = CGPointMake(translation.x-viewCenter.x, translation.y-viewCenter.y);
    
    float distanceend = hypotf(endPoint.x,endPoint.y);
    float xl = (endPoint.x);
    //    计算夹角 (1,0)
    float aa= xl/distanceend;
    float angle =fabs(acos(aa));
    NSLog(@"click %.2f",angle);
    //
    if (endPoint.y>0) {
        angle=2*M_PI-angle;
    }
    
    if(angle<=0)
    {
        angle =2*M_PI+angle;
    }
    
    float percent = 100*0.5*angle/M_PI;
    
    float start = 0.0;
    for (int i=0; i<self.pieChartPercentArray.count;i++) {
        
        float percent0 = [self.pieChartPercentArray[i] floatValue];
        if (percent>=start&&percent<=start+percent0) {
            
            [self scalemoveout:i centerPercent:start+percent0*0.5];
            break;
        }else
        {
            start+=percent0;
        }
    }
    
}
#pragma mark - 出列
- (void)scalemoveout:(int)idx centerPercent:(float)percent
{
    //    将原来的半径扩大
    if(_previousIdx>hasNotMoved)
    {
        [self retrieve:_previousIdx centerPercent:_oldPercent];
        if (_previousIdx!=idx) {
            [self scalebigger:idx centerPercent:percent];
        }
    }else
    {
        [self scalebigger:idx centerPercent:percent];
        
    }
    
    if (_previousIdx==idx&&_previousIdx>hasNotMoved) {
        _previousIdx = hasNotMoved;
    }else
    {
        _previousIdx = idx;
    }
    _oldPercent = percent;
    
}
#pragma mark - 放大
- (void)scalebigger:(int)idx centerPercent:(float)percent
{
    float start = 0.0;
    float end = 0.0;
    float oldPercent = 0.0;
    
    for (int i=0; i<self.pieChartPercentArray.count;i++) {
        float percent = [self.pieChartPercentArray[i] floatValue];
        end -=2*M_PI*percent*0.01;
        
        if(i==idx)
        {
            UIBezierPath *path = [self piePathWithRadius:_thirdCircle startAngle:-2*M_PI*oldPercent*0.01 endAngle:-2*M_PI*(oldPercent+percent)*0.01];
            CAShapeLayer *shape = _layerArray[idx];
            shape.path = path.CGPath;
            [self.layer insertSublayer:shape atIndex:4];
            break;
        }else
        {
            start = end;
            oldPercent+=percent;
            
            continue;
        }
    }
}
#pragma mark - 恢复
- (void)retrieve:(int)idx centerPercent:(float)percent
{
    float start = 0.0;
    float end = 0.0;
    float oldPercent = 0.0;
    
    for (int i=0; i<self.pieChartPercentArray.count;i++) {
        float percent = [self.pieChartPercentArray[i] floatValue];
        end -=2*M_PI*percent*0.01;
        
        if(i==idx)
        {
            UIBezierPath *path = [self piePathWithRadius:_secondCircle startAngle:-2*M_PI*oldPercent*0.01 endAngle:-2*M_PI*(oldPercent+percent)*0.01];
            CAShapeLayer *shape = _layerArray[idx];
            shape.path = path.CGPath;
            break;
        }else
        {
            start = end;
            oldPercent+=percent;
            continue;
        }
    }
}
#pragma mark - 放大效果 可修改 目前弃用（审美残废还没有想出比较可爱的放大效果）
- (void)moveout:(int)idx centerPercent:(float)percent
{
    float angle = percent *2*M_PI*0.01;
    
    CAShapeLayer *shape = _layerArray[idx];
    NSLog(@"移动 %d %.2f",idx,angle);
    
    CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.fromValue =  [NSValue valueWithCGPoint: shape.position];
    
    CGPoint toPoint = shape.position;
    
    toPoint.x += 20*cos(angle);
    toPoint.y -= 20*sin(angle);
    animation.duration = 0.3;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [shape addAnimation:animation forKey:@"movexy"];
    
    {
        CAShapeLayer *maskshape = _maskLayerArray[idx];
        
        CABasicAnimation *maskanimation  = [CABasicAnimation animationWithKeyPath:@"position"];
        
        maskanimation.fromValue =  [NSValue valueWithCGPoint: maskshape.position];
        
        CGPoint toPoint = maskshape.position;
        
        toPoint.x += 20*cos(angle);
        toPoint.y -= 20*sin(angle);
        maskanimation.duration = 0.3;
        maskanimation.toValue = [NSValue valueWithCGPoint:toPoint];
        maskanimation.removedOnCompletion = NO;
        maskanimation.fillMode = kCAFillModeForwards;
        
        [maskshape addAnimation:maskanimation forKey:@"maskmovexy"];
    }
}
#pragma mark - 计算区
#pragma mark - 饼图某扇形区域的路径
- (UIBezierPath *)piePathWithRadius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    UIBezierPath *path = [UIBezierPath bezierPath]; // 创建路径
    
    [path moveToPoint:viewCenter]; // 设置起始点
    [path addArcWithCenter:viewCenter radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO]; // 绘制一个圆弧
    
    path.lineWidth     = 0.1;
    path.lineCapStyle  = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [path closePath]; // 封闭未形成闭环的路径
    
    [path stroke]; // 绘制
    return path;
}
@end
