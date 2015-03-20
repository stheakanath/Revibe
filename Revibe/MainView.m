//
//  MainView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "utilities.h"
#import "conversations.h"

#import "MainView.h"
#import "MainCell.h"
#import "ChatView.h"
#import "ComposeView.h"
#import "NavigationController.h"

@interface MainView() {
    int totalUnread;
    UIImageView *imageBagde;
    NSMutableArray *conversations;
}
@end

@implementation MainView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab1a"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab1b"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadConversations) name:NOTIFICATION_PUSH_RECEIVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadConversations) name:NOTIFICATION_CONVERSATION_CREATED object:nil];
    }
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DeleteMessageItem(conversations[indexPath.row]);
        [conversations removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        UIImageView *noMessageBackgroundView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            noMessageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noMessageImage_iPad.png"]];
        } else {
            noMessageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noMessageImage.png"]];
        }
        if (conversations.count == 0) {
            [noMessageBackgroundView setFrame:self.tableView.frame];
            self.tableView.backgroundView = noMessageBackgroundView;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"revibe";
    self.tabBarItem.title = nil;
    self.tableView.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(actionNew)];
    imageBagde = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_badge"]];
    imageBagde.frame = CGRectMake(26, 3, imageBagde.frame.size.width, imageBagde.frame.size.height);
    [self.tabBarController.tabBar addSubview:imageBagde];
    imageBagde.hidden = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadConversations) forControlEvents:UIControlEventValueChanged];
    self.tableView.tableFooterView = [[UIView alloc] init];
    totalUnread = 0;
    conversations = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([PFUser currentUser] != nil)
        [self loadConversations];
    else LoginUser(self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([PFUser currentUser] != nil)
        [self loadConversations];
    else LoginUser(self);
}

#pragma mark - Backend actions

- (void)loadConversations {
    PFUser *user = [PFUser currentUser];
    PFQuery *query1 = [PFQuery queryWithClassName:PF_CONVERSATIONS_CLASS_NAME];
    [query1 whereKey:PF_CONVERSATIONS_USER1 equalTo:user];
    PFQuery *query2 = [PFQuery queryWithClassName:PF_CONVERSATIONS_CLASS_NAME];
    [query2 whereKey:PF_CONVERSATIONS_USER2 equalTo:user];
    PFQuery *queryCompound = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [queryCompound whereKey:PF_CONVERSATIONS_BLOCKEDBY equalTo:[NSNull null]];
    [queryCompound includeKey:PF_CONVERSATIONS_USER1];
    [queryCompound includeKey:PF_CONVERSATIONS_USER2];
    [queryCompound orderByDescending:PF_CONVERSATIONS_CREATEDAT];
    [queryCompound setLimit:1000];
    [queryCompound findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            [conversations removeAllObjects];
            [conversations addObjectsFromArray:objects];
            [self.tableView reloadData];
            [self countUnread];
        } else [ProgressHUD showError:error.userInfo[@"error"]];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Helper methods

- (void)countUnread {
    UIImageView *noMessageBackgroundView;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        noMessageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noMessageImage_iPad.png"]];
    } else {
         noMessageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noMessageImage.png"]];
    }
    UIImageView *mainBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    mainBackgroundView.alpha = .55f;
    if (conversations.count > 0) {
        [mainBackgroundView setFrame:self.tableView.frame];
        self.tableView.backgroundView = mainBackgroundView;
    } else {
        [noMessageBackgroundView setFrame:self.tableView.frame];
        self.tableView.backgroundView = noMessageBackgroundView;
    }
    totalUnread = 0;
    for (PFObject *conversation in conversations) {
        PFUser *user = [PFUser currentUser];
        PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
        PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
        if ([user.objectId isEqualToString:user1.objectId])
            if ([conversation[PF_CONVERSATIONS_UNREAD1] boolValue])
                totalUnread++;
        if ([user.objectId isEqualToString:user2.objectId])
            if ([conversation[PF_CONVERSATIONS_UNREAD2] boolValue])
                totalUnread++;
    }
    [self updateTabBadge];
}

- (void)updateTabBadge {
    imageBagde.hidden = ((self.tabBarController.selectedIndex == 0) || (totalUnread == 0));
}

#pragma mark - User actions

- (void)actionNew {
    ComposeView *composeView = [[ComposeView alloc] initWith:nil];
    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:composeView];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)actionChat:(PFObject *)conversation {
    ChatView *chatView = [[ChatView alloc] initWith:conversation];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

- (void)actionCleanup {
    [conversations removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainCell *cell = (MainCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil){
        cell = [[MainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    } else {
        for (UIView *subview in cell.contentView.subviews)
            [subview removeFromSuperview];
    }
    [cell bindData:conversations[indexPath.row] MainView:self];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    return cell;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self updateTabBadge];
}

@end