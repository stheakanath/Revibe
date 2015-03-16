
#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ContactsView : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)actionSend:(PFUser *)user;


@end
