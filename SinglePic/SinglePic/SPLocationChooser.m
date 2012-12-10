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
    int __block bucketDisplayIndex;
}
@property (strong) NSMutableArray* buckets;
@property (strong,readwrite) SPBucket* chosenBucket;
@property (strong) UIView* bucketView;
@property (strong) NSMutableArray* selectionIndicators;
@property (strong) NSMutableArray* buttonTitles;
@property (strong) NSMutableArray* buttonIcons;
@property (strong) UIView* statusView;
@property (strong) UIActivityIndicatorView* activityIndicator;
@property (strong) SPLabel* statusLabel;

-(void)_init;
-(void)retrieveBuckets;
-(void)displayCurrentBucket:(SPBucket*)currentBucket;
-(void)displayBuckets;
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index;
-(void)selectLocationAtIndex:(int)index;
-(void)displaySelectedAtIndex:(int)index;
@end

@implementation SPLocationChooser
@synthesize buckets = _buckets, selectionIndicators = _selectionIndicators, buttonTitles = _buttonTitles, buttonIcons = _buttonIcons; //Private
@synthesize delegate = _delegate,chosenBucket = _chosenBucket;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.buckets = [NSMutableArray array];
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
        bucketDisplayIndex = 0;
        
        [self _init];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.buckets = [NSMutableArray array];
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
        bucketDisplayIndex = 0;
        
        [self _init];
    }
    return self;
}
#define STATUS_HEIGHT 30
-(void)_init
{
    self.statusView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,STATUS_HEIGHT)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,STATUS_HEIGHT,STATUS_HEIGHT)];
    self.statusLabel = [[SPLabel alloc] initWithFrame:CGRectMake(STATUS_HEIGHT + 5, 0, self.frame.size.width - STATUS_HEIGHT - 5, STATUS_HEIGHT)];
    self.bucketView = [[UIView alloc] initWithFrame:CGRectMake(0,STATUS_HEIGHT,self.frame.size.width,self.frame.size.height - STATUS_HEIGHT)];
    
    [self.statusView addSubview:self.activityIndicator];
    [self.statusView addSubview:self.statusLabel];
    [self addSubview:self.statusView];
    [self addSubview:self.bucketView];
    
    //Customize Look and Feel
    self.backgroundColor = [UIColor clearColor];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.style = LABEL_STYLE_SMALL;
    self.statusLabel.alpha = 0.0;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.alpha = 0.0;
    self.activityIndicator.color = TINT_BASE;
    
    [self retrieveBuckets];
}
#pragma mark - IBActions
-(IBAction)locationSelected:(id)sender
{
    int index = [sender tag];
    [self selectLocationAtIndex:index];
}
#pragma mark - Private methods
-(void)retrieveBuckets
{
    //Retrieve current bucket
    SPBucket* currentBucket = [[SPProfileManager sharedInstance] myBucket];
    if(currentBucket)
    {
        [self displayCurrentBucket:currentBucket];
    }
    
    //Retrieve buckets
    
    
    //Display and fade in status
    [self.activityIndicator startAnimating];
    self.statusLabel.text = @"Finding nearby locations...";
    [UIView animateWithDuration:0.5 animations:^{
        self.activityIndicator.alpha = 1.0;
        self.statusLabel.alpha = 1.0;
    }];

    __unsafe_unretained SPLocationChooser* weakSelf = self;
    [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
     {
         [weakSelf.buckets addObjectsFromArray:buckets];
         [weakSelf displayBuckets];
         
     } andErrorHandler:^
     {
         [weakSelf.activityIndicator stopAnimating];
     }];
}
-(void)displayCurrentBucket:(SPBucket*)currentBucket
{
    [self.buckets addObject:currentBucket];
    [self.bucketView addSubview: [self buttonForLocation:currentBucket atIndex:0]];
    [self displaySelectedAtIndex:0];
    bucketDisplayIndex++;
}
-(void)displayBuckets
{
    //Stop the activity animation - move bucket content up
    [self.activityIndicator stopAnimating];
    self.statusLabel.text = @"";
    
    [UIView animateWithDuration:1.0 animations:^{
        self.bucketView.top = 0;
    }];
    
    SPBucket* currentBucket = [[SPProfileManager sharedInstance] myBucket];
    SPBucket* bucketToRemove = nil; //We may have already displayed a currently set bucket at index 0
                                    // If this is the case, and we retrieve the same bucket again, we'll remove it from the array
    
        //Adds buttons representing the 4 closest buckets
    for(int bucketIndex = bucketDisplayIndex; bucketIndex < self.buckets.count; bucketIndex++) {
        
            //Only display the first 4
        if(bucketIndex >= 5) break;
        
        SPBucket* bucket = [self.buckets objectAtIndex:bucketIndex];
        if(currentBucket && [currentBucket.identifier isEqualToString:bucket.identifier])
        {
                //This is the currently chosen location, should be removed from the results, and not displayed
            bucketToRemove = bucket;
        }
        else
        {
                //Must be added in this order
            [self.bucketView addSubview: [self buttonForLocation:bucket atIndex:bucketDisplayIndex]];
            bucketDisplayIndex++;
        }
        
    }
    
        // Triggered if we retrieved the currently set bucket (which would already be stored in self.buckets)
    if(bucketToRemove)
    {
        [self.buckets removeObject:bucketToRemove];
    }
}
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
    buttonLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"I live in", nil),locationName];
    [self.buttonTitles addObject:buttonLabel];
    
    //Right Checkmark (selection indicator)
    UIImageView* selectionIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width, 0, 10,button.height)];
    selectionIndicatorView.hidden = YES;
    selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    selectionIndicatorView.image = [UIImage imageNamed:@"Checkmark.png"];
    [self.selectionIndicators addObject:selectionIndicatorView];
    
    if(self.chosenBucket != bucket)
    {
        iconView.selected = NO;
        buttonLabel.alpha = 0.5;
    }
    
    [view addSubview:card];
    [view addSubview:button];
    [view addSubview:iconView];
    [view addSubview:buttonLabel];
    [view addSubview:selectionIndicatorView];
    
    return view;
}
-(void)selectLocationAtIndex:(int)index
{
    [Crashlytics setObjectValue:@"Clicked on a 'Bucket' button in a Location Chooser view." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [self displaySelectedAtIndex:index];
    
    self.chosenBucket = [self.buckets objectAtIndex:index];
    
    if(self.delegate)
    {
        [self.delegate locationChooserSelectionChanged:self];
    }
}
-(void)displaySelectedAtIndex:(int)index
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
}
@end
