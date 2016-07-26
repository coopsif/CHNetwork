//
//  AppDelegate+Check.m
//  CHNetwork
//
//  Created by Cher on 16/7/26.
//  Copyright © 2016年 Cher. All rights reserved.
//

#import "AppDelegate+Check.h"
#import "CHAppHelper.h"

@implementation AppDelegate (Check)

+(void)load{
     //检测网络
     [[CHAppHelper sharedInstance] startCheckNetwork];
}

@end
