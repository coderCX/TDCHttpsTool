//
//  NetworkUtil.h
//  TodayCity
//
//  Created by common on 15/4/16.
//  Copyright (c) 2015年 TodayCity. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *kReachabilityChangedNotification;

@interface TDCNetworkUtil : NSObject

/**
 * 使用第三方库SSKeychain 获取保存在keychain里面的 uuid 如果第一次则生成一个并保存到keychain中
 **/
+ (NSString *)getSSKeychainValue;

/**
 *  获取本地IP地址
 */
+ (NSString *)getIPAddress;

/**
 *  获取网络类型
 *
 *  @return获取网络类型
 */
+ (int)netType;
/**
 *  根据网络类型枚举获取网络名称
 *
 *  @return 根据网络类型枚举获取网络名称
 */
+ (NSString *)apnNameWithReachabilityStatus:(NSInteger)status;
/**
 *  网络接入点名称
 *
 *  @return网络接入点名称
 */
+ (NSString *)apnName;

/**
 *  网络接入点详细类型
 *
 *  @return网络接入点详细类型
 */
+ (int)netDetailType;

/**
 *  运营商名称
 *
 *  @return 运营商名称
 */
+ (NSString *)carrierName;

/**
 *  检查网络是否连接
 *
 *  @return检查网络是否连接
 */
+ (BOOL)connectedToNetwork;

@end
