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
    CLLocation* userLocation;
}
@property (strong) NSMutableArray* buckets;
@property (strong,readwrite) SPBucket* chosenBucket;
@property (strong) UIView* bucketView;
@property (strong) NSMutableArray* selectionIndicators;
@property (strong) NSMutableArray* distanceLabels;
@property (strong) NSMutableArray* buttonTitles;
@property (strong) NSMutableArray* buttonIcons;
@property (strong) UIView* statusView;
@property (strong) UIActivityIndicatorView* activityIndicator;
@property (strong) SPLabel* statusLabel;

-(void)_init;
-(void)retrieveLocation;
-(void)retrieveBuckets;
-(void)displayCurrentBucket:(SPBucket*)currentBucket;
-(void)displayBuckets;
-(void)sortAndFilterBuckets;
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index;
-(void)selectLocationAtIndex:(int)index;
-(void)displaySelectedAtIndex:(int)index;
@end

@implementation SPLocationChooser

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _init];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _init];
    }
    return self;
}
#define STATUS_HEIGHT 30
-(void)_init
{
    self.buckets = [NSMutableArray array];
    self.autoresizesSubviews = NO;
    self.selectionIndicators = [NSMutableArray array];
    self.buttonTitles = [NSMutableArray array];
    self.distanceLabels = [NSMutableArray array];
    self.buttonIcons = [NSMutableArray array];
    _bucketsToDisplay = 4;
    bucketDisplayIndex = 0;
    userLocation = nil;
    
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
    
    //Retrieve current bucket
    SPBucket* currentBucket = [[SPProfileManager sharedInstance] myBucket];
    if(currentBucket)
    {
        [self displayCurrentBucket:currentBucket];
    }
    
    [self retrieveLocation];
}
#pragma mark - IBActions
-(IBAction)locationSelected:(id)sender
{
    int index = [sender tag];
    [self selectLocationAtIndex:index];
}
#pragma mark - Private methods
-(void)retrieveLocation
{
    //
    [[SPLocationManager sharedInstance] getLocation];
    
    //Retrieve location
    if([[SPLocationManager sharedInstance] locationAvaliable])
    {
        //Display and fade in status
        [self.activityIndicator startAnimating];
        self.statusLabel.text = @"Finding your location...";
        [UIView animateWithDuration:0.5 animations:^{
            self.activityIndicator.alpha = 1.0;
            self.statusLabel.alpha = 1.0;
        }];
        
        [[SPLocationManager sharedInstance] waitOnLocationWithCompletion:^(CLLocation* location)
        {
            userLocation = location;
            [self retrieveBuckets];
        }
        andError:^
        {
            // Location couldn't be found - or not allowed
            [self retrieveBuckets];
        }];
    }
    else
    {
        [self retrieveBuckets];
    }
}
-(void)retrieveBuckets
{
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
         
         [weakSelf sortAndFilterBuckets];
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
-(void)sortAndFilterBuckets
{
    /* Step 1 Remove instance of CurrentBucket from Array */
    
    SPBucket* currentBucket = [[SPProfileManager sharedInstance] myBucket];
    if(currentBucket)
    {
        [self.buckets removeObject:currentBucket];
    }
    
    /* Step 2 Remove duplicate of Current Bucket */
    
    SPBucket* bucketToRemove = nil; //We may have already displayed a currently set bucket at index 0
                                    // If this is the case, and we retrieve the same bucket again, we'll remove it from the array
    for(SPBucket* bucket in self.buckets)
    {
        if(currentBucket && [currentBucket.identifier isEqualToString:bucket.identifier])
        {
            bucketToRemove = bucket;
            break;
        }
    }
        //Remove a duplicate of the current bucket retrieved from the server
    if(bucketToRemove)
    {
        [self.buckets removeObject:bucketToRemove];
    }
    
    /* Step 3 Sort by GPS Location */
    
    if(userLocation) //If we have a user location, sort buckets by that location
    {
        [self.buckets sortUsingComparator:^NSComparisonResult(SPBucket* bucket1, SPBucket* bucket2) {
            
            CLLocation* bucket1Location = [[CLLocation alloc] initWithLatitude:bucket1.coordinate.latitude longitude:bucket1.coordinate.longitude];
            CLLocation* bucket2Location = [[CLLocation alloc] initWithLatitude:bucket2.coordinate.latitude longitude:bucket2.coordinate.longitude];
            
            CLLocationDistance bucket1Distance = [userLocation distanceFromLocation:bucket1Location];
            CLLocationDistance bucket2Distance = [userLocation distanceFromLocation:bucket2Location];
            
            return (bucket1Distance < bucket2Distance) ? NSOrderedAscending : NSOrderedDescending;
        }];
    }
    else
    {
        // If we don't have a user location set, we can sort by the current bucket (if set)
        // This way, user's who want to change buckets will only see buckets (presumeably) around them
        if(currentBucket)
        {
            [self.buckets sortUsingComparator:^NSComparisonResult(SPBucket* bucket1, SPBucket* bucket2) {
                
                CLLocation* currentBucketLocation = [[CLLocation alloc] initWithLatitude:currentBucket.coordinate.latitude longitude:currentBucket.coordinate.longitude];
                
                CLLocation* bucket1Location = [[CLLocation alloc] initWithLatitude:bucket1.coordinate.latitude longitude:bucket1.coordinate.longitude];
                CLLocation* bucket2Location = [[CLLocation alloc] initWithLatitude:bucket2.coordinate.latitude longitude:bucket2.coordinate.longitude];
                
                CLLocationDistance bucket1Distance = [currentBucketLocation distanceFromLocation:bucket1Location];
                CLLocationDistance bucket2Distance = [currentBucketLocation distanceFromLocation:bucket2Location];
                
                return (bucket1Distance < bucket2Distance) ? NSOrderedAscending : NSOrderedDescending;
            }];
        }
    }

    /* Step 4 Re-insert current bucket at the top */
    
    if(currentBucket)
    {
        [self.buckets insertObject:currentBucket atIndex:0];
    }
}
-(void)displayBuckets
{
    //Stop the activity animation - move bucket content up
    [self.activityIndicator stopAnimating];
    self.statusLabel.text = @"";
    
    [UIView animateWithDuration:1.0 animations:^{
        self.bucketView.top = 0;
        self.bucketView.height += STATUS_HEIGHT;
    }];
    
        //Adds buttons representing the closest buckets
    for(int bucketIndex = bucketDisplayIndex; bucketIndex < self.buckets.count; bucketIndex++) {
        
        //Only display the first X buckets
        if(bucketIndex >= _bucketsToDisplay) break;
        
        //Must be added in this order
        SPBucket* bucket = [self.buckets objectAtIndex:bucketIndex];
        [self.bucketView addSubview: [self buttonForLocation:bucket atIndex:bucketDisplayIndex]];
        bucketDisplayIndex++;
    }
    
    
    if(self.autoselectFirstBucket == YES)
    {
        // Select the first closest bucket
        [self displaySelectedAtIndex:0];
        
        self.chosenBucket = [self.buckets objectAtIndex:0];
        
        if(self.delegate)
        {
            [self.delegate locationChooserSelectionChanged:self];
        }
    }

}
#define ICON_DIMENSION 20
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index
{
    int buttonY = (self.frame.size.height/_bucketsToDisplay * index);
    int avaliableHeight = self.frame.size.height;
    int buttonHeight = (avaliableHeight /_bucketsToDisplay ) - 5;
    int iconDimension = (self.frame.size.height/_bucketsToDisplay ) * 0.4;
    
    int iconY = (buttonHeight - iconDimension) / 2;
    CGRect frame = CGRectMake(0, floor(buttonY), floor(self.frame.size.width),floor(buttonHeight));
    CGRect iconFrame = CGRectMake(iconDimension / 2,iconY, iconDimension, iconDimension);
    
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
    SPLabel* buttonLabel = [[SPLabel alloc] initWithFrame:CGRectMake(floor(iconView.width + iconView.left),floor(iconView.top),floor(-iconView.left - iconView.width + button.width - iconView.width - 32),floor(iconView.height))];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:11];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    buttonLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"I live in", nil),locationName];
    [self.buttonTitles addObject:buttonLabel];
    
    //Right Checkmark (selection indicator)
    UIImageView* selectionIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width + 25, 0, 10,button.height)];
    selectionIndicatorView.hidden = YES;
    selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    selectionIndicatorView.image = [UIImage imageNamed:@"Checkmark.png"];
    [self.selectionIndicators addObject:selectionIndicatorView];
    
    //Right Distance Label
    SPLabel* distanceLabel = [[SPLabel alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width - 2,0,45,button.height)];
    distanceLabel.textAlignment = UITextAlignmentRight;
    distanceLabel.textColor = [UIColor darkGrayColor];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.style = LABEL_STYLE_EXTRA_SMALL;
    [self.distanceLabels addObject:distanceLabel];
    
    if(userLocation)
    {
        CLLocation* bucketLocation = [[CLLocation alloc] initWithLatitude:bucket.coordinate.latitude longitude:bucket.coordinate.longitude];
        CLLocationDistance distanceInMeters = [userLocation distanceFromLocation:bucketLocation];
        double distanceInKilometers = distanceInMeters / 1000.0;
        distanceLabel.text = [NSString stringWithFormat:@"%.0f km",distanceInKilometers];
    }
    
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
    [view addSubview:distanceLabel];
    
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
        UILabel* distanceLabel = [self.distanceLabels objectAtIndex:i];
        
        if(i == index)
        {
            selectionIndicator.hidden = NO;
            iconView.selected = YES;
            buttonLabel.alpha = 1.0;
            distanceLabel.alpha = 0.0;
        }
        else
        {
            selectionIndicator.hidden = YES;
            iconView.selected = NO;
            buttonLabel.alpha = 0.5;
            distanceLabel.alpha = 1.0;
        }
    }
}
@end
