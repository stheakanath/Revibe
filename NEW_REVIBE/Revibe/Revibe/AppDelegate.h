//
//  AppDelegate.h
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MainView.h"
#import "ContactsView.h"
#import "SettingsView.h"
#import "NavigationController.h"
#import "AppConstant.h"
#import "utilities.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) MainView *mainView;
@property (strong, nonatomic) ContactsView *contactsView;
@property (strong, nonatomic) SettingsView *settingsView;

@end

