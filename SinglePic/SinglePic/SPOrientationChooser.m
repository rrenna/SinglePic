//
//  SPOrientationChooser.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPOrientationChooser.h"
#import "SPCardView.h"
#import "SPLabel.h"

@interface SPOrientationChooser()
-(UIButton*)buttonForGender:(GENDER)gender andPreference:(GENDER)preference;
-(int)indexForGender:(GENDER)gender andPreference:(GENDER)preference;
-(void)selectOrientationAtIndex:(int)index;
-(void)showSelectionAtIndex:(int)index;
-(IBAction)orientationSelected:(id)sender;
//Stores the orientation selection indicator images
@property (retain) NSMutableArray* selectionIndicators;
@property (retain) NSMutableArray* buttonTitles;
@property (retain) NSMutableArray* buttonIcons;
@end

@implementation SPOrientationChooser
@synthesize delegate,chosenGender,chosenPreference;
@synthesize selectionIndicators,buttonTitles,buttonIcons;//Private
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        chosenGender = DEFAULT_GENDER; //default
        chosenPreference = DEFAULT_PREFERENCE; //default
        
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
    }
    return self;
}
-(void)layoutSubviews
{
    //Must be added in this order
    [self addSubview: [self buttonForGender:GENDER_FEMALE andPreference:GENDER_MALE] ];
    [self addSubview: [self buttonForGender:GENDER_MALE andPreference:  GENDER_FEMALE] ];
    [self addSubview: [self buttonForGender:GENDER_MALE andPreference:  GENDER_MALE] ];
    [self addSubview: [self buttonForGender:GENDER_FEMALE andPreference:GENDER_FEMALE] ];
        
    //Attempts to retrieve the last selected values from a previous annonymous session
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        chosenGender = [[SPProfileManager sharedInstance] myAnnonymousGender];
        chosenPreference = [[SPProfileManager sharedInstance] myAnnonymousPreference];
    }
    //Retrieves the stored gender & preference out of your current profile
    else if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_PROFILE)
    {
        chosenGender = [[SPProfileManager sharedInstance] myGender];
        chosenPreference = [[SPProfileManager sharedInstance] myPreference];
    }
    
    [self showSelectionAtIndex:[self indexForGender:chosenGender andPreference:chosenPreference] ];

}
#pragma mark - IBActions
-(IBAction)orientationSelected:(id)sender
{
    int index = [sender tag];
    [self selectOrientationAtIndex:index];
}
#pragma mark - Private methods
-(UIView*)buttonForGender:(GENDER)gender andPreference:(GENDER)preference
{
    int index = [self indexForGender:gender andPreference:preference];
    int buttonY = self.frame.size.height/4 * index;
    int buttonHeight = (self.frame.size.height/4 ) - 5;
    int iconDimension = (self.frame.size.height/4 ) * 0.4;
    int iconY = (buttonHeight - iconDimension) / 2;
    CGRect frame = CGRectMake(0, floor(buttonY), floor(self.frame.size.width),floor(buttonHeight));
    CGRect iconFrame = CGRectMake(iconDimension / 2,iconY, iconDimension, iconDimension);
    
    NSString* genderName = GENDER_NAMES[gender];
    NSString* preferenceName = GENDER_NAMES[preference];
    NSString* genderInitial = [genderName substringToIndex:1];
    NSString* preferenceInitial = [preferenceName substringToIndex:1];
    NSString* genderPreferenceKey = [NSString stringWithFormat:@"I'm a %@ seeking a %@", genderName, preferenceName ];
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    
    //Card View
    SPCardView* card = [[SPCardView alloc] initWithFrame:view.bounds];
    [card setStyle:CARD_STYLE_YELLOW];
    card.alpha = 0.25;
    
    //Button - will contain a tag storing the index
    UIButton* button = [[UIButton alloc] initWithFrame:view.bounds];
    button.tag = index;

    [button addTarget:self action:@selector(orientationSelected:) forControlEvents:UIControlEventTouchUpInside];
    //Left Icon
    NSString* iconFileName = [NSString stringWithFormat:@"Orientation-%@s%@-default.png",[genderInitial capitalizedString],[preferenceInitial capitalizedString]];
    NSString* iconSelectedFileName = [NSString stringWithFormat:@"Orientation-%@s%@-selected.png",[genderInitial capitalizedString],[preferenceInitial capitalizedString]];
    UIButton* iconView = [[UIButton alloc] initWithFrame:iconFrame];
    [iconView setImage:[UIImage imageNamed:iconFileName] forState:UIControlStateNormal];
    [iconView setImage:[UIImage imageNamed:iconSelectedFileName] forState:UIControlStateSelected];
    [buttonIcons addObject:iconView];
    
    //Label
    SPLabel* buttonLabel = [[SPLabel alloc] initWithFrame:CGRectMake(floor(iconView.width + iconView.left),floor(iconView.top),floor(-iconView.left - iconView.width + button.width - iconView.width - 8),floor(iconView.height))];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:11];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    buttonLabel.text = NSLocalizedString(genderPreferenceKey, nil);
    [self.buttonTitles addObject:buttonLabel];
    
    //Right Checkmark (selection indicator)
    UIImageView* selectionIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width, 0, 10,button.height)];
    selectionIndicatorView.hidden = YES;
    selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    selectionIndicatorView.image = [UIImage imageNamed:@"Checkmark.png"];
    [selectionIndicators addObject:selectionIndicatorView];
    
    [view addSubview:card];
    [view addSubview:button];
    [view addSubview:iconView];
    [view addSubview:buttonLabel];
    [view addSubview:selectionIndicatorView];
    
    return view;
}
-(int)indexForGender:(GENDER)gender andPreference:(GENDER)preference
{    
    if(gender == GENDER_FEMALE)
    {
        if(preference == GENDER_MALE)
        {
            return 0;
        }
        return 3;
    }
    else
    {
        if(preference == GENDER_MALE)
        {
            return 2;
        }
        return 1;
    }
}
-(void)selectOrientationAtIndex:(int)index
{
    [self showSelectionAtIndex:index];
    
    if(self.delegate)
    {
        [self.delegate orientationChooserSelectionChanged:self];
    }
}
-(void)showSelectionAtIndex:(int)index
{
    for(int i = 0; i < [self.selectionIndicators count]; i++)
    {
        UIImageView* selectionIndicator = [self.selectionIndicators objectAtIndex:i];
        SPLabel* buttonLabel = [self.buttonTitles objectAtIndex:i];
        UIButton* iconView = [self.buttonIcons objectAtIndex:i];
        
        if(i == index)
        {
            selectionIndicator.hidden = NO;
            iconView.selected = YES;
            buttonLabel.alpha = 1.0;
        }
        else
        {
            selectionIndicator.hidden = YES;
            iconView.selected = NO;
            buttonLabel.alpha = 0.5;
        }
    }
    
    if(index == 0 || index == 3)
    {
        chosenGender = GENDER_FEMALE;
    }
    else
    {
        chosenGender = GENDER_MALE;
    }
    if(index == 0 || index == 2)
    {
        chosenPreference = GENDER_MALE;
    }
    else
    {
        chosenPreference = GENDER_FEMALE;
    }

}
@end
