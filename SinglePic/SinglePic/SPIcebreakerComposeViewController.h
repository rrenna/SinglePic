//
//  SPIcebreakerComposeScreen.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPTabContentViewController.h"

@interface SPIcebreakerComposeViewController : SPTabContentViewController <UITextViewDelegate>
{
    IBOutlet SPStyledView* topBarView;
    IBOutlet SPLabel *titleLabel;
    IBOutlet SPStyledButton* cancelButton;
    IBOutlet SPStyledButton* saveButton;
    IBOutlet UITextView* textView;
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel* characterCountLabel;
}

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;
@end
