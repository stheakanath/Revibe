
#import "validators.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* ValidatePassword(NSString *value)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *validationMessage = nil;

	NSRange searchRange = NSMakeRange(0, value.length);
	NSRange foundRange = [value rangeOfString:@"^[0-9a-zA-Z.-_!@#&æøåäöéèáàÆØÅÄÖÉÈÁÀ]{6,32}$" options:NSRegularExpressionSearch range:searchRange];

	if ([value length] < 6)
	{
		validationMessage = @"Password is too short.";
	}
	else if ([value length] > 32)
	{
		validationMessage = @"Password is too long.";
	}
	else if (!foundRange.length)
	{
		validationMessage = @"Password has invalid character.";
	}
	return validationMessage;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* ValidateEmail(NSString *value)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *validationMessage = nil;

	NSRange searchRange = NSMakeRange(0, value.length);
	NSRange foundRange = [value rangeOfString:@"\\w+@[a-zA-Z_]+?\\.[a-zA-Z]{2,6}" options:NSRegularExpressionSearch range:searchRange];

	if (!foundRange.length)
	{
		validationMessage = @"Invalid email address.";
	}
	return validationMessage;
}
