
#import <UIKit/UIKit.h>

#import "MainView.h"
#import "ContactsView.h"
#import "SettingsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) MainView *mainView;
@property (strong, nonatomic) ContactsView *contactsView;
@property (strong, nonatomic) SettingsView *settingsView;

@end
