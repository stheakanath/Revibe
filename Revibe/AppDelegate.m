//
//  AppDelegate.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsView.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"MDafzB3mWLkAme4YPD0sg6ictEoLS8S1Ujz7ntSH" clientKey:@"IVOmK1mN1jaFIif00ivdmVr8wLdoCrWzwry72Bg6"];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    [PFImageView class];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainView = [[MainView alloc] init];
    self.contactsView = [[ContactsView alloc] init];
    self.settingsView = [[SettingsView alloc] init];
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.mainView];
    NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.contactsView];
    NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.settingsView];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, nil];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.tabBar.shadowImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.backgroundImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.barTintColor = HEXCOLOR(0xFFFFFFFF);
    self.tabBarController.selectedIndex = DEFAULT_TAB;
    self.tabBarController.delegate = self.mainView;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Push notification methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (self.tabBarController.selectedIndex != 0) {
        [PFPush handlePush:userInfo];
    }
    PostNotification(NOTIFICATION_PUSH_RECEIVED);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

@end
