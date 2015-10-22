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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
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
    // Called when app is opened from a push notification and when app is running and a notification is received.
    // In the first scenario, try pushing the shared poll. In the latter, just set the badge count on the tabbar.
    if ([application applicationState] != UIApplicationStateActive) {
        [_nav popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Open from Notification" object:nil];
    }
//    NSDictionary *info = [userInfo objectForKey:@"aps"];
//    [UIApplication sharedApplication].applicationIconBadgeNumber = [[info objectForKey:@"badge"] integerValue];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"Recieve Notification" object:nil];
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
    if (![[defaults objectForKey:APNS_TOKEN_KEY] isEqualToString:sbuf]) {
        [defaults setObject:sbuf forKey:APNS_TOKEN_KEY];
        [defaults synchronize];
        
        // We only want to refresh the token if we are logged in
        if ([Venmo sharedInstance].isSessionValid) {
            [Database updateAPNSToken];
        }
    }
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
