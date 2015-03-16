
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView()
{
	BOOL random;
	BOOL notification;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellRandom;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNotification;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlocked;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAccount;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSupport;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property (strong, nonatomic) IBOutlet UIImageView *imageRandom;
@property (strong, nonatomic) IBOutlet UIImageView *imageNotification;

@property (strong,nonatomic) IBOutlet UIImageView *settingsHeart;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, labelUsername, labelLikes;
@synthesize cellRandom, cellNotification, cellBlocked, cellAccount, cellSupport, cellTerms;
@synthesize imageRandom, imageNotification;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[[UIImage imageNamed:@"tab3a"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab3b"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
	[super viewDidLoad];
	self.title = @"myVibe";
	self.tabBarItem.title = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_logout"]
																	style:UIBarButtonItemStylePlain target:self action:@selector(actionLogout)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadUser) forControlEvents:UIControlEventValueChanged];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	self.tableView.tableFooterView = [[UIView alloc] init];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:.35f
         
                              delay:.2f
         
                            options:UIViewAnimationOptionCurveEaseOut
         
                         animations:^ {
                             _settingsHeart.transform = CGAffineTransformMakeScale(2.5f, 2.5f);
                             _settingsHeart.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             
                         }
         
                         completion:^(BOOL finished) {
                         }];
    }
    
    //Insert Background Image Here
//    UIImageView *settingsViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_background2.png"]];
//    [settingsViewBackground setFrame:self.tableView.frame];
//    self.tableView.backgroundView = settingsViewBackground;
//    settingsViewBackground.alpha = 0.55f;
    
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadUser];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	labelUsername.text = user[PF_USER_USERNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFQuery *query = [PFQuery queryWithClassName:PF_USER2_CLASS_NAME];
	[query whereKey:PF_USER2_USER equalTo:user];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			PFObject *user2 = [objects firstObject];
			int likes = [user2[PF_USER2_LIKES] intValue];
			labelLikes.text = [NSString stringWithFormat:@"%d", likes];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
		[self.refreshControl endRefreshing];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	random = [user[PF_USER_RANDOM] boolValue];
	notification = [user[PF_USER_NOTIFICATION] boolValue];
	[self updateViewDetails];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRandom:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	random = !random;
	[self updateViewDetails];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user[PF_USER_RANDOM] = [NSNumber numberWithBool:random];
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionNotification:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	notification = !notification;
	[self updateViewDetails];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user[PF_USER_NOTIFICATION] = [NSNumber numberWithBool:notification];
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelUsername.text = nil;
	labelLikes.text = nil;
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[PFUser logOut];
		[self actionCleanup];
		ParsePushUserResign();
		PostNotification(NOTIFICATION_USER_LOGGED_OUT);

		LoginUser(self);
	}
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 6;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
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

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 0) [self actionRandom:nil];
	if (indexPath.row == 1) [self actionNotification:nil];
	if (indexPath.row == 2)
	{
		BlockedView *blockedView = [[BlockedView alloc] init];
		blockedView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:blockedView animated:YES];
	}
	if (indexPath.row == 3)
	{
		AccountView *accountView = [[AccountView alloc] init];
		accountView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:accountView animated:YES];
	}
	if (indexPath.row == 4)
	{
		SupportView *supportView = [[SupportView alloc] init];
		supportView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:supportView animated:YES];
	}
	if (indexPath.row == 5)
	{
		TermsView *termsView = [[TermsView alloc] init];
		termsView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:termsView animated:YES];
	}
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageRandom.image = random ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
	imageNotification.image = notification ? [UIImage imageNamed:@"settings_on"] : [UIImage imageNamed:@"settings_off"];
}

@end
