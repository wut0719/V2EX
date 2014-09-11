//
//  Hot+Input.h
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "Hot.h"

@interface Hot (Input)

+ (Hot *)hotWithInfo:(NSDictionary *)hotDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
//批量加载
+ (void)loadHotFromListArray:(NSArray *)hotLists //of hot Dictionary
    intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
