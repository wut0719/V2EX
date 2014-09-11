//
//  Fetcher.m
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "Fetcher.h"

@implementation Fetcher

+ (NSURL *)URLforHot
{
    return [NSURL URLWithString:@"https://www.v2ex.com/api/topics/hot.json"];
}

+ (NSURL *)URLforLatest
{
    return [NSURL URLWithString:@"https://www.v2ex.com/api/topics/latest.json"];
}

+ (NSURL *)URLforMemberbyName:(NSString *)name
{
    NSString *urlString = @"https://www.v2ex.com/api/members/show.json?username=";
    [urlString stringByAppendingString:name];
    return [NSURL URLWithString:urlString];
}

@end
