//
//  PasswordView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "PasswordView.h"

@interface PasswordView()

@property (strong, nonatomic) UITextField *fieldPassword1;
@property (strong, nonatomic) UITextField *fieldPassword2;

@end

@implementation PasswordView

@synthesize fieldPassword1, fieldPassword2;

- (void) setUpInterface {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen] bounds].size.width-30, 57)];
    [prompt setText:@"Make changes to your password"];
    [prompt setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.view addSubview:prompt];
    UIView *split = [[UIView alloc] initWithFrame:CGRectMake(0, 57, [[UIScreen mainScreen] bounds].size.width, 1)];
    [split setBackgroundColor:TABLE_COLOR];
    [self.view addSubview:split];
    self.fieldPassword1 = [[UITextField alloc] initWithFrame:CGRectMake(15, 57,  [[UIScreen mainScreen] bounds].size.width-30, 57)];
    [self.fieldPassword1 setPlaceholder:@"New password"];
    [self.fieldPassword1 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.view addSubview:self.fieldPassword1];
    UIView *split1 = [[UIView alloc] initWithFrame:CGRectMake(0, 114, [[UIScreen mainScreen] bounds].size.width, 1)];
    [split1 setBackgroundColor:TABLE_COLOR];
    [self.view addSubview:split1];
    self.fieldPassword2 = [[UITextField alloc] initWithFrame:CGRectMake(15, 114,  [[UIScreen mainScreen] bounds].size.width-30, 57)];
    [self.fieldPassword2 setPlaceholder:@"Repeat password"];
    [self.fieldPassword2 setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.view addSubview:self.fieldPassword2];
    UIView *split2 = [[UIView alloc] initWithFrame:CGRectMake(0, 114, [[UIScreen mainScreen] bounds].size.width, 1)];
    [split2 setBackgroundColor:TABLE_COLOR];
    [self.view addSubview:split2];
    UIButton *savebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [savebutton setFrame:CGRectMake(0, 171, [[UIScreen mainScreen] bounds].size.width, 57)];
    [savebutton setTitle:@"Save" forState:UIControlStateNormal];
    [savebutton.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:21]];
    [savebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [savebutton setBackgroundColor:TABLE_COLOR];
    [savebutton addTarget:self action:@selector(actionSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savebutton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInterface];
    self.title = @"New Password";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [fieldPassword1 becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Backend actions

- (void)saveUser {
    if ([fieldPassword1.text length] == 0) { [ProgressHUD showError:@"Password must be set."]; return; }
    if ([fieldPassword2.text length] == 0) { [ProgressHUD showError:@"Please retype password."]; return; }
    if ([fieldPassword1.text isEqualToString:fieldPassword2.text] == NO) { [ProgressHUD showError:@"Password must be the same."]; return; }
    [self dismissKeyboard];
    [ProgressHUD show:nil Interaction:NO];
    PFUser *user = [PFUser currentUser];
    user.password = fieldPassword1.text;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (error == nil) {
             [ProgressHUD showSuccess:@"Saved."];
             [self.navigationController popViewControllerAnimated:YES];
         } else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

#pragma mark - User actions

- (void)actionBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(id)sender {
    [self saveUser];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == fieldPassword1)
        [fieldPassword2 becomeFirstResponder];
    if (textField == fieldPassword2)
        [self saveUser];
    return YES;
}

@end