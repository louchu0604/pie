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
static BOOL openWrite;
static NSMutableArray <NSDictionary*> *vcArray;
static NSMutableString *saveLogs;
static NSDictionary *commands;
static NSDateFormatter *formatter;
static NSString *currentIndex;
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
        openWrite = false;
        vcArray = [NSMutableArray new];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cy_trace_command" ofType:@"json"];
        
        NSData *data=[NSData dataWithContentsOfFile:path];
       commands = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        saveLogs = [NSMutableString new];
        currentIndex = @"";
        
        //        判断文件是否存在？donothing:create a new one
        
//    why serial? writeToFile需要串行执行 查阅oc的文件读写原理（）
    });
    return manager;
    
}
- (void)freshCommand
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cy_trace_command" ofType:@"json"];
    
    NSData *data=[NSData dataWithContentsOfFile:path];
    commands = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
}
- (void)addAction:(SEL)action from:(nullable id)sender to:(nullable id)target
{
    if (openWrite) {
        NSLog(@"可以记录");
        
        NSMutableString *logStr = [NSMutableString new];
        [logStr appendString:[NSString stringWithFormat:@"sel:%@ from:%@  ",NSStringFromSelector(action),NSStringFromClass([sender class])]];
        [logStr appendString:@"("];
        if ([sender isKindOfClass:[UIButton class]]) {
            NSString *strtitle = ((UIButton *)sender).currentTitle;
            
            if (strtitle) {
                NSLog(@"strtitle : %@",strtitle);
                [logStr appendString:[NSString stringWithFormat:@"按钮名称:%@ ",strtitle]];
            }
            NSString *imagename = ((UIButton *)sender).imageView.image.accessibilityIdentifier;
            if ((imagename)) {
                NSLog(@"imagename : %@",imagename);
                [logStr appendString:[NSString stringWithFormat:@"按钮图片:%@ ",imagename]];
            }
           
        }
        Class cls = NSClassFromString(@"_UIButtonBarButton");
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            NSString *strtitle = ((UIBarButtonItem *)sender).title;
            
            if (strtitle) {
                NSLog(@"strtitle : %@",strtitle);
                [logStr appendString:[NSString stringWithFormat:@"按钮名称:%@ ",strtitle]];
            }
            NSString *imagename = ((UIBarButtonItem *)sender).image.accessibilityIdentifier;
            if ((imagename)) {
                NSLog(@"imagename : %@",imagename);
                [logStr appendString:[NSString stringWithFormat:@"按钮图片:%@ ",imagename]];
            }
            
        }
        
        if ([sender isKindOfClass:[UISwitch class]]) {
            BOOL open = ((UISwitch *)sender).on;
            if (open) {
                [logStr appendString:@"open"];

            }else
            {
                [logStr appendString:@"close"];
            }
        }
    
        [logStr appendString:[NSString stringWithFormat:@") to:%@ \r",NSStringFromClass([target class])]];
        [self saveLog:logStr];
        
    }
    
//    key的值为路径+要追踪的方法
    
//    query current vc add event
    
//    遍历superview 举例：viewcontroller_view_btn
//    NSLog(@"\r url:%@ \r action:%@ class:%@",url_path,NSStringFromSelector(action),NSStringFromClass([sender class]));
    
}
- (void)currentIndex:(NSString *)index
{
    currentIndex = index;
}
#pragma mark - 路径重置
- (void)setCurrentPath
{
    [vcArray removeAllObjects];
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
    
    NSMutableString *str = [NSMutableString new];
    for (NSDictionary *vcinfo in vcArray) {
        NSLog(@"当前vc ：%@ %@",[vcinfo valueForKey:@"name"],[vcinfo valueForKey:@"add"]);
        [str appendString:[vcinfo valueForKey:@"name"]];
        [str appendString:@"-"];
    }
    openWrite = false;
    if ([[commands valueForKey:@"isAll"] intValue]==1){//isAll==1 对此页面开始的路径都生效
        for (NSDictionary  *dic in [commands valueForKey:@"path"]) {
            if ([str hasPrefix:[dic valueForKey:@"path"]]&& [[dic valueForKey:@"index"] indexOfObject:currentIndex]!=NSNotFound) {
                openWrite = true;
                break;
            }
        }
    }else
    {
        for (NSDictionary  *dic in [commands valueForKey:@"path"]) {
            if ([str isEqualToString:[dic valueForKey:@"path"]]&& [[dic valueForKey:@"index"] indexOfObject:currentIndex]!=NSNotFound) {
                openWrite = true;
                break;
            }
        }
    }
    if(openWrite)
    {
        [self saveLog:[NSString stringWithFormat:@"time:%@ tab:%@ path:%@ \r",[formatter stringFromDate:[NSDate date]],currentIndex,str]];
    }
    
}
- (void)saveLog:(NSString *)tracelog
{
    [saveLogs appendString:tracelog];
    [self writeLog];
}
- (void)writeLog
{
    if (saveLogs.length==0) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    
   
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:savePath];
    if (![fileManager fileExistsAtPath:filePath]) {
        
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    BOOL result =[saveLogs writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (result) {//
        [saveLogs setString:@""];
        NSLog(@"write success");
    }else
    {
        NSLog(@"write fail");
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
