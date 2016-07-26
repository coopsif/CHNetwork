//
//  CHNetwork.h
//  AboutAFNetworking
//
//  Created by Cher on 16/7/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define NoNetworkCode -1001
#define NoNetworkDomain @"网络出走了~"

typedef NS_ENUM(NSInteger, RequestType)
{
     CHNetwork_GET = 0,
     CHNetwork_POST = 1,
     CHNetwork_DELETE = 2,
     CHNetwork_PUT,
};

typedef NS_ENUM(NSInteger, ErrorType)
{
     CHNetworkErrorTypeDefault = 0,
     CHNetworkErrorTypeNoNetWork = 1,
};

@interface CHNetwork : NSObject

/**
 *  基于AFNetworking 3.0 网络请求初步封装
 */

/**
 *  获取CHNetwork单例对象
 *
 *  @return 单例对象
 */
+ (instancetype)sharedInstance;

/**
 *  初始化(还原)网络请求头
 */
- (void)initializationRequestSerializer;

/**
 *  更新网络请求头
 *
 *  @param dic 更新网络请求头字典参数
 */
- (void)updateRequestSerializer:(NSDictionary *)parameters;

/**
 *  发起网络请求
 *
 *  @param url        请求地址
 *  @param type       请求类型 RequestType
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return 标记网络请求id
 */
- (NSNumber *)requestUrl:(NSString *)url type:(RequestType)type parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *responseDict))success failure:(void(^)(NSError *error, ErrorType errorType))failure;

/**
 *  取消指定标记的网络请求
 *
 *  @param requestID 指定标记id
 */
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

/**
 *  取消指定标记组的网络请求
 *
 *  @param requestIDList 指定标记组
 */
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
