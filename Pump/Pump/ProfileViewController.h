//
//  ProfileViewController.h
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
#import <HMSegmentedControl/HMSegmentedControl.h>

@interface ProfileViewController : UIViewController <UserManagerDelegate>

-(void) refresh;

@property (nonatomic) HMSegmentedControl *segmentedControl;

@end
