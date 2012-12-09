//
//  SPLocationChooser.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import "SPLocationChooser.h"
#import "SPBucket.h"
#import "SPCardView.h"

@interface SPLocationChooser()
{
    BOOL bucketsRetrieved;
}
@property (strong) NSArray* buckets;
@property (strong) NSMutableArray* selectionIndicators;
@property (strong) NSMutableArray* buttonTitles;
@property (strong) NSMutableArray* buttonIcons;
@property (strong,readwrite) SPBucket* chosenBucket;

-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index;
-(void)selectLocationAtIndex:(int)index;
@end

@implementation SPLocationChooser
@synthesize buckets = _buckets, selectionIndicators = _selectionIndicators, buttonTitles = _buttonTitles, buttonIcons = _buttonIcons; //Private
@synthesize delegate = _delegate,chosenBucket = _chosenBucket;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
        bucketsRetrieved = NO;
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
        bucketsRetrieved = NO;
    }
    return self;
}
-(void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];

    if(!bucketsRetrieved)
    {
        bucketsRetrieved = YES;
        //Retrieve buckets
        [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
         {
             self.buckets = buckets;
             
                 //Adds buttons representing the 4 closest buckets
             for(int i=0;i< self.buckets.count; i++) {
                 
                     //Only display the first 4
                 if(i >= 5) break;
                 
                 SPBucket* bucket = [self.buckets objectAtIndex:i];
                     //Must be added in this order
                 [self addSubview: [self buttonForLocation:bucket atIndex:i]];
             }
             
         } andErrorHandler:^
         {
             
         }];
    }
}
#pragma mark - IBActions
-(IBAction)locationSelected:(id)sender
{
    int index = [sender tag];
    [self selectLocationAtIndex:index];
}
#pragma mark - Private methods
#define ICON_DIMENSION 20
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index
{
    int buttonY = (self.frame.size.height/4 * index);
    int avaliableHeight = self.frame.size.height;
    int buttonHeight = (avaliableHeight /4 ) - 5;
    int iconY = (buttonHeight - ICON_DIMENSION) / 2;
    CGRect frame = CGRectMake(0, floor(buttonY), floor(self.frame.size.width),floor(buttonHeight));
    CGRect iconFrame = CGRectMake(8,iconY, ICON_DIMENSION, ICON_DIMENSION);
    
    NSString* locationName = bucket.name;

    UIView* view = [[UIView alloc] initWithFrame:frame];
    
    //Card View
    SPCardView* card = [[SPCardView alloc] initWithFrame:view.bounds];
    [card setStyle:CARD_STYLE_YELLOW];
    card.alpha = 0.25;
    
    //Button - will contain a tag storing the index
    UIButton* button = [[UIButton alloc] initWithFrame:view.bounds];
    button.tag = index;
    
    [button addTarget:self action:@selector(locationSelected:) forControlEvents:UIControlEventTouchUpInside];
    //Left Icon
    NSString* iconFileName = @"location-pin.png";
    NSString* iconSelectedFileName = @"location-pin.png";
    
    UIButton* iconView = [[UIButton alloc] initWithFrame:iconFrame];
    [iconView setImage:[UIImage imageNamed:iconFileName] forState:UIControlStateNormal];
    [iconView setImage:[UIImage imageNamed:iconSelectedFileName] forState:UIControlStateSelected];
    [self.buttonIcons addObject:iconView];
    
        //Label
    SPLabel* buttonLabel = [[SPLabel alloc] initWithFrame:CGRectMake(floor(iconView.width + iconView.left),floor(iconView.top),floor(-iconView.left - iconView.width + button.width - iconView.width - 8),floor(iconView.height))];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:11];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    buttonLabel.text = [NSString stringWithFormat:@"I live in %@",locationName];
    [self.buttonTitles addObject:buttonLabel];
    
        //Right Checkmark (selection indicator)
    UIImageView* selectionIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width, 0, 10,button.height)];
    selectionIndicatorView.hidden = YES;
    selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    selectionIndicatorView.image = [UIImage imageNamed:@"Checkmark.png"];
    [self.selectionIndicators addObject:selectionIndicatorView];
    
    [view addSubview:card];
    [view addSubview:button];
    [view addSubview:iconView];
    [view addSubview:buttonLabel];
    [view addSubview:selectionIndicatorView];
    
    return view;
}
-(void)selectLocationAtIndex:(int)index
{
    for(int i = 0; i < [self.selectionIndicators count]; i++)
    {
        UIImageView* selectionIndicator = [self.selectionIndicators objectAtIndex:i];
        UILabel* buttonLabel = [self.buttonTitles objectAtIndex:i];
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
    
    self.chosenBucket = [self.buckets objectAtIndex:index];
    
    if(self.delegate)
    {
        [self.delegate locationChooserSelectionChanged:self];
    }
}
@end
