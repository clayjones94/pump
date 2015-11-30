//
//  CarFlowViewController.h
//  en
//
//  Created by Clay Jones on 11/18/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarMakeViewController.h"
#import "CarYearViewController.h"
#import "CarModelViewController.h"

@class CarFlowViewController;

@protocol CarFlowViewControllerDelegate <NSObject>
@optional
- (void) carFlowViewController: (CarFlowViewController *)controller didFindMPG: (NSNumber *)mpg;
- (void) couldNotFindMPGForCarFlowViewController: (CarFlowViewController *)controller;
@end

@interface CarFlowViewController : UINavigationController <CarModelViewControllerDelegate>

@property id<CarFlowViewControllerDelegate> flowDelegate;

@end
