//
//  TripInfoViewController.h
//  Pump
//
//  Created by Clay Jones on 9/16/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TripInfoViewController : UIViewController

@property (nonatomic) NSDictionary *tripMembership;
-(instancetype)initWithPath: (GMSPath *)path;

@end
