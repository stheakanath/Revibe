//
//  MainView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "MainView.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "utilities.h"
#import "conversations.h"

#import "NavigationController.h"

@interface MainView ()

@end

@implementation MainView

- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        NSLog(@"load the users here");
        //[self loadConversations];
    }
    else LoginUser(self);
}

@end
