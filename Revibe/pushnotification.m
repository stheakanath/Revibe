
#import <Parse/Parse.h>

#import "AppConstant.h"

#import "pushnotification.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserAssign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ParsePushUserResign(void)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [NSNull null];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushMessage(PFObject *conversation, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
	PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];

	PFUser *userSend = [user.objectId isEqualToString:user1.objectId] ? user2 : user1;
	if ([userSend[PF_USER_NOTIFICATION] boolValue])
	{
		PFQuery *queryInstallation = [PFInstallation query];
		[queryInstallation whereKey:PF_INSTALLATION_USER equalTo:userSend];

		PFPush *push = [[PFPush alloc] init];
		[push setQuery:queryInstallation];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: text, @"alert",
                              @"Increment", @"badge",
                              nil];
        [push setData:data];
		[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil)
			{
				NSLog(@"SendPushMessage send error.");
			}
		}];
	}
}


void SendPushLiked(PFObject *conversation) {
	PFUser *user = [PFUser currentUser];
	PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
	PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
	PFUser *userSend = [user.objectId isEqualToString:user1.objectId] ? user2 : user1;
	if ([userSend[PF_USER_NOTIFICATION] boolValue]) {
		PFQuery *queryInstallation = [PFInstallation query];
		[queryInstallation whereKey:PF_INSTALLATION_USER equalTo:userSend];
		PFPush *push = [[PFPush alloc] init];
		[push setQuery:queryInstallation];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: @"You have a liked message!", @"alert",
                              @"Increment", @"badge",
                              nil];
		[push setData:data];
		[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (error != nil) {
				NSLog(@"SendPushLiked send error.");
			}
		}];
	}
}
