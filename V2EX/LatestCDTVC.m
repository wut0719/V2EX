//
//  LatestCDTVC.m
//  V2EX
//
//  Created by wp on 14-9-21.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "LatestCDTVC.h"
#import "Latest.h"
#import "LatestDatabaseAvailability.h" //接收通知使用
#import "ContentViewController.h"

@interface LatestCDTVC ()
- (IBAction)refresh:(id)sender;

@end

@implementation LatestCDTVC

- (void)awakeFromNib
{
    //监听AppDelegate发送的通知，接收context
    [[NSNotificationCenter defaultCenter] addObserverForName:LatestDatabaseAvailabilityNotification
                                                      object:nil //任何对象发送的，都接收
                                                       queue:nil //在当前正在执行的queue上进行
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[LatestDatabaseAvailabilityContext];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Latest"];
    request.predicate = nil; //全部
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];  //降序
    self.debug = YES;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Latest Cell"];
    
    //获得要插入的hot（依据位置）
    Latest *latest = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = latest.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"作者：%@", latest.author];
    
    return cell;
}


- (IBAction)refresh:(id)sender
{
    [sender endRefreshing];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ContentViewController class]]) {
        if ([segue.identifier isEqualToString:@"Latest Content"]) {
            ContentViewController *cvc = (ContentViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            Latest *latest = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cvc.contentTitle.title = latest.title;
            cvc.contentText = latest.content;
        }
    }
}
@end
