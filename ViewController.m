//
//  ViewController.m
//  CHNetwork
//
//  Created by Cher on 16/7/26.
//  Copyright © 2016年 Cher. All rights reserved.
//

#import "ViewController.h"
#import "CHNetworkConfigHeader.h"
#import "CHAppHelper.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentNetwork;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation ViewController


- (void)viewDidLoad {
     [super viewDidLoad];
     // Do any additional setup after loading the view, typically from a nib.
     
     NSString *recommend_url = @"https://api.douban.com/v2/book/1220562";
     NSNumber *req_id = [[CHNetwork sharedInstance] requestUrl:recommend_url
                                                          type:CHNetwork_GET
                                                    parameters:nil
                                                       success:^(NSDictionary *responseDict) {
                                                            
                                                            NSLog(@"%@",responseDict);
                                                       } failure:^(NSError *error, ErrorType errorType) {
                                                            if (errorType == CHNetworkErrorTypeNoNetWork) {
                                                                 NSLog(@"%@",error.domain);
                                                            }
                                                       }];
     
     //取消网络请求
     //[[CHNetwork sharedInstance] cancelRequestWithRequestID:req_id];
     
     
     __block __weak ViewController *weakSelf = self;
     [[CHAppHelper sharedInstance] openLocationServiceOnCompletion:^(CLPlacemark *placemark) {
          
          if (placemark) {
               //NSLog(@"%@",placemark.addressDictionary);
               for (NSString *key in placemark.addressDictionary) {
                    NSLog(@"%@:%@\n",key,placemark.addressDictionary[key]);
               }
               dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.locationLabel.text = placemark.addressDictionary[@"Name"];
               });
          }
     }];
     
     [[CHAppHelper sharedInstance] addObserver:self forKeyPath:@"networkReachabilityStatus" options:NSKeyValueObservingOptionNew context:nil];
     
}

- (void)dealloc{
     [[CHAppHelper sharedInstance] removeObserver:self forKeyPath:@"networkReachabilityStatus"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
     if ([keyPath isEqualToString:@"networkReachabilityStatus"]) {
          NSLog(@"%@",change[@"new"]);
          CHAppHelperReachabilityStatus networkReachabilityStatus = [change[@"new"] integerValue];
          switch (networkReachabilityStatus) {
               case CHAppHelperReachabilityStatusUnknown:
               {
                    self.currentNetwork.text = @"当前无网络";
               }
                    break;
               case CHAppHelperReachabilityStatusNotReachable:
               {
                    self.currentNetwork.text = @"当前无网络";
               }
                    break;
               case CHAppHelperReachabilityStatusReachableViaWWAN:
               {
                    self.currentNetwork.text = @"当前2/3/4G网络";
               }
                    break;
               case CHAppHelperReachabilityStatusReachableViaWiFi:
               {
                    self.currentNetwork.text = @"当前WiFi网络";
               }
                    break;
                    
               default:
                    break;
          }
          
     }
}


- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
     // Dispose of any resources that can be recreated.
}

@end
