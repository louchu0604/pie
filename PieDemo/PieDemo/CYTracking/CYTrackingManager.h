//
//  CYTrackingManager.h
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
enum{
    kPrensentVC=0,
    kDismissVC,
    kPushVC,
    kPopVC,
};
//写：生成一条 写一条
//上报：后台运行||主动上报||
@interface CYTrackingManager : NSObject
+(instancetype)sharedTrackingManager;
- (void)addAction:(SEL)action from:(nullable id)sender to:(nullable id)target;
- (void)addVC:(NSDictionary *)info;
- (void)removeVC:(NSDictionary *)info;
- (void)resetVCArray:(NSArray *)vc;
- (void)freshCommand;
- (void)currentIndex:(NSString *)index;
@end
