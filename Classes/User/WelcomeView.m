
#import "AppConstant.h"

#import "WelcomeView.h"
#import "LoginView.h"
#import "RegisterView.h"

@implementation WelcomeView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginView *loginView = [[LoginView alloc] init];
	loginView.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
	navController.navigationBar.barTintColor = [UIColor whiteColor];
	navController.navigationBar.tintColor = HEXCOLOR(0x5BCAEAFF);
	navController.navigationBar.titleTextAttributes =
		@{NSForegroundColorAttributeName:HEXCOLOR(0x5BCAEAFF), NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:24]};
	navController.navigationBar.translucent = NO;
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegister:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RegisterView *registerView = [[RegisterView alloc] init];
	registerView.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerView];
	navController.navigationBar.barTintColor = [UIColor whiteColor];
	navController.navigationBar.tintColor = HEXCOLOR(0x5BCAEAFF);
	navController.navigationBar.titleTextAttributes =
		@{NSForegroundColorAttributeName:HEXCOLOR(0x5BCAEAFF), NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:24]};
	navController.navigationBar.translucent = NO;
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - LoginDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didLoginSucessfully
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RegisterDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didRegisterSucessfully
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
