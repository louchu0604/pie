//
//  CYTrackingManager.h
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import <Foundation/Foundation.h>
enum{
    kPrensentVC=0,
    kDismissVC,
    kPushVC,
    kPopVC,
};
@interface CYTrackingManager : NSObject
+(instancetype)sharedTrackingManager;
- (void)addEvent:(SEL)action from:(nullable id)sender;
- (void)currentVC:(id)vc event:(int)event;
- (void)addVC:(NSDictionary *)info;
- (void)removeVC:(NSDictionary *)info;
- (void)resetVCArray:(NSArray *)vc;
@end
