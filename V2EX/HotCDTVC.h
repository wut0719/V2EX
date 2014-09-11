//
//  HotCDTVC.h
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface HotCDTVC : CoreDataTableViewController <UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL switchHoL;
@end
