//
//  SPAAppDelegate.m
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import "SPAAppDelegate.h"
#import "SPErrorNotifier.h"


@interface SPAAppDelegate()
@property (strong) NSArray* buckets;
@property (strong) NSMutableDictionary* accounts;

-(void)retrieveAllBuckets;
-(void)retrieveAccounts;
-(void)logoutOfActiveAccount;
-(void)saveAccounts;
-(NSString*)randomStringOfLength:(int)length;
@end

@implementation SPAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[SPRequestManager sharedInstance] EnableRealtimeReachabilityMonitoring];
    [[SPErrorManager sharedInstance] setErrorNotifierController:[SPErrorNotifier new]];
    
    [self retrieveAllBuckets];
    [self retrieveAccounts];
}
- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - IBActions
- (IBAction)createNewUser:(id)sender
{
    NSString* email = [self.createNewUserEmail stringValue];
    NSString* userName = [self.createNewUserUsername stringValue];
    NSString* password = [self.createNewUserPassword stringValue];
    GENDER gender = ([self.createNewUserGenderPreferenceSegmentedControl selectedSegment] <= 1) ? GENDER_MALE : GENDER_FEMALE;
    GENDER preference = ([self.createNewUserGenderPreferenceSegmentedControl selectedSegment] % 2 == 0) ? GENDER_MALE : GENDER_FEMALE;
    NSInteger bucketIndex = [self.createNewUserBucketPicker indexOfSelectedItem];
    SPBucket* bucket = [self.buckets objectAtIndex:bucketIndex];
    
    if([userName length] < MINIMUM_USERNAME_LENGTH)
    {
        [self.createNewUserErrorLabel setStringValue:@"Username is too short"];
        return;
    }
    if([password length] < MINIMUM_PASSWORD_LENGTH)
    {
        [self.createNewUserErrorLabel setStringValue:@"Password is too short"];
        return;
    }
    if([email length] < MINIMUM_EMAIL_LENGTH)
    {
        [self.createNewUserErrorLabel setStringValue:@"Email is too short"];
        return;
    }
    
    //Can not create new accounts if logged into another one
    [self logoutOfActiveAccount];
    
    [self.createNewUserProgressIndicator startAnimation:nil];
    
    [[SPProfileManager sharedInstance] registerWithEmail:email andUserName:userName andPassword:password andGender:gender andPreference:preference andBucket:bucket andCompletionHandler:^(id responseObject) {
        
        //Store account
        NSDictionary* accountDictionary = @{@"email":email,@"password":password,@"gender":GENDER_NAMES[gender],@"preference":GENDER_NAMES[preference],@"bucketID":bucket.identifier};
        
        [self.accounts setObject:accountDictionary forKey:userName];
        [self saveAccounts];
        
        //Reset fields
        [self.createNewUserUsername setStringValue:@""];
        [self.createNewUserEmail setStringValue:@""];
        [self.createNewUserPassword setStringValue:@""];
        [self.createNewUserErrorLabel setStringValue:@""];
        [self.createNewUserProgressIndicator stopAnimation:@""];
        //Dismiss Panel
        [self.createNewUserPanel orderOut:nil];
        //The profile manager will automatically login to a newly registered account, this functionality is not required for this application
        [[SPProfileManager sharedInstance] logout];
        
        //Reload tableView
        [self.accountsTableView reloadData];
        
    } andErrorHandler:^{
        
        [self.createNewUserErrorLabel setStringValue:@"User couldn't be created..."];
        [self.createNewUserProgressIndicator stopAnimation:nil];
        
    }];
}
- (IBAction)createNewUserBucketPickerSelectionChanged:(id)sender
{
    NSMenuItem* item = [self.createNewUserBucketPicker selectedItem];
    [self.createNewUserBucketPicker setTitle:item.title];
}

- (IBAction)connectToAccount:(id)sender
{
    //Login
    if([[SPProfileManager sharedInstance] myUserType] == USER_TYPE_ANNONYMOUS)
    {
        NSInteger selectedRow = [self.accountsTableView selectedRow];
        NSString* username = [[self.accounts allKeys] objectAtIndex:selectedRow];
        NSDictionary* accountDictionary = [self.accounts objectForKey:username];
        NSString* email = [accountDictionary objectForKey:@"email"];
        NSString* password = [accountDictionary objectForKey:@"password"];
        
        [[SPProfileManager sharedInstance] loginWithEmail:email andPassword:password andCompletionHandler:^(id responseObject)
         {
             NSImage* profileImage = [[SPProfileManager sharedInstance] myImage];
             NSString* icebreaker = [[SPProfileManager sharedInstance] myIcebreaker];
             
             if(profileImage)
             {
                 [self.accountImageView setImage:profileImage];
             }
             
             //Disable interaction with the table
             [self.accountsTableView setEnabled:NO];
             self.accountBox.title = username;
             [self.accountIcebreakerTextField setStringValue:icebreaker];
             [self.accountImageView setEnabled:YES];
             [self.accountImageView setEditable:YES];
             [self.connectToAccountButton setTitle:@"Disconnect"];
             
         } andErrorHandler:^
         {
                 //
         }];
    }
    //Logout
    else
    {
        [self logoutOfActiveAccount];
    }
}
- (IBAction)removeAccount:(id)sender
{
    NSInteger selectedRow = [self.accountsTableView selectedRow];
    NSString* key = [[self.accounts allKeys] objectAtIndex:selectedRow];
    [self.accounts removeObjectForKey:key];
    
    [self saveAccounts];
    [self.accountsTableView reloadData];
    [self logoutOfActiveAccount];
}
- (IBAction)openCreateNewUserPanel:(id)sender
{
    [self.createNewUserBucketPicker removeAllItems];
    //Populate createNewUserBucketPicker with Buckets
    for(SPBucket* bucket in self.buckets)
    {
        [self.createNewUserBucketPicker addItemWithTitle:bucket.name];
    }
    [self.createNewUserBucketPicker synchronizeTitleAndSelectedItem];
    
    //Populate Password and Email with random characters
    NSString* email = [NSString stringWithFormat:@"%@@%@.%@",[self randomStringOfLength:4],[self randomStringOfLength:4],[self randomStringOfLength:3]];
    NSString* password = [self randomStringOfLength:MINIMUM_PASSWORD_LENGTH];
    
    [self.createNewUserEmail setStringValue:email];
    [self.createNewUserPassword setStringValue:password];
    
    [self.createNewUserPanel makeKeyAndOrderFront:nil];
}
- (IBAction)imageViewInteracted:(id)sender {
    
    NSImage* newImage = [self.accountImageView image];
    
    [[SPProfileManager sharedInstance] saveMyPicture:newImage withCompletionHandler:^(id responseObject)
    {
        
    } andProgressHandler:^(float progress)
    {

    } andErrorHandler:^
    {
        [self.accountImageView setImage:nil];
    }];
}
- (IBAction)saveIcebreaker:(id)sender {
    
    [[SPProfileManager sharedInstance] saveMyIcebreaker:[self.accountIcebreakerTextField stringValue] withCompletionHandler:^(id responseObject)
    {
        
    }
    andErrorHandler:^
    {
        
        
    }];
}
#pragma mark - Private Methods
-(void)retrieveAllBuckets
{
    [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets) {
        
        self.buckets = buckets;
        [self.createNewUserBucketPicker selectItemAtIndex:0];
        
        self.openCreateNewUserPanelButton.enabled = YES;
        
    } andErrorHandler:^{
       
        NSAlert* bucketErrorAlert = [NSAlert new];
        bucketErrorAlert.messageText = @"Couldn't retrieve buckets";
        [bucketErrorAlert runModal];
        
    }];
}
-(void)retrieveAccounts
{
    self.accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
    
    //Create new dictionary if not yet created
    if(!self.accounts)
    {
        self.accounts = [NSMutableDictionary dictionary];
    }
    
    [self.accountsTableView reloadData];
}
-(void)logoutOfActiveAccount
{
    [self.accountImageView setImage:nil];
    [self.accountsTableView setEnabled:YES];
    self.accountBox.title = @"";
    self.accountIcebreakerTextField.stringValue = @"";
    [self.accountImageView setEnabled:NO];
    [self.accountImageView setEditable:NO];
    [self.connectToAccountButton setTitle:@"Connect"];
    //
    [[SPProfileManager sharedInstance] logout];
}
-(void)saveAccounts
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:self.accounts forKey:@"accounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
-(NSString *) randomStringOfLength: (int) length {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}
#pragma mark - SPBaseApplicationController methods
-(BOOL)canRegisterForPushNotifications
{
    return NO;
}
-(void)registerForPushNotifications
{
}
-(void)unregisterForPushNotifications
{
}
-(NSString*)deviceToken
{
    return @"";
}
-(BOOL)canSendMail
{
    return NO;
}
-(void)presentEmailWithRecipients:(NSArray*)recipients andSubject:(NSString*)subject andBody:(NSString*)body
{
    NSAssert(NO,@"Implement on OS X");
}
#pragma mark - NSTableView Delegate and Datasource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.accounts count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* username = [[self.accounts allKeys] objectAtIndex:row];
    NSDictionary* accountDictionary = [self.accounts objectForKey:username];
    
    NSTextField* contentField = [NSTextField new];
    contentField.backgroundColor = [NSColor clearColor];
    [contentField setEditable:NO];
    [contentField setBordered:NO];
    
    //Set content
    if([tableColumn.identifier isEqualToString:@"usernames"])
    {
        [contentField setStringValue:username];
    }
    else if([tableColumn.identifier isEqualToString:@"buckets"])
    {
        NSString* bucketID = [accountDictionary objectForKey:@"bucketID"];
        [contentField setStringValue:bucketID];
    }
    else if([tableColumn.identifier isEqualToString:@"genders"])
    {
        NSString* gender = [accountDictionary objectForKey:@"gender"];
        [contentField setStringValue:gender];
    }
    else
    {
        NSString* preference = [accountDictionary objectForKey:@"preference"];
        [contentField setStringValue:preference];
    }
    
    return contentField;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    [self.connectToAccountButton setEnabled:YES];
    return YES;
}
@end
