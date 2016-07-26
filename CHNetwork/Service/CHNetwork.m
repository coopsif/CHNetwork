//
//  CHNetwork.m
//  AboutAFNetworking
//
//  Created by Cher on 16/7/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "CHNetworkConfigHeader.h"
#import "CHAppHelper.h"
@interface CHNetwork()

@property (nonatomic, strong) AFHTTPSessionManager *aFHTTPSessionManager;
@property (nonatomic, strong) NSMutableDictionary *dataTaskdict;
@property (nonatomic, strong) NSNumber *recordedRequestId;

@end

@implementation CHNetwork

+ (instancetype)sharedInstance{
     
     static CHNetwork *_cHNetwork = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          _cHNetwork = [[CHNetwork alloc] init];
     });
     return _cHNetwork;
}

- (id)init{
     self = [super init];
     if (self) {
          _aFHTTPSessionManager = [AFHTTPSessionManager manager];
          [self initializationRequestSerializer];
     }
     return self;
}

- (NSNumber *)generateRequestId
{
     if (_recordedRequestId == nil) {
          _recordedRequestId = @(1);
     } else {
          if ([_recordedRequestId integerValue] == NSIntegerMax) {
               _recordedRequestId = @(1);
          } else {
               _recordedRequestId = @([_recordedRequestId integerValue] + 1);
          }
     }
     return _recordedRequestId;
}

- (NSMutableDictionary *)dataTaskdict{
     
     if (_dataTaskdict == nil) {
          _dataTaskdict = [NSMutableDictionary dictionary];
     }
     return _dataTaskdict;
}


#pragma mark ---- public method
- (void)initializationRequestSerializer{
     
     AFHTTPRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
     [serializer setTimeoutInterval:30.f];
     _aFHTTPSessionManager.requestSerializer = serializer;
     _aFHTTPSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (void)updateRequestSerializer:(NSDictionary *)parameters{
     
     if (!parameters) return;
     AFHTTPRequestSerializer *serializer = _aFHTTPSessionManager.requestSerializer;
     [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          [serializer setValue:obj forHTTPHeaderField:key];
     }];
     _aFHTTPSessionManager.requestSerializer = serializer;
}

- (NSNumber *)requestUrl:(NSString *)url type:(RequestType)type parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *responseDict))success failure:(void(^)(NSError *error, ErrorType errorType))failure{
     
     if (!url) return nil;
     if (![[CHAppHelper sharedInstance] isReachable]) {//无网络操作
          NSError *error =  [NSError errorWithDomain:NoNetworkDomain code:NoNetworkCode userInfo:nil];
          failure?failure(error,CHNetworkErrorTypeNoNetWork):nil;
          return nil;
     }
     
     NSURLSessionDataTask *dataTask;
     NSNumber *requestId = [self generateRequestId];
     switch (type) {
          case CHNetwork_GET:
          {
               dataTask = [_aFHTTPSessionManager GET:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) {
                         success?success(nil):nil;
                         return;// 如果这个operation是被cancel的，那就不用处理回调了。
                    }
                    [self.dataTaskdict removeObjectForKey:requestId];
                    NSDictionary *responseDic = [CHTools jsonToDictionary:responseObject];
                    success?success(responseDic):nil;
                    
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) return;
                    [self.dataTaskdict removeObjectForKey:requestId];
                    failure?failure(error,CHNetworkErrorTypeDefault):nil;
               }];
          }
               break;
          case CHNetwork_POST:
          {
               
               dataTask = [_aFHTTPSessionManager POST:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) {
                         success?success(nil):nil;
                         return;
                    }
                    [self.dataTaskdict removeObjectForKey:requestId];
                    NSDictionary *responseDic = [CHTools jsonToDictionary:responseObject];
                    success?success(responseDic):nil;
                    
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) return;
                    [self.dataTaskdict removeObjectForKey:requestId];
                    failure?failure(error,CHNetworkErrorTypeDefault):nil;
               }];
          }
               break;
          case CHNetwork_DELETE:
          {
               dataTask = [_aFHTTPSessionManager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) {
                         success?success(nil):nil;
                         return;
                    }
                    [self.dataTaskdict removeObjectForKey:requestId];
                    NSDictionary *responseDic = [CHTools jsonToDictionary:responseObject];
                    success?success(responseDic):nil;
                    
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) return;
                    [self.dataTaskdict removeObjectForKey:requestId];
                    failure?failure(error,CHNetworkErrorTypeDefault):nil;
               }];
          }
               break;
          case CHNetwork_PUT:
          {
               dataTask = [_aFHTTPSessionManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) {
                         success?success(nil):nil;
                         return;
                    }
                    [self.dataTaskdict removeObjectForKey:requestId];
                    NSDictionary *responseDic = [CHTools jsonToDictionary:responseObject];
                    success?success(responseDic):nil;
                    
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSURLSessionDataTask *storedTask = self.dataTaskdict[requestId];
                    if (storedTask == nil) return;
                    [self.dataTaskdict removeObjectForKey:requestId];
                    failure?failure(error,CHNetworkErrorTypeDefault):nil;
               }];
          }
               break;
          default:
               break;
     }
     
     self.dataTaskdict[requestId] = dataTask;
     return requestId;
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID{

     if (requestID == nil) return;
     NSURLSessionDataTask *task = self.dataTaskdict[requestID];
     [task cancel];
     [self.dataTaskdict removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList{
     
     for (NSNumber *requestId in requestIDList) {
          [self cancelRequestWithRequestID:requestId];
     }
}


#pragma mark ----- private method

- (void)removeCompletedRequest:(NSNumber *)requestID{
     
     NSURLSessionDataTask *task = self.dataTaskdict[requestID];
     [task cancel];
     [self.dataTaskdict removeObjectForKey:requestID];
}




@end
