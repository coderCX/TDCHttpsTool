//
//  HttpResponse.m
//  NJH
//
//  Created by ChengXi on 15/12/9.
//  Copyright © 2015年 ChengXi. All rights reserved.
//  

#import "HttpResponse.h"

@implementation HttpResponse
SingletonM(HttpResponse)

- (id)returnHttpResponse:(id)json{
    NSDictionary *dict = json;
    self.baseCode =  [dict[@"base"][@"code"] intValue];
    self.baseMsg =dict[@"base"][@"msg"];
    if (dict[@"data"]) {
        self.data = dict[@"data"];
    } else {
        self.data = nil;
    }
    return self;
}

@end
