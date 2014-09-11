//
//  Latest+Input.m
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "Latest+Input.h"
#import "Fetcher.h"

@implementation Latest (Input)

+ (Latest *)latestWithInfo:(NSDictionary *)latestDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Latest *latest = nil;
    NSNumber *unique = latestDictionary[LATEST_UNIQUE_ID];
    //检查数据库中是否已有
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Latest"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count]> 1) {
        //应该是有且仅有一个匹配
        //handle error
    } else if ([matches count]) {
        latest = [matches firstObject];
    } else {
        //匹配过程成功，但结果不存在 -> 在数据库中创建
        latest = [NSEntityDescription insertNewObjectForEntityForName:@"Latest" inManagedObjectContext:context];
        latest.unique = unique;
        latest.title = [latestDictionary valueForKeyPath:LATEST_TITLE];
        latest.author = [latestDictionary valueForKeyPath:LATEST_MEMBER_USERNAME];
        latest.content = [latestDictionary valueForKeyPath:LATEST_CONTENT];
        latest.created = [latestDictionary valueForKeyPath:LATEST_CREATED];
    }
    return latest;
}
//批量加载
+ (void)loadLatestFromListArray:(NSArray *)latestLists //of latest Dictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *latest in latestLists) {
        [self latestWithInfo:latest inManagedObjectContext:context];
    }
}
@end
