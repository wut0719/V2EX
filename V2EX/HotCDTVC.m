//
//  HotCDTVC.m
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "HotCDTVC.h"
#import "Hot.h"
#import "HotDatabaseAvailability.h" //接收通知使用
#import "ContentViewController.h"

@interface HotCDTVC ()
- (IBAction)refresh:(id)sender;

@end

@implementation HotCDTVC

- (void)awakeFromNib
{
    //监听appdelegate发送的通知，接收context
    [[NSNotificationCenter defaultCenter] addObserverForName:HotDatabaseAvailabilityNotification
                                                      object:nil //任何对象发送的，都接收
                                                       queue:nil //在当前正在执行的queue上进行
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[HotDatabaseAvailabilityContext];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hot"];
    request.predicate = nil; //全部
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"replies" ascending:NO]];  //降序
    self.debug = YES;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:self.managedObjectContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Hot Cell"];
    
    //获得要插入的hot（依据位置）
    Hot *hot = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = hot.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"作者：%@", hot.author];
    
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
        if ([segue.identifier isEqualToString:@"Hot Content"]) {
            ContentViewController *cvc = (ContentViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            Hot *hot = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cvc.contentTitle.title = hot.title;
            cvc.contentText = hot.content;
        }
    }
}
@end
