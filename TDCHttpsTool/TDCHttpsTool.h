//
//  TDCHttpTool.h
//  CityLove
//
//  Created by chengxi on 2016/12/14.
//  Copyright © 2016年 chengxi. All rights reserved.
//   采用单例 重新设计， 此单例文件跟随网络请求文件一起存在

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "TDC_Device.h"
#import "TDC_Person.h"

// 基础参数Base节点Key
#define Key_Req_Base            @"base"
#define Key_Req_Param           @"param"
#define Key_Resp_Base           @"base"
#define Key_Resp_Data           @"data"
#define Key_Resp_Data_Other     @"other"
#define Key_Resp_Code           @"code"
#define Key_Resp_Msg            @"msg"

/**
 请求所依赖的几个库有：
 AFNetworking
 Reachability
 SDWebImage
 SAMKeychain
 */

typedef void (^HttpSuccessBlock)(id JSON,int code,NSString *msg);
typedef void (^HttpFailureBlock)(NSError *error);

@interface TDCHttpsTool : NSObject

SingletonH(TDCHttpsTool)

/**
 get 请求

 @param url URL
 @param params 请求体
 @param success 成功Block
 @param failure 失败Block
 */
- (void)getWithURL:(NSString *)url params:(NSDictionary *)params
                                   success:(HttpSuccessBlock)success
                                   failure:(HttpFailureBlock)failure;

/**
 post 请求
 
 @param url URL
 @param params 请求体
 @param success 成功Block
 @param failure 失败Block
 */
- (void)postWithURL:(NSString *)url params:(NSDictionary *)params
           success:(HttpSuccessBlock)success
           failure:(HttpFailureBlock)failure;



/**
 下载网络图片
 @param url url
 @param place 占位图
 @param imageView 显示控件
 */
- (void)downloadImage:(NSString *)url
                place:(UIImage *)place
                imageView:(UIImageView *)imageView;
@end
