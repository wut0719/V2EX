//
//  ContentViewController.h
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *contentTitle;
@property (weak, nonatomic) IBOutlet UITextView *content;

@property (strong, nonatomic) NSString *contentText;

@end
