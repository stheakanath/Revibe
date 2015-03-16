//
//  BlockedView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "BlockedView.h"

@interface BlockedView() {
    NSMutableArray *conversations;
}

@end

@implementation BlockedView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Blocked";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    conversations = [[NSMutableArray alloc] init];
}

-(void) viewDidAppear:(BOOL)animated {
    UIImageView *mainViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blocked_background.png"]];
    [mainViewBackground setFrame:self.tableView.frame];
    self.tableView.backgroundView = mainViewBackground;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConversations];
}

#pragma mark - Backend actions

- (void)loadConversations {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PF_CONVERSATIONS_CLASS_NAME];
    [query whereKey:PF_CONVERSATIONS_BLOCKEDBY equalTo:user];
    [query orderByAscending:PF_CONVERSATIONS_TITLE];
    [query setLimit:1000];
    [query findObjectsInBackgroundWtithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil) {
             [conversations removeAllObjects];
             [conversations addObjectsFromArray:objects];
             [self.tableView reloadData];
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

#pragma mark - User actions

- (void)actionBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    PFObject *conversation = conversations[indexPath.row];
    cell.textLabel.text = conversation[PF_CONVERSATIONS_LASTMESSAGE];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blocked_unblock"]];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 57;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *conversation = conversations[indexPath.row];
    conversation[PF_CONVERSATIONS_BLOCKEDBY] = [NSNull null];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error == nil)
             [self loadConversations];
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

@end