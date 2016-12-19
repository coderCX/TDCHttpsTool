//
//  CL_Device.m
//  CityLove
//
//  Created by chengxi on 2016/12/12.
//  Copyright © 2016年 chengxi. All rights reserved.
//

#import "TDC_Device.h"
#import "TDCNetworkUtil.h"
#import "TDC_DeviceUtil.h"
#import "Reachability.h"

@implementation TDC_Device
{
    Reachability *reachbility;
}
- (id)init
{
    self = [super init];
    
    [self initStorage];
    
    [self registObserverForStorageProperty];
    
    return self;
}

+ (id)constructFromStorage
{
    id result;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceInfo"];
    if (data != nil)
    {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        result = [[self alloc] init];
    }
    
    return result;
}

- (void)initStorage
{
    NSDictionary *infoDictionary=[[NSBundle mainBundle] infoDictionary];
    _appId = @"CGI001";
    _channels = @"";
    _ver = [infoDictionary objectForKey:@"CFBundleVersion"];
    _clientVer = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    _apn = [TDCNetworkUtil apnName];
    reachbility = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [reachbility startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:kReachabilityChangedNotification object:nil];
    
    _deviceId = [TDCNetworkUtil getSSKeychainValue];
    _platform = @"IOS";
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _resolution = [NSString stringWithFormat:@"%f*%f", screenSize.width, screenSize.height];
    _brand = @"iPhone";
    _carrier = [TDCNetworkUtil carrierName]?:@"";
    _deviceType = [TDC_DeviceUtil platformString];
    _platformVer = [TDC_DeviceUtil systemVersion];
}

- (void)registObserverForStorageProperty
{
    [self addObserver:self forKeyPath:@"city" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"cityCode" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"valat" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"lalong" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"usersCity" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"usersCityCode" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unRegistObserverForStorageProperty
{
    [self removeObserver:self forKeyPath:@"city"];
    [self removeObserver:self forKeyPath:@"cityCode"];
    [self removeObserver:self forKeyPath:@"valat"];
    [self removeObserver:self forKeyPath:@"lalong"];
    [self removeObserver:self forKeyPath:@"usersCity"];
    [self removeObserver:self forKeyPath:@"usersCityCode"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSArray *keyPaths = @[@"city", @"cityCode", @"valat", @"lalong", @"usersCity", @"usersCityCode"];
    if (object == self && [keyPaths containsObject:keyPath])
    {
        NSData *archiverData = [NSKeyedArchiver archivedDataWithRootObject:self];
        
        [[NSUserDefaults standardUserDefaults] setObject:archiverData forKey:@"DeviceInfo"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [self registObserverForStorageProperty];
    
    [self initStorage];
    
    _city = [aDecoder decodeObjectForKey:@"city"]?:@"";
    _cityCode = [aDecoder decodeObjectForKey:@"cityCode"];
    _valat = [aDecoder decodeFloatForKey:@"valat"];
    _lalong = [aDecoder decodeFloatForKey:@"lalong"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_cityCode forKey:@"cityCode"];
    [aCoder encodeFloat:_valat forKey:@"valat"];
    [aCoder encodeFloat:_lalong forKey:@"lalong"];
}

- (void)dealloc
{
    [self unRegistObserverForStorageProperty];
    [reachbility stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (NSString *)cityCode
{
    if (_cityCode == nil)
    {
        return @"0551";
    }
    
    return _cityCode;
}

- (NSString *)city
{
    if (_city == nil)
    {
        return @"合肥";
    }
    return _city;
}
- (void)networkStatusChange:(NSNotification *)notification
{
    Reachability *r = notification.object;
    _apn = [TDCNetworkUtil apnNameWithReachabilityStatus:[r currentReachabilityStatus]];
    if ([_apn isEqualToString:@"none"]) {
        _apn = [TDCNetworkUtil apnName];
    }
}

@end
