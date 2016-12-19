//
//  TDCHttpTool.m
//  CityLove
//
//  Created by chengxi on 2016/12/14.
//  Copyright © 2016年 chengxi. All rights reserved.
//

#import "TDCHttpsTool.h"
#import "HttpResponse.h"

@interface TDCHttpsTool()

/**
 AF Http Object
 */
@property (nonatomic,strong) AFHTTPSessionManager *afSessionManger;

@end

@implementation TDCHttpsTool

SingletonM(TDCHttpsTool)

// 懒加载
- (AFHTTPSessionManager *)afSessionManger
{
    if (!_afSessionManger)
    {
        _afSessionManger = [AFHTTPSessionManager manager];
        _afSessionManger.requestSerializer = [AFJSONRequestSerializer serializer];
        _afSessionManger.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _afSessionManger;
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params
               success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{
    
    [self.afSessionManger POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        if (success == nil) return;
        HttpResponse *response =  [[HttpResponse sharedHttpResponse] returnHttpResponse:responseObject];
        // 返回
        success(response.data,response.baseCode,response.baseMsg);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        if (failure == nil) return;
        failure(error);
    }];
}

- (void)getWithURL:(NSString *)url params:(NSDictionary *)params
           success:(HttpSuccessBlock)success
           failure:(HttpFailureBlock)failure
{
    [self.afSessionManger GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success == nil) return;
         HttpResponse *response =  [[HttpResponse sharedHttpResponse] returnHttpResponse:responseObject];
         // 返回
         success(response.data,response.baseCode,response.baseMsg);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (failure == nil) return;
         failure(error);
     }];
}

- (void)downloadImage:(NSString *)url place:(UIImage *)place imageView:(UIImageView *)imageView
{
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:place options:SDWebImageRetryFailed|SDWebImageLowPriority];
}

@end
