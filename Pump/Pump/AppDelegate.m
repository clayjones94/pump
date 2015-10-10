//
//  AppDelegate.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "TripViewController.h"
#import "Utils.h"
#import "Database.h"
#import "Constants.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "Database.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TripManager.h"
#import "UserManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    TripViewController *_tripvc;
    UINavigationController *_nav;
    
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Venmo startWithAppId:VENMO_APP_ID secret:VENMO_APP_SECRET name: VENMO_APP_NAME];
    
//    if (![Venmo isVenmoAppInstalled]) {
    [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAPI];
//    }
//    else {
//        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAppSwitch];
//    }
    
    [GMSServices provideAPIKey:@"AIzaSyA-N5dxHG2g7YzeegbO0tJF4XbAGUgbbtg"];
    
    _tripvc = [[TripViewController alloc] init];
    _nav = [[UINavigationController alloc] initWithRootViewController:_tripvc];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, [UIColor whiteColor]]
                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];

    CGSize newSize = CGSizeMake(60.0f, 40.0f);
    UIGraphicsBeginImageContext(newSize);
    [[UIImage imageNamed:@"PumpTitle-White"] drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _nav.navigationBar.topItem.titleView = [[UIImageView alloc] initWithImage:newImage];
    [_nav.navigationBar setTitleTextAttributes:attrsDictionary];

    _nav.navigationBar.barTintColor = [Utils defaultColor];
    
    self.window.rootViewController = _nav;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Called when app is opened from a push notification and when app is running and a notification is received.
    // In the first scenario, try pushing the shared poll. In the latter, just set the badge count on the tabbar.
    if ([application applicationState] != UIApplicationStateActive) {
        [_nav popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Open from Notification" object:nil];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUInteger capacity = deviceToken.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = deviceToken.bytes;
    NSInteger i;
    for (i = 0; i < deviceToken.length; ++i) {
        [sbuf appendFormat:@"%02lX", (unsigned long)buf[i]];
    }
    
    [defaults setObject:sbuf forKey:APNS_TOKEN_KEY];
    [defaults synchronize];
    
    // We only want to refresh the token if we are logged in
    [Database updateAPNSToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


-(void)applicationWillEnterForeground:(UIApplication *)application {
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"ending background task");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [[TripManager sharedManager].locationManager startUpdatingLocation];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[Venmo sharedInstance] handleOpenURL:url]) {
        return YES;
    }
    return NO;
}

-(void)applicationWillResignActive:(UIApplication *)application {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:[UserManager sharedManager].recents];
        [userDefaults setObject:dataSave forKey:@"recents"];
        [userDefaults synchronize];
    });
}

-(void)applicationWillTerminate:(UIApplication *)application {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:[UserManager sharedManager].recents];
//    [userDefaults setObject:dataSave forKey:@"recents"];
//    [userDefaults synchronize];
}

#pragma Core Data

-(void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    if ([moc hasChanges] && ![moc save:&error]) {
        NSLog(@"Unresolved error %@, %@",error, [error userInfo]);
        abort();
    }
}

-(NSManagedObjectContext *) managedObjectContext {
    if(_managedObjectContext != nil){
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

-(NSManagedObjectModel *) managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
    
}

-(NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationObjectsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@",error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

-(NSURL *) applicationObjectsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
