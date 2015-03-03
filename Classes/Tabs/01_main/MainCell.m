
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "conversations.h"
#import "pushnotification.h"
#import "utilities.h"

#import "MainCell.h"
#import "MainView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MainCell()
{
	PFObject *conversation;
	MainView *mainView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MainCell

@synthesize labelUsername, imageIncoming, labelElapsed, labelMessage, labelSwipeLeft, imageUnread, imageLiked;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFObject *)conversation_ MainView:(MainView *)mainView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    if (UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:.35f
         
                              delay:.2f
         
                            options:UIViewAnimationOptionCurveEaseOut
         
                         animations:^ {
                             imageLiked.transform = CGAffineTransformMakeScale(2.5f, 2.5f);
                             imageLiked.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             
                         }
         
                         completion:^(BOOL finished) {
                         }];
    }
    
    //_cellBackgroundColor.hidden = YES;
    
	conversation = conversation_;
	mainView = mainView_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
	PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	BOOL outgoing = [user.objectId isEqualToString:user1.objectId];
	BOOL incoming = [user.objectId isEqualToString:user2.objectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelUsername.text = user2[PF_USER_USERNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:conversation[PF_CONVERSATIONS_LASTCREATED]];
	labelElapsed.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelMessage.text = conversation[PF_CONVERSATIONS_LASTMESSAGE];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelUsername.hidden = incoming;
	imageIncoming.hidden = outgoing;
	labelSwipeLeft.hidden = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	BOOL unread1 = [conversation[PF_CONVERSATIONS_UNREAD1] boolValue];
	BOOL unread2 = [conversation[PF_CONVERSATIONS_UNREAD2] boolValue];
	BOOL unread = (incoming && unread2) || (outgoing && unread1);
	imageUnread.hidden = !unread;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *liked = conversation[PF_CONVERSATIONS_LIKED];
	NSString *lastKey = conversation[PF_CONVERSATIONS_LASTKEY];
	imageLiked.image = [liked containsObject:lastKey] ? [UIImage imageNamed:@"main_liked_yes"] : [UIImage imageNamed:@"main_liked_no"];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
//	UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
//	gestureTap = UISwipeGestureRecognizerDirectionLeft;
//	[self addGestureRecognizer:gestureTap];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleSingleTap)];
	singleTap.numberOfTapsRequired = 1;
	[self addGestureRecognizer:singleTap];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
//- (void)handleSwipeLeft
////-------------------------------------------------------------------------------------------------------------------------------------------------
//{
//    
//	[mainView actionChat:conversation];
//}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)handleSingleTap
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    	UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        gestureTap.numberOfTapsRequired = 1;
    	[self addGestureRecognizer:gestureTap];
    [mainView actionChat:conversation];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLike:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	PFUser *lastUser = conversation[PF_CONVERSATIONS_LASTUSER];
	if ([user.objectId isEqualToString:lastUser.objectId]) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *liked = conversation[PF_CONVERSATIONS_LIKED];
	NSString *lastKey = conversation[PF_CONVERSATIONS_LASTKEY];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([liked containsObject:lastKey])
	{
		[liked removeObject:lastKey];
		UpdateConversationLiked(conversation, liked);
		UpdateUserLikes(conversation, -1);
	}
	else
	{
		[liked addObject:lastKey];
		UpdateConversationLiked(conversation, liked);
		UpdateUserLikes(conversation, 1);
		SendPushLiked(conversation);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
//    imageLiked.image = [liked containsObject:lastKey] ? [UIImage imageNamed:@"main_liked_yes"] : [UIImage imageNamed:@"main_liked_no"];
    
    if (UIGestureRecognizerStateBegan) {
        
            imageLiked.image = [liked containsObject:lastKey] ? [UIImage imageNamed:@"main_liked_yes"] : [UIImage imageNamed:@"main_liked_no"];
        
        [UIView animateWithDuration:0.45f
         
                              delay:0
         
                            options:UIViewAnimationOptionCurveEaseOut
         
                         animations:^ {
                             imageLiked.transform = CGAffineTransformMakeScale(3.5f, 3.5f);
                             imageLiked.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
         
                         completion:^(BOOL finished) {
                         }];
    }}

@end
