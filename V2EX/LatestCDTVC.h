//
//  LatestCDTVC.h
//  V2EX
//
//  Created by wp on 14-9-21.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface LatestCDTVC : CoreDataTableViewController <UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
