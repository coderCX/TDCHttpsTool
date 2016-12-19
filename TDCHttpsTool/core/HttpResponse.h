//
//  HttpResponse.h
//  NJH
//
//  Created by ChengXi on 15/12/9.
//  Copyright © 2015年 ChengXi. All rights reserved.
//  http返回数据模型

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface HttpResponse : NSObject

SingletonH(HttpResponse)

/** 
 返回的状态码
 */
@property (nonatomic,assign) int        baseCode;

/** 
 返回的提示信息
 */
@property (nonatomic,copy) NSString     *baseMsg;

/** 
 返回的数据
 */
@property (nonatomic,strong) id          data;

- (id)returnHttpResponse:(id)json;

@end
