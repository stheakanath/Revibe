
#import <Firebase/Firebase.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"

#import "conversations.h"

void CreateConversations(NSMutableArray *recipients, NSString *message) {
	for (PFUser *user in recipients)
		CreateConversation(user, message);
}

void CreateConversation(PFUser *user, NSString *message) {
    PFObject *conversation = [PFObject objectWithClassName:PF_CONVERSATIONS_CLASS_NAME];
    conversation[PF_CONVERSATIONS_USER1] = [PFUser currentUser];
    conversation[PF_CONVERSATIONS_USER2] = user;
    conversation[PF_CONVERSATIONS_TITLE] = user[PF_USER_USERNAME];
    conversation[PF_CONVERSATIONS_LASTKEY] = @"";
    conversation[PF_CONVERSATIONS_LASTMESSAGE] = message;
    conversation[PF_CONVERSATIONS_LASTCREATED] = [NSDate date];
    conversation[PF_CONVERSATIONS_LASTUSER] = [PFUser currentUser];
    conversation[PF_CONVERSATIONS_UNREAD1] = @NO;
    conversation[PF_CONVERSATIONS_UNREAD2] = @YES;
    conversation[PF_CONVERSATIONS_LIKED] = [NSArray array];
    conversation[@"deleted"] = [NSArray array];
    
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            CreateFirebaseItem(conversation, message);
            PostNotification(NOTIFICATION_CONVERSATION_CREATED);
            SendPushMessage(conversation, message);
        } else NSLog(@"CreateConversation save error.");
    }];
}

void CreateFirebaseItem(PFObject *conversation, NSString *text) {
	PFUser *user = [PFUser currentUser];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *dateStr = [formatter stringFromDate:[NSDate date]];
	NSDictionary *values = @{@"text":text, @"userId":user.objectId, @"date":dateStr};
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE, conversation.objectId]];
	[[firebase childByAutoId] setValue:values withCompletionBlock:^(NSError *error, Firebase *ref) {
		if (error == nil) {
			conversation[PF_CONVERSATIONS_LASTKEY] = [ref key];
			[conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
			}];
		} else [ProgressHUD showError:@"Network error."];
	}];
}

void UpdateConversation(PFObject *conversation, NSString *key, NSString *message) {
	PFUser *user = [PFUser currentUser];
	PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
	PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
	conversation[PF_CONVERSATIONS_LASTKEY] = key;
	conversation[PF_CONVERSATIONS_LASTMESSAGE] = message;
	conversation[PF_CONVERSATIONS_LASTCREATED] = [NSDate date];
	conversation[PF_CONVERSATIONS_LASTUSER] = [PFUser currentUser];
	if ([user.objectId isEqualToString:user1.objectId]) conversation[PF_CONVERSATIONS_UNREAD2] = @YES;
	if ([user.objectId isEqualToString:user2.objectId]) conversation[PF_CONVERSATIONS_UNREAD1] = @YES;
	[conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error != nil) NSLog(@"UpdateConversation network error.");
	}];
}

void UpdateConversationUnread(PFObject *conversation) {
	PFUser *user = [PFUser currentUser];
	PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
	PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
	if ([user.objectId isEqualToString:user1.objectId]) conversation[PF_CONVERSATIONS_UNREAD1] = @NO;
	if ([user.objectId isEqualToString:user2.objectId]) conversation[PF_CONVERSATIONS_UNREAD2] = @NO;
	[conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error != nil)
            NSLog(@"UpdateConversationUnread network error.");
	}];
}

void UpdateConversationLiked(PFObject *conversation, NSMutableArray *liked) {
	conversation[PF_CONVERSATIONS_LIKED] = liked;
	[conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		 if (error != nil) NSLog(@"UpdateConversationLiked network error.");
	}];
}

void DeleteMessageItem(PFObject *message) {
    NSLog(@"%@", message[@"deleted"]);
    NSMutableArray* deleted = [message[@"deleted"] mutableCopy];
    [deleted addObject:[PFUser currentUser][@"username"]];
    message[@"deleted"] = deleted;
    if ([deleted count] == 2) {
        NSLog(@"Both users have deleted!");
        [message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil) NSLog(@"DeleteMessageItem delete error.");
        }];
    } else {
         NSLog(@"Only one user has deleted!");
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil) NSLog(@"DeleteMessageItem network error.");
        }];
    }
}

void UpdateUserLikes(PFObject *conversation, int amout) {
    PFUser *user = [PFUser currentUser];
    PFUser *user1 = conversation[PF_CONVERSATIONS_USER1];
    PFUser *user2 = conversation[PF_CONVERSATIONS_USER2];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER2_CLASS_NAME];
    if ([user.objectId isEqualToString:user1.objectId]) [query whereKey:PF_USER2_USER equalTo:user2];
    if ([user.objectId isEqualToString:user2.objectId]) [query whereKey:PF_USER2_USER equalTo:user1];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil) {
             PFObject *user2 = [objects firstObject];
             [user2 incrementKey:PF_USER2_LIKES byAmount:[NSNumber numberWithInt:amout]];
             [user2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                  if (error != nil) NSLog(@"UpdateUserLikes save error.");
              }];
         }
         else NSLog(@"UpdateUserLikes query error.");
     }];
}
