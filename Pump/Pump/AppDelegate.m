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

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[Database postTripMembershipWithOwner:@"clayowner" member:@"claymember" amount:@4 andTrip:@"tripsdaf"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Venmo startWithAppId:VENMO_APP_ID secret:VENMO_APP_SECRET name: VENMO_APP_NAME];
    
    if (![Venmo isVenmoAppInstalled]) {
        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAPI];
    }
    else {
        [[Venmo sharedInstance] setDefaultTransactionMethod:VENTransactionMethodAppSwitch];
    }
    
    TripViewController *tripvc = [[TripViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tripvc];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, [UIColor whiteColor]]
                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];

    
    
    nav.navigationBar.topItem.title = @"Pump";
    [nav.navigationBar setTitleTextAttributes:attrsDictionary];

    nav.navigationBar.barTintColor = [Utils defaultColor];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[Venmo sharedInstance] handleOpenURL:url]) {
        return YES;
    }
    return NO;
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
