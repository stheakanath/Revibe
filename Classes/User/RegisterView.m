
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "pushnotification.h"
#import "utilities.h"
#import "validators.h"

#import "RegisterView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RegisterView()

@property (strong, nonatomic) IBOutlet UITextField *fieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;
@property (strong, nonatomic) IBOutlet UIButton *buttonSignUp;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RegisterView

@synthesize delegate;
@synthesize fieldUsername, fieldPassword, fieldEmail, buttonSignUp;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Sign Up";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"]
																	 style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	buttonSignUp.hidden = YES;
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
		buttonSignUp.frame = CGRectMake(0, 434-frame.size.height, 320, 70);
	} completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardWillHide:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		buttonSignUp.frame = CGRectMake(0, 434, 320, 70);
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
- (IBAction)actionSignUp:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *username	= fieldUsername.text;
	NSString *password	= fieldPassword.text;
	NSString *email		= fieldEmail.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([username length] == 0)			{ [ProgressHUD showError:@"Username must be set."]; return; }
	if ([username length] > 15)			{ [ProgressHUD showError:@"Username is too long."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSRange range = [username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
	if (range.location != NSNotFound)	{ [ProgressHUD showError:@"Username must not contain space."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *passwordValidator = ValidatePassword(password);
	if ([password length] == 0)			{ [ProgressHUD showError:@"Password must be set."]; return; }
	if (passwordValidator != nil)		{ [ProgressHUD showError:passwordValidator]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *emailValidator = ValidateEmail(email);
	if ([email length] == 0)			{ [ProgressHUD showError:@"Email must be set."]; return; }
	if (emailValidator != nil)			{ [ProgressHUD showError:emailValidator]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissKeyboard];
	[ProgressHUD show:@"Please wait..." Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self checkUsername:@{@"username":username, @"password":password, @"email":email}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)checkUsername:(NSDictionary *)dict
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_USERNAME equalTo:dict[@"username"]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				[self getIndex:dict];
			}
			else [ProgressHUD showError:@"Username already exists."];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)getIndex:(NSDictionary *)dict_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)registerUser:(NSDictionary *)dict
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser user];
	user.username = dict[@"username"];
	user.password = dict[@"password"];
	user.email = dict[@"email"];
	user[PF_USER_INDEX] = dict[@"index"];
	user[PF_USER_RANDOM] = @YES;
	user[PF_USER_NOTIFICATION] = @YES;
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[self createUser2:user];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)createUser2:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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
		}
		else
		{
			[ProgressHUD showError:error.userInfo[@"error"]];
			[[PFUser currentUser] deleteInBackground];
			[PFUser logOut];
		}
	}];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldEmail)
	{
		[self unhideSignUpButton];
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
		[fieldEmail becomeFirstResponder];
	}
	if (textField == fieldEmail)
	{
		[self actionSignUp:nil];
	}
	return YES;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)unhideSignUpButton
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect frame = buttonSignUp.frame;
	frame.origin.x = -320;
	buttonSignUp.frame = frame;

	buttonSignUp.hidden = NO;

	[UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		CGRect frame = buttonSignUp.frame;
		frame.origin.x = 0;
		buttonSignUp.frame = frame;
	} completion:nil];
}

@end
