//
//  CL_Person.m
//  CityLove
//
//  Created by chengxi on 2016/12/12.
//  Copyright © 2016年 chengxi. All rights reserved.
//

#import "TDC_Person.h"
#import "TDC_Device.h"


#define Key_USER_ID  @"UserId"
#define Key_NICKNAME  @"NickName"
#define Key_PORTRAIT  @"PortraitImageURL"
#define Key_SEXUAL  @"SEXUAL"
#define Key_Birthday  @"Birthday"
#define Key_Account  @"Account"
#define Key_Password  @"Password"
#define Key_Experience @"Experience"
#define Key_Signature @"Signature"
#define Key_OrderUrl @"OrderURL"
#define Key_Role     @"roleType"
//#define Key_Longitude     @"longitude"
//#define Key_Latitude    @"latitude"
#define Key_Money    @"money"

@interface TDC_Person ()
{
    NSUserDefaults *_userDefaults;
    
    TDC_Device *_deviceInfo;
}
@end

@implementation TDC_Person

- (id)initWithDeviceInfo:(TDC_Device *)deviceInfo
{
    self  = [self init];
    
    _deviceInfo = deviceInfo;
    
    return self;
}

- (BOOL)isLogin
{
    return self.userId.length != 0;
}

- (id)init
{
    self = [super init];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    _userId = [_userDefaults objectForKey:Key_USER_ID];//   001151e2f5474ab58fdbe82582aa2738
    _nickName = [_userDefaults objectForKey:Key_NICKNAME];
    _headImageURL = [_userDefaults objectForKey:Key_PORTRAIT];
    _sexual = [_userDefaults objectForKey:Key_SEXUAL];
    _birthday = [_userDefaults objectForKey:Key_Birthday];
    _experience = [[_userDefaults objectForKey:Key_Experience] doubleValue];
    _account = [_userDefaults objectForKey:Key_Account];
    _signature = [_userDefaults objectForKey:Key_Signature];
//    _longitude = [_userDefaults objectForKey:Key_Longitude];
//    _latitude = [_userDefaults objectForKey:Key_Latitude];
    _money = [_userDefaults objectForKey:Key_Money];
    [self examine];
    return self;
}

//- (void)setRoleType:(NSString *)roleType{
//    _roleType = roleType;
//    [_userDefaults setObject:roleType forKey:Key_Role];
//}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    
    [_userDefaults setObject:userId forKey:Key_USER_ID];
}

- (void)setPortraitImageURL:(NSString *)portraitImageURL
{
    _headImageURL = portraitImageURL;
    
    [_userDefaults setObject:portraitImageURL forKey:Key_PORTRAIT];
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    [_userDefaults setObject:nickName forKey:Key_NICKNAME];
    
}

- (void)setBirthday:(NSString *)birthday
{
    _birthday = birthday;
    
    [_userDefaults setObject:birthday forKey:Key_Birthday];
}

- (void)setMoney:(NSString *)money
{
    _money = money;
    [_userDefaults setObject:money forKey:Key_Money];
}

//- (void)setLongitude:(NSString *)longitude
//{
//    _longitude = longitude;
//    [_userDefaults setObject:longitude forKey:Key_Longitude];
//}
//
//- (void)setLatitude:(NSString *)latitude
//{
//    _latitude = latitude;
//    [_userDefaults setObject:latitude forKey:latitude];
//}

- (void)setPassword:(NSString *)password
{
    _password = password;
    [_userDefaults setObject:password forKey:Key_Password];
}

- (void)setAccount:(NSString *)account
{
    _account = account;
    
    [_userDefaults setObject:account forKey:Key_Account];
}

- (void)setSexual:(NSString *)sexual
{
    _sexual = sexual;
    [_userDefaults setObject:sexual forKey:Key_SEXUAL];
}

- (void)setExperience:(double)experience
{
    _experience = experience;
    
    [_userDefaults setObject:[NSNumber numberWithDouble:experience] forKey:Key_Experience];
}

- (void)setSignature:(NSString *)signature
{
    _signature = signature;
    
    [_userDefaults setObject:signature forKey:Key_Signature];
}

/**
   由于经纬度无效实时获取   所以如果接口有需求的话需要自己在每个接口重新为经纬度字段 单独 赋值当前最新经纬度
 */
- (NSMutableDictionary *)requestBaseParam
{
    NSArray *keys = @[@"appId", @"channels", @"ver", @"clientVer", @"apn", @"deviceId", @"valat", @"lalong", @"platform", @"platformVer", @"resolution", @"deviceType", @"carrier", @"city", @"brand"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:16];
    
    for (NSString *key in keys)
    {
        dic[key] = [_deviceInfo valueForKeyPath:key];
    }
    
    dic[@"uid"] = [self userId]?:@"";
    
//    dic[@"city"] = [_deviceInfo usersCity];
    
    return dic;
}

- (void)clearPersonInfo
{
    self.userId = nil;
    self.headImageURL = nil;
    self.nickName = nil;
    self.sexual = nil;
    self.birthday = nil;
    self.money = nil;
    self.signature = nil;
//    self.orderUrl = nil;
    self.experience = 0;
    self.account = 0;
    self.password = 0;
//    self.roleType = nil;
}

- (void)examine
{
    if (!self.isLogin)
    {
        [self clearPersonInfo];
    }
    if ([self.sexual isKindOfClass:[NSNumber class]])
    {
        int sex = [self.sexual intValue];
        
        self.sexual = [NSString stringWithFormat:@"%d", sex];
    }
}


+ (NSString *)sexText:(int)sex
{
    NSString *result = @"";
    switch (sex) {
        case 0:
            result = @"未知";
            break;
        case 1:
            result = @"男";
            
            break;
        case 2:
            result = @"女";
            
            break;
            
        default:
            break;
    }
    return result;
}

@end
