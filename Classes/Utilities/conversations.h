
#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		CreateConversations				(NSMutableArray *recipients, NSString *message);
void		CreateConversation				(PFUser *user, NSString *message);
void		CreateFirebaseItem				(PFObject *conversation, NSString *text);

void		UpdateConversation				(PFObject *conversation, NSString *key, NSString *message);
void		UpdateConversationUnread		(PFObject *conversation);
void		UpdateConversationLiked			(PFObject *conversation, NSMutableArray *liked);

void		UpdateUserLikes					(PFObject *conversation, int amout);
