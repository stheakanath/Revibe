//
//  AccountView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppConstant.h"
#import "AccountView.h"
#import "EmailView.h"
#import "PasswordView.h"

@interface AccountView()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;

@end

@implementation AccountView

@synthesize viewHeader, labelUsername;
@synthesize cellEmail, cellPassword;

- (void) setUpCells {
    //viewHeader
    self.viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 57)];
    UILabel *usernamelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, 80, 21)];
    usernamelabel.text = @"Username";
    [usernamelabel setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.viewHeader addSubview:usernamelabel];
    self.labelUsername = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-215, 18, 200, 21)];
    [self.labelUsername setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.labelUsername setTextAlignment:NSTextAlignmentRight];
    [self.viewHeader addSubview:self.labelUsername];
    
    //cellPassword
    self.cellPassword = [[UITableViewCell alloc] init];
    UILabel *anyone = [[UILabel alloc] initWithFrame:CGRectMake(15, 17, 114, 24)];
    anyone.text = @"New Password";
    [anyone setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellPassword.contentView addSubview:anyone];
    UILabel *anyone1 = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-135, 17, 94, 24)];
    anyone1.text = @"************";
    anyone1.textAlignment = NSTextAlignmentRight;
    [anyone1 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellPassword.contentView addSubview:anyone1];
    
    //cellEmail
    self.cellEmail = [[UITableViewCell alloc] init];
    self.cellEmail.textLabel.font =[UIFont fontWithName:@"Avenir Medium" size:17];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Account Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setUpCells];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = viewHeader;
    PFUser *user = [PFUser currentUser];
    labelUsername.text = user[PF_USER_USERNAME];
    cellEmail.textLabel.text = user[PF_USER_EMAIL];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) cell = cellEmail;
    if (indexPath.row == 1) cell = cellPassword;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_arrow"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        EmailView *emailView = [[EmailView alloc] init];
        [self.navigationController pushViewController:emailView animated:YES];
    } else if (indexPath.row == 1) {
        PasswordView *passwordView = [[PasswordView alloc] init];
        [self.navigationController pushViewController:passwordView animated:YES];
    }
}

@end