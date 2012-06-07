//
//  SPIcebreakerComposeScreen.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPIcebreakerComposeViewController.h"

@implementation SPIcebreakerComposeViewController

#pragma mark - View lifecycle
-(id)init
{
    self = [self initWithNibName:@"SPIcebreakerComposeViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Look and Feel
    [topBarView setStyle:STYLE_TAB];
    [cancelButton setStyle:STYLE_TAB];
    [saveButton setStyle:STYLE_CONFIRM_BUTTON];
    
    imageView.image = [[SPProfileManager sharedInstance] myImage];
    textView.text = [[SPProfileManager sharedInstance] myIcebreaker];
    [self textViewDidChange:textView];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [self close];
}
-(IBAction)save:(id)sender
{
    [[SPProfileManager sharedInstance] saveMyIcebreaker:textView.text withCompletionHandler:^(id responseObject) 
    {
        #if defined (TESTING)
        [TestFlight passCheckpoint:@"Saved new Icebreaker"];
        #endif
        
        [self close];
    } 
    andErrorHandler:^
    {
        
    }];
}
#pragma mark - UITextViewDelegate methods
- (void)textViewDidChange:(UITextView *)textView_
{
    characterCountLabel.text = [NSString stringWithFormat:@"%d",[textView_.text length]];
}
- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Disallow line-breaks and tabs
    if([text isEqualToString:@"\n"] || [text isEqualToString:@"\t"])
    {
        return NO;
    }
    
    //Also Disallow any any operation that would push length over ICEBREAKER_LENGTH_LIMIT characters
    int textLength = _textView.text.length;
    int modifyToLength = (textLength + (text.length - range.length));
    
    if(modifyToLength  > ICEBREAKER_LENGTH_LIMIT)
    {
        return NO;
    }
    
    return YES;
}
@end
