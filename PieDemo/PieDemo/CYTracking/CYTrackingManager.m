//
//  CYTrackingManager.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "CYTrackingManager.h"

//维护一个串行队列
#define savePath @"cytracking.txt"
static dispatch_queue_t serialQueue;
static CYTrackingManager * manager;
static int CYTrackingCurrentVCIndex;//页面的深度
static int CYTrackingCurrentViewIndex;//视图的深度
static NSMutableString *url_path;
static NSMutableArray <NSDictionary*> *vcArray;
@interface CYTrackingManager()
@end
//static id *__unsafe_unretained *vc;

//统计： 路径_要追踪的方法名：次数
//日志：路径：调用的方法名 时间
//路径：维护一个路径数组： 每次pop回来 都需要比对（比对指针即可）

@implementation CYTrackingManager
+(instancetype)sharedTrackingManager
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[CYTrackingManager alloc] init];
        serialQueue = dispatch_queue_create("me.dearcy.cytrackingQueue", NULL);
        url_path = [NSMutableString new];
        vcArray = [NSMutableArray new];
        
        //        判断文件是否存在？donothing:create a new one
        
//    why serial? writeToFile需要串行执行 查阅oc的文件读写原理（）
    });
    return manager;
    
}
- (void)addEvent:(SEL)action from:(nullable id)sender
{
//    key的值为路径+要追踪的方法
    
//    query current vc add event
    
//    遍历superview 举例：viewcontroller_view_btn
//    NSLog(@"\r url:%@ \r action:%@ class:%@",url_path,NSStringFromSelector(action),NSStringFromClass([sender class]));
    
}
#pragma mark - 路径重置
- (void)setCurrentPath
{
    [vcArray removeAllObjects];
}
- (void)currentVC:(NSString *)vc
{
    if(url_path.length==0){
        [url_path appendString:vc];
    }else
    {
        [url_path appendString:@"-"];
        [url_path appendString:vc];
    }
}
- (void)p_removeVC:(id)vc
{
    for (id element in vcArray) {
        if (vc==element) {
            [vcArray removeObject:element];
            break;
        }
    }
}
#pragma mark - 根据内存地址来匹配
- (void)addVC:(NSDictionary *)info
{
    [vcArray addObject:info];
     NSLog(@"add");
    [self printvcarray];

}
- (void)removeVC:(NSDictionary *)info
{
    
    for (NSDictionary *vcinfo in vcArray) {
        if ([[vcinfo valueForKey:@"add"] isEqualToString:[info valueForKey:@"add"]]) {
            [vcArray removeObject:vcinfo];
            break;
        }
    }
    NSLog(@"remove");
    [self printvcarray];
   
}
- (void)printvcarray
{
    for (NSDictionary *vcinfo in vcArray) {
        NSLog(@"当前vc ：%@ %@",[vcinfo valueForKey:@"name"],[vcinfo valueForKey:@"add"]);
    }
}
- (void)resetVCArray:(NSArray *)vc
{
    [vcArray removeAllObjects];
    [vcArray addObjectsFromArray:vc];
     NSLog(@"reset");
    [self printvcarray];
}
@end
