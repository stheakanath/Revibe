
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "PasswordView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PasswordView()

@property (strong, nonatomic) IBOutlet UITextField *fieldPassword1;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword2;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation PasswordView

@synthesize fieldPassword1, fieldPassword2;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"New Password";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"]
																	style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	[fieldPassword1 becomeFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([fieldPassword1.text length] == 0) { [ProgressHUD showError:@"Password must be set."]; return; }
	if ([fieldPassword2.text length] == 0) { [ProgressHUD showError:@"Please retype password."]; return; }
	if ([fieldPassword1.text isEqualToString:fieldPassword2.text] == NO) { [ProgressHUD showError:@"Password must be the same."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissKeyboard];
	[ProgressHUD show:nil Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user.password = fieldPassword1.text;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[ProgressHUD showSuccess:@"Saved."];
			[self.navigationController popViewControllerAnimated:YES];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSave:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self saveUser];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldPassword1)
	{
		[fieldPassword2 becomeFirstResponder];
	}
	if (textField == fieldPassword2)
	{
		[self saveUser];
	}
	return YES;
}

@end
