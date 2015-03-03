
#import <Parse/Parse.h>

#import "AppConstant.h"
#import "conversations.h"

#import "ComposeView.h"
#import "RecipientsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ComposeView()
{
	PFUser *user;
	CGFloat heightKeyboard;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *viewInput;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UITextView *textInput;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ComposeView

@synthesize viewInput, viewBackground, textInput, buttonSend;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(PFUser *)user_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	user = user_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    [UIView animateWithDuration:1
                          delay:0  /* starts the animation after 3 seconds */
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         _saySomething.alpha = 0.0;
                         _saySomething.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
	[super viewDidLoad];
	self.title = @"Send Vibe";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"]
																	 style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	heightKeyboard = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self registerForKeyboardNotifications];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
        [UIView animateWithDuration:1
                              delay:.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             _randomWord.alpha = 0.0;
                             _randomWord.alpha = 1.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    
    
    int randomlabel = arc4random() % 45;
    
    switch (randomlabel) {
            
        case 0:
            _randomWord.text = @"🐯";
            break;
        case 1:
            _randomWord.text = @"🐭";
            break;
        case 2:
            _randomWord.text = @"FUN";
            break;
        case 3:
            _randomWord.text = @"🐰";
            break;
        case 4:
            _randomWord.text = @"🐸";
            break;
        case 5:
            _randomWord.text = @"🐯";
            break;
        case 6:
            _randomWord.text = @"🐨";
            break;
        case 7:
            _randomWord.text = @"🐷";
            break;
        case 8:
            _randomWord.text = @"FUNNY";
            break;
        case 9:
            _randomWord.text = @"🐮";
            break;
        case 10:
            _randomWord.text = @"AWESOME";
            break;
        case 11:
            _randomWord.text = @"🐼";
            break;
        case 12:
            _randomWord.text = @"HAASOME";
            break;
        case 13:
            _randomWord.text = @"CRAZY";
            break;
        case 14:
            _randomWord.text = @"🐤";
            break;
        case 15:
            _randomWord.text = @"🐣";
            break;
        case 16:
            _randomWord.text = @"CAL";
            break;
        case 17:
            _randomWord.text = @"🐶";
            break;
        case 18:
            _randomWord.text = @"BRUHH";
            break;
        case 19:
            _randomWord.text = @"😄";
            break;
        case 20:
            _randomWord.text = @"😊";
            break;
        case 21:
            _randomWord.text = @"😉";
            break;
        case 22:
            _randomWord.text = @"😘";
            break;
        case 23:
            _randomWord.text = @"😜";
            break;
        case 24:
            _randomWord.text = @"😂";
            break;
        case 25:
            _randomWord.text = @"😁";
            break;
        case 26:
            _randomWord.text = @"😛";
            break;
        case 27:
            _randomWord.text = @"😝";
            break;
        case 28:
            _randomWord.text = @"😅";
            break;
        case 29:
            _randomWord.text = @"😱";
            break;
        case 30:
            _randomWord.text = @"🐧";
            break;
        case 31:
            _randomWord.text = @"😎";
            break;
        case 32:
            _randomWord.text = @"😋";
            break;
        case 33:
            _randomWord.text = @"😆";
            break;
        case 34:
            _randomWord.text = @"😮";
            break;
        case 35:
            _randomWord.text = @"😏";
            break;
        case 36:
            _randomWord.text = @"🙈";
            break;
        case 37:
            _randomWord.text = @"🙉";
            break;
        case 38:
            _randomWord.text = @"🙊";
            break;
        case 39:
            _randomWord.text = @"🔥";
            break;
        case 40:
            _randomWord.text = @"👌";
            break;
        case 41:
            _randomWord.text = @"👍";
            break;
        case 42:
            _randomWord.text = @"💁";
            break;
        case 43:
            _randomWord.text = @"🐻";
            break;
        case 44:
            _randomWord.text = @"HILARIOUS";
            default:
            break;
    }
    
	[super viewDidAppear:animated];
	[textInput becomeFirstResponder];
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
        heightKeyboard = frame.size.height;
		viewInput.frame = CGRectMake(0, self.view.frame.size.height - heightKeyboard - 50, 320, 55);
	} completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)keyboardWillHide:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *info = [notification userInfo];
	NSTimeInterval duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		heightKeyboard = 0;
		viewInput.frame = CGRectMake(0, 449, 320, 55);
	} completion:nil];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBack
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSend:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = textInput.text;
	if ([text length] != 0)
	{
		if (user != nil)
		{
			CreateConversation(user, text);
			[self actionBack];
		}
		else
		{
			RecipientsView *recipientsView = [[RecipientsView alloc] initWith:text];
			[self.navigationController pushViewController:recipientsView animated:YES];
		}
	}
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - UITextViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)textViewDidChange:(UITextView *)textView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGFloat widthText = textInput.frame.size.width;
	CGSize sizeText = [textInput sizeThatFits:CGSizeMake(widthText, MAXFLOAT)];
	CGFloat heightText = fminf(MAX_HEIGHT_INPUT, fmaxf(45, sizeText.height));
	CGFloat heightView = heightText + 10;
	//---------------------------------------------------------------------------------------------------------------------------------------------
    viewInput.frame = CGRectMake(0, self.view.frame.size.height - heightKeyboard - heightView, 320, heightView);
	viewBackground.frame = CGRectMake(0, 0, 240, heightView);
	textInput.frame = CGRectMake(5, 5, widthText, heightText);
	buttonSend.frame = CGRectMake(260, (heightView-29)/2, 40, 29);
    
    NSInteger restrictedLength=150;
    NSString *temp=textView.text;
    
    if([[textView text] length] > restrictedLength){
        
        textView.text=[temp substringToIndex:[temp length]-1];
        
    }
    
}

- (IBAction)randomWord:(id)sender {
}
@end
