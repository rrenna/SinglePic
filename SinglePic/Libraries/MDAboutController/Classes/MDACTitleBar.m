//
//  MDACTitleBar.m
//  MDAboutController
//
//  Created by Dimitri Bouniol on 5/23/11.
//  Copyright 2011 Mochi Development Inc. All rights reserved.
//  
//  Copyright (c) 2011 Dimitri Bouniol, Mochi Development, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  EleMints, the EleMints Icon, Mochi Dev, and the Mochi Development logo are
//  copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you left in the credit line generated
//  automatically by the code that links back to this page :)
//

#import "MDACTitleBar.h"
#import "MDAboutController.h"
#import "SPStyledButton.h"
#import "SPLabel.h"

@implementation MDACTitleBar

- (id)initWithController:(MDAboutController *)controller
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, 320, 44)])) {
        background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 59)];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        background.image = [UIImage imageNamed:@"MDACTitleBar.png"];
        background.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:background];
        [background release];
        
        title = [[SPLabel alloc] initWithFrame:self.bounds];
        title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        title.backgroundColor = nil;
        title.opaque = NO;
        title.textAlignment = UITextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        title.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        title.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:title];
        [title release];
        
        doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-55, 7, 50, 30)];
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [doneButton setBackgroundImage:[UIImage imageNamed:@"MDACDoneButton.png"] forState:UIControlStateNormal];
            //[doneButton setBackgroundImage:[UIImage imageNamed:@"MDACDoneButtonPressed.png"] forState:UIControlStateHighlighted];
        [doneButton setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        doneButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        doneButton.titleLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:12];
        
        [doneButton addTarget:controller action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        [doneButton release];
    }
    return self;
}

- (void)setTitle:(NSString *)aTitle
{
    title.text = aTitle;
}

- (NSString *)title
{
    return title.text;
}

- (void)setButtonTitle:(NSString *)aTitle
{
    doneButton.titleLabel.text = aTitle;
}

- (NSString *)buttonTitle
{
    return doneButton.titleLabel.text;
}

- (void)setButtonHidden:(BOOL)yn
{
    buttonHidden = yn;
    
    if (buttonHidden) {
        doneButton.frame = CGRectMake(self.bounds.size.width+5, 7, 50, 30);
    } else {
        doneButton.frame = CGRectMake(self.bounds.size.width-55, 7, 50, 30);
    }
}

- (BOOL)isButtonHidden
{
    return buttonHidden;
}

@end