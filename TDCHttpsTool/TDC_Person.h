//
//  CL_Person.h
//  CityLove
//
//  Created by chengxi on 2016/12/12.
//  Copyright © 2016年 chengxi. All rights reserved.
/**
 之后项目 继承自本类做Person模型管理
 本类的属性从项目角度考虑基本是之后的必填字段 
 */

#import <Foundation/Foundation.h>

@class TDC_Device;
@interface TDC_Person : NSObject

/**
 设备初始化
 @param deviceInfo 设备对象
 @return 设备对象
 */
- (id)initWithDeviceInfo:(TDC_Device *)deviceInfo;

/**
 *  是否登录了
 */
@property (nonatomic, readonly) BOOL isLogin;

/**
 *  用户ID
 */
@property (nonatomic,copy) NSString *userId;

/**
 *  头像地址
 */
@property (nonatomic,copy) NSString *headImageURL;

/**
 *  昵称
 */
@property (nonatomic,copy) NSString *nickName;

/**
 *  签名
 */
@property (nonatomic,copy) NSString *signature;

/**
 *  性别//0代表未知，1代表男，2代表女
 */
@property (nonatomic,copy) NSString *sexual;

/**
 *  生日
 */
@property (nonatomic,copy) NSString *birthday;

/**
 *  经验值
 */
@property (nonatomic,assign) double experience;

/**
 *  用户账户登录名
 */
@property (nonatomic,copy) NSString *account;

/**
 *  用户账户密码
 */
@property (nonatomic,copy) NSString *password;

/**
 *  金币
 */
@property (nonatomic,copy) NSString *money;


/**
 清空用户信息
 */
- (void)clearPersonInfo;

/**
 *  获取请求基础参数
 */
- (NSMutableDictionary *)requestBaseParam;

@end
