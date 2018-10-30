//
//  CYNodeManager.m
//  CYTracking
//
//  Created by 楼楚 on 2018/7/8.
//  Copyright © 2018年 Chu Lou. All rights reserved.
//

#import "CYNodeManager.h"

static CYNodeManager *nodeManager;
static NSMutableArray *nodes;
@implementation CYNodeManager
+ (instancetype)sharedNodeManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nodeManager = [[CYNodeManager alloc]init];
        nodes = [NSMutableArray new];
    });
    
    return nodeManager;
}
@end
