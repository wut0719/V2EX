//
//  Fetcher.h
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

//  keypath for hot in a Hot dictionary
#define HOT_TITLE @"title"
#define HOT_MEMBER_USERNAME @"member.username"
#define HOT_CONTENT @"content"
#define HOT_REPLIES @"replies"
#define HOT_UNIQUE_ID @"id"
//  keypath for latest
#define LATEST_TITLE @"title"
#define LATEST_MEMBER_USERNAME @"member.username"
#define LATEST_CONTENT @"content"
#define LATEST_CREATED @"created"
#define LATEST_UNIQUE_ID @"id"

#import <Foundation/Foundation.h>

@interface Fetcher : NSObject

+ (NSURL *)URLforHot;
+ (NSURL *)URLforLatest;
+ (NSURL *)URLforMemberbyName:(NSString *)name;

@end
