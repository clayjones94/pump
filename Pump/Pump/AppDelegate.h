//
//  AppDelegate.h
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void) saveContext;
-(NSURL *) applicationObjectsDirectory;

@end

