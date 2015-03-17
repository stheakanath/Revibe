//
//  ReceipentsView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "conversations.h"
#import "RecipientsView.h"

@interface RecipientsView() {
	NSString *message;
    NSMutableArray *userFriends, *addressContacts, *randomUsers;
    BOOL friendsLoaded, contactsLoaded, randomLoaded;
	NSMutableDictionary *names;
	NSMutableDictionary *selected;
    NSMutableDictionary *selected1;
	NSIndexPath *indexSelected;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RecipientsView

- (void) setUpInterface {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 119)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
    [send setBackgroundColor:GREEN_COLOR];
    send.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 119, [[UIScreen mainScreen] bounds].size.width, 55);
    [send addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 13, 40, 29)];
    img.image = [UIImage imageNamed:@"compose_send"];
    [send addSubview:img];
    [self.view addSubview:send];
}

- (id)initWith:(NSString *)message_ {
	self = [super init];
	message = [message_ copy];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self setUpInterface];
	self.title = @"Recipients";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	self.tableView.tableFooterView = [[UIView alloc] init];
    userFriends = [[NSMutableArray alloc] init];
    addressContacts = [[NSMutableArray alloc] init];
    randomUsers = [[NSMutableArray alloc] init];
	names = [[NSMutableDictionary alloc] init];
    selected1 = [[NSMutableDictionary alloc] init];
	selected = [[NSMutableDictionary alloc] init];
	[self loadFriends];
    [self loadRandomUser];
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
	ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (granted) [self loadContacts];
		});
	});
}

#pragma mark - Backend methods

- (void)loadFriends {
    friendsLoaded = NO;
    PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
    [query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
    [query includeKey:PF_FRIENDS_USER2];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            [userFriends removeAllObjects];
            for (PFObject *object in objects)
                [userFriends addObject:object[PF_FRIENDS_USER2]];
            friendsLoaded = YES;
            [self reloadTableIfReady];
        } else [ProgressHUD showError:error.userInfo[@"error"]];
    }];
}

- (void)loadContacts {
    contactsLoaded = NO;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
        CFIndex personCount = CFArrayGetCount(allPeople);
        [addressContacts removeAllObjects];
        for (int i=0; i<personCount; i++) {
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
            for (CFIndex j=0; j<ABMultiValueGetCount(multi1); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi1, j);
                if (tmp != nil) [emails addObject:[NSString stringWithFormat:@"%@", tmp]];
            }
            NSMutableArray *phones = [[NSMutableArray alloc] init];
            ABMultiValueRef multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex j=0; j<ABMultiValueGetCount(multi2); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi2, j);
                if (tmp != nil) [phones addObject:[NSString stringWithFormat:@"%@", tmp]];
            }
            NSString *name = [NSString stringWithFormat:@"%@ %@", first, last];
            [addressContacts addObject:@{@"name":name, @"emails":emails, @"phones":phones}];
        }
        CFRelease(allPeople);
        CFRelease(addressBook);
        contactsLoaded = YES;
        [self reloadTableIfReady];
    }
}

- (void)loadRandomUser {
    randomLoaded = NO;
    PFUser *user = [PFUser currentUser];
    if ([user[PF_USER_RANDOM] boolValue] == NO) { [randomUsers removeAllObjects]; randomLoaded = YES; return; }
    PFQuery *query = [PFQuery queryWithClassName:PF_INDEX_CLASS_NAME];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            NSMutableArray *randoms = [[NSMutableArray alloc] init];
            for (int i = 0; i < USER_RANDOM_QUERY; i++) {
                int random = 0;
                while ((random == 0) || (random == [user[PF_USER_INDEX] intValue])) random = arc4random() % [object[PF_INDEX_LAST] intValue];
                [randoms addObject:[NSNumber numberWithInt:random]];
            }
            PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
            [query whereKey:PF_USER_RANDOM equalTo:@YES];
            [query whereKey:PF_USER_INDEX containedIn:randoms];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    [randomUsers removeAllObjects];
                    for (NSNumber *random in randoms)
                        for (PFUser *user in objects)
                            if ([random intValue] == [user[PF_USER_INDEX] intValue]) {
                                [randomUsers addObject:user];
                                goto endLoop;
                            }
                endLoop:
                    randomLoaded = YES;
                    [self reloadTableIfReady];
                } else [ProgressHUD showError:error.userInfo[@"error"]];
            }]; } else [ProgressHUD showError:error.userInfo[@"error"]];
    }];
}

- (void)reloadTableIfReady {
    if (contactsLoaded && friendsLoaded && randomLoaded) {
        [self.tableView reloadData];
    }
		
}

#pragma mark - User actions

- (void)actionBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSend:(id)sender {
	NSMutableArray *recipients = [[NSMutableArray alloc] init];
	NSMutableArray *recipientIds = [[NSMutableArray alloc] init];
    for (PFUser *user in randomUsers) {
        if (([selected1[user.objectId] boolValue]) && ([recipientIds containsObject:user.objectId] == NO))
        {
            [recipients addObject:user];
            [recipientIds addObject:user.objectId];
        }
    }
	for (PFUser *user in userFriends) {
		if (([selected[user.objectId] boolValue]) && ([recipientIds containsObject:user.objectId] == NO)) {
			[recipients addObject:user];
			[recipientIds addObject:user.objectId];
		}
	}
	if ([recipients count] != 0) {
		CreateConversations(recipients, message);
		[self dismissViewControllerAnimated:YES completion:nil];
	} else [ProgressHUD showError:@"Please select a user."];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"%i", [randomUsers count]);
    if (section == 0) return [randomUsers count];
	if (section == 1) return [userFriends count];
	if (section == 2) return [addressContacts count];
    return 0;

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    if (indexPath.section == 0) {
        PFUser *user = randomUsers[indexPath.row];
        NSString *accessoryImage = [selected1[user.objectId] boolValue] ? @"recipients_checked_yes" : @"recipients_checked_no";
        cell.textLabel.text = @"Anyone on Revibe";
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage]];
    } else if (indexPath.section == 1) {
        PFUser *user = userFriends[indexPath.row];
        NSString *accessoryImage = [selected[user.objectId] boolValue] ? @"recipients_checked_yes" : @"recipients_checked_no";
        cell.textLabel.text = user[PF_USER_USERNAME];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage]];
	} else if (indexPath.section == 2) {
		NSDictionary *user = addressContacts[indexPath.row];
		cell.textLabel.text = user[@"name"];
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_invite"]];
	}
	cell.layoutMargins = UIEdgeInsetsZero;
	cell.preservesSuperviewLayoutMargins = NO;
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
        [self changeSelected:indexPath Selected:selected1 User:randomUsers[indexPath.row]];
	if (indexPath.section == 1)
		[self changeSelected:indexPath Selected:selected User:userFriends[indexPath.row]];
	if (indexPath.section == 2) {
		indexSelected = indexPath;
		[self inviteUser:addressContacts[indexPath.row]];
	}
}

- (void)changeSelected:(NSIndexPath *)indexPath Selected:(NSMutableDictionary *)selected1 User:(PFUser *)user {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
	if ([selected1[user.objectId] boolValue]) {
		[selected1 removeObjectForKey:user.objectId];
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_checked_no"]];
	} else {
		selected1[user.objectId] = @YES;
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recipients_checked_yes"]];
	}
}

#pragma mark - Invite helper method

- (void)inviteUser:(NSDictionary *)user {
	if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] != 0)) {
		UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email invitation", @"SMS invitation", nil];
		[action showInView:self.view];
	} else if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] == 0))
		[self sendMail:user];
	else if (([user[@"emails"] count] == 0) && ([user[@"phones"] count] != 0))
		[self sendSMS:user];
	else [ProgressHUD showError:@"This contact does not have enough information to be invited."];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) return;
	NSDictionary *user = addressContacts[indexSelected.row];
	if (buttonIndex == 0) [self sendMail:user];
	if (buttonIndex == 1) [self sendSMS:user];
}

#pragma mark - Mail sending method

- (void)sendMail:(NSDictionary *)user {
	if ([MFMailComposeViewController canSendMail]) {
		PFUser *current = [PFUser currentUser];
		NSString *text = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];
		MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
		[mailCompose setToRecipients:user[@"emails"]];
		[mailCompose setSubject:@""];
		[mailCompose setMessageBody:text isHTML:YES];
		mailCompose.mailComposeDelegate = self;
		[self presentViewController:mailCompose animated:YES completion:nil];
	} else [ProgressHUD showError:@"Please configure your mail first."];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	if (result == MFMailComposeResultSent)
		[ProgressHUD showSuccess:@"Mail sent successfully."];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS sending method

- (void)sendSMS:(NSDictionary *)user {
	if ([MFMessageComposeViewController canSendText]) {
		PFUser *current = [PFUser currentUser];
		NSString *text = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];
		MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
		messageCompose.recipients = user[@"phones"];
		messageCompose.body = text;
		messageCompose.messageComposeDelegate = self;
		[self presentViewController:messageCompose animated:YES completion:nil];
	} else [ProgressHUD showError:@"SMS cannot be sent from this device."];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	if (result == MessageComposeResultSent)
		[ProgressHUD showSuccess:@"SMS sent successfully."];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
