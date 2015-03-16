
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "ContactsCell.h"
#import "ContactsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ContactsCell()
{
	PFUser *user;
	ContactsView *contactsView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ContactsCell

@synthesize labelUsername, labelLikes, imageHeart, imageRegistered, buttonSend;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFUser *)user_ Name:(NSString *)name Likes:(BOOL)likes ContactsView:(ContactsView *)contactsView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	user = user_;
	contactsView = contactsView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (likes) [self showLikes]; else [self hideLikes];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelUsername.text = (name != nil) ? name : user[PF_USER_USERNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFQuery *query = [PFQuery queryWithClassName:PF_USER2_CLASS_NAME];
	[query whereKey:PF_USER2_USER equalTo:user];
	[query setCachePolicy:kPFCachePolicyCacheThenNetwork];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			PFObject *user2 = [objects firstObject];
			int likes = [user2[PF_USER2_LIKES] intValue];
			labelLikes.text = [NSString stringWithFormat:@"%d", likes];
		}
		else if (error.code != 120) [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showLikes
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelLikes.hidden = NO;
	imageHeart.hidden = NO;
	imageRegistered.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hideLikes
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelLikes.hidden = YES;
	imageHeart.hidden = YES;
	imageRegistered.hidden = NO;
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSend:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[contactsView actionSend:user];
}

@end
