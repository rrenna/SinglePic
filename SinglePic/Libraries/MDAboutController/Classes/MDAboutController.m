//
//  MDAboutController.m
//  MDAboutController
//
//  Created by Dimitri Bouniol on 4/18/11.
//  Copyright 2011 Mochi Development Inc. All rights reserved.
//
//  Copyright (c) 2010 Dimitri Bouniol, Mochi Development, Inc.
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

#import "MDAboutController.h"
#import "UIImage+DBMaskedImageAdditions.h"
#import "MDACTitleBar.h"
#import "MDACCredit.h"
#import "MDACCreditItem.h"
#import "MDACListCredit.h"
#import "MDACTextCredit.h"
#import "MDACImageCredit.h"
#import "MDACIconCredit.h"
#import "MDACWebViewController.h"
#import "MDACStyle.h"
//
#import "SPLabel.h"
#import "TestFlight.h"

#pragma mark Constants

static NSString *MDACIconCellID         = @"MDACIconCell";
static NSString *MDACSpacerCellID       = @"MDACSpacerCell";
static NSString *MDACListTitleCellID    = @"MDACListTitleCellID";
static NSString *MDACTopListCellID      = @"MDACTopListCell";
static NSString *MDACMiddleListCellID   = @"MDACMiddleListCell";
static NSString *MDACBottomListCellID   = @"MDACBottomListCell";
static NSString *MDACSingleListCellID   = @"MDACSingleListCell";
static NSString *MDACTextCellID         = @"MDACTextCell";
static NSString *MDACImageCellID        = @"MDACImageCell";

@interface MDAboutController ()

- (void)generateCachedCells; // internal
- (void)generateCachedCellsIfNeeded; // internal

- (void)openMailToRecipient:(NSString *)recipient subject:(NSString *)subject;

@property (nonatomic, retain, readwrite) MDACStyle *style;

@end

@implementation MDAboutController

@synthesize showsTitleBar, titleBar, backgroundColor, hasSimpleBackground, credits, style;

- (id)initWithStyle:(MDACStyle *)aStyle
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.style = aStyle;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        
        self.backgroundColor = [self.style backgroundColor];
        self.hasSimpleBackground = [self.style hasSimpleBackground];
        
        credits = [[NSMutableArray alloc] init];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *versionString = nil;
        
        // Former makes about string too long
        //self.navigationItem.title = [NSString stringWithFormat:@"About %@", appName];
        self.navigationItem.title = @"About";
        
        NSString *bundleShortVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *bundleVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        if (bundleShortVersionString && bundleVersionString) {
            versionString = [NSString stringWithFormat:@"Version %@ (%@)",
                             bundleShortVersionString,
                             bundleVersionString];
        } else if (bundleShortVersionString) {
            versionString = [NSString stringWithFormat:@"Version %@", bundleShortVersionString];
        } else if (bundleVersionString) {
            versionString = [NSString stringWithFormat:@"Version %@", bundleVersionString];
        }
		
        UIImage *icon = nil;
        
        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"]) {
            NSArray *iconRefs = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFiles"];
            
            float targetSize = 57.*[UIScreen mainScreen].scale;
            float lastSize = 0;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                targetSize = 72;
            }
            
            NSMutableArray *icons = [[NSMutableArray alloc] init];
            
            for (NSString *iconRef in iconRefs) {
                UIImage *imageA = [UIImage imageNamed:iconRef];
                
                NSUInteger i = 0;
                
                for (i = 0; i < [icons count]; i++) {
                    UIImage *imageB = [icons objectAtIndex:i];
                    if (imageA.size.width*imageA.scale < imageB.size.width*imageB.scale)
                        break;
                }
                
                [icons insertObject:imageA atIndex:i];
            }
            
            for (UIImage *testIcon in icons) {
                if (testIcon.size.width*testIcon.scale > lastSize ) {
                    lastSize = testIcon.size.width*testIcon.scale;
                    icon = testIcon;
                    
                    if (testIcon.size.width*testIcon.scale >= targetSize)
                        break;
                }
            }
            
            [icons release];
        } else {
            icon = [UIImage imageNamed:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIconFile"]];
        }
        
        if (icon) {
            UIImage *maskImage = [UIImage imageNamed:@"MDACIconMask.png"];
            icon = [icon maskedImageWithMask:maskImage];
        }
        
        [credits addObject:[MDACIconCredit iconCreditWithAppName:appName versionString:versionString icon:icon]];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"plist"];
        if (path) {
            NSArray *creditsFile = [[NSArray alloc] initWithContentsOfFile:path];
            if (creditsFile) {
                for (NSDictionary *creditDict in creditsFile) {
                    if (creditDict) {
                        if ([[creditDict objectForKey:@"Type"] isEqualToString:@"List"]) {
                            [credits addObject:[MDACListCredit listCreditWithDictionary:creditDict]];
                        } else if ([[creditDict objectForKey:@"Type"] isEqualToString:@"Text"]) {
                            [credits addObject:[MDACTextCredit textCreditWithDictionary:creditDict]];
                        } if ([[creditDict objectForKey:@"Type"] isEqualToString:@"Image"]) {
                            [credits addObject:[MDACImageCredit imageCreditWithDictionary:creditDict]];
                        }
                    }
                }
            }
            [creditsFile release];
        }
        
        // To remove (:sadface:) the following credit, call [aboutController removeLastCredit]; after initializing your controller.
        
        [credits addObject:[MDACTextCredit textCreditWithText:@"About screen powered by MDAboutViewController, available free on GitHub!"
                                                         font:[UIFont boldSystemFontOfSize:11]
                                                    alignment:UITextAlignmentCenter
                                                      linkURL:[NSURL URLWithString:@"https://github.com/mochidev/MDAboutControllerDemo"]]];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithStyle:nil];
}

- (void)setBackgroundColor:(UIColor *)aColor
{
    if (backgroundColor != aColor) {
        [backgroundColor release];
        backgroundColor = [aColor retain];
        
        tableView.backgroundColor = backgroundColor;
        if ([self isViewLoaded])
            self.view.backgroundColor = backgroundColor;
    }
    
    self.hasSimpleBackground = !CGColorGetPattern(backgroundColor.CGColor);
}

- (MDACStyle *)style
{
    if (!style) {
        self.style = [MDACStyle style];
    }
    return style;
}

- (void)dealloc
{
    [style release];
    [cachedCellCredits release];
    [cachedCellHeights release];
    [cachedCellIDs release];
    [cachedCellIndices release];
    [credits release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)generateCachedCells
{
    [cachedCellCredits release];
    [cachedCellHeights release];
    [cachedCellIDs release];
    [cachedCellIndices release];
    
    cachedCellCredits = [[NSMutableArray alloc] init];
    cachedCellHeights = [[NSMutableArray alloc] init];
    cachedCellIDs = [[NSMutableArray alloc] init];
    cachedCellIndices = [[NSMutableArray alloc] init];
    
    NSString *cellID;
    NSUInteger index, count;
    
    int i = 1;
    int j;
    
    [cachedCellCredits addObject:[NSNull null]];
    [cachedCellHeights addObject:[NSNumber numberWithFloat:[self.style spacerHeight]]];
    [cachedCellIDs addObject:MDACSpacerCellID];
    [cachedCellIndices addObject:[NSNull null]];
    
    for (MDACCredit *tempCredit in credits) {
        if ([tempCredit isMemberOfClass:[MDACListCredit class]]) {
            count = [(MDACListCredit *)tempCredit count];
            j = i;
            i += count;
            
            if ([(MDACListCredit *)tempCredit title] && ![[(MDACListCredit *)tempCredit title] isEqualToString:@""]) {
                [cachedCellCredits addObject:tempCredit];
                [cachedCellHeights addObject:[NSNumber numberWithFloat:[self.style listTitleHeight]]];
                [cachedCellIDs addObject:MDACListTitleCellID];
                [cachedCellIndices addObject:[NSNull null]];
            }
            
            for (; j < i; j++) {
                index = j - (i - count);
                if (index == count-1) {
                    if (index == 0) {
                        cellID = MDACSingleListCellID;
                    } else {
                        cellID = MDACBottomListCellID;
                    }
                } else if (index == 0) {
                    cellID = MDACTopListCellID;
                } else {
                    cellID = MDACMiddleListCellID;
                }
                
                [cachedCellCredits addObject:tempCredit];
                [cachedCellHeights addObject:[NSNumber numberWithFloat:[self.style listHeight]]];
                [cachedCellIDs addObject:cellID];
                [cachedCellIndices addObject:[NSNumber numberWithInteger:index]];
            }
        } else if ([tempCredit isMemberOfClass:[MDACIconCredit class]]) {
            i += 1;
            
            float iconHeight = 57;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                iconHeight = 72;
            
            iconHeight += [self.style iconAdditionalHeight];
            
            [cachedCellCredits addObject:tempCredit];
            [cachedCellHeights addObject:[NSNumber numberWithFloat:iconHeight]];
            [cachedCellIDs addObject:MDACIconCellID];
            [cachedCellIndices addObject:[NSNull null]];
        } else if ([tempCredit isMemberOfClass:[MDACTextCredit class]]) {
            i += 1;
            
            CGSize textSize; //CGSizeMake(300, 30);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                textSize = [[(MDACTextCredit *)tempCredit text] sizeWithFont:[(MDACTextCredit *)tempCredit font]
                                                           constrainedToSize:CGSizeMake(450, 1000)
                                                               lineBreakMode:UILineBreakModeWordWrap];
            } else {
                textSize = [[(MDACTextCredit *)tempCredit text] sizeWithFont:[(MDACTextCredit *)tempCredit font]
                                                           constrainedToSize:CGSizeMake(300, 1000)
                                                               lineBreakMode:UILineBreakModeWordWrap];
            }
            
            [cachedCellCredits addObject:tempCredit];
            [cachedCellHeights addObject:[NSNumber numberWithFloat:textSize.height]];
            [cachedCellIDs addObject:MDACTextCellID];
            [cachedCellIndices addObject:[NSNull null]];
        } else if ([tempCredit isMemberOfClass:[MDACImageCredit class]]) {
            i += 1;
            
            [cachedCellCredits addObject:tempCredit];
            [cachedCellHeights addObject:[NSNumber numberWithFloat:[(MDACImageCredit *)tempCredit image].size.height]];
            [cachedCellIDs addObject:MDACImageCellID];
            [cachedCellIndices addObject:[NSNull null]];
        } else {
            i += 1;
            
            [cachedCellCredits addObject:tempCredit];
            [cachedCellHeights addObject:[NSNumber numberWithFloat:[self.style spacerHeight]]];
            [cachedCellIDs addObject:MDACSpacerCellID];
            [cachedCellIndices addObject:[NSNull null]];
        }
        
        i += 1;
        
        [cachedCellCredits addObject:[NSNull null]];
        [cachedCellHeights addObject:[NSNumber numberWithFloat:[self.style spacerHeight]]];
        [cachedCellIDs addObject:MDACSpacerCellID];
        [cachedCellIndices addObject:[NSNull null]];
    }
}

- (void)generateCachedCellsIfNeeded
{
    if (!cachedCellCredits) {
        [self generateCachedCells];
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = nil;
    MDACCredit *credit = nil;
    NSUInteger index = 0;
    
    [self generateCachedCellsIfNeeded];
    
    if ((NSNull *)[cachedCellIDs objectAtIndex:indexPath.row] != [NSNull null])
        cellID = [cachedCellIDs objectAtIndex:indexPath.row];
    
    if ((NSNull *)[cachedCellCredits objectAtIndex:indexPath.row] != [NSNull null])
        credit = [cachedCellCredits objectAtIndex:indexPath.row];
    
    if ((NSNull *)[cachedCellIndices objectAtIndex:indexPath.row] != [NSNull null])
        index = [[cachedCellIndices objectAtIndex:indexPath.row] integerValue];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    SPLabel *textLabel = nil, *detailTextLabel = nil;
    UIImageView *linkAvailableImageView = nil;
    
    UIImageView *iconView = nil;
    UIView *containerView = nil;
    
    UIImageView *imageView = nil;
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        
        if (cellID == MDACTopListCellID || cellID == MDACMiddleListCellID || cellID == MDACBottomListCellID || cellID == MDACSingleListCellID) {
            UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [self.style listHeight])];
            UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [self.style listHeight])];
            
            UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width-20, [self.style listHeight])];
            UIImageView *selectedBackgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width-20, [self.style listHeight])];
            
            if (cellID == MDACTopListCellID) {
                backgroundImage.frame = CGRectMake(10, -1, tableView.bounds.size.width-20, [self.style listHeight]+1);
                backgroundImage.image = [self.style listCellBackgroundTop];
                selectedBackgroundImage.frame = CGRectMake(10, -1, tableView.bounds.size.width-20, [self.style listHeight]+1);
                selectedBackgroundImage.image = [self.style listCellBackgroundTopSelected];
            } else if (cellID == MDACMiddleListCellID) {
                backgroundImage.image = [self.style listCellBackgroundMiddle];
                selectedBackgroundImage.image = [self.style listCellBackgroundMiddleSelected];
            } else if (cellID == MDACBottomListCellID) {
                backgroundImage.frame = CGRectMake(10, 0, tableView.bounds.size.width-20, [self.style listHeight]+1);
                backgroundImage.image = [self.style listCellBackgroundBottom];
                selectedBackgroundImage.frame = CGRectMake(10, 0, tableView.bounds.size.width-20, [self.style listHeight]+1);
                selectedBackgroundImage.image = [self.style listCellBackgroundBottomSelected];
            } else {
                backgroundImage.frame = CGRectMake(10, -1, tableView.bounds.size.width-20, [self.style listHeight]+2);
                backgroundImage.image = [self.style listCellBackgroundSingle];
                selectedBackgroundImage.frame = CGRectMake(10, -1, tableView.bounds.size.width-20, [self.style listHeight]+2);
                selectedBackgroundImage.image = [self.style listCellBackgroundSingleSelected];
            }
            
            backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [backgroundView addSubview:backgroundImage];
            [backgroundImage release];
            
            selectedBackgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [selectedBackgroundView addSubview:selectedBackgroundImage];
            [selectedBackgroundImage release];
            
            cell.backgroundView = backgroundView;
            [backgroundView release];
            
            cell.selectedBackgroundView = selectedBackgroundView;
            [selectedBackgroundView release];
            
            textLabel = [[SPLabel alloc] init];
            textLabel.font = [self.style listCellFont];
            
            
            if(cellID == MDACSingleListCellID)
            {
                textLabel.backgroundColor = [self.style listCellBackgroundColorSingle];
                textLabel.textColor = [self.style listCellTextColorSingle];
                textLabel.shadowColor = [self.style listCellShadowColorSingle];
            }
            else
            {
                textLabel.backgroundColor = [self.style listCellBackgroundColor];
                textLabel.textColor = [self.style listCellTextColor];
                textLabel.shadowColor = [self.style listCellShadowColor];
            }
            
 
          
            textLabel.shadowOffset = [self.style listCellShadowOffset];
            textLabel.tag = 1;
            [cell.contentView addSubview:textLabel];
            [textLabel release];
            
            detailTextLabel = [[SPLabel alloc] init];
            detailTextLabel.font = [self.style listCellDetailFont];
            
            if(cellID == MDACSingleListCellID)
            {
                detailTextLabel.backgroundColor = [self.style listCellBackgroundColorSingle];
                detailTextLabel.textColor = [self.style listCellTextColorSingle];
                detailTextLabel.shadowColor = [self.style listCellShadowColorSingle];
            }
            else
            {
                detailTextLabel.backgroundColor = [self.style listCellBackgroundColor];
                detailTextLabel.textColor = [self.style listCellDetailTextColor];
                detailTextLabel.shadowColor = [self.style listCellShadowColor];
            }
            
       
            detailTextLabel.shadowOffset = [self.style listCellShadowOffset];
            detailTextLabel.textAlignment = UITextAlignmentRight;
            detailTextLabel.tag = 2;
            [cell.contentView addSubview:detailTextLabel];
            [detailTextLabel release];
            
            linkAvailableImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width-39, 9, 24, 24)];
            linkAvailableImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            linkAvailableImageView.image = [self.style listCellLinkArrow];
            linkAvailableImageView.tag = 3;
            [cell.contentView addSubview:linkAvailableImageView];
            [linkAvailableImageView release];
        } else if (cellID == MDACIconCellID) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            containerView = [[UIView alloc] init];
            containerView.tag = 5;
            containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            
            iconView = [[UIImageView alloc] init];
            UIImageView *iconBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDACIconShadow.png"]];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                iconView.frame = CGRectMake(0, 0, 72, 72);
                containerView.frame = CGRectMake(roundf((cell.contentView.bounds.size.width-212)/2.), 0, 212, 92);
            } else {
                iconView.frame = CGRectMake(0, 0, 57, 57);
                containerView.frame = CGRectMake(roundf((cell.contentView.bounds.size.width-198)/2.), 0, 198, 77);
            }
            
            iconBackground.center = CGPointMake(10+iconView.bounds.size.width/2., containerView.bounds.size.height/2.+3);
            iconView.center = CGPointMake(iconBackground.center.x, iconBackground.center.y-3);
            iconView.tag = 4;
            
            [containerView addSubview:iconBackground];
            [containerView addSubview:iconView];
            
            [iconBackground release];
            [iconView release];
            
            textLabel = [[SPLabel alloc] initWithFrame:CGRectMake(iconView.bounds.size.width+25, floorf(10+iconView.bounds.size.height/2.-17), 170, 22)];
            textLabel.font = [self.style iconCellFont];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.opaque = NO;
            textLabel.textColor = [self.style iconCellTextColor];
            textLabel.shadowColor = [self.style iconCellShadowColor];
            textLabel.shadowOffset = [self.style iconCellShadowOffset];
            textLabel.tag = 1;
            [containerView addSubview:textLabel];
            [textLabel release];
            
            detailTextLabel = [[SPLabel alloc] initWithFrame:CGRectMake(iconView.bounds.size.width+25, floorf(10+iconView.bounds.size.height/2.+3), 170, 20)];
            detailTextLabel.font = [self.style iconCellDetailFont];
            detailTextLabel.backgroundColor = [UIColor clearColor];
            detailTextLabel.opaque = NO;
            detailTextLabel.textColor = [self.style iconCellTextColor];
            detailTextLabel.shadowColor = [self.style iconCellShadowColor];
            detailTextLabel.shadowOffset = [self.style iconCellShadowOffset];
            detailTextLabel.tag = 2;
            [containerView addSubview:detailTextLabel];
            [detailTextLabel release];
            
            [cell.contentView addSubview:containerView];
            [containerView release];
        } else if (cellID == MDACListTitleCellID) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            textLabel = [[SPLabel alloc] initWithFrame:CGRectMake(20, -10, cell.contentView.bounds.size.width-40, cell.contentView.bounds.size.height)];
            textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            textLabel.lineBreakMode = UILineBreakModeTailTruncation;
            textLabel.numberOfLines = 0;
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.opaque = NO;
            textLabel.font = [self.style listCellTitleFont];
            textLabel.textColor = [self.style listCellTitleTextColor];
            textLabel.shadowColor = [self.style listCellTitleShadowColor];
            textLabel.shadowOffset = [self.style listCellTitleShadowOffset];
            textLabel.tag = 1;
            [cell.contentView addSubview:textLabel];
            [textLabel release];
        } else if (cellID == MDACTextCellID) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            textLabel = [[SPLabel alloc] initWithFrame:CGRectMake(10, 0, cell.contentView.bounds.size.width-20, cell.contentView.bounds.size.height)];
            textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            textLabel.lineBreakMode = UILineBreakModeWordWrap;
            textLabel.numberOfLines = 0;
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.opaque = NO;
            textLabel.textColor = [self.style textCellTextColor];
            textLabel.highlightedTextColor = [self.style textCellHighlightedTextColor];
            textLabel.shadowColor = [self.style textCellShadowColor];
            textLabel.shadowOffset = [self.style textCellShadowOffset];
            textLabel.tag = 1;
            [cell.contentView addSubview:textLabel];
            [textLabel release];
        } else if (cellID == MDACImageCellID) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.opaque = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = 6;
            [cell.contentView addSubview:imageView];
            [imageView release];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        if (cellID == MDACTopListCellID || cellID == MDACMiddleListCellID || cellID == MDACBottomListCellID || cellID == MDACSingleListCellID) {
            textLabel = (SPLabel *)[cell.contentView viewWithTag:1];
            detailTextLabel = (SPLabel *)[cell.contentView viewWithTag:2];
            linkAvailableImageView = (UIImageView *)[cell.contentView viewWithTag:3];
            
        } else if (cellID == MDACIconCellID) {
            textLabel = (SPLabel *)[cell.contentView viewWithTag:1];
            detailTextLabel = (SPLabel *)[cell.contentView viewWithTag:2];
            iconView = (UIImageView *)[cell.contentView viewWithTag:4];
            containerView = (UIImageView *)[cell.contentView viewWithTag:5];
        } else if (cellID == MDACTextCellID) {
            textLabel = (SPLabel *)[cell.contentView viewWithTag:1];
        } else if (cellID == MDACListTitleCellID) {
            textLabel = (SPLabel *)[cell.contentView viewWithTag:1];
        } else if (cellID == MDACImageCellID) {
            imageView = (UIImageView *)[cell.contentView viewWithTag:6];
        }
    }
    
    if ([credit isMemberOfClass:[MDACListCredit class]]) {
        if (cellID == MDACListTitleCellID) {
            textLabel.text = [(MDACListCredit *)credit title];
        } else {
            textLabel.text = [(MDACListCredit *)credit itemAtIndex:index].name;
            detailTextLabel.text = [[(MDACListCredit *)credit itemAtIndex:index].role lowercaseString];
            
            [textLabel sizeToFit];
            [detailTextLabel sizeToFit];
            
            if ([(MDACListCredit *)credit itemAtIndex:index].link) {
                linkAvailableImageView.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                linkAvailableImageView.hidden = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (detailTextLabel.text) {
                textLabel.frame = CGRectMake(114, floorf((cell.contentView.bounds.size.height-textLabel.bounds.size.height)/2.-2), textLabel.bounds.size.width, textLabel.bounds.size.height);
                detailTextLabel.frame = CGRectMake(24, floorf((cell.contentView.bounds.size.height-detailTextLabel.bounds.size.height)/2.-1), 80, detailTextLabel.bounds.size.height);
            } else {
                textLabel.frame = CGRectMake(24, roundf((cell.contentView.bounds.size.height-textLabel.bounds.size.height)/2.-2), textLabel.bounds.size.width, textLabel.bounds.size.height);
            }
        }
    } else if ([credit isMemberOfClass:[MDACIconCredit class]]) {
        textLabel.text = [(MDACIconCredit *)credit appName];
        detailTextLabel.text = [(MDACIconCredit *)credit versionString];
        iconView.image = [(MDACIconCredit *)credit icon];
        CGRect containerFrame = containerView.frame;
        containerFrame.size.width = iconView.bounds.size.width + 35 + MAX([textLabel sizeThatFits:CGSizeZero].width , [detailTextLabel sizeThatFits:CGSizeZero].width);
        if (containerFrame.size.width > 300) containerFrame.size.width = 300;
        containerFrame.origin.x = roundf((cell.contentView.bounds.size.width-containerFrame.size.width)/2.);
        containerView.frame = containerFrame;
    } else if ([credit isMemberOfClass:[MDACTextCredit class]]) {
        textLabel.textAlignment = [(MDACTextCredit *)credit textAlignment];
        textLabel.font = [(MDACTextCredit *)credit font];
        textLabel.text = [(MDACTextCredit *)credit text];
        textLabel.highlighted = ([(MDACTextCredit *)credit link] != nil);
    } else if ([credit isMemberOfClass:[MDACImageCredit class]]) {
        imageView.image = [(MDACImageCredit *)credit image];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.hasSimpleBackground || [cell.reuseIdentifier isEqualToString:MDACSpacerCellID] || [cell.reuseIdentifier isEqualToString:MDACListTitleCellID])
        cell.backgroundColor = [UIColor clearColor];
}

- (void)openMailToRecipient:(NSString *)recipient subject:(NSString *)subject
{
    #ifdef BETA
    [TestFlight openFeedbackView];
    #else
    UIViewController *mailer = [[[NSClassFromString(@"MFMailComposeViewController") alloc] init] autorelease];
    [mailer performSelector:@selector(setMailComposeDelegate:) withObject:self];
    [mailer performSelector:@selector(setToRecipients:) withObject:[NSArray arrayWithObject:recipient]];
    [mailer performSelector:@selector(setSubject:) withObject:subject];
    
    // dear compiler warning... shut up
    // the following should be fully backwards compatible.
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        objc_msgSend(self, @selector(presentViewController:animated:completion:), mailer, YES, NULL);
        //        [self presentViewController:mailer animated:YES completion:NULL];
    } else {
        objc_msgSend(self, @selector(presentModalViewController:animated:), mailer, YES);
        //        [self presentModalViewController:mailer animated:YES];
    }
    #endif
}

- (void)mailComposeController:(id)controller didFinishWithResult:(int)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    MDACCredit *credit = nil;
    id cellID = nil;
    NSUInteger index = 0;
    
    [self generateCachedCellsIfNeeded];
    
    if ((NSNull *)[cachedCellCredits objectAtIndex:indexPath.row] != [NSNull null])
        credit = [cachedCellCredits objectAtIndex:indexPath.row];
    
    if ((NSNull *)[cachedCellIndices objectAtIndex:indexPath.row] != [NSNull null])
        index = [[cachedCellIndices objectAtIndex:indexPath.row] integerValue];
    
    if ((NSNull *)[cachedCellIDs objectAtIndex:indexPath.row] != [NSNull null])
        cellID = [cachedCellIDs objectAtIndex:indexPath.row];
    
    if ([credit isMemberOfClass:[MDACListCredit class]] && cellID != MDACListTitleCellID) {
        NSURL *url = [(MDACListCredit *)credit itemAtIndex:index].link;
        if (url) {
            if ([url.scheme isEqualToString:@"x-controller"]) {
                Class ViewController = NSClassFromString([url resourceSpecifier]);
                if ([ViewController isSubclassOfClass:[UIViewController class]]) {
                    if (self.navigationController) {
                        UIViewController *viewController = [[ViewController alloc] init];
                        [self.navigationController pushViewController:viewController animated:YES];     
                        [viewController release];
                    }
                }
            }
            else if ([url.scheme isEqualToString:@"selector"]) {
                //Addition - Ryan Renna
                //Performs the requested selector on self - must be implemented
                SEL selector = NSSelectorFromString([url resourceSpecifier]);
                if([self respondsToSelector:selector])
                {
                    [self performSelector:selector];
                }
            }
            else if ([url.scheme isEqualToString:@"mailto"]) {
                if (NSClassFromString(@"MFMailComposeViewController")) {
                    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                    NSString *versionString = nil;
                    NSString *bundleShortVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    NSString *bundleVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                    
                    if (bundleShortVersionString && bundleVersionString) {
                        versionString = [NSString stringWithFormat:@" %@ (%@)",
                                         bundleShortVersionString,
                                         bundleVersionString];
                    } else if (bundleShortVersionString) {
                        versionString = [NSString stringWithFormat:@" %@", bundleShortVersionString];
                    } else if (bundleVersionString) {
                        versionString = [NSString stringWithFormat:@" %@", bundleVersionString];
                    }
                    NSString *subject = [NSString stringWithFormat:@"%@%@ Support", appName, versionString];
                    
                    NSString *recipient = [url resourceSpecifier];
                    if ([[(MDACListCredit *)credit itemAtIndex:index].userAssociations objectForKey:@"EmailName"]) {
                        recipient = [NSString stringWithFormat:@"%@ <%@>", [[(MDACListCredit *)credit itemAtIndex:index].userAssociations objectForKey:@"EmailName"], recipient];
                    }
                    
                    [self openMailToRecipient:recipient subject:subject];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else if (!self.navigationController) {
                [[UIApplication sharedApplication] openURL:url];
            } else {
                NSURL *url = [(MDACListCredit *)credit itemAtIndex:index].link;
                
                MDACWebViewController *linkViewController = [[MDACWebViewController alloc] initWithURL:url];
                [[self navigationController] pushViewController:linkViewController animated:YES];     
                [linkViewController release];
            }
        }
    } else if ([credit isMemberOfClass:[MDACTextCredit class]]) {
        if ([(MDACTextCredit *)credit link]) {
            if (!self.navigationController) {
                [[UIApplication sharedApplication] openURL:[(MDACTextCredit *)credit link]];
            } else {
                NSURL *url =[(MDACTextCredit *)credit link];
                
                MDACWebViewController *linkViewController = [[MDACWebViewController alloc] initWithURL:url];
                [[self navigationController] pushViewController:linkViewController animated:YES];           
                [linkViewController release];
            }
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self generateCachedCellsIfNeeded];
    CGFloat toolbarHeight = 0;
    if (indexPath.section == 0 && indexPath.row == 0 && !self.navigationController.navigationBarHidden && self.navigationController.navigationBar.translucent)
        toolbarHeight = self.navigationController.navigationBar.frame.size.height;
    return [[cachedCellHeights objectAtIndex:indexPath.row] floatValue] + toolbarHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self generateCachedCellsIfNeeded];
    return [cachedCellCredits count];
}

- (void)loadView
{
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.view = rootView;
    rootView.backgroundColor = self.backgroundColor;
    [rootView release];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, rootView.bounds.size.width, rootView.bounds.size.height-44) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.backgroundColor = self.backgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [rootView addSubview:tableView];
    [tableView release];
    
    MDACTitleBar *aTitleBar = [[MDACTitleBar alloc] initWithController:self];
    aTitleBar.title = self.navigationItem.title;
    self.titleBar = aTitleBar;
    [aTitleBar release];
}

- (void)dismiss:(id)sender
{
    [SPSoundHelper playTap];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.showsTitleBar = !self.navigationController;
    if ([titleBar isMemberOfClass:[MDACTitleBar class]]) {
        [(MDACTitleBar *)titleBar setButtonHidden:(self.parentViewController.class == [UITabBarController class])];
    }
}

- (void)setTitleBar:(UIView *)aTitleBar
{
    if (aTitleBar != titleBar) {
        [self.view addSubview:aTitleBar];
        [titleBar removeFromSuperview];
        
        [titleBar release];
        titleBar = [aTitleBar retain];
        
        titleBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        
        self.showsTitleBar = showsTitleBar;
    }
}

- (void)setShowsTitleBar:(BOOL)yn
{
    [self setShowsTitleBar:yn animated:NO];
}

- (void)setShowsTitleBar:(BOOL)yn animated:(BOOL)animated
{
    showsTitleBar = yn;
    
    if (showsTitleBar) {
        titleBar.hidden = NO;
        if (animated) {
            [UIView animateWithDuration:0.15 delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 titleBar.alpha = 1.;
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.25 delay:0
                                                     options:UIViewAnimationOptionBeginFromCurrentState
                                                  animations:^(void) {
                                                      titleBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, titleBar.bounds.size.height);
                                                      tableView.frame = CGRectMake(0, titleBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-titleBar.bounds.size.height);
                                                  }
                                                  completion:NULL];
                             }];
            
        } else {
            titleBar.alpha = 1.;
            titleBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, titleBar.bounds.size.height);
            tableView.frame = CGRectMake(0, titleBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-titleBar.bounds.size.height);
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 titleBar.frame = CGRectMake(0, -titleBar.bounds.size.height, self.view.bounds.size.width, titleBar.bounds.size.height);
                                 tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.15 delay:0
                                                     options:UIViewAnimationOptionBeginFromCurrentState
                                                  animations:^(void) {
                                                      titleBar.alpha = 0;
                                                  }
                                                  completion:^(BOOL finished) {
                                                      titleBar.hidden = YES;
                                                  }];
                             }];
            
        } else {
            titleBar.hidden = YES;
            titleBar.alpha = 0;
            titleBar.frame = CGRectMake(0, -titleBar.bounds.size.height, self.view.bounds.size.width, titleBar.bounds.size.height);
            tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
    }
}

- (void)viewDidUnload
{
    self.titleBar = nil;
    tableView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;//return YES;
}

#pragma mark - Manipulating Credits

- (void)addCredit:(MDACCredit *)aCredit
{
    [credits addObject:aCredit];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (void)insertCredit:(MDACCredit *)aCredit atIndex:(NSUInteger)index
{
    [credits insertObject:aCredit atIndex:index];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (void)replaceCreditAtIndex:(NSUInteger)index withCredit:(MDACCredit *)aCredit
{
    [credits replaceObjectAtIndex:index withObject:aCredit];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (void)removeLastCredit
{
    [credits removeLastObject];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (void)removeCredit:(MDACCredit *)aCredit
{
    [credits removeObject:aCredit];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (void)removeCreditAtIndex:(NSUInteger)index
{
    [credits removeObjectAtIndex:index];
    
    [cachedCellCredits release];
    cachedCellCredits = nil;
    
    [tableView reloadData];
}

- (NSUInteger)creditCount
{
    return [credits count];
}

@end

