//
//  AppDelegate.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "TripViewController.h"
#import "HomeViewController.h"
#import "Utils.h"
#import "Database.h"
#import "Constants.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "Database.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TripManager.h"
#import "UserManager.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate {
    HomeViewController *_homevc;
    UINavigationController *_nav;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    [Venmo startWithAppId:VENMO_APP_ID secret:VENMO_APP_SECRET name: VENMO_APP_NAME];
    
//    if (![Venmo isVenmoAppInstalled]) {
        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAPI];
//    }
//    else {
//        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAppSwitch];
//    }

    [GMSServices provideAPIKey:@"AIzaSyA-N5dxHG2g7YzeegbO0tJF4XbAGUgbbtg"];
    [Parse setApplicationId:@"3salmH3rmskFoOp8q1BzjV2Vh6ZS4NL3FDKCOVN8"
                  clientKey:@"S02VfRDWGwjPFvRz5QR0CaJIEgQ8rJa5QpqcNzBO"];
    
    _homevc = [[HomeViewController alloc] init];
    _nav = [[UINavigationController alloc] initWithRootViewController:_homevc];
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
    
    [_nav.navigationBar.layer setBorderWidth:0];
    _nav.navigationBar.barTintColor = [Utils defaultColor];
    _nav.navigationBar.backgroundColor = [Utils defaultColor];
    _nav.navigationBar.tintColor = [Utils defaultColor];
    
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
//                                      forBarPosition:UIBarPositionAny
//                                          barMetrics:UIBarMetricsDefault];
//    
//    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    self.window.rootViewController = _nav;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


-(void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Recieve Notification" object:nil];
}

//-(void)applicationDidEnterBackground:(UIApplication *)application {
//    
//}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
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
}

@end
