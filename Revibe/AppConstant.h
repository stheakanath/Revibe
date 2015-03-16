
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#define GREEN_COLOR [UIColor colorWithRed:199/255.0 green:224/255.0 blue:162/255.0 alpha:1]
#define BLUE_COLOR [UIColor colorWithRed:91/255.0 green:202/255.0 blue:234/255.0 alpha:1]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DEFAULT_TAB							0

#define		TOP_LIKED_USERS						3
#define		DELAY_LIKED_USER					2
#define		USER_RANDOM_QUERY					10
#define		MAX_HEIGHT_INPUT					100

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		TITLES_LAST_INDEX					227

//-------------------------------------------------------------------------------------------------------------------------------------------------

//I'VE REARRANGED THE COLORS HERE

#define		COLOR_INCOMING_PLAIN				HEXCOLOR(0x5BCAEAFF)
#define		COLOR_INCOMING_LIKED				HEXCOLOR(0x7BE3FFFF)
#define		COLOR_OUTGOING_PLAIN				HEXCOLOR(0xC7E0A2FF)
#define		COLOR_OUTGOING_LIKED				HEXCOLOR(0xD5F49FFF)

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		MESSAGE_INVITE_ADDRESSBOOK			@"Hey! Add me on Revibe. My name is %@. http://revibeapp.com"

#define		MESSAGE_PUSH_UNREAD					@"Conversation unread value changed."
#define		MESSAGE_PUSH_LIKED					@"Conversation liked value changed."

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		FIREBASE							@"https://amber-heat-645.firebaseio.com"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"
#define		PF_INSTALLATION_OBJECTID			@"objectId"
#define		PF_INSTALLATION_USER				@"user"

#define		PF_USER_CLASS_NAME					@"_User"
#define		PF_USER_OBJECTID					@"objectId"
#define		PF_USER_USERNAME					@"username"
#define		PF_USER_PASSWORD					@"password"
#define		PF_USER_EMAIL						@"email"
#define		PF_USER_INDEX						@"index"
#define		PF_USER_RANDOM						@"random"
#define		PF_USER_NOTIFICATION				@"notification"

#define		PF_CONVERSATIONS_CLASS_NAME			@"Conversations"
#define		PF_CONVERSATIONS_USER1				@"user1"
#define		PF_CONVERSATIONS_USER2				@"user2"
#define		PF_CONVERSATIONS_TITLE				@"title"
#define		PF_CONVERSATIONS_LASTKEY			@"lastKey"
#define		PF_CONVERSATIONS_LASTMESSAGE		@"lastMessage"
#define		PF_CONVERSATIONS_LASTCREATED		@"lastCreated"
#define		PF_CONVERSATIONS_LASTUSER			@"lastUser"
#define		PF_CONVERSATIONS_UNREAD1			@"unread1"
#define		PF_CONVERSATIONS_UNREAD2			@"unread2"
#define		PF_CONVERSATIONS_LIKED				@"liked"
#define		PF_CONVERSATIONS_BLOCKEDBY			@"blockedBy"
#define		PF_CONVERSATIONS_CREATEDAT			@"createdAt"

#define		PF_FRIENDS_CLASS_NAME				@"Friends"
#define		PF_FRIENDS_USER1					@"user1"
#define		PF_FRIENDS_USER2					@"user2"

#define		PF_INDEX_CLASS_NAME					@"Index"
#define		PF_INDEX_LAST						@"last"

#define		PF_TITLES_CLASS_NAME				@"Titles"
#define		PF_TITLES_TITLE						@"title"
#define		PF_TITLES_INDEX						@"index"

#define		PF_USER2_CLASS_NAME					@"User2"
#define		PF_USER2_USER						@"user"
#define		PF_USER2_EMAIL						@"email"
#define		PF_USER2_LIKES						@"likes"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
#define		NOTIFICATION_CONVERSATION_CREATED	@"NCConversationCreated"
#define		NOTIFICATION_PUSH_RECEIVED			@"NCPushReceived"
