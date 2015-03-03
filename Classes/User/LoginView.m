
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"

#import "LoginView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoginView()

@property (strong, nonatomic) IBOutlet UITextField *fieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogin;


@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation LoginView

@synthesize delegate;
@synthesize fieldUsername, fieldPassword, buttonLogin;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Log In";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"]
																	 style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	buttonLogin.hidden = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self registerForKeyboardNotifications];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	[fieldUsername becomeFirstResponder];
}

#pragma mark - Keyboard Notifications

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)registerForKeyboardNotifications
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	CGRect frame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		buttonLogin.frame = CGRectMake(0, 434-frame.size.height, 320, 70);
	} completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardWillHide:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		buttonLogin.frame = CGRectMake(0, 434, 320, 70);
	} completion:nil];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *username = fieldUsername.text;
	NSString *password = fieldPassword.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([username length] == 0)	{ [ProgressHUD showError:@"Username must be set."]; return; }
	if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissKeyboard];
	[ProgressHUD show:@"Signing in..." Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
	{
		if (user != nil)
		{
			ParsePushUserAssign();
			PostNotification(NOTIFICATION_USER_LOGGED_IN);
			[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_USERNAME]]];
			[self dismissViewControllerAnimated:YES completion:^{ if (delegate != nil) [delegate didLoginSucessfully]; }];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionForgot:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *username = fieldUsername.text;
	if ([username length] != 0)
	{
		NSString *message = [NSString stringWithFormat:@"Send information to %@?", username];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password recovery" message:message delegate:self
												  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
		[alertView show];
	}
	else [ProgressHUD showError:@"Please type username first."];
}

#pragma mark - UIAlertViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		NSString *username = fieldUsername.text;
		PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
		[query whereKey:PF_USER_USERNAME equalTo:username];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				PFUser *user = [objects firstObject];
				if (user != nil)
				{
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldPassword)
	{
		[self unhideLoginButton];
	}
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldUsername)
	{
		[fieldPassword becomeFirstResponder];
	}
	if (textField == fieldPassword)
	{
		[self actionLogin:nil];
	}
	return YES;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)unhideLoginButton
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect frame = buttonLogin.frame;
	frame.origin.x = -320;
	buttonLogin.frame = frame;

	buttonLogin.hidden = NO;

	[UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		CGRect frame = buttonLogin.frame;
		frame.origin.x = 0;
		buttonLogin.frame = frame;
	} completion:nil];
}

@end
