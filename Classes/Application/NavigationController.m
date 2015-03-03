// Hello world! 


#import "AppConstant.h"

#import "NavigationController.h"

@implementation NavigationController

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
	self.navigationBar.barTintColor = HEXCOLOR(0x5BCAEAFF);
	self.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationBar.titleTextAttributes =
		@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:24]};
	self.navigationBar.translucent = NO;
}

@end
