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
        
    });
    return manager;
    
}
- (void)freshCommand
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cy_trace_command" ofType:@"json"];
    
    NSData *data=[NSData dataWithContentsOfFile:path];
    commands = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
}
#pragma mark - 记录相应的点击日志
- (void)addAction:(SEL)action from:(nullable id)sender to:(nullable id)target
{
    if (openWrite) {
        NSMutableString *logStr = [NSMutableString new];
        [logStr appendString:[NSString stringWithFormat:@"sel:%@ from:%@  ",NSStringFromSelector(action),NSStringFromClass([sender class])]];
        [logStr appendString:@"("];
        if ([sender isKindOfClass:[UIButton class]]) {
            NSString *strtitle = ((UIButton *)sender).currentTitle;
            if (strtitle) {
                [logStr appendString:[NSString stringWithFormat:@"按钮名称:%@ ",strtitle]];
            }
            NSString *imagename = ((UIButton *)sender).imageView.image.accessibilityIdentifier;
            if ((imagename)) {
                [logStr appendString:[NSString stringWithFormat:@"按钮图片:%@ ",imagename]];
            }
        }
        Class cls = NSClassFromString(@"_UIButtonBarButton");
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            NSString *strtitle = ((UIBarButtonItem *)sender).title;
            
            if (strtitle) {
                [logStr appendString:[NSString stringWithFormat:@"按钮名称:%@ ",strtitle]];
            }
            NSString *imagename = ((UIBarButtonItem *)sender).image.accessibilityIdentifier;
            if ((imagename)) {
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
}

#pragma mark - tab切换
- (void)currentIndex:(NSString *)index
{
    currentIndex = index;
}
#pragma mark - vc入栈
- (void)addVC:(NSDictionary *)info
{
    [vcArray addObject:info];
    [self printvcarray];

}
#pragma mark - vc出栈 根据内存地址来匹配
- (void)removeVC:(NSDictionary *)info
{
    for (NSDictionary *vcinfo in vcArray) {
        if ([[vcinfo valueForKey:@"add"] isEqualToString:[info valueForKey:@"add"]]) {
            [vcArray removeObject:vcinfo];
            break;
        }
    }
    [self printvcarray];
   
}
#pragma mark - nav resetVCs
- (void)resetVCArray:(NSArray *)vc
{
    [vcArray removeAllObjects];
    [vcArray addObjectsFromArray:vc];
    NSLog(@"reset");
    [self printvcarray];
}
#pragma mark - 查看当前路径 格式VCName-VCName-VCName-VCName-...
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
    dispatch_sync(serialQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentDirectory = [directoryPaths objectAtIndex:0];
        
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:savePath];
        
        
        if (![fileManager fileExistsAtPath:filePath]) {
            
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        NSData *data =[saveLogs dataUsingEncoding:NSUTF8StringEncoding];
        NSFileHandle *writeFileHandle =[NSFileHandle fileHandleForWritingAtPath:filePath];
        [writeFileHandle seekToEndOfFile]; //设置偏移量跳到文件的末尾
        [writeFileHandle writeData:data]; //写入数据
        [writeFileHandle closeFile]; //关闭文件
        
        [saveLogs setString:@""];
        NSLog(@"write success");
    });
  
}

@end
