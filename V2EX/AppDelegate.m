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
#import "HotDatabadeAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
@property (strong, nonatomic) NSURLSession *downloadSession;
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();//block的声明
@end


@implementation AppDelegate

#pragma mark - lauching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //准备UIManagedDoucment
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDatabase";
    NSURL *url = [documentDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([fileManager fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"couldn't open document at %@",url);
            }
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:0 completionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            } else {
                NSLog(@"coulden't create document at %@",url);
            }
        }];
    }
    return YES;
}
- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.databaseContext = self.document.managedObjectContext;
        //进行core data的操作
        [self startFetch];
    }
}
- (void)setDatabaseContext:(NSManagedObjectContext *)databaseContext
{
    _databaseContext = databaseContext;
    NSDictionary *userInfo = self.databaseContext ? @{ HotDatabaseAvailabilityContext : self.databaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:HotDatabaseAvailabilityNotification
                                                        object:nil //所有object都能接收
                                                      userInfo:userInfo];
}
#pragma mark - fetching
- (void)startFetch
{
    [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.downloadSession downloadTaskWithURL:[Fetcher URLforHot]];
            task.taskDescription = @"Just uploaded fetch!";
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"Just uploaded fetch!"];
            urlSessionConfig.allowsCellularAccess = NO;
            _downloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _downloadSession;
}
- (NSArray *)hotListAtURL:(NSURL *)url
{
    NSData *hotListJSONData = [NSData dataWithContentsOfURL:url];
    NSArray *hotPropertyList = [NSJSONSerialization JSONObjectWithData:hotListJSONData
                                                                   options:0
                                                                     error:NULL];
    return hotPropertyList;
}

#pragma mark - NSURLSessionDownloadDelegate required
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    //文件刚下载完成时
    //检查是否是自己的下载任务，通过taskDescription
    if ([downloadTask.taskDescription isEqualToString:@"Just uploaded fetch!"]) {
        NSManagedObjectContext *context = self.databaseContext;
        if (context) {
            NSArray *hotList = [self hotListAtURL:localFile];
            [context performBlock:^{
                [Hot loadHotFromListArray:hotList intoManagedObjectContext:context];
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
        [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
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
