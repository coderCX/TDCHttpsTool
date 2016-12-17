//
//  TDC_DeviceUtil.h
//  CityLove
//
//  Created by chengxi on 2016/12/12.
//  Copyright © 2016年 chengxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDC_DeviceUtil : NSObject

/**
 *  手机型号
 *
 *  @return 手机型号
 */
+ (NSString *)platformString;

/**
 *  系统版本号
 *
 *  @return 系统版本号
 */
+ (NSString *)systemVersion;

/**
 *  获取屏幕分辨率
 *
 *  @return 获取屏幕分辨率
 */
+ (NSString *)resolution;

@end
