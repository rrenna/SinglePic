//
//  SPBrowseScreenController.m
//  pickMeApp
//
//  Created by Ryan Renna on 11-11-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SPBrowseViewController.h"
#import "ColorGrid.h"
#import "SPProfileIconController.h"
#import "SPProfileViewController.h"
#import "SPBlockView.h"
#import <Box2D/Box2D.h> //Must be included AFTER MKMapKit or anything that includes MKMapKit
#import <typeinfo>

#define REFRESH_HEADER_HEIGHT 8.0f //52.0f
#define BROWSE_ROW_LIMIT 5
#define BROWSE_ROW_LIMIT_TALL 6
#define BROWSE_COLUMN_AMOUNT 3
#define PTM_RATIO 16
#define TICK (0.016666666) // same as (1.0f/60.0f)

//Box2D
struct b2World;
struct b2Body;
static b2PrismaticJointDef shaftJoint;

@interface SPBrowseViewController()
{
    UIView *refreshHeaderView;
    UIImageView *refreshArrow;
    UIView*  nextHeaderView;
    UILabel* nextLabel;
    ColorGrid *colorGrid;
    
    BOOL isDragging;
    BOOL isLoading;
    BOOL isDroping;
    __block BOOL isRestarting;
    NSTimer *dropTimer;
    NSMutableArray* queuedSelectorCalls;
    
    //Stack Management
    BOOL stackPaused[3];
    
    //Box2D
    struct b2World* world;
    struct b2Body* groundBody;
    b2Body *barrierBody;
    
}
@property (retain) NSArray* stacks;
@property (retain) NSMutableArray* profileControllers;
@property (retain) CADisplayLink* tickDisplayLink;

-(void)createPhysicsWorld;
-(void)createPhysicalBarrier;
-(void)destroyPhysicalBarrier;
-(void)addPullToNextHeader;
-(void)beginDropSchedule;
-(void)dropAllOnscreenBlocks;
-(void)pauseAllStacks;
-(void)pauseStack:(int)stackIndex;
-(BOOL)isStackPaused:(int)stackIndex;
-(void)resumeAllStacks;
-(void)resumeStack:(int)stackIndex;
-(void)destroyBlockView:(SPBlockView*)blockView;
-(void)addBodyForBoxView:(SPBlockView *)blockView;
-(void)initializeBodyForBoxView:(SPBlockView *)blockView;
-(void)removeProfileByID:(NSString*)profileID;
-(int)currentTickCount;
-(int)tickCountWithOffset:(int)offset;
-(void)increaseCurrentTickCount;
-(void)tick:(NSTimer *)timer;
-(void)drop:(NSTimer *)timer;
-(void)performSelector:(SEL)aSelector afterTicks:(int)ticks;

@end

@implementation SPBrowseViewController
@synthesize stacks = _stacks, profileControllers, tickDisplayLink = _tickDisplayLink; //Private

-(id)init
{
    self = [self initWithNibName:@"SPBrowseViewController" bundle:nil];
    if(self)
    {
        self.profileControllers = [NSMutableArray array];
        queuedSelectorCalls = [NSMutableArray new];
        self.stacks = @[ [NSMutableArray array],[NSMutableArray array],[NSMutableArray array] ];
        stackPaused[0] = NO; stackPaused[1] = NO; stackPaused[2] = NO;
        isDroping = NO;
        isDragging = NO;
        isLoading = NO;
        
        //We don't have to listen for this notification if this is an annonyous user
        if([[SPProfileManager sharedInstance] myUserType] != USER_TYPE_ANNONYMOUS)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart:) name:NOTIFICATION_MY_GENDER_CHANGED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart:) name:NOTIFICATION_MY_PREFERENCE_CHANGED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart:) name:NOTIFICATION_MY_BUCKET_CHANGED object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProfileByID:) name:NOTIFICATION_BLOCKED_PROFILE object:nil];
        }
    }
    return self;
}
-(void)viewDidLoad
{
    //Sets up the browse screen's physics engine
    [self setup];
    //Set up 'pull to next' header
    [self addPullToNextHeader];
    //Sets the controller to visible, can later be paused to reduce computational load
    [self visible];
}
-(void)viewDidAppear:(BOOL)animated
{
    //Calculates the scrollView's content size after resizing (depending on screen resolution)
    CGSize scrollContentSize = scrollView.frame.size;
    scrollView.contentSize = scrollContentSize;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [profileControllers release];
    [queuedSelectorCalls release];
    
    [_tickDisplayLink invalidate];
    [dropTimer invalidate];
    
    [_tickDisplayLink release];
    [dropTimer release];
    
    delete world;
    
    [super dealloc];
}
-(void)setup
{
    [self createPhysicsWorld];
    [self createPhysicalBarrier];
    
    self.tickDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_tickDisplayLink setFrameInterval:1];
    [_tickDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if(![dropTimer isValid])
    {
        const float delay = 0.8; //Start the browsing experience
        
        __unsafe_unretained SPBrowseViewController* weakSelf = self;
        [[SPProfileManager sharedInstance] retrieveProfilesWithCompletionHandler:^(NSArray *profiles)
         {
             dropTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:weakSelf selector:@selector(drop:) userInfo:nil repeats:YES];
         } 
         andErrorHandler:^
         {
             dropTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:weakSelf selector:@selector(drop:) userInfo:nil repeats:YES];
         }];
    }
}
-(void)visible
{
    //TODO: Improve resume functionality
}
#pragma mark - IBActions
-(IBAction)restart:(id)sender
{
    if(!isRestarting)
    {
        [Crashlytics setObjectValue:@"Pulled Browse screen down for more profiles - restarting." forKey:@"last_UI_action"];
        
        isRestarting = YES;
        
        //Pause any further additional blocks from being dropped
        [self pauseAllStacks];
        
        //If there are any remaining profiles in the browse screen, release them now
        [self dropAllOnscreenBlocks];
        
        __unsafe_unretained SPBrowseViewController* weakSelf = self;
        [[SPProfileManager sharedInstance] retrieveProfilesWithCompletionHandler:^(NSArray *profiles)
         {
             //Resume dropping
             [self resumeAllStacks];
             
             //Currently used to stop infinite restart loops
             if([profiles count] > 0)
             {
                 [[SPProfileManager sharedInstance] restartProfiles];
                 [weakSelf next:nil];
             }
             else
             {
                 [self dropAllOnscreenBlocks];
             }
             
             isRestarting = NO;
         }
         andErrorHandler:^
         {
             //Resume dropping
             [self resumeAllStacks];
             
             isRestarting = NO;
         }];
    }
}

-(IBAction)next:(id)sender
{
    #if defined (BETA)
    [TestFlight passCheckpoint:@"Pulled Browse screen down for more profiles."];
    #endif
    
    [Crashlytics setObjectValue:@"Pulled Browse screen down for more profiles." forKey:@"last_UI_action"];
    
    
    [SPSoundHelper playTap];
    
    [UIView animateWithDuration:0.5 animations:^
    {
            browseInstructionsLabel.alpha = 0.0;
    }];

   //No more profiles
   if([[SPProfileManager sharedInstance] remainingProfiles] == 0)
   {
       [self restart:nil];
   }
   else
   {
       [self dropAllOnscreenBlocks];
   }
}
#pragma mark - SPBlockViewDelegate methods
-(void)blockViewWasSelected : (SPBlockView*) blockView
{
    [SPSoundHelper playTap];
    
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        [Crashlytics setObjectValue:@"Selected Profile block in Browse screen (but is not signed in)" forKey:@"last_UI_action"];
    }
    else
    {
        #if defined (BETA)
        [TestFlight passCheckpoint:@"Viewed a profile"];
        #endif
        
        [Crashlytics setObjectValue:@"Selected Profile block in Browse screen" forKey:@"last_UI_action"];
        
        SPProfileViewController* profileController = [[[SPProfileViewController alloc] initWithProfile:blockView.data] autorelease];
        [self pushModalController:profileController];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BROWSE_SCREEN_PROFILE_SELECTED object:self];
}
#pragma mark - Overriden methods
-(void)willClose
{
    //Suspends the main timer
    [_tickDisplayLink invalidate]; self.tickDisplayLink = nil;
    //Suspends the drop timer
    [dropTimer invalidate]; dropTimer = nil;
    
    [super willClose];
}
#pragma mark - Private methods
-(void)createPhysicsWorld
{
	CGSize screenSize = canvasView.bounds.size;
    
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -15.0f);//-30.0f);
    
    
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(gravity);
    // This will speed up the physics simulation
    world->SetAllowSleeping(true);
	world->SetContinuousPhysics(false);
    world->SetWarmStarting(true);
    
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
    
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
    
	// Define the ground box shape.
    b2EdgeShape groundBox;
    
	// bottom
	groundBox.Set(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox, 0);
    
	// top
	groundBox.Set(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox, 0);
    
	// left
	groundBox.Set(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox, 0);
    
	// right
	groundBox.Set(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox, 0);
}
-(void)createPhysicalBarrier
{
    //Ensure there's no physical barrier already created
    [self destroyPhysicalBarrier];
    
    // Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
    CGPoint barrierCenter = CGPointMake(135.0f, 436.5f);
    CGSize barrierSize = CGSizeMake(150.0f/PTM_RATIO/2.0, 1.0/PTM_RATIO/2.0);
    
	bodyDef.position.Set(barrierCenter.x/PTM_RATIO, (canvasView.frame.size.height - barrierCenter.y)/PTM_RATIO);
    
    // Tell the physics world to create the body
	barrierBody = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
    
	dynamicBox.SetAsBox(barrierSize.width, barrierSize.height);
    
    // Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 20000.0f;
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.05f; // 0 is a lead ball, 1 is a super bouncy ball
	barrierBody->CreateFixture(&fixtureDef);
}
-(void)destroyPhysicalBarrier
{
    if(barrierBody)
    {
        world->DestroyBody(barrierBody);
        barrierBody = nil;//Zero out the pointer so the view can never be re-removed
    }
}
-(void)addPullToNextHeader
{  
        // Load color settings
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Colors"
                                                                 ofType:@"plist"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        
        // Grab an array of predefined colors
        NSArray *colors = [settings objectForKey:@"Colors"];
        
        refreshHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)] autorelease];
        refreshHeaderView.backgroundColor = [UIColor clearColor];
        
        // Create the loading color grid
        colorGrid = [[[ColorGrid alloc] initWithFrame:CGRectMake(0, 0 - ROWS * CELL_DIMENSION, COLUMNS * CELL_DIMENSION, ROWS * CELL_DIMENSION) colors:colors] autorelease];
        
        refreshArrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]] autorelease];
        refreshArrow.frame = CGRectMake(floorf((COLUMNS * CELL_DIMENSION - 21.5) / 2),
                                        floorf(REFRESH_HEADER_HEIGHT - 31),
                                        21.5, 21);
        
        [refreshHeaderView addSubview:refreshArrow];
        [scrollView addSubview:colorGrid];
        [scrollView addSubview:refreshHeaderView];
}
-(void)beginDropSchedule
{    
    [profileControllers removeAllObjects];
    [self resumeAllStacks];
}
-(void)dropAllOnscreenBlocks
{
    //Destroys the Box2D Body of the bottom view, which represent the shape keeping the profile blocks from falling
    [self destroyPhysicalBarrier];
    
    if([[SPProfileManager sharedInstance] remainingProfiles] > 0)
    {
        //Fade out & destroy all blocks
        float delay = 2.0;
        
        for(NSMutableArray* stack in self.stacks)
        {
            for(SPBlockView* blockView in stack)
            {
                if([blockView isKindOfClass:[SPBlockView class]])
                {
                    __unsafe_unretained SPBrowseViewController* weakSelf = self;
                    [UIView animateWithDuration:0.5 delay:delay options:nil animations:^{
                        
                        blockView.alpha = 0.0;
                        
                    } completion:^(BOOL finished) {
                        
                        [weakSelf destroyBlockView:blockView];
                    }];
                    
                    delay -= 0.02;
                }
            }
            
            [stack removeAllObjects]; //Must be done after iteration
        }
        
        //Pause the block dropping
        [self pauseAllStacks];
        [self performSelector:@selector(beginDropSchedule) afterTicks:4500 * TICK];
    }
    
        //[self performSelector:@selector(stopLoading) afterTicks:6250 * TICK];
    [self performSelector:@selector(createPhysicalBarrier) afterTicks:7380 * TICK];
}
-(void)pauseAllStacks
{
    stackPaused[0] = YES;
    stackPaused[1] = YES;
    stackPaused[2] = YES;
}
-(void)pauseStack:(int)stackIndex
{
    stackPaused[stackIndex] = YES;
}
-(BOOL)isStackPaused:(int)stackIndex
{
    return stackPaused[stackIndex];
}
-(void)resumeStack:(int)stackIndex
{
    stackPaused[stackIndex] = NO;
}
-(void)resumeAllStacks
{
    stackPaused[0] = NO;
    stackPaused[1] = NO;
    stackPaused[2] = NO;
}
-(void)destroyBlockView:(SPBlockView*)blockView
{
    b2Body *body = (b2Body*)[blockView tag];
    
    if((int)[blockView tag] > 0 && body)
    {
        // Used the C++ Dynamic cast to ensure that the provided body is indeed an instance of b2Body, if so the result will be
        // another pointer to the same b2Body, which can be destroyed by world successfully
        b2Body *bodyCast = dynamic_cast<b2Body *>(body);
        
        if(bodyCast)
        {
            world->DestroyBody(body);
            blockView.tag = -1;
            [blockView removeFromSuperview];
        }
    }
}
-(void)addBodyForBoxView:(SPBlockView *)blockView
{
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	CGPoint p = blockView.center;
	CGPoint boxDimensions = CGPointMake(blockView.bounds.size.width/PTM_RATIO/2.0,blockView.bounds.size.height/PTM_RATIO/2.0);
    
	bodyDef.position.Set(p.x/PTM_RATIO, (canvasView.frame.size.height - p.y)/PTM_RATIO);
	bodyDef.userData = blockView;
    
	// Tell the physics world to create the body
	b2Body *body = world->CreateBody(&bodyDef);
    
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
    
	dynamicBox.SetAsBox(boxDimensions.x, boxDimensions.y);
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.05f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.125; // 0 is a lead ball, 1 is a super bouncy ball
	body->CreateFixture(&fixtureDef);

    // a dynamic body reacts to forces right away
	body->SetType(b2_dynamicBody);
    
	// we abuse the tag property as pointer to the physical body
	blockView.tag = (int)body;
}
-(void)initializeBodyForBoxView:(SPBlockView *)blockView
{
    if([blockView tag] == -1)
    {
        // If the blockView has it's tag set to -1, then it's b2Body was destroyed before it was initialized. During destruction
        // it's tag was reset to -1.
    }
    else
    {
        b2Body* body = (b2Body*)[blockView tag];
        shaftJoint.Initialize(groundBody, body, b2Vec2(0.0f, 17.0f), b2Vec2(0.0f, 1.0f));
        blockView.joint = (b2PrismaticJoint*)world->CreateJoint(&shaftJoint);

    }
}
int currentTick = 0;
-(int)currentTickCount
{
    return currentTick;
}
-(int)tickCountWithOffset:(int)offset
{
    if((INT_MAX - currentTick) < offset)
    {
        return offset - (INT_MAX - currentTick);
    }
    else
    {
        return currentTick + offset;
    }
}
-(void)increaseCurrentTickCount
{
    if(currentTick == INT_MAX)
    {
        currentTick = 0;
    }
    else
    {
        currentTick++;
    }
}
-(void)tick:(NSTimer *)timer
{
    NSMutableArray* selectorsToPerform = nil;
    //Flag actions to be performed, or reduce their tick count
    for(_SPBrowseViewQueuedSelectorCall* queuedSelectorCall in queuedSelectorCalls) {
        
        if([self currentTickCount] == queuedSelectorCall.ticks) {
            
            //Add entry to deletion array
            if(!selectorsToPerform) { selectorsToPerform = [NSMutableArray arrayWithObject:queuedSelectorCall]; }
            else { [selectorsToPerform addObject:queuedSelectorCall]; }
        }
    }
    //Perform actions
    for(_SPBrowseViewQueuedSelectorCall* queuedSelectorCall in selectorsToPerform)
    {
        [self performSelector: queuedSelectorCall.selector];
    }
    //Delete performed actions
    if(selectorsToPerform)
    {
        [queuedSelectorCalls removeObjectsInArray:selectorsToPerform];
    }
    
    [self increaseCurrentTickCount];
    
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
    int32 velocityIterations = 4;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(TICK, velocityIterations, positionIterations);
    
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        b2Vec2 linearVelocity = b->GetLinearVelocity();
        
        //Prevent view modification if no vertical change will be made - UIView optmization (I hope)
        if(linearVelocity.y == 0)
        {
            //Do nothing
        }
        else
        {
            void* userData = b->GetUserData();
            if (userData != NULL)
            {
                b2Vec2 position = b->GetPosition();
                
                UIView *oneView = (UIView *)userData;
                
                // y Position subtracted because of flipped coordinate system
                CGPoint newCenter = CGPointMake(position.x * PTM_RATIO,
                                                canvasView.bounds.size.height - position.y * PTM_RATIO);
                oneView.center = newCenter;
                
                //CGAffineTransform transform = CGAffineTransformMakeRotation(- b->GetAngle());
                //oneView.transform = transform;
            }
        }
	}
}
-(void)removeProfileByID:(NSString*)profileID
{
    /*
     [UIView beginAnimations:nil context:context];
     [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:socialButton cache:NO];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
     [UIView setAnimationDuration:duration];
     [UIView commitAnimations];
     */
    /*
     b2Body *body = (b2Body*)[boxView tag];
     world->DestroyBody(body);
     stackCount[boxView.column]--;
     [boxView removeFromSuperview];
     */
}
-(void)drop:(NSTimer *)timer
{
    static const int padding = 5;
    static const int rowLimit = (self.view.height >  460 ) ? BROWSE_ROW_LIMIT_TALL : BROWSE_ROW_LIMIT;
    
    //Interate over each column
    for(int columnIndex = 0; columnIndex < BROWSE_COLUMN_AMOUNT; columnIndex++)
    {
        if(![self isStackPaused:columnIndex])
        {
            //Drop a profile box if this stack isn't paused
            NSMutableArray* stack = [self.stacks objectAtIndex:columnIndex];
            if([stack count] < rowLimit)
            {
                SPProfile* profile = [[SPProfileManager sharedInstance] nextProfile];
   
                if(profile)
                {
                    int boxDimension = (int)(canvasView.frame.size.width / 3.0) - padding;
                    CGRect frame = CGRectMake(boxDimension * columnIndex + (padding * columnIndex), - 150, boxDimension, boxDimension);
                    
                    SPBlockView* blockView = [[[SPBlockView alloc] initWithFrame:frame] autorelease];
                    blockView.delegate = self;
                    blockView.column = columnIndex;
                    
                    SPProfileIconController* profileIcon = [[[SPProfileIconController alloc] initWithProfile:profile] autorelease];
                    [self.profileControllers addObject:profileIcon];
                    //Pauses the stack until the next profile's thumbnail has downloaded (or failed)
                    [self pauseStack:columnIndex];
                    
                    blockView.data = profile;
                    [blockView setController:profileIcon];
                    
                    [stack addObject:blockView];
                    
                    [self addBodyForBoxView:blockView];
                    
                    __unsafe_unretained SPBrowseViewController* weakSelf = self;
                    id block_proceed = ^(UIImage *thumbnail)
                    {
                        [self initializeBodyForBoxView:blockView];
                        [canvasView addSubview:blockView];
                        [canvasView sendSubviewToBack:blockView];
                        [weakSelf resumeStack:columnIndex];
                    };
                    id block_error = ^()
                    {
                        [self initializeBodyForBoxView:blockView];
                        [canvasView addSubview:blockView];
                        [canvasView sendSubviewToBack:blockView];
                        [weakSelf resumeStack:columnIndex];
                    };
                    
                    [[SPProfileManager sharedInstance] retrieveProfileThumbnail:profile withCompletionHandler:block_proceed andErrorHandler:block_error];
                    
                }
            }
            
            //No more contacts - dismiss loading bar
            if(isLoading && [[SPProfileManager sharedInstance] remainingProfiles] > 0)
            {
                [self stopLoading];
            }
        }
    }
}
-(void)performSelector:(SEL)aSelector afterTicks:(int)ticks
{
    int scheduledTick = [self tickCountWithOffset:ticks];
    
    _SPBrowseViewQueuedSelectorCall* queuedSelectorCall = [[_SPBrowseViewQueuedSelectorCall new] autorelease];
    queuedSelectorCall.selector = aSelector;
    queuedSelectorCall.ticks = scheduledTick;
    
    [queuedSelectorCalls addObject:queuedSelectorCall];
}
- (void)startLoading 
{
    isLoading = YES;
    
    // Show the header and animate the loading color grid
    [colorGrid drawGrid];
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3];
    scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshArrow.hidden = YES;
    
    [UIView commitAnimations];
    
    // Next action
    [self next:nil];
}
- (void)stopLoading
{
    isLoading = NO;
    
    [colorGrid drawRow];
    
    //Re-display helper text
    [UIView animateWithDuration:0.5 animations:^
     {
         browseInstructionsLabel.alpha = 1.0;
     }];
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    scrollView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets scrollViewContentInset = scrollView.contentInset;
    scrollViewContentInset.top = 1.0;
    scrollView.contentInset = scrollViewContentInset;
    [UIView commitAnimations];
}
- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    // Reset the header
    nextLabel.text = @"";
}
#pragma mark - UIScrollView delegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (isLoading) {
            // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
            // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
    
    /*if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            nextLabel.text = @"Release for more...";//self.textRelease;
            [nextArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            nextLabel.text = @"Keep pulling for more...";//self.textPull;
            [nextArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }*/
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}
@end

@implementation _SPBrowseViewQueuedSelectorCall
@synthesize ticks,selector;
@end
