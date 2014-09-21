//
//  AppDelegate.m
//  V2EX
//
//  Created by wp on 14-9-9.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "AppDelegate.h"
#import "Fetcher.h"
#import "Hot+Input.h"
#import "HotDatabaseAvailability.h"
#import "Latest+Input.h"
#import "LatestDatabaseAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument *hotDocument;
@property (strong, nonatomic) UIManagedDocument *latestDocument;
@property (strong, nonatomic) NSManagedObjectContext *hotDatabaseContext;
@property (strong, nonatomic) NSManagedObjectContext *latestDatabaseContext;
@property (strong, nonatomic) NSURLSession *hotDownloadSession;
@property (strong, nonatomic) NSURLSession *latestDownloadSession;
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();//block的声明
@end


@implementation AppDelegate

#pragma mark - lauching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //准备UIManagedDoucment
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *hotDocumentName = @"HotDatabase";
    NSURL *hotURL = [documentDirectory URLByAppendingPathComponent:hotDocumentName];
    NSURL *latestURL = [documentDirectory URLByAppendingPathComponent:@"LatestDatabase"];
    self.hotDocument = [[UIManagedDocument alloc] initWithFileURL:hotURL];
    self.latestDocument =[[UIManagedDocument alloc] initWithFileURL:latestURL];
    
    if ([fileManager fileExistsAtPath:[hotURL path]]) {
        [self.hotDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"couldn't open document at %@",hotURL);
            }
        }];
    } else {
        [self.hotDocument saveToURL:hotURL forSaveOperation:0 completionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"coulden't create document at %@",hotURL);
            }
        }];
    }
    if ([fileManager fileExistsAtPath:[latestURL path]]) {
        [self.latestDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"couldn't open document at %@",latestURL);
            }
        }];
    } else {
        [self.latestDocument saveToURL:latestURL forSaveOperation:0 completionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"coulden't create document at %@",latestURL);
            }
        }];
    }
    return YES;
}

- (void)documentIsReady
{
    if (self.hotDocument.documentState == UIDocumentStateNormal) {
        self.hotDatabaseContext = self.hotDocument.managedObjectContext;
        //进行core data的操作
        [self startHotFetch];
    }
    if (self.latestDocument.documentState == UIDocumentStateNormal) {
        self.latestDatabaseContext = self.latestDocument.managedObjectContext;
        //进行core data的操作
        [self startLatestFetch];
    }
}
- (void)setHotDatabaseContext:(NSManagedObjectContext *)databaseContext
{
    _hotDatabaseContext = databaseContext;
    NSDictionary *userInfo = self.hotDatabaseContext ? @{ HotDatabaseAvailabilityContext : self.hotDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:HotDatabaseAvailabilityNotification
                                                        object:nil //所有object都能接收
                                                      userInfo:userInfo];
}
- (void)setLatestDatabaseContext:(NSManagedObjectContext *)databaseContext
{
    _latestDatabaseContext = databaseContext;
    NSDictionary *userInfo = self.latestDatabaseContext ? @{ LatestDatabaseAvailabilityContext : self.latestDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:LatestDatabaseAvailabilityNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - fetching
- (void)startHotFetch
{
    [self.hotDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *hotTask = [self.hotDownloadSession downloadTaskWithURL:[Fetcher URLforHot]];
            hotTask.taskDescription = @"Just uploaded hot fetch!";
            [hotTask resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}
- (void)startLatestFetch
{
    [self.latestDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *latestTask = [self.latestDownloadSession downloadTaskWithURL:[Fetcher URLforLatest]];
            latestTask.taskDescription = @"Just uploaded latest fetch!";
            [latestTask resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

- (NSURLSession *)hotDownloadSession
{
    if (!_hotDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"Just uploaded hot fetch!"];
            urlSessionConfig.allowsCellularAccess = NO;
            _hotDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _hotDownloadSession;
}
- (NSURLSession *)latestDownloadSession
{
    if (!_latestDatabaseContext) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"Just uploaded latest fetch!"];
            urlSessionConfig.allowsCellularAccess = NO;
            _latestDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _latestDownloadSession;
}
- (NSArray *)hotListAtURL:(NSURL *)url
{
    NSData *hotListJSONData = [NSData dataWithContentsOfURL:url];
    NSArray *hotList = [NSJSONSerialization JSONObjectWithData:hotListJSONData
                                                                   options:0
                                                                     error:NULL];
    return hotList;
}
- (NSArray *)latestListAtURL:(NSURL *)url
{
    NSData *latestListJSONData = [NSData dataWithContentsOfURL:url];
    NSArray *latestList = [NSJSONSerialization JSONObjectWithData:latestListJSONData
                                                          options:0
                                                            error:NULL];
    return latestList;
}

#pragma mark - NSURLSessionDownloadDelegate required
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    //文件刚下载完成时
    //检查是否是自己的下载任务，通过taskDescription
    if ([downloadTask.taskDescription isEqualToString:@"Just uploaded hot fetch!"]) {
        NSManagedObjectContext *context = self.hotDatabaseContext;
        if (context) {
            NSArray *hotList = [self hotListAtURL:localFile];
            [context performBlock:^{
                [Hot loadHotFromListArray:hotList intoManagedObjectContext:context];
            }];
        } else {
            [self downloadTasksMightBeComplete];
        }
    }
    if ([downloadTask.taskDescription isEqualToString:@"Just uploaded latest fetch!"]) {
        NSManagedObjectContext *context = self.latestDatabaseContext;
        if (context) {
            NSArray *latestList = [self latestListAtURL:localFile];
            [context performBlock:^{
                [Hot loadHotFromListArray:latestList intoManagedObjectContext:context];
            }];
        } else {
            [self downloadTasksMightBeComplete];
        }
    }
    
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

- (void)downloadTasksMightBeComplete
{
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        [self.hotDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.downloadBackgroundURLSessionCompletionHandler;
                self.downloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}

#pragma mark - no use
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
