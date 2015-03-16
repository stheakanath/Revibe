
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "conversations.h"

#import "RecipientsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecipientsView()
{
	NSString *message;
	NSMutableArray *users1;
	NSMutableArray *users2;
	NSMutableArray *users3;
	NSMutableArray *users4;

	BOOL loaded1, loaded2, loaded3, loaded4;

	NSMutableDictionary *names;
	NSMutableDictionary *selected1;
	NSMutableDictionary *selected2;
	NSMutableDictionary *selected3;

	NSIndexPath *indexSelected;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecipientsView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)message_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	message = [message_ copy];
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Recipients";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"]
																	style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users1 = [[NSMutableArray alloc] init];
	users2 = [[NSMutableArray alloc] init];
	users3 = [[NSMutableArray alloc] init];
	users4 = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	names = [[NSMutableDictionary alloc] init];
	selected1 = [[NSMutableDictionary alloc] init];
	selected2 = [[NSMutableDictionary alloc] init];
	selected3 = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUsers1];
	[self loadUsers3];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
	ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (granted) [self loadUsers4];
		});
	});

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
- (void)loadUsers2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *emails = [[NSMutableArray alloc] init];
	for (NSDictionary *user in users4)
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
			for (PFObject *object in objects)
			{
				PFUser *user = object[PF_USER2_USER];
				if (added++ < TOP_LIKED_USERS) [users2 addObject:user];
				[self removeFromContacts:user[PF_USER_EMAIL]];
			}
			loaded2 = YES;
			[self reloadTableIfReady];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers3
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	loaded3 = NO;
	PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
	[query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
	[query includeKey:PF_FRIENDS_USER2];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users3 removeAllObjects];
			for (PFObject *object in objects)
			{
				[users3 addObject:object[PF_FRIENDS_USER2]];
			}
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

		NSString *name1 = user1[PF_USER_USERNAME];
		NSString *name2 = user2[PF_USER_USERNAME];

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
	loaded2 = NO; loaded4 = NO;
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
	{
		CFErrorRef *error = NULL;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
		ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
		CFIndex personCount = CFArrayGetCount(allPeople);

		[users4 removeAllObjects];
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
			[users4 addObject:@{@"name":name, @"emails":emails, @"phones":phones}];
		}

		CFRelease(allPeople);
		CFRelease(addressBook);
		loaded4 = YES;
		[self loadUsers2];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)reloadTableIfReady
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (loaded1 && loaded2 && loaded3 && loaded4)
		[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)removeFromContacts:(NSString *)email_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *remove = [[NSMutableArray alloc] init];

	for (NSDictionary *user in users4)
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
		[users4 removeObject:user];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSend:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableArray *recipients = [[NSMutableArray alloc] init];
	NSMutableArray *recipientIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *user in users1)
	{
		if (([selected1[user.objectId] boolValue]) && ([recipientIds containsObject:user.objectId] == NO))
		{
			[recipients addObject:user];
			[recipientIds addObject:user.objectId];
		}
	}
	for (PFUser *user in users2)
	{
		if (([selected2[user.objectId] boolValue]) && ([recipientIds containsObject:user.objectId] == NO))
		{
			[recipients addObject:user];
			[recipientIds addObject:user.objectId];
		}
	}
	for (PFUser *user in users3)
	{
		if (([selected3[user.objectId] boolValue]) && ([recipientIds containsObject:user.objectId] == NO))
		{
			[recipients addObject:user];
			[recipientIds addObject:user.objectId];
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([recipients count] != 0)
	{
		CreateConversations(recipients, message);
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	else [ProgressHUD showError:@"Please select a user."];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return [users1 count];
	if (section == 1) return [users2 count];
	if (section == 2) return [users3 count];
	if (section == 3) return [users4 count];
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];

	if (indexPath.section == 0)
	{
		PFUser *user = users1[indexPath.row];
		NSString *accessoryImage = [selected1[user.objectId] boolValue] ? @"recipients_checked_yes" : @"recipients_checked_no";
		cell.textLabel.text = @"Anyone on Revibe";
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage]];
	}
	if (indexPath.section == 1)
	{
		PFUser *user = users2[indexPath.row];
		NSString *email = user[PF_USER_EMAIL];
		NSString *accessoryImage = [selected2[user.objectId] boolValue] ? @"recipients_checked_yes" : @"recipients_checked_no";
		cell.textLabel.text = names[email];
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage]];
	}
	if (indexPath.section == 2)
	{
		PFUser *user = users3[indexPath.row];
		NSString *accessoryImage = [selected3[user.objectId] boolValue] ? @"recipients_checked_yes" : @"recipients_checked_no";
		cell.textLabel.text = user[PF_USER_USERNAME];
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage]];
	}
	if (indexPath.section == 3)
	{
		NSDictionary *user = users4[indexPath.row];
		cell.textLabel.text = user[@"name"];
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_invite"]];
	}

	cell.layoutMargins = UIEdgeInsetsZero;
	cell.preservesSuperviewLayoutMargins = NO;

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 0)
	{
		[self changeSelected:indexPath Selected:selected1 User:users1[indexPath.row]];
	}
	if (indexPath.section == 1)
	{
		[self changeSelected:indexPath Selected:selected2 User:users2[indexPath.row]];
	}
	if (indexPath.section == 2)
	{
		[self changeSelected:indexPath Selected:selected3 User:users3[indexPath.row]];
	}
	if (indexPath.section == 3)
	{
		indexSelected = indexPath;
		[self inviteUser:users4[indexPath.row]];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)changeSelected:(NSIndexPath *)indexPath Selected:(NSMutableDictionary *)selected User:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if ([selected[user.objectId] boolValue])
	{
		[selected removeObjectForKey:user.objectId];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_checked_no"]];
	}
	else
	{
		selected[user.objectId] = @YES;
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_checked_yes"]];
	}
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
		[action showInView:self.view];
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
	NSDictionary *user = users4[indexSelected.row];
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
		NSString *text = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];

		MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
		[mailCompose setToRecipients:user[@"emails"]];
		[mailCompose setSubject:@""];
		[mailCompose setMessageBody:text isHTML:YES];
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
		NSString *text = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];

		MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
		messageCompose.recipients = user[@"phones"];
		messageCompose.body = text;
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

@end
