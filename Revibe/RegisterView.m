//
//  RegisterView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "RegisterView.h"

@interface RegisterView()

@property (strong, nonatomic) UITextField *fieldUsername;
@property (strong, nonatomic) UITextField *fieldPassword;
@property (strong, nonatomic) UITextField *fieldEmail;
@property (strong, nonatomic) UIButton *buttonSignUp;

@end

@implementation RegisterView

@synthesize delegate, fieldUsername, fieldPassword, fieldEmail, buttonSignUp;

- (void) setUpInterface {
    [self.view setBackgroundColor:BLUE_COLOR];
    
    //Field Username
    self.fieldUsername = [[UITextField alloc] initWithFrame:CGRectMake(0, 7, [[UIScreen mainScreen] bounds].size.width, 63)];
    [self.fieldUsername setBackgroundColor:[UIColor whiteColor]];
    [self.fieldUsername setFont:[UIFont fontWithName:@"Avenir Medium" size:32]];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.fieldUsername setLeftViewMode:UITextFieldViewModeAlways];
    [self.fieldUsername setTextColor:BLUE_COLOR];
    [self.fieldUsername setPlaceholder:@"USERNAME"];
    [self.fieldUsername setLeftView:spacerView];
    [self.view addSubview:self.fieldUsername];
    
    //Password
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.fieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, [[UIScreen mainScreen] bounds].size.width, 63)];
    [self.fieldPassword setBackgroundColor:[UIColor whiteColor]];
    [self.fieldPassword setFont:[UIFont fontWithName:@"Avenir Medium" size:32]];
    [self.fieldPassword setLeftViewMode:UITextFieldViewModeAlways];
    [self.fieldPassword setTextColor:BLUE_COLOR];
    [self.fieldPassword setPlaceholder:@"NEW PASSWORD"];
    self.fieldPassword.secureTextEntry = YES;
    [self.fieldPassword setLeftView:spacerView1];
    [self.view addSubview:self.fieldPassword];
    
    //Email
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.fieldEmail = [[UITextField alloc] initWithFrame:CGRectMake(0, 150, [[UIScreen mainScreen] bounds].size.width, 63)];
    [self.fieldEmail setBackgroundColor:[UIColor whiteColor]];
    [self.fieldEmail setFont:[UIFont fontWithName:@"Avenir Medium" size:32]];
    [self.fieldEmail setLeftViewMode:UITextFieldViewModeAlways];
    [self.fieldEmail setTextColor:BLUE_COLOR];
    [self.fieldEmail setPlaceholder:@"EMAIL ADDRESS"];
    [self.fieldEmail setLeftView:spacerView2];
    [self.view addSubview:self.fieldEmail];
    
    UILabel *discression = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, [[UIScreen mainScreen] bounds].size.width, 40)];
    [discression setText:@"By signing up to Revibe, you are agreeing \nto the terms of service and privacy policy."];
    [discression setFont:[UIFont fontWithName:@"Avenir Medium" size:14]];
    discression.numberOfLines = 2;
    [discression setTextAlignment:NSTextAlignmentCenter];
    [discression setTextColor:[UIColor whiteColor]];
    [self.view addSubview:discression];
    
    self.buttonSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSignUp setBackgroundColor:GREEN_COLOR];
    [self.buttonSignUp setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 134, [[UIScreen mainScreen] bounds].size.width, 70)];
    [self.buttonSignUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.buttonSignUp.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:44]];
    [self.buttonSignUp addTarget:self action:@selector(actionSignUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSignUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sign Up";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    buttonSignUp.hidden = YES;
    [self registerForKeyboardNotifications];
    [self setUpInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [fieldUsername becomeFirstResponder];
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
    int keyboardSize = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        buttonSignUp.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - keyboardSize - 134, [[UIScreen mainScreen] bounds].size.width, 70);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        buttonSignUp.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 134, [[UIScreen mainScreen] bounds].size.width, 70);
    } completion:nil];
}

#pragma mark - User actions

- (void)actionBack {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSignUp:(id)sender {
    NSString *username	= fieldUsername.text;
    NSString *password	= fieldPassword.text;
    NSString *email		= fieldEmail.text;

    if ([username length] == 0)			{ [ProgressHUD showError:@"Username must be set."]; return; }
    if ([username length] > 15)			{ [ProgressHUD showError:@"Username is too long."]; return; }

    NSRange range = [username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (range.location != NSNotFound)	{ [ProgressHUD showError:@"Username must not contain space."]; return; }

    NSString *passwordValidator = ValidatePassword(password);
    if ([password length] == 0)			{ [ProgressHUD showError:@"Password must be set."]; return; }
    if (passwordValidator != nil)		{ [ProgressHUD showError:passwordValidator]; return; }

    NSString *emailValidator = ValidateEmail(email);
    if ([email length] == 0)			{ [ProgressHUD showError:@"Email must be set."]; return; }
    if (emailValidator != nil)			{ [ProgressHUD showError:emailValidator]; return; }

    [self dismissKeyboard];
    [ProgressHUD show:@"Please wait..." Interaction:NO];

    [self checkUsername:@{@"username":username, @"password":password, @"email":email}];
}

- (void)checkUsername:(NSDictionary *)dict {
    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_USERNAME equalTo:dict[@"username"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil) {
             if ([objects count] == 0)
                 [self getIndex:dict];
             else [ProgressHUD showError:@"Username already exists."];
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

- (void)getIndex:(NSDictionary *)dict_ {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dict_];
    PFQuery *query = [PFQuery queryWithClassName:PF_INDEX_CLASS_NAME];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (error == nil)
         {
             [object incrementKey:PF_INDEX_LAST];
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (error == nil)
                  {
                      NSNumber *index = object[PF_INDEX_LAST];
                      [dict setObject:index forKey:@"index"];
                      [self registerUser:dict];
                  }
                  else [ProgressHUD showError:error.userInfo[@"error"]];
              }];
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

- (void)registerUser:(NSDictionary *)dict {
    PFUser *user = [PFUser user];
    user.username = dict[@"username"];
    user.password = dict[@"password"];
    user.email = dict[@"email"];
    user[PF_USER_INDEX] = dict[@"index"];
    user[PF_USER_RANDOM] = @YES;
    user[PF_USER_NOTIFICATION] = @YES;
    user[PF_USER_LIKES] = @0;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error == nil)
             //DELETE WHEN COMPLETE
             [self createUser2:user];
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

/********************************************************************************************************************************************************
 TEMPORARY DELETE WHEN IMPLEMENTED!!!!! ldsk;jfas;ldkfjs;dfjslakfak;sdk;fdask;fdaskl;adfskl;adks;dfl;afkl;kl;afdskl;dfaskl;fads;kl
 ***********************************************************************************************************************************/
- (void)createUser2:(PFUser *)user {
    PFObject *object = [PFObject objectWithClassName:PF_USER2_CLASS_NAME];
    object[PF_USER2_USER] = user;
    object[PF_USER2_EMAIL] = user.email;
    object[PF_USER2_LIKES] = @0;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             ParsePushUserAssign();
             PostNotification(NOTIFICATION_USER_LOGGED_IN);
             [ProgressHUD showSuccess:@"Registration was successful."];
             [self dismissViewControllerAnimated:YES completion:^{ if (delegate != nil) [delegate didRegisterSucessfully]; }];
         } else {
             [ProgressHUD showError:error.userInfo[@"error"]];
             [[PFUser currentUser] deleteInBackground];
             [PFUser logOut];
         }
     }];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == fieldEmail)
        [self unhideSignUpButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == fieldUsername)
        [fieldPassword becomeFirstResponder];
    if (textField == fieldPassword)
        [fieldEmail becomeFirstResponder];
    if (textField == fieldEmail)
        [self actionSignUp:nil];
    return YES;
}

#pragma mark - Helper methods

- (void)unhideSignUpButton {
    CGRect frame = buttonSignUp.frame;
    frame.origin.x = -[[UIScreen mainScreen] bounds].size.width;
    buttonSignUp.frame = frame;
    buttonSignUp.hidden = NO;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = buttonSignUp.frame;
        frame.origin.x = 0;
        buttonSignUp.frame = frame;
    } completion:nil];
}

@end
