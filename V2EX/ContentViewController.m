//
//  ContentViewController.m
//  V2EX
//
//  Created by wp on 14-9-10.
//  Copyright (c) 2014年 wt. All rights reserved.
//

#import "ContentViewController.h"

@implementation ContentViewController

- (void)setContent:(UITextView *)content
{
    _content = content;
    _content.text = self.contentText;
}

@end
