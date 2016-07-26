//
//  CHAppHelper.m
//  AboutAFNetworking
//
//  Created by Cher on 16/7/21.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "CHAppHelper.h"
#import <UIKit/UIKit.h>
#import <Reachability/Reachability.h>

#define CH_PlacemarkKey @"CH_PlacemarkKey"

typedef void(^CLPlacemarkBlock)(CLPlacemark *);

@interface CHAppHelper()<CLLocationManagerDelegate,UIAlertViewDelegate>
{
     CLLocationManager *_manager;
     BOOL isGoneLOCATION_SERVICES;
}

@property (readwrite, nonatomic, assign) CHAppHelperReachabilityStatus networkReachabilityStatus;
@property (nonatomic, copy)              CLPlacemarkBlock placemarkBlock;

@end

@implementation CHAppHelper

- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
     self = [super init];
     if (self) {
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
     }
     return self;
}

#pragma mark ---- public method
/* 生成单例对象 */
+ (instancetype)sharedInstance {
     
     static CHAppHelper *_cHAppHelper = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          _cHAppHelper = [[CHAppHelper alloc] init];
     });
     return _cHAppHelper;
}

/* 开启地理位置定位服务 */
- (void)openLocationServiceOnCompletion:(void (^)(CLPlacemark *placemark))completion {
     
     if (completion) {
          self.placemarkBlock = [completion copy];
     }
     if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
          if (_manager) {
               _manager = nil;
          }
          _manager = [[CLLocationManager alloc]init];
          _manager.delegate = self;
          _manager.desiredAccuracy = kCLLocationAccuracyBest;
          [_manager requestAlwaysAuthorization];
          //_manager.distanceFilter = 10;
          [_manager startUpdatingLocation];
     }else{
          UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去开启",nil];
          alvertView.tag = 1001;
          [alvertView show];
     }
}

/* 检测当前网络 */
- (void)startCheckNetwork {
     
     //检测 remoteHostName 可达性
     NSString *remoteHostName = @"www.apple.com";
     Reachability *hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
     [hostReachability startNotifier];
     [self updataNetworkReachabilityStatus:hostReachability];
}

/* 检测当前网络是否可用 */
- (BOOL)isReachable {
     return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
     return self.networkReachabilityStatus == CHAppHelperReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
     return self.networkReachabilityStatus == CHAppHelperReachabilityStatusReachableViaWiFi;
}

#pragma mark - delegate
/* CLLocationManager */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
     [_manager stopUpdatingLocation];
     
     CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
     //CLLocation * marsLoction = [location locationBaiduFromMars];
     CLGeocoder *geocoder = [[CLGeocoder alloc] init];
     [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
          
          if (placemarks.count > 0) {
               //NSLog(@"%@",placemarks);
               CLPlacemark *placemark = [placemarks firstObject];
               self.placemarkBlock(placemark);
          }
     }];
}
/* UIAlertView */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (alertView.tag == 1001 && buttonIndex == 1) {
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
          isGoneLOCATION_SERVICES = YES;
     }
}

#pragma mark ---- 通知
/* app变活跃 */
- (void)becomeActive{
     if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&isGoneLOCATION_SERVICES) {
          [self openLocationServiceOnCompletion:nil];
          isGoneLOCATION_SERVICES = NO;
     }
}

/* 网络变化 */
- (void)reachabilityChanged:(NSNotification *)note {
     
     Reachability* curReach = [note object];
     NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
     [self updataNetworkReachabilityStatus:curReach];
}


#pragma mark - private method

/* 根据当前网络变化赋值网络状态 */
- (void)updataNetworkReachabilityStatus:(Reachability *)reachability{
     NetworkStatus netStatus = [reachability currentReachabilityStatus];
     switch (netStatus)
     {
          case NotReachable:
          {
               self.networkReachabilityStatus = CHAppHelperReachabilityStatusNotReachable;
               break;
          }
          case ReachableViaWWAN:
          {
               self.networkReachabilityStatus = CHAppHelperReachabilityStatusReachableViaWWAN;
               break;
          }
          case ReachableViaWiFi:
          {
               self.networkReachabilityStatus = CHAppHelperReachabilityStatusReachableViaWiFi;
               break;
          }
     }
}

@end
