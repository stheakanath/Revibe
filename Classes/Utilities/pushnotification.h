
#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		ParsePushUserAssign		(void);
void		ParsePushUserResign		(void);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		SendPushMessage			(PFObject *conversation, NSString *text);
void		SendPushUnread			(PFObject *conversation);
void		SendPushLiked			(PFObject *conversation);
