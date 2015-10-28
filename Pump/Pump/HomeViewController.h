//
//  HomeViewController.h
//  Pump
//
//  Created by Clay Jones on 10/24/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HMSegmentedControl/HMSegmentedControl.h>
#import "TripManager.h"
#import "TripViewController.h"

@interface HomeViewController : UIViewController
@property (nonatomic) HMSegmentedControl *segmentedControl;
@end
