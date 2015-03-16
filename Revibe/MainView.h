//
//  MainView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MainView : UITableViewController <UITabBarControllerDelegate>

- (void)actionChat:(PFObject *)conversation;

@end
