//
//  LoginView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "LoginView.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"

@interface LoginView ()

@property (strong, nonatomic) UITextField *fieldUsername;
@property (strong, nonatomic) UITextField *fieldPassword;
@property (strong, nonatomic) UIButton *buttonLogin;

@end

@implementation LoginView

int keyboardHeight;

@synthesize delegate, fieldUsername, fieldPassword, buttonLogin;

- (void) interfaceSetUp {
    [self.view setBackgroundColor:GREEN_COLOR];
    
    self.fieldUsername = [[UITextField alloc] initWithFrame:CGRectMake(0, 7, [[UIScreen mainScreen] bounds].size.width, 63)];
    [self.fieldUsername setBackgroundColor:[UIColor whiteColor]];
    [self.fieldUsername setFont:[UIFont fontWithName:@"Avenir Medium" size:32]];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.fieldUsername setLeftViewMode:UITextFieldViewModeAlways];
    [self.fieldUsername setTextColor:BLUE_COLOR];
    [self.fieldUsername setPlaceholder:@"USERNAME"];
    [self.fieldUsername setDelegate:self];
    [self.fieldUsername setLeftView:spacerView];
    [self.view addSubview:self.fieldUsername];
    
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.fieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, [[UIScreen mainScreen] bounds].size.width, 63)];
    [self.fieldPassword setBackgroundColor:[UIColor whiteColor]];
    [self.fieldPassword setFont:[UIFont fontWithName:@"Avenir Medium" size:32]];
    [self.fieldPassword setLeftViewMode:UITextFieldViewModeAlways];
    [self.fieldPassword setTextColor:BLUE_COLOR];
    [self.fieldPassword setPlaceholder:@"NEW PASSWORD"];
    [self.fieldPassword setDelegate:self];
    self.fieldPassword.secureTextEntry = YES;
    [self.fieldPassword setLeftView:spacerView1];
    [self.view addSubview:self.fieldPassword];
    
    UIButton *forgotpassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotpassword setFrame:CGRectMake(0, 145, [[UIScreen mainScreen] bounds].size.width, 70)];
    [forgotpassword setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    [forgotpassword.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:18]];
    [forgotpassword addTarget:self action:@selector(actionForgot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgotpassword];

    self.buttonLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonLogin setBackgroundColor:BLUE_COLOR];
    [self.buttonLogin setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 134, [[UIScreen mainScreen] bounds].size.width, 70)];
    [self.buttonLogin setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.buttonLogin.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:44]];
    [self.buttonLogin addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonLogin];
    
}

- (void)viewDidLoad {
    //Navigation Bar Set Up
    [super viewDidLoad];
    self.title = @"Log In";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    buttonLogin.hidden = YES;
    
    //Actual Screen Set Up
    [self interfaceSetUp];
    [self registerForKeyboardNotifications];
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
    keyboardHeight = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        buttonLogin.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 134, [[UIScreen mainScreen] bounds].size.width, 70);
    } completion:nil];
}

#pragma mark - User actions

- (void)actionBack {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionLogin:(id)sender {
    NSString *username = fieldUsername.text;
    NSString *password = fieldPassword.text;
    if ([username length] == 0)	{ [ProgressHUD showError:@"Username must be set."]; return; }
    if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
    [self dismissKeyboard];
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
         if (user != nil) {
             ParsePushUserAssign();
             PostNotification(NOTIFICATION_USER_LOGGED_IN);
             [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_USERNAME]]];
             [self dismissViewControllerAnimated:YES completion:^{ if (delegate != nil) [delegate didLoginSucessfully]; }];
         } else  {
             if (!connected())
                 [ProgressHUD showError:@"Not connected to internet!"];
             else
                 [ProgressHUD showError:error.userInfo[@"error"]];
         }
     }];
}

- (IBAction)actionForgot:(id)sender {
    NSString *username = fieldUsername.text;
    if ([username length] != 0) {
        NSString *message = [NSString stringWithFormat:@"Send information to %@?", username];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password recovery" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alertView show];
    }
    else [ProgressHUD showError:@"Please type username first."];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString *username = fieldUsername.text;
        PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query whereKey:PF_USER_USERNAME equalTo:username];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             if (error == nil) {
                 PFUser *user = [objects firstObject];
                 if (user != nil) {
                     [PFUser requestPasswordResetForEmailInBackground:user[PF_USER_EMAIL]];
                     [ProgressHUD showSuccess:@"Email sent."];
                 }
                 else [ProgressHUD showError:@"No user registered with that username."];
             }
             else [ProgressHUD showError:error.userInfo[@"error"]];
         }];
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == fieldPassword)
        [self unhideLoginButton];
    if (textField == fieldUsername)
        [self hideLoginButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == fieldUsername)
        [fieldPassword becomeFirstResponder];
    if (textField == fieldPassword)
        [self actionLogin:nil];
    return YES;
}

#pragma mark - Helper methods

- (void)unhideLoginButton {
    CGRect frame = buttonLogin.frame;
    frame.origin.x = -[[UIScreen mainScreen] bounds].size.width;
    buttonLogin.frame = frame;
    buttonLogin.hidden = NO;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        buttonLogin.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 224 - 124, [[UIScreen mainScreen] bounds].size.width, 70);
    } completion:nil];
}

- (void) hideLoginButton {
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.buttonLogin setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 134, [[UIScreen mainScreen] bounds].size.width, 70)];
    } completion:nil];
}

@end
