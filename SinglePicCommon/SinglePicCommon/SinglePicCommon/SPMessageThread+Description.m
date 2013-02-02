
#import "SPMessageThread+Description.h"

@implementation SPMessageThread (Description)
-(NSString*)description
{
    NSString* userID = [self userID];
    int numberOfUnread = [[self unreadMessagesCount] intValue];
    
    
    NSString* description = [NSString stringWithFormat:@"User ID: %@ Unread Count:%d",userID,numberOfUnread];
    return description;
}
@end
