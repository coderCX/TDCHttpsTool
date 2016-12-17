//
//  CL_Device.h
//  CityLove
//
//  Created by chengxi on 2016/12/12.
//  Copyright © 2016年 chengxi. All rights reserved.
//  设备信息

#import <Foundation/Foundation.h>

@interface TDC_Device : NSObject


+ (id)constructFromStorage;

//定位
/**
 *  城市名
 */
@property (nonatomic) NSString *city;

/**
 *  城市区号
 */
@property (nonatomic) NSString *cityCode;

/**
 *  经度
 */
@property (nonatomic) float lalong;

/**
 *  纬
 */
@property (nonatomic) float valat;

//设备参数
/**
 *  应用程序标识
 */
@property (nonatomic, readonly) NSString *appId;

/**
 *  渠道号码
 */
@property (nonatomic, readonly) NSString *channels;

/**
 *  协议版本号
 */
@property (nonatomic, readonly) NSString *ver;

/**
 *  客户端版本号
 */
@property (nonatomic, readonly) NSString *clientVer;

/**
 *  网络接入点
 */
@property (nonatomic, readonly) NSString *apn;

/**
 *  设备号
 */
@property (nonatomic, readonly) NSString *deviceId;

/**
 *  平台，Android或IOS
 */
@property (nonatomic, readonly) NSString *platform;

/**
 *  分辨率 640*960
 */
@property (nonatomic, readonly) NSString *resolution;

/**
 *  手机品牌
 */
@property (nonatomic, readonly) NSString *brand;

/**
 *  运营商
 */
@property (nonatomic, readonly) NSString *carrier;

/**
 *  手机型号
 */
@property (nonatomic, readonly) NSString *deviceType;

/**
 *  平台版本号
 */
@property (nonatomic, readonly) NSString *platformVer;

@end
