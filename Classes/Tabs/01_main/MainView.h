
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MainView : UITableViewController <UITabBarControllerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)actionChat:(PFObject *)conversation;

@end
