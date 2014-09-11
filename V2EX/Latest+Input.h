//
//  Latest+Input.h
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "Latest.h"

@interface Latest (Input)

+ (Latest *)latestWithInfo:(NSDictionary *)latestDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
//批量加载
+ (void)loadLatestFromListArray:(NSArray *)latestLists //of latest Dictionary
    intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
