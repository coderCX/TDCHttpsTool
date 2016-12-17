//
//  NetworkUtil.m
//  TodayCity
//
//  Created by common on 15/4/16.
//  Copyright (c) 2015年 TodayCity. All rights reserved.
//

#import "TDCNetworkUtil.h"
#import "SAMKeychain.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#include <time.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))

#define BUFFERSIZE  4000
#define MAXADDRS    32
char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];
unsigned long ip_addrs[MAXADDRS];

static int nextAddr = 0;

NSString* keychainUUID = nil;

typedef enum
{
    WIFI,		//WIFI
    LINE,		//有线
    NET_3G,		//废弃3G
    GPRS,
    TD_SCDMA,	//3G  China Mobile
    CDMA2000,	//3G  China Telecom
    WCDMA,		//3G  China Unicom
    LTE_TDD,	//4G  China Mibile
    LTE_FDD,	//4G  China Unicom
    SRV_WALKER  //Server walker,2Mb and No upload detect
}net_type_t;

@implementation TDCNetworkUtil

/**
 * 使用第三方库SSKeychain 获取保存在keychain里面的 uuid 如果第一次则生成一个并保存到keychain中
 **/
+ (NSString *)getSSKeychainValue
{
    if (![self isEmpty:keychainUUID]) {
        NSLog(@"getSSKeychainValue:%@", keychainUUID);
        return keychainUUID;
    }
    
    NSError *error = nil;
    keychainUUID = [SAMKeychain passwordForService:@"9H75NGB8GK.com.channelsoft.NetPhone" account:@"user" error:&error];
    if ([error.domain isEqualToString:kSAMKeychainErrorDomain]  || [self isEmpty:keychainUUID])
    {
        keychainUUID = [self genUUID];
        OSStatus status = [SAMKeychain setPassword:[NSString stringWithFormat:@"%@", keychainUUID]
                                       forService:@"9H75NGB8GK.com.channelsoft.NetPhone"
                                          account:@"user"];
        if (status != noErr){
            NSLog(@"SSKeychain setPassword status:%d", (int)status);
        }
    }
    
    return keychainUUID;
}
/**
 * 产生唯一标识
 **/
+ (NSString *)genUUID
{
    CFUUIDRef uuid_ref=CFUUIDCreate(nil);
    CFStringRef uuid_string_ref=CFUUIDCreateString(nil, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid=[NSString stringWithString:(__bridge NSString *)(uuid_string_ref)];
    CFRelease(uuid_string_ref);
    return uuid;
}

#pragma mark - 网络接入点类型

/**
 *  获取网络类型
 *
 *  @return  获取网络类型
 */
+ (int)netType
{
    NSLog(@"NetworkUtil Get netType");
    int getType = [self currentNetworkStatus] ;
    if (getType == ReachableViaWiFi) {
        NSLog(@"NetworkUtil 当前网络类型:WIFI");
        return  WIFI;
    }else {
        NSLog(@"NetworkUtil 当前网络类型:非WIFI...");
        int returedNettype = GPRS;
        for (int i = 0; i < 10; i++) {
            returedNettype = [self netDetailType];
            if (returedNettype != WIFI) {
                NSLog(@"NetworkUtil 当前网络类型:非WIFI:%d", returedNettype);
                return returedNettype;
            } else {
                // 当系统返回的是WiFi，再通过探测www.baidu.com来确认是否WiFi通道可行
                if ([self currentNetworkStatus] == ReachableViaWiFi) {
                    NSLog(@"NetworkUtil 当前网络类型:已连上WIFI:%d",returedNettype);
                    return WIFI;
                }
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    return GPRS;
}

/**
 *  网络接入点名称
 *
 *  @return  网络接入点名称
 */
+ (NSString *)apnName
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    return [self apnNameWithReachabilityStatus:[r currentReachabilityStatus]];
}

+ (NSString *)apnNameWithReachabilityStatus:(NSInteger)status
{
    NSString *result;
    switch (status) {
        case NotReachable:
            // 没有网络连接
            result = @"none";
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            result = @"Cellular";
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            result = @"WiFi";
            break;
        default:
            // 未知
            result = @"Unknown";
            break;
    }
    return result;
}

/**
 *  网络接入点详细类型
 *
 *  @return 网络接入点详细类型
 */
+ (int)netDetailType
{
    NSLog(@"NetworkUtil Get netDetailType");
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    
//#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        NSString *radioAccessTechnology = netInfo.currentRadioAccessTechnology;
        if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
            return GPRS;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
            return GPRS;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            return WCDMA;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
            if ([carrier.carrierName  isEqual: @"中国移动"] || [carrier.carrierName  isEqual: @"CMHK"] ) {
                return TD_SCDMA;
            }
            return WCDMA;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
            return WCDMA;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return CDMA2000;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
            return CDMA2000;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
            return CDMA2000;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
            return CDMA2000;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return CDMA2000;
        } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
            if ([carrier.carrierName  isEqual: @"中国移动"] || [carrier.carrierName  isEqual: @"CMHK"] ) {
                return LTE_TDD;
            }
            return LTE_FDD;
        }
        
    }
//#endif
    
    
    // 下面的方法是获取系统的界面显示 对应不同的返回系统定义网络值，最终方法返回不使用系统定义网络值。
    // 1，2，3，5 分别对应的收集状况是2G、3G、4G及WIFI
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    int netType = GPRS;
    
    //获取到系统定义网络值
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
        }
    }
    
    if (netType == 5) {//wifi直接返回0，非wifi进行运营商查询
        return WIFI;
    }else if (netType == 1) {//GPRS 2g
        return GPRS;
    }else if (netType == 4 || netType == 3){//4g 不区分运营商
        if ([carrier.carrierName  isEqual: @"中国移动"] || [carrier.carrierName  isEqual: @"CMHK"] ) {
            return LTE_TDD;
        }
        return  LTE_FDD;
    }else if (netType == 2){//3g 哎 参差不齐 只好区别下了...
        NSLog(@"NetworkUtil 当前运营商类型:%@ 网络类型:3G",carrier.carrierName);
        if ([carrier.carrierName  isEqual: @"中国联通"] || [carrier.carrierName  isEqual: @"CHN-UNICOM"]) {
            return WCDMA;
        }else if ([carrier.carrierName  isEqual: @"中国移动"] || [carrier.carrierName  isEqual: @"CMHK"] ) {
            return TD_SCDMA;
        }else if ([carrier.carrierName  isEqual: @"中国电信"] ) {
            return CDMA2000;
        }
        return TD_SCDMA; //3g不能识别 默认移动
    }
    return GPRS;
}

/**
 *  返回当前的网络类型
 */
+ (NetworkStatus)currentNetworkStatus
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReach currentReachabilityStatus];
}

/**
 *  运营商名称
 *
 *  @return  运营商名称
 */
+ (NSString *)carrierName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return carrier.carrierName;
}

#pragma mark - IP地址

void InitAddresses()
{
    nextAddr = 0;
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i] = 0;
    }
}

void FreeAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if (if_names[i] != 0) free(if_names[i]);
        if (ip_names[i] != 0) free(ip_names[i]);
        if (hw_addrs[i] != 0) free(hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    InitAddresses();
}

void GetIPAddresses()
{
    int                 i, len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in  *sin;
    
    char temp[80];
    
    int sockfd;
    
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i] = 0;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return;
    }
    
    lastname[0] = 0;
    
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;  // for next one in buffer
        
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue;   // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0;      // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue;   /* already processed this interface */
        }
        
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue;   // ignore if interface not up
        }
        
        if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
        if (if_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(if_names[nextAddr], ifr->ifr_name);
        
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        
        ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
        if (ip_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(ip_names[nextAddr], temp);
        
        ip_addrs[nextAddr] = sin->sin_addr.s_addr;
        
        ++nextAddr;
    }
    
    close(sockfd);
}

void GetHWAddresses()
{
    struct ifconf ifc;
    struct ifreq *ifr;
    int i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char temp[80];
    
    for (i=0; i<MAXADDRS; ++i)
    {
        hw_addrs[i] = NULL;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
    {
        perror("ioctl error");
        close(sockfd);
        return;
    }
    
    ifr = ifc.ifc_req;
    
    cplim = buffer + ifc.ifc_len;
    
    for (cp=buffer; cp < cplim; )
    {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK)
        {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a,b,c,d,e,f;
            int i;
            
            strcpy(temp, (char*)ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            
            for (i=0; i<MAXADDRS; ++i)
            {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
                {
                    if (hw_addrs[i] == NULL)
                    {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    close(sockfd);
}

/**
 *  获取数据网络下IP地址
 */
+ (NSString *) getIPAddressInWWAN
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}

/**
 *  获取数据网络下IP地址
 */
+ (NSString *)getIPAddressInWIFI
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    NSLog(@"LocalAddress : %@", address);
    return address;
}

/**
 *  获取本地IP地址
 */
+ (NSString *)getIPAddress
{
    NSString *ipAddr = @"";
    if ([self netType] == WIFI) {
        ipAddr = [self getIPAddressInWIFI];
    } else {
        ipAddr = [self getIPAddressInWWAN];
    }
    if ([self isEmpty:ipAddr]) {
        ipAddr = @"";
    }
    return ipAddr;
}

+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    if (defaultRouteReachability) {
        CFRelease(defaultRouteReachability);
    }
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (BOOL)isEmpty:(NSString *)str{
    if (str==nil) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSString *tmpStr = [self trim:str];
    if ([@"" isEqualToString:tmpStr]||[@"(null)" isEqualToString:tmpStr]) {
        return YES;
    }
    return NO;
}

+(NSString *)trim:(NSString *)dirtyString{
    if (dirtyString==nil) {
        return nil;
    }
    return [dirtyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
