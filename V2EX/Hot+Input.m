//
//  Hot+Input.m
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "Hot+Input.h"
#import "Fetcher.h"

@implementation Hot (Input)

+ (Hot *)hotWithInfo:(NSDictionary *)hotDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Hot *hot = nil;
    NSNumber *unique = hotDictionary[HOT_UNIQUE_ID];
    //检查数据库中是否已有
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hot"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count]> 1) {
        //应该是有且仅有一个匹配
        //handle error
    } else if ([matches count]) {
        hot = [matches firstObject];
    } else {
        //匹配过程成功，但结果不存在 -> 在数据库中创建
        hot = [NSEntityDescription insertNewObjectForEntityForName:@"Hot" inManagedObjectContext:context];
        hot.unique = unique;
        hot.title = [hotDictionary valueForKeyPath:HOT_TITLE];
        hot.author = [hotDictionary valueForKeyPath:HOT_MEMBER_USERNAME];
        hot.content = [hotDictionary valueForKeyPath:HOT_CONTENT];
        hot.replies = [hotDictionary valueForKeyPath:HOT_REPLIES];
    }
    
    
    return hot;
}
//批量加载
+ (void)loadHotFromListArray:(NSArray *)hotLists //of hot Dictionary
    intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *hot in hotLists) {
        [self hotWithInfo:hot inManagedObjectContext:context];
    }
}
@end
