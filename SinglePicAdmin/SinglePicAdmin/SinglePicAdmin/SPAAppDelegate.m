//
//  SPAAppDelegate.m
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import "SPAAppDelegate.h"

@interface SPAAppDelegate()
@property (strong) NSArray* buckets;
@property (strong) NSMutableDictionary* accounts;
@end

@implementation SPAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[SPRequestManager sharedInstance] EnableRealtimeReachabilityMonitoring];
    
    [self retrieveAllBuckets];
    [self retrieveAccounts];
}
#pragma mark - IBActions
- (IBAction)createNewUser:(id)sender
{
    NSString* email = [self.createNewUserEmail stringValue];
    NSString* userName = [self.createNewUserUsername stringValue];
    NSString* password = [self.createNewUserPassword stringValue];
    GENDER gender = GENDER_FEMALE;
    GENDER preference = GENDER_MALE;
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
        [[NSUserDefaults standardUserDefaults] setObject:self.accounts forKey:@"accounts"];
        
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
    NSInteger selectedRow = [self.accountsTableView selectedRow];
    NSString* username = [[self.accounts allKeys] objectAtIndex:selectedRow];
    NSDictionary* accountDictionary = [self.accounts objectForKey:username];
    NSString* email = [accountDictionary objectForKey:@"email"];
    NSString* password = [accountDictionary objectForKey:@"password"];
    
    [[SPProfileManager sharedInstance] loginWithEmail:email andPassword:password andCompletionHandler:^(id responseObject)
    {
        //Disable interaction with the table
        [self.accountsTableView setEnabled:NO];
        
        self.accountBox.title = username;
        
        NSImage* profileImage = [[SPProfileManager sharedInstance] myImage];
        if(profileImage)
        {
            [self.accountImageView setImage:profileImage];
        }
        
        [self.accountImageView setEnabled:YES];
        
    } andErrorHandler:^
    {
        //
    }];
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
    
    [self.createNewUserPanel makeKeyAndOrderFront:nil];
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
    //
    [[SPProfileManager sharedInstance] logout];
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
