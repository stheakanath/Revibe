
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "utilities.h"

#import "ContactsView.h"
#import "ContactsCell.h"
#import "ComposeView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ContactsView()
{
	NSMutableArray *users1;
	NSMutableArray *users2;
	NSMutableArray *users3;
	NSMutableArray *users4;
	NSMutableArray *users5;

	BOOL loaded1, loaded2, loaded3, loaded4, loaded5;

	NSMutableDictionary *names;

	NSIndexPath *indexSelected;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UITextField *fieldUsername;
@property (strong, nonatomic) IBOutlet UIImageView *addUser;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ContactsView

@synthesize viewHeader, fieldUsername;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[[UIImage imageNamed:@"tab2a"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		[self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab2b"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
		self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Contacts";
	self.tabBarItem.title = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"ContactsCell" bundle:nil] forCellReuseIdentifier:@"ContactsCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users1 = [[NSMutableArray alloc] init];
	users2 = [[NSMutableArray alloc] init];
	users3 = [[NSMutableArray alloc] init];
	users4 = [[NSMutableArray alloc] init];
	users5 = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	names = [[NSMutableDictionary alloc] init];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.row == 0 && indexPath.section == 0)
        return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"I clickde deleted");
        
        PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
        [query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
        [query whereKey:PF_FRIENDS_USER2 equalTo:users4[indexPath.row]];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 for (PFObject *object in objects)
                 {
                     [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          if (error != nil) NSLog(@"Delete error delete error.");
                      }];
                 }
             }
             else [ProgressHUD showError:error.userInfo[@"error"]];
         }];

        [users4 removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    if (UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:.45f
         
                              delay:.2f
         
                            options:UIViewAnimationOptionCurveEaseOut
         
                         animations:^ {
                             _addUser.transform = CGAffineTransformMakeScale(4.0f, 4.0f);
                             _addUser.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             
                         }
         
                         completion:^(BOOL finished) {
                         }];
    }
    
    //Insert Background Image Here
    UIImageView *contactsViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_background.png"]];
    [contactsViewBackground setFrame:self.tableView.frame];
    self.tableView.backgroundView = contactsViewBackground;
    contactsViewBackground.alpha = 0.55f;
    
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadUsers1];
		[self loadUsers4];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				if (granted) [self loadUsers5];
			});
		});
	}
	else LoginUser(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers1
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	loaded1 = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	if ([user[PF_USER_RANDOM] boolValue] == NO) { [users1 removeAllObjects]; loaded1 = YES; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFQuery *query = [PFQuery queryWithClassName:PF_INDEX_CLASS_NAME];
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
	{
		if (error == nil)
		{
			int index_self = [user[PF_USER_INDEX] intValue];
			int index_last = [object[PF_INDEX_LAST] intValue];
			//-------------------------------------------------------------------------------------------------------------------------------------
			NSMutableArray *randoms = [[NSMutableArray alloc] init];
			for (int i=0; i<USER_RANDOM_QUERY; i++)
			{
				int random = 0;
				while ((random == 0) || (random == index_self)) random = arc4random() % index_last;
				[randoms addObject:[NSNumber numberWithInt:random]];
			}
			//-------------------------------------------------------------------------------------------------------------------------------------
			PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
			[query whereKey:PF_USER_RANDOM equalTo:@YES];
			[query whereKey:PF_USER_INDEX containedIn:randoms];
			[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
			{
				if (error == nil)
				{
					[users1 removeAllObjects];
					for (NSNumber *random in randoms)
					{
						for (PFUser *user in objects)
						{
							if ([random intValue] == [user[PF_USER_INDEX] intValue])
							{
								[users1 addObject:user];
								goto endLoop;
							}
						}
					}
					endLoop:
					loaded1 = YES;
					[self reloadTableIfReady];
				}
				else [ProgressHUD showError:error.userInfo[@"error"]];
			}];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers23
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *emails = [[NSMutableArray alloc] init];
	for (NSDictionary *user in users5)
	{
		for (NSString *email in user[@"emails"])
		{
			[emails addObject:email];
			[names setObject:user[@"name"] forKey:email];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFQuery *query = [PFQuery queryWithClassName:PF_USER2_CLASS_NAME];
	[query whereKey:PF_USER2_USER notEqualTo:[PFUser currentUser]];
	[query whereKey:PF_USER2_EMAIL containedIn:emails];
	[query orderByDescending:PF_USER2_LIKES];
	[query includeKey:PF_USER2_USER];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			int added = 0;
			[users2 removeAllObjects];
			[users3 removeAllObjects];
			for (PFObject *object in objects)
			{
				PFUser *user = object[PF_USER2_USER];
				if (added++ < TOP_LIKED_USERS) [users2 addObject:user]; else [users3 addObject:user];
				[self removeFromContacts:user[PF_USER_EMAIL]];
			}
			loaded2 = YES;
			[self sortUser3];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sortUser3
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSArray *sorted = [users3 sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
	{
		PFUser *user1 = (PFUser *)a;
		PFUser *user2 = (PFUser *)b;

		NSString *email1 = user1[PF_USER_EMAIL];
		NSString *email2 = user2[PF_USER_EMAIL];

		NSString *name1 = names[email1];
		NSString *name2 = names[email2];

		return [name1 compare:name2];
	}];

	[users3 removeAllObjects];
	[users3 addObjectsFromArray:sorted];

	loaded3 = YES;
	[self reloadTableIfReady];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers4
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	loaded4 = NO;
	PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
	[query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
	[query includeKey:PF_FRIENDS_USER2];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users4 removeAllObjects];
			for (PFObject *object in objects)
			{
				[users4 addObject:object[PF_FRIENDS_USER2]];
			}
			[self sortUser4];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sortUser4
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSArray *sorted = [users4 sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
	{
		PFUser *user1 = (PFUser *)a;
		PFUser *user2 = (PFUser *)b;

		NSString *name1 = user1[PF_USER_USERNAME];
		NSString *name2 = user2[PF_USER_USERNAME];

		return [name1 compare:name2];
	}];

	[users4 removeAllObjects];
	[users4 addObjectsFromArray:sorted];

	loaded4 = YES;
	[self reloadTableIfReady];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers5
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	loaded2 = NO; loaded3 = NO; loaded5 = NO;
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
	{
		CFErrorRef *error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
		ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
		CFIndex personCount = CFArrayGetCount(allPeople);

		[users5 removeAllObjects];
		for (int i=0; i<personCount; i++)
		{
			ABMultiValueRef tmp;
			ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

			NSString *first = @"";
			tmp = ABRecordCopyValue(person, kABPersonFirstNameProperty);
			if (tmp != nil) first = [NSString stringWithFormat:@"%@", tmp];

			NSString *last = @"";
			tmp = ABRecordCopyValue(person, kABPersonLastNameProperty);
			if (tmp != nil) last = [NSString stringWithFormat:@"%@", tmp];

			NSMutableArray *emails = [[NSMutableArray alloc] init];
			ABMultiValueRef multi1 = ABRecordCopyValue(person, kABPersonEmailProperty);
			for (CFIndex j=0; j<ABMultiValueGetCount(multi1); j++)
			{
				tmp = ABMultiValueCopyValueAtIndex(multi1, j);
				if (tmp != nil) [emails addObject:[NSString stringWithFormat:@"%@", tmp]];
			}

			NSMutableArray *phones = [[NSMutableArray alloc] init];
			ABMultiValueRef multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty);
			for (CFIndex j=0; j<ABMultiValueGetCount(multi2); j++)
			{
				tmp = ABMultiValueCopyValueAtIndex(multi2, j);
				if (tmp != nil) [phones addObject:[NSString stringWithFormat:@"%@", tmp]];
			}

			NSString *name = [NSString stringWithFormat:@"%@ %@", first, last];
			[users5 addObject:@{@"name":name, @"emails":emails, @"phones":phones}];
		}

		CFRelease(allPeople);
		CFRelease(addressBook);
		loaded5 = YES;
		[self loadUsers23];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)reloadTableIfReady
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (loaded1 && loaded2 && loaded3 && loaded4 && loaded5)
		[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)removeFromContacts:(NSString *)email_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *remove = [[NSMutableArray alloc] init];

	for (NSDictionary *user in users5)
	{
		for (NSString *email in user[@"emails"])
		{
			if ([email isEqualToString:email_])
			{
				[remove addObject:user];
			}
		}
	}

	for (NSDictionary *user in remove)
	{
		[users5 removeObject:user];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionAdd:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];
	NSString *username = [fieldUsername.text copy];
	if ([username length] != 0)
	{
		PFUser *user = [PFUser currentUser];
		PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
		[query whereKey:PF_USER_USERNAME equalTo:username];
		[query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				PFUser *useradd = [objects firstObject];
				if (useradd != nil)
				{
					[self addFriend:useradd];
				}
				else [ProgressHUD showError:@"No user found."];
			}
			else [ProgressHUD showError:error.userInfo[@"error"]];
		}];
	}
	fieldUsername.text = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addFriend:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
	[query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
	[query whereKey:PF_FRIENDS_USER2 equalTo:user];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				PFObject *friend = [PFObject objectWithClassName:PF_FRIENDS_CLASS_NAME];
				friend[PF_FRIENDS_USER1] = [PFUser currentUser];
				friend[PF_FRIENDS_USER2] = user;
				[friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error == nil)
					{
						[self loadUsers4];
						[ProgressHUD showSuccess:@"User added."];
					}
					else [ProgressHUD showError:@"User already added."];
				}];
			}
			else [ProgressHUD showError:@"User already added."];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSend:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ComposeView *composeView = [[ComposeView alloc] initWith:user];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:composeView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[users1 removeAllObjects];
	[users2 removeAllObjects];
	[users3 removeAllObjects];
	[users4 removeAllObjects];
	[users5 removeAllObjects];
	[names removeAllObjects];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 5;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return [users1 count];
	if (section == 1) return [users2 count];
	if (section == 2) return [users3 count];
	if (section == 3) return [users4 count];
	if (section == 4) return [users5 count];
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) || (indexPath.section == 1) || (indexPath.section == 2) || (indexPath.section == 3))
	{
		PFUser *user; NSString *email; NSString *name;
		if (indexPath.section == 0) { user = users1[indexPath.row]; name = @"Anyone on Revibe"; }
		if (indexPath.section == 1) { user = users2[indexPath.row]; email = user[PF_USER_EMAIL]; name = names[email]; }
		if (indexPath.section == 2) { user = users3[indexPath.row]; email = user[PF_USER_EMAIL]; name = names[email]; }
		if (indexPath.section == 3) { user = users4[indexPath.row]; name = nil; }

		ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCell" forIndexPath:indexPath];
		[cell bindData:user Name:name Likes:(indexPath.section == 1) ContactsView:self];
		cell.layoutMargins = UIEdgeInsetsZero;
		cell.preservesSuperviewLayoutMargins = NO;
		return cell;
	}
	if (indexPath.section == 4)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];

		NSDictionary *user = users5[indexPath.row];
		cell.textLabel.text = user[@"name"];
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];

		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_invite"]];
		cell.layoutMargins = UIEdgeInsetsZero;
		cell.preservesSuperviewLayoutMargins = NO;

		return cell;
	}
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"%i %i", indexPath.row, indexPath.section);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) || (indexPath.section == 2) || (indexPath.section == 3))
	{
		ContactsCell *cell = (ContactsCell *) [tableView cellForRowAtIndexPath:indexPath];
		[cell showLikes];
		[self performSelector:@selector(delayedHideLikes:) withObject:cell afterDelay:DELAY_LIKED_USER];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 4)
	{
		indexSelected = indexPath;
		[self inviteUser:users5[indexPath.row]];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedHideLikes:(ContactsCell *)cell
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[cell hideLikes];
}

#pragma mark - Invite helper method

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)inviteUser:(NSDictionary *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] != 0))
	{
		UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
											  destructiveButtonTitle:nil otherButtonTitles:@"Email invitation", @"SMS invitation", nil];
		[action showFromTabBar:[[self tabBarController] tabBar]];
	}
	else if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] == 0))
	{
		[self sendMail:user];
	}
	else if (([user[@"emails"] count] == 0) && ([user[@"phones"] count] != 0))
	{
		[self sendSMS:user];
	}
	else [ProgressHUD showError:@"This contact does not have enough information to be invited."];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex == actionSheet.cancelButtonIndex) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *user = users5[indexSelected.row];
	if (buttonIndex == 0) [self sendMail:user];
	if (buttonIndex == 1) [self sendSMS:user];
}

#pragma mark - Mail sending method

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMail:(NSDictionary *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([MFMailComposeViewController canSendMail])
	{
		PFUser *current = [PFUser currentUser];
		NSString *message = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];

		MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
		[mailCompose setToRecipients:user[@"emails"]];
		[mailCompose setSubject:@""];
		[mailCompose setMessageBody:message isHTML:YES];
		mailCompose.mailComposeDelegate = self;
		[self presentViewController:mailCompose animated:YES completion:nil];
	}
	else [ProgressHUD showError:@"Please configure your mail first."];
}

#pragma mark - MFMailComposeViewControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (result == MFMailComposeResultSent)
	{
		[ProgressHUD showSuccess:@"Mail sent successfully."];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS sending method

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendSMS:(NSDictionary *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([MFMessageComposeViewController canSendText])
	{
		PFUser *current = [PFUser currentUser];
		NSString *message = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];

		MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
		messageCompose.recipients = user[@"phones"];
		messageCompose.body = message;
		messageCompose.messageComposeDelegate = self;
		[self presentViewController:messageCompose animated:YES completion:nil];
	}
	else [ProgressHUD showError:@"SMS cannot be sent from this device."];
}

#pragma mark - MFMessageComposeViewControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (result == MessageComposeResultSent)
	{
		[ProgressHUD showSuccess:@"SMS sent successfully."];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldUsername)
	{
		[self actionAdd:nil];
	}
	return YES;
}
@end
