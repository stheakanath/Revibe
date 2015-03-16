//
//  SettingsView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"

#import "SettingsView.h"
#import "BlockedView.h"
#import "AccountView.h"
#import "SupportView.h"
#import "TermsView.h"

@interface SettingsView() {
    BOOL random;
    BOOL notification;
}

@property (strong, nonatomic) UIView *viewHeader;
@property (strong, nonatomic) UILabel *labelUsername;
@property (strong, nonatomic) UILabel *labelLikes;
@property (strong, nonatomic) UIImageView *settingsHeart;

@property (strong, nonatomic) UITableViewCell *cellRandom;
@property (strong, nonatomic) UITableViewCell *cellNotification;
@property (strong, nonatomic) UITableViewCell *cellBlocked;
@property (strong, nonatomic) UITableViewCell *cellAccount;
@property (strong, nonatomic) UITableViewCell *cellSupport;
@property (strong, nonatomic) UITableViewCell *cellTerms;

@property (strong, nonatomic) UIImageView *imageRandom;
@property (strong, nonatomic) UIImageView *imageNotification;

@end

@implementation SettingsView

@synthesize viewHeader, labelUsername, labelLikes;
@synthesize cellRandom, cellNotification, cellBlocked, cellAccount, cellSupport, cellTerms;
@synthesize imageRandom, imageNotification;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab3a"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab3b"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    return self;
}

- (void) setUpCells {
    //viewHeader
    self.viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 90)];
    self.labelUsername = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 180, 90)];
    [self.labelUsername setFont:[UIFont fontWithName:@"Avenir Medium" size:21]];
    self.labelLikes = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 120, 0, 60, 90)];
    [self.labelLikes setFont:[UIFont fontWithName:@"Avenir Medium" size:24]];
    [self.labelLikes setTextAlignment:NSTextAlignmentRight];
    [self.labelLikes setTextColor:HEART_COLOR];
    [self.viewHeader addSubview:self.labelLikes];
    [self.viewHeader addSubview:self.labelUsername];
    self.settingsHeart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_heart"]];
    [self.settingsHeart setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-57, 29, 42, 32)];
    [self.viewHeader addSubview:self.settingsHeart];
    
    //cellRandom
    self.cellRandom = [[UITableViewCell alloc] init];
    UILabel *anyone = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone.text = @"Vibe with Anyone";
    [anyone setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellRandom.contentView addSubview:anyone];
    UIButton *vibeanyone = [UIButton buttonWithType:UIButtonTypeCustom];
    //[vibeanyone setBackgroundImage:[UIImage imageNamed:@"settings_on"] forState:UIControlStateNormal];
    [vibeanyone setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 15, 57, 57)];
    [vibeanyone addTarget:self action:@selector(actionRandom:) forControlEvents:UIControlEventTouchUpInside];
    self.imageRandom = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 11, 56, 35)];
    self.imageRandom.image = random ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
    [self.cellRandom.contentView addSubview:self.imageRandom];
    [self.cellRandom.contentView addSubview:vibeanyone];
    
    //cellNotification
    self.cellNotification = [[UITableViewCell alloc] init];
    UILabel *anyone1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone1.text = @"Notification Sounds";
    [anyone1 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellNotification.contentView addSubview:anyone1];
    UIButton *vibeanyone1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageNotification = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 11, 56, 35)];
    self.imageNotification.image = notification ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
    [self.cellNotification.contentView addSubview:self.imageNotification];
    [vibeanyone1 setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 0, 57, 57)];
    [vibeanyone1 addTarget:self action:@selector(actionNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellNotification.contentView addSubview:vibeanyone1];
    
    //cellBlocked
    self.cellBlocked = [[UITableViewCell alloc] init];
    UILabel *anyone2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone2.text = @"Blocked Conversations";
    [anyone2 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellBlocked.contentView addSubview:anyone2];
    
    //cellAccount
    self.cellAccount = [[UITableViewCell alloc] init];
    UILabel *anyone3 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone3.text = @"Account Settings";
    [anyone3 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellAccount.contentView addSubview:anyone3];

    //cellSupport
    self.cellSupport = [[UITableViewCell alloc] init];
    UILabel *anyone4 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone4.text = @"Support";
    [anyone4 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellSupport.contentView addSubview:anyone4];
    
    //cellTerms
    self.cellTerms = [[UITableViewCell alloc] init];
    UILabel *anyone5 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 230, 57)];
    anyone5.text = @"Terms of Service & Privacy";
    [anyone5 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.cellTerms.contentView addSubview:anyone5];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"myVibe";
    self.tabBarItem.title = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_logout"] style:UIBarButtonItemStylePlain target:self action:@selector(actionLogout)];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadUser) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setUpCells];
}

- (void)viewDidAppear:(BOOL)animated {
    if (UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:.35f delay:.2f options:UIViewAnimationOptionCurveEaseOut animations:^ {
            _settingsHeart.transform = CGAffineTransformMakeScale(2.5f, 2.5f);
            _settingsHeart.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {}];
    }
    self.tableView.tableHeaderView = viewHeader;
    [super viewDidAppear:animated];
    if ([PFUser currentUser] != nil)
        [self loadUser];
    else LoginUser(self);
}

#pragma mark - Backend actions

/**********************************************************************************************************************
 WHY DO WE NEED TO QUERY IN ORDER TO GET LIKES FOR CURRENTUSER??? SEE AND FIX THIS
 *******************************************************************************************************************/
- (void)loadUser {
    PFUser *user = [PFUser currentUser];
    labelUsername.text = user[PF_USER_USERNAME];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:user[PF_USER_USERNAME]];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil)
            labelLikes.text = [NSString stringWithFormat:@"%d", [[objects firstObject][PF_USER_LIKES] intValue]];
        else if (error.code != 120) [ProgressHUD showError:error.userInfo[@"error"]];
    }];
    random = [user[PF_USER_RANDOM] boolValue];
    notification = [user[PF_USER_NOTIFICATION] boolValue];
    [self updateViewDetails];
}

#pragma mark - User actions

- (void)actionLogout {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

- (IBAction)actionRandom:(id)sender {
    random = !random;
    [self updateViewDetails];
    PFUser *user = [PFUser currentUser];
    user[PF_USER_RANDOM] = [NSNumber numberWithBool:random];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

- (IBAction)actionNotification:(id)sender {
    notification = !notification;
    [self updateViewDetails];
    PFUser *user = [PFUser currentUser];
    user[PF_USER_NOTIFICATION] = [NSNumber numberWithBool:notification];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

- (void)actionCleanup {
    labelUsername.text = nil;
    labelLikes.text = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [PFUser logOut];
        [self actionCleanup];
        ParsePushUserResign();
        PostNotification(NOTIFICATION_USER_LOGGED_OUT);
        LoginUser(self);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) cell = cellRandom;
    if (indexPath.row == 1) cell = cellNotification;
    if (indexPath.row == 2) cell = cellBlocked;
    if (indexPath.row == 3) cell = cellAccount;
    if (indexPath.row == 4) cell = cellSupport;
    if (indexPath.row == 5) cell = cellTerms;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    if ((indexPath.row == 0) || (indexPath.row == 1))
        cell.accessoryView = nil;
    else cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_arrow"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 57;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) [self actionRandom:nil];
    if (indexPath.row == 1) [self actionNotification:nil];
    if (indexPath.row == 2) {
        BlockedView *blockedView = [[BlockedView alloc] init];
        blockedView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:blockedView animated:YES];
    } else if (indexPath.row == 3) {
        AccountView *accountView = [[AccountView alloc] init];
        accountView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:accountView animated:YES];
    } else if (indexPath.row == 4) {
        SupportView *supportView = [[SupportView alloc] init];
        supportView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:supportView animated:YES];
    } else if (indexPath.row == 5) {
        TermsView *termsView = [[TermsView alloc] init];
        termsView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:termsView animated:YES];
    }
}

#pragma mark - Helper methods

- (void)updateViewDetails {
    self.imageRandom.image = random ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
    self.imageNotification.image = notification ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
}

@end
