//
//  ContactsView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "utilities.h"
#import "ContactsView.h"
#import "ContactsCell.h"
#import "ComposeView.h"
#import "NavigationController.h"

@interface ContactsView() {
    NSMutableArray *userFriends, *addressContacts, *randomUsers;
    BOOL friendsLoaded, contactsLoaded, randomLoaded;
    NSIndexPath *indexSelected;
}

@property (strong, nonatomic) UIView *viewHeader;
@property (strong, nonatomic) UITextField *fieldUsername;
@property (strong, nonatomic) UIButton *add;

@end

@implementation ContactsView

@synthesize viewHeader, fieldUsername;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab2a"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab2b"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
    }
    return self;
}


- (void) setUpInterface {
    self.viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 54)];
    [self.viewHeader setBackgroundColor:[UIColor whiteColor]];
    self.fieldUsername = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 250, 54)];
    [self.fieldUsername setPlaceholder:@"Type username and add..."];
    [self.fieldUsername setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.fieldUsername setDelegate:self];
    [self.fieldUsername setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.viewHeader addSubview:self.fieldUsername];
    self.add = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.add setBackgroundImage:[UIImage imageNamed:@"contacts_add"] forState:UIControlStateNormal];
    [self.add setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 35, 15, 20, 20)];
    [self.add addTarget:self action:@selector(actionAdd:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewHeader addSubview:self.add];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = @"Contacts";
    self.tabBarItem.title = nil;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    userFriends = [[NSMutableArray alloc] init];
    addressContacts = [[NSMutableArray alloc] init];
    randomUsers = [[NSMutableArray alloc] init];
    [self setUpInterface];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
        [query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
        [query whereKey:PF_FRIENDS_USER2 equalTo:userFriends[indexPath.row]];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             if (error == nil) {
                 for (PFObject *object in objects) {
                     [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                          if (error != nil) NSLog(@"Delete error delete error.");
                      }];
                 }
             }
             else [ProgressHUD showError:error.userInfo[@"error"]];
         }];
        [userFriends removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)viewDidAppear:(BOOL)animated {
        [UIView animateWithDuration:.45f delay:.2f  options:UIViewAnimationOptionCurveEaseOut animations:^ {
            self.add.transform = CGAffineTransformMakeScale(4.0f, 4.0f);
            self.add.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {}];
    UIImageView *contactsViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_background.png"]];
    [contactsViewBackground setFrame:self.tableView.frame];
    self.tableView.backgroundView = contactsViewBackground;
    contactsViewBackground.alpha = 1.0f;
    self.tableView.tableHeaderView = viewHeader;
    [super viewDidAppear:animated];
    if ([PFUser currentUser] != nil) {
        [self loadRandomUser];
        [self loadFriends];
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) [self loadContacts];
            });
        });
    }
    else LoginUser(self);
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
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
   if (randomLoaded && friendsLoaded && contactsLoaded)
        [self.tableView reloadData];
}

- (void)removeFromContacts:(NSString *)email_ {
    NSMutableArray *remove = [[NSMutableArray alloc] init];
    for (NSDictionary *user in addressContacts)
        for (NSString *email in user[@"emails"])
            if ([email isEqualToString:email_])
                [remove addObject:user];
    for (NSDictionary *user in remove)
        [addressContacts removeObject:user];
}

#pragma mark - User actions

- (IBAction)actionAdd:(id)sender {
    [self dismissKeyboard];
    NSString *username = [[[fieldUsername.text copy] lowercaseString] stringByTrimmingCharactersInSet:
                                                    [NSCharacterSet whitespaceCharacterSet]];
    if ([username length] != 0) {
        PFUser *user = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query whereKey:PF_USER_CASE_USERNAME equalTo:username];
        [query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             if (error == nil) {
                 PFUser *useradd = [objects firstObject];
                 if (useradd != nil)
                     [self addFriend:useradd];
                 else [ProgressHUD showError:@"No user found."];
             } else [ProgressHUD showError:error.userInfo[@"error"]];
         }];
    }
    fieldUsername.text = nil;
}

- (void)addFriend:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:PF_FRIENDS_CLASS_NAME];
    [query whereKey:PF_FRIENDS_USER1 equalTo:[PFUser currentUser]];
    [query whereKey:PF_FRIENDS_USER2 equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil) {
             if ([objects count] == 0) {
                 PFObject *friend = [PFObject objectWithClassName:PF_FRIENDS_CLASS_NAME];
                 friend[PF_FRIENDS_USER1] = [PFUser currentUser];
                 friend[PF_FRIENDS_USER2] = user;
                 [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                      if (error == nil) {
                          [self loadFriends];
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

- (void)actionSend:(PFUser *)user {
    ComposeView *composeView = [[ComposeView alloc] initWith:user];
    NavigationController *navController = [[NavigationController alloc] initWithRootViewController:composeView];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)actionCleanup {
    [userFriends removeAllObjects];
    [addressContacts removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [randomUsers count]; //Anyone on Revibe
    if (section == 1) return [userFriends count]; //Friends on Revibe
    if (section == 2) return [addressContacts count]; //Contact Book
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) || (indexPath.section == 1)) {
        PFUser *user; NSString *name;
        if (indexPath.section == 0) { user = randomUsers[indexPath.row]; name = @"Anyone on Revibe"; }
        if (indexPath.section == 1) { user = userFriends[indexPath.row]; name = nil; }
        ContactsCell *cell = (ContactsCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil){
            cell = [[ContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        } else {
            for (UIView *subview in cell.contentView.subviews)
                [subview removeFromSuperview];
        }
        [cell bindData:user Name:name Likes:(indexPath.section == 1) ContactsView:self];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = NO;
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        NSDictionary *user = addressContacts[indexPath.row];
        cell.textLabel.text = user[@"name"];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_invite"]];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = NO;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%li %li", (long)indexPath.row, (long)indexPath.section);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        ContactsCell *cell = (ContactsCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell actionSend:self];
    } else if ((indexPath.section == 0) || (indexPath.section == 1)) {
        ContactsCell *cell = (ContactsCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell showLikes];
        [self performSelector:@selector(delayedHideLikes:) withObject:cell afterDelay:DELAY_LIKED_USER];
    } else if (indexPath.section == 2) {
        indexSelected = indexPath;
        [self inviteUser:addressContacts[indexPath.row]];
    }
}

- (void)delayedHideLikes:(ContactsCell *)cell {
    [cell hideLikes];
}

#pragma mark - Invite helper method

- (void)inviteUser:(NSDictionary *)user {
    if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] != 0)) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email invitation", @"SMS invitation", nil];
        [action showFromTabBar:[[self tabBarController] tabBar]];
    }
    else if (([user[@"emails"] count] != 0) && ([user[@"phones"] count] == 0))
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

#pragma mark - Sending Methods

- (void)sendMail:(NSDictionary *)user {
    if ([MFMailComposeViewController canSendMail]) {
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent)
        [ProgressHUD showSuccess:@"Mail sent successfully."];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendSMS:(NSDictionary *)user {
    if ([MFMessageComposeViewController canSendText]) {
        PFUser *current = [PFUser currentUser];
        NSString *message = [NSString stringWithFormat:MESSAGE_INVITE_ADDRESSBOOK, current[PF_USER_USERNAME]];
        MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
        messageCompose.recipients = user[@"phones"];
        messageCompose.body = message;
        messageCompose.messageComposeDelegate = self;
        [self presentViewController:messageCompose animated:YES completion:nil];
    } else [ProgressHUD showError:@"SMS cannot be sent from this device."];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent)
        [ProgressHUD showSuccess:@"SMS sent successfully."];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (textField == fieldUsername)
        [self actionAdd:nil];
    return YES;
}
@end