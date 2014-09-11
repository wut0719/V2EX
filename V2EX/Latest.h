//
//  Latest.h
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Latest : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * created;
@property (nonatomic, retain) NSNumber * unique;

@end
