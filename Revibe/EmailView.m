//
//  EmailView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "EmailView.h"

@interface EmailView()

@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;

@end

@implementation EmailView

@synthesize fieldEmail;

- (void) setUpInterface {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [[UIScreen mainScreen] bounds].size.width-30, 57)];
    [prompt setText:@"Make changes to your email address"];
    [prompt setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.view addSubview:prompt];
    UIView *split = [[UIView alloc] initWithFrame:CGRectMake(0, 57, [[UIScreen mainScreen] bounds].size.width, 1)];
    [split setBackgroundColor:TABLE_COLOR];
    [self.view addSubview:split];
    self.fieldEmail = [[UITextField alloc] initWithFrame:CGRectMake(15, 57,  [[UIScreen mainScreen] bounds].size.width-30, 57)];
    [self.fieldEmail setPlaceholder:@"Email address"];
    [self.fieldEmail setFont:[UIFont fontWithName:@"Avenir Medium" size:17]];
    [self.view addSubview:self.fieldEmail];
    UIView *split1 = [[UIView alloc] initWithFrame:CGRectMake(0, 114, [[UIScreen mainScreen] bounds].size.width, 1)];
    [split1 setBackgroundColor:TABLE_COLOR];
    [self.view addSubview:split1];
    UIButton *savebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [savebutton setFrame:CGRectMake(0, 114, [[UIScreen mainScreen] bounds].size.width, 57)];
    [savebutton setTitle:@"Save" forState:UIControlStateNormal];
    [savebutton.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:21]];
    [savebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [savebutton setBackgroundColor:TABLE_COLOR];
    [savebutton addTarget:self action:@selector(actionSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savebutton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Email";
    [self setUpInterface];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [fieldEmail becomeFirstResponder];
    [self loadUser];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Backend actions

- (void)loadUser {
    PFObject *user = [PFUser currentUser];
    fieldEmail.text = user[PF_USER_EMAIL];
}

- (void)saveUser {
    if ([fieldEmail.text length] == 0) { [ProgressHUD showError:@"Email address must be set."]; return; }
    [self dismissKeyboard];
    [ProgressHUD show:nil Interaction:NO];
    PFUser *user = [PFUser currentUser];
    user.email = fieldEmail.text;
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
    if (textField == fieldEmail)
        [self saveUser];
    return YES;
}

@end