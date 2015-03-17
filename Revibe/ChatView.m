//
//  ChatView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "conversations.h"
#import "pushnotification.h"
#import "ChatView.h"
#import "ChatCell.h"

@interface ChatView() {
    PFObject *conversation;
    BOOL initialized;
    Firebase *firebase;
    FirebaseHandle handle;
    NSMutableArray *keys;
    NSMutableArray *messages;
    NSMutableArray *liked;
    CGFloat heightKeyboard;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewInput;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UITextView *textInput;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;

@end

@implementation ChatView

@synthesize viewInput, viewBackground, textInput, buttonSend, labelMessage;

- (id)initWith:(PFObject *)conversation_ {
    self = [super init];
    conversation = conversation_;
    return self;
}

- (void) setUpInterface {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 119)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.viewInput = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 119, [[UIScreen mainScreen] bounds].size.width, 55)];
    [self.viewInput setBackgroundColor:GREEN_COLOR];
    self.viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 80, 55)];
    [self.viewBackground setBackgroundColor:TABLE_COLOR];
    [self.viewInput addSubview:self.viewBackground];
    self.textInput = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width - 90, 45)];
    [self.textInput setFont:[UIFont fontWithName:@"Avenir Medium" size:21]];
    [self.textInput setBackgroundColor:[UIColor clearColor]];
    self.textInput.delegate = self;
    [self.viewInput addSubview:self.textInput];
    self.buttonSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSend setImage:[UIImage imageNamed:@"compose_send"] forState:UIControlStateNormal];
    self.buttonSend.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 13, 40, 29);
    [self.buttonSend addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewInput addSubview:self.buttonSend];
    [self.view addSubview:self.viewInput];
    self.labelMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 20, 60)];
    [self.labelMessage setFont:[UIFont fontWithName:@"Avenir Next Medium" size:12]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *user = [PFUser currentUser];
    if ([conversation[PF_CONVERSATIONS_TITLE] isEqualToString:user[PF_USER_USERNAME]])
        self.title = @"";
    else
        self.title = conversation[PF_CONVERSATIONS_TITLE];
    [self setUpInterface];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_block"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBlock)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    heightKeyboard = 0;
    [self registerForKeyboardNotifications];
    keys = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    liked = [[NSMutableArray alloc] initWithArray:conversation[PF_CONVERSATIONS_LIKED] copyItems:YES];
    [self loadMessages];
    UpdateConversationUnread(conversation);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [textInput becomeFirstResponder];

    
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        heightKeyboard = frame.size.height;
        viewInput.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 119 - heightKeyboard, [[UIScreen mainScreen] bounds].size.width, 55);
        self.tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 119 - heightKeyboard);
        [self scrollToBottom];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        heightKeyboard = 0;
        viewInput.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 119, [[UIScreen mainScreen] bounds].size.width, 55);
        self.tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 119);
    } completion:nil];
}

#pragma mark - Backend methods

- (void)loadMessages {
    initialized = NO;
    firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE, conversation.objectId]];
    [firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
         NSString *userId = snapshot.value[@"userId"];
         NSString *dateStr = snapshot.value[@"date"];
         NSString *text = snapshot.value[@"text"];
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
         [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
         NSDate *date = [formatter dateFromString:dateStr];
         [keys addObject:snapshot.key];
         [messages addObject:@{@"text":text, @"userId":userId, @"date":date}];
         if (initialized) {
             [self.tableView reloadData];
             [self scrollToBottom];
         }
     }];
    handle = [firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [firebase removeObserverWithHandle:handle];
        [self.tableView reloadData];
        [self scrollToBottom];
        initialized	= YES;
    }];
}

#pragma mark - User actions

- (void)actionBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionBlock {
    NSString *message = [NSString stringWithFormat:@"No longer receive messages from person?"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [ProgressHUD show:nil Interaction:NO];
        conversation[PF_CONVERSATIONS_BLOCKEDBY] = [PFUser currentUser];
        [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (error == nil) {
                 [ProgressHUD dismiss];
                 [self actionBack];
             }
             else [ProgressHUD showError:error.userInfo[@"error"]];
         }];
    }
}

- (IBAction)actionSend:(id)sender {
    [self dismissKeyboard];
    NSString *text = textInput.text;
    if ([text length] != 0) {
        PFUser *user = [PFUser currentUser];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        NSDictionary *values = @{@"text":text, @"userId":user.objectId, @"date":dateStr};
        [[firebase childByAutoId] setValue:values withCompletionBlock:^(NSError *error, Firebase *ref) {
             if (error == nil) {
                 SendPushMessage(conversation, text);
                 UpdateConversation(conversation, [ref key],text);
             }
             else [ProgressHUD showError:@"Network error"];
         }];
    }
    textInput.text = nil;
    [self textViewDidChange:nil];
}

- (void)actionLike:(NSIndexPath *)indexPath {
    PFUser *user = [PFUser currentUser];
    NSDictionary *message = messages[indexPath.item];
    NSString *userId = message[@"userId"];
    if ([userId isEqualToString:user.objectId] == NO) {
        NSString *key = keys[indexPath.item];
        if ([liked containsObject:key]) {
            [liked removeObject:key];
            UpdateConversationLiked(conversation, liked);
            UpdateUserLikes(conversation, -1);
        } else {
            [liked addObject:key];
            UpdateConversationLiked(conversation, liked);
            UpdateUserLikes(conversation, 1);
            SendPushLiked(conversation);
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = messages[indexPath.row];
    labelMessage.text = message[@"text"];
    CGSize sizeText = [labelMessage sizeThatFits:CGSizeMake(165, MAXFLOAT)];
    return sizeText.height + 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [PFUser currentUser];
    NSString *key = keys[indexPath.item];
    NSDictionary *message = messages[indexPath.item];
    NSString *userId = message[@"userId"];
    BOOL isLiked = [liked containsObject:key];
    BOOL outgoing = [userId isEqualToString:user.objectId];
    ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    else
        for (UIView *subview in cell.contentView.subviews)
            [subview removeFromSuperview];
    [cell bindData:messages[indexPath.row] Outgoing:outgoing Liked:isLiked ChatView:self IndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    return cell;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat widthText = textInput.frame.size.width;
    CGSize sizeText = [textInput sizeThatFits:CGSizeMake(widthText, MAXFLOAT)];
    CGFloat heightText = fmaxf(45, sizeText.height); heightText = fminf(MAX_HEIGHT_INPUT, heightText);
    CGFloat heightView = heightText + 10;
    viewInput.frame = CGRectMake(0, self.view.frame.size.height - heightKeyboard - heightView, [[UIScreen mainScreen] bounds].size.width, heightView);
    viewBackground.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width- 80, heightView);
    textInput.frame = CGRectMake(5, 5, widthText, heightText);
    buttonSend.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, (heightView-29)/2, 40, 29);
    NSInteger restrictedLength=150;
    NSString *temp=textView.text;
    if([[textView text] length] > restrictedLength){
        textView.text=[temp substringToIndex:[temp length]-1];
    }
    
}

#pragma mark - Helper methods

- (void)scrollToBottom {
    if ([messages count] != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end