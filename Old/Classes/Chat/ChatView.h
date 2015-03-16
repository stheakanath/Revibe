
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIAlertViewDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

- (id)initWith:(PFObject *)conversation_;

- (void)actionLike:(NSIndexPath *)indexPath;

@end
