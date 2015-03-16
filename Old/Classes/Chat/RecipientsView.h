
#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecipientsView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(NSString *)message_;

@end
