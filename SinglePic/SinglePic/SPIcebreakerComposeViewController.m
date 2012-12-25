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
    
    //Localize Controls
    titleLabel.text = NSLocalizedString(@"About Me", nil);
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    //Look and Feel
    [topBarView setStyle:STYLE_TAB];
    [cancelButton setStyle:STYLE_TAB];
    [saveButton setStyle:STYLE_CONFIRM_BUTTON];
    
    imageView.image = [[SPProfileManager sharedInstance] myImage];
    textView.text = [[SPProfileManager sharedInstance] myIcebreaker];
    [self textViewDidChange:textView];
    
    //On load set focus to the textview
    [textView becomeFirstResponder];
}
#pragma mark - IBActions
-(IBAction)cancel:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Cancel' button in the edit Icebreaker screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [self close];
}
-(IBAction)save:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Save' button in the edit Icebreaker screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    saveButton.enabled = NO;
    
    [[SPProfileManager sharedInstance] saveMyIcebreaker:textView.text withCompletionHandler:^(id responseObject) 
    {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Set new Icebreaker"];
        #endif

        [self close];
    } 
    andErrorHandler:^
    {
        saveButton.enabled = YES;
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
